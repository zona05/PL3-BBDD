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
Solicita parámetros de conexion.
"""
def ask_conn_parameters():
    print("Introduce los datos de conexion:")
    host = input("Host (default: localhost): ") or "localhost"
    port = ask_port("Puerto TCP: ")
    user = input("Usuario: ")
    password = input("Contraseña: ")
    database = 'bbdd_pl2'
    return (host, port, user, password, database)

"""
Muestra las opciones del programa.
"""
def opciones_programa():

    print("1. Mostrar los discos que tengan más de 5 canciones. Construir la expresión equivalente en álgebra relacional")
    print("2. Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo")
    print("3. Disco con mayor duración de la colección. Construir la expresión equivalente en álgebra relacional")
    print("4. De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan")
    print("5. Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación.")
    print("6. Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’. Construir la expresión equivalente en álgebra relacional")
    print("7. Lista de discos con la duración total del mismo, editados antes del año 2000")
    print("8. Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez")
    print("9. Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M.")
    print("10. Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su disco más nuevo, y el año medio de todos sus discos de su colección")
    print("11. Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos")
    print("12. Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos\n")
    print("13. Insertar un disco en la base de datos")

"""
Ejecuta una consulta SQL en la base de datos y salta errores de codificacion.
"""
def ejecutar_consulta(opcion):
    if(opcion == "1"):
        query = "SELECT d.titulo_disco, d.fecha_publicacion, COUNT(*) AS numero_canciones FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi GROUP BY d.titulo_disco, d.fecha_publicacion HAVING COUNT(*) > 5 ORDER BY numero_canciones;"
    elif(opcion == "2"):
        query = "SELECT u.nombre_usuario, u.nombre_completo, e.disco_titulo, e.disco_fecha_publi, e.pais_edicion, e.edicion_fecha_publi, e.formato_edicion, e.estado_edicion FROM u_tiene_e e JOIN usuarios u ON e.nombre_usu = u.nombre_usuario WHERE u.nombre_completo LIKE 'Juan García Gomez' AND e.formato_edicion = 'Vinyl';"    
    elif(opcion == "3"):
        query = "WITH Disco_Length AS ( SELECT d.titulo_disco, d.fecha_publicacion, SUM(c.duracion_cancion) AS total_length FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi GROUP BY d.titulo_disco, d.fecha_publicacion HAVING SUM(c.duracion_cancion) IS NOT NULL ) SELECT d.titulo_disco, d.fecha_publicacion, SUM(c.duracion_cancion) AS total_length FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi GROUP BY d.titulo_disco, d.fecha_publicacion HAVING SUM(c.duracion_cancion) >= ALL(SELECT total_length FROM Disco_Length);"
    elif(opcion == "4"):
        query = "SELECT u.nombre_usuario, u.nombre_completo, udd.disco_titulo, udd.disco_fecha_publi, d.nombre_grupo FROM usuarios u JOIN u_desea_d udd ON u.nombre_usuario = udd.nombre_usu JOIN discos d ON udd.disco_titulo = d.titulo_disco AND udd.disco_fecha_publi = d.fecha_publicacion WHERE u.nombre_completo LIKE 'Juan García Gomez';"
    elif(opcion == "5"):
        query = "SELECT e.disco_titulo, e.disco_fecha_publi, e.fecha_edicion, e.pais, e.formato FROM ediciones e WHERE e.disco_fecha_publi BETWEEN 1970 AND 1972 ORDER BY e.disco_fecha_publi, e.disco_titulo;"
    elif(opcion == "6"):
        query = "SELECT DISTINCT d.nombre_grupo FROM discos d JOIN generos_disco gd ON d.titulo_disco = gd.disco_titulo AND d.fecha_publicacion = gd.disco_fecha_publi WHERE gd.genero = 'Electronic';"
    elif(opcion == "7"):
        query = "SELECT DISTINCT d.titulo_disco, d.fecha_publicacion, SUM(c.duracion_cancion) AS total_length FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi JOIN ediciones e ON d.titulo_disco = e.disco_titulo AND d.fecha_publicacion = e.disco_fecha_publi WHERE e.fecha_edicion < 2000 GROUP BY d.titulo_disco, d.fecha_publicacion;"
    elif(opcion == "8"):
        query = "SELECT ul.nombre_completo AS es_de, ur.nombre_completo AS es_deseado_por, ute.disco_titulo, ute.disco_fecha_publi, ute.pais_edicion, ute.edicion_fecha_publi, ute.formato_edicion, ute.estado_edicion FROM u_tiene_e ute JOIN u_desea_d udd ON ute.disco_titulo = udd.disco_titulo AND ute.disco_fecha_publi = udd.disco_fecha_publi JOIN usuarios ur ON udd.nombre_usu = ur.nombre_usuario JOIN usuarios ul ON ute.nombre_usu = ul.nombre_usuario WHERE ul.nombre_completo LIKE 'Juan García Gomez' AND ur.nombre_completo LIKE 'Lorena Sáez Pérez';"
    elif(opcion == "9"):
        query = "SELECT u.nombre_completo AS nombre_de_usuario, ute.disco_titulo, ute.disco_fecha_publi, ute.pais_edicion, ute.edicion_fecha_publi, ute.formato_edicion, ute.estado_edicion, ute.id FROM u_tiene_e ute JOIN usuarios u ON ute.nombre_usu = u.nombre_usuario WHERE u.nombre_completo LIKE '%Gomez García%' AND (ute.estado_edicion = 'NM' OR ute.estado_edicion = 'M');"
    elif(opcion == "10"):
        query = "SELECT u.nombre_usuario, COUNT(ute.id),MIN(ute.disco_fecha_publi)::INTEGER, MAX(ute.disco_fecha_publi)::INTEGER, AVG(ute.disco_fecha_publi)::INTEGER FROM usuarios u JOIN u_tiene_e ute ON u.nombre_usuario = ute.nombre_usu GROUP BY u.nombre_usuario;"
    elif(opcion == "11"):
        query = "SELECT  d.nombre_grupo FROM disco d JOIN edicion e ON (e.titulo_disco = d.titulo_disco AND e.anio_publicacion = d.anio_publicacion) GROUP BY d.nombre_grupo HAVING COUNT(*) > 5 ORDER BY d.nombre_grupo;"
    elif(opcion == "12"):
        query = "WITH discos_ussuario AS (SELECT nombre_usu, COUNT(id) AS numero_discos FROM u_tiene_e GROUP BY nombre_usu ) SELECT nombre_usu, COUNT(id) FROM u_tiene_e GROUP BY nombre_usu HAVING COUNT(id) >= ALL(SELECT numero_discos FROM discos_ussuario);"
    else:
        print("Opción no válida")
    return query

"""
Inserta un nuevo disco, grupo y canciones.
"""
def insertar_disco(conn):
    try:
        grupo = input("Nombre del grupo: ")
        disco = input("Título del disco: ")
        anio = int(input("Año de publicacion: "))
        urlportada = input("URL de la portada: ")
        with conn.cursor() as cur:
            cur.execute("SELECT url_g FROM grupos WHERE nombre_grupo = %s", (grupo,))
            grupo_id = cur.fetchone()
            if not grupo_url:
                cur.execute("INSERT INTO grupos (nombre) VALUES (%s) RETURNING id", (grupo,))
                grupo_url = cur.fetchone()[0]

            cur.execute("""
                INSERT INTO discos (titulo, anio, genero, grupo_id) 
                VALUES (%s, %s, %s, %s) RETURNING url_g
            """, (disco, anio, urlportada, grupo_id))
            disco_id = cur.fetchone()[0]

            print("Añade canciones al disco (deja vacío para terminar):")
            while True:
                cancion = input("Nombre de la cancion: ")
                if not cancion:
                    break
                duracion = int(input("Duracion en segundos: "))
                cur.execute("""
                    INSERT INTO canciones (id_disco,titulo_disco, duracion_cancion ) 
                    VALUES (%s, %s, %s)
                """, (disco_id,cancion,duracion))

            conn.commit()
            print("Disco, grupo y canciones insertados correctamente.")
    except Exception as e:
        conn.rollback()
        print(f"Error al insertar: {e}")

def main():
    try:
        host, port, user, password, database = ask_conn_parameters()
        conn_str = f'host={host} port={port} user={user} password={password} dbname={database}'
        conn = psycopg2.connect(conn_str)

        conn.set_client_encoding('UTF-8')
        print("Conexion establecida.")
        salir_bucle = False
        while not salir_bucle:
            opciones_programa()
            opcion = int(input("Selecciona una opcion: "))
            if opcion == 0:
                print("Saliendo del programa.")
                break
            elif  1<=  opcion <= 12 :
                ejecutar_consulta(opcion)
            elif opcion == 13:
                insertar_disco(conn)
            else:
                print("Opcion no valida.")
                salir_bucle = True

        conn.close()
    except PortException as pe:
        print(pe)
    except UnicodeDecodeError as unicode_err:
        print(f"Error de codificacion: {unicode_err}")
    except psycopg2.OperationalError as conn_err:
        print(f"Error al conectar a la base de datos: {conn_err}")
    except Exception as e:
        print(f"Error general: {e}")

if __name__ == "__main__":
    main()
