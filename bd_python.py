import sys
import psycopg2

class PortException(Exception): pass

"""
Solicita un puerto TCP válido.
"""
def ask_port(msg):
    try:
        port = int(input(msg))
        if port < 1024 or port > 65535:
            raise ValueError
        return port
    except ValueError:
        raise PortException("El puerto no es válido.")

"""
Solicita parámetros de conexión.
"""
def ask_conn_parameters():
    print("Introduce los datos de conexión:")
    host = input("Host (default: localhost): ") or "localhost"
    port = ask_port("Puerto TCP: ")
    user = input("Usuario: ")
    password = input("Contraseña: ")
    database = input("Base de datos: ")
    return host, port, user, password, database

"""
Muestra las opciones del programa.
"""
def opciones_programa():
    print("\nOpciones:")
    print("1. Consultas predefinidas (elige de la lista)")
    print("2. Insertar un nuevo disco con su grupo y canciones")
    print("0. Salir\n")

"""
Ejecuta una consulta SQL en la base de datos y salta errores de codificación.
"""
def ejecutar_consulta(conn, query):
    try:
        with conn.cursor() as cur:
            cur.execute(query)
            resultados = cur.fetchall()
            for fila in resultados:
                print([str(col).encode('utf-8', 'ignore').decode('utf-8', 'ignore') for col in fila])
    except psycopg2.Error as db_err:
        print(f"Error al ejecutar consulta: {db_err}")
    except UnicodeDecodeError as e:
        print(f"Error de codificación: {e}")


"""
Inserta un nuevo disco, grupo y canciones.
"""
def insertar_disco(conn):
    try:
        grupo = input("Nombre del grupo: ")
        disco = input("Título del disco: ")
        anio = int(input("Año de publicación: "))
        genero = input("Género: ")
        with conn.cursor() as cur:
            cur.execute("SELECT id FROM grupos WHERE nombre = %s", (grupo,))
            grupo_id = cur.fetchone()
            if not grupo_id:
                cur.execute("INSERT INTO grupos (nombre) VALUES (%s) RETURNING id", (grupo,))
                grupo_id = cur.fetchone()[0]

            cur.execute("""
                INSERT INTO discos (titulo, anio, genero, grupo_id) 
                VALUES (%s, %s, %s, %s) RETURNING id
            """, (disco, anio, genero, grupo_id))
            disco_id = cur.fetchone()[0]

            print("Añade canciones al disco (deja vacío para terminar):")
            while True:
                cancion = input("Nombre de la canción: ")
                if not cancion:
                    break
                duracion = int(input("Duración en segundos: "))
                cur.execute("""
                    INSERT INTO canciones (nombre, duracion, disco_id) 
                    VALUES (%s, %s, %s)
                """, (cancion, duracion, disco_id))

            conn.commit()
            print("Disco, grupo y canciones insertados correctamente.")
    except Exception as e:
        conn.rollback()
        print(f"Error al insertar: {e}")

def main():
    try:
        host, port, user, password, database = ask_conn_parameters()
        conn_str = f"host={host} port={port} user={user} password={password} dbname={database}"
        conn = psycopg2.connect(conn_str)

        conn.set_client_encoding('UTF8')
        print("Conexión establecida.")

        while True:
            opciones_programa()
            opcion = int(input("Selecciona una opción: "))
            if opcion == 0:
                print("Saliendo del programa.")
                break
            elif opcion == 1:
                query = input("Escribe tu consulta SQL: ")
                ejecutar_consulta(conn, query)
            elif opcion == 2:
                insertar_disco(conn)
            else:
                print("Opción no válida.")

        conn.close()
    except PortException as pe:
        print(pe)
    except psycopg2.OperationalError as conn_err:
        print(f"Error al conectar a la base de datos: {conn_err}")
    except Exception as e:
        print(f"Error general: {e}")

if __name__ == "__main__":
    main()
