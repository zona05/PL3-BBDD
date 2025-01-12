import sys
import psycopg2
import pytest

class portException(Exception): pass

def ask_port(msg):
    """
        ask for a valid TCP port
        ask_port :: String -> IO Integer | Exception
    """
    try:                                                                        # try
        answer  = input(msg)                                                    # pide el puerto
        port    = int(answer)                                                   # convierte a entero
        if (port < 1024) or (port > 65535):                                     # si el puerto no es valido
            raise ValueError                                                    # lanza una excepción
        else:
            return port
    except ValueError:     
        raise portException                                                     # raise portException
    #finally:                                                                    # finally
    #    return port                                                             # return port

def ask_conn_parameters():
    """
        ask_conn_parameters:: () -> IO String
        pide los parámetros de conexión
        TODO: cada estudiante debe introducir los valores para su base de datos
    """
    host = 'localhost'                                                          # 
    port = ask_port('TCP port number: ')                                        # pide un puerto TCP
    user = 'oscar'                                                                   # TODO
    password = 'oscar'                                                               # TODO
    database = 'discos'                                                               # TODO
    return (host, port, user,
             password, database)


def opciones_programa():
    print("Colsulta 1. Mostrar los discos que tengan más de 5 canciones. Construir la expresión equivalente en álgebra relacional")
    print("Colsulta 2. Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo")
    print("Colsulta 3. Disco con mayor duración de la colección. Construir la expresión equivalente en álgebra relacional")
    print("Colsulta 4. De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan")
    print("Colsulta 5. Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación.")
    print("Colsulta 6. Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’. Construir la expresión equivalente en álgebra relacional")
    print("Colsulta 7. Lista de discos con la duración total del mismo, editados antes del año 2000")
    print("Colsulta 8. Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez")
    print("Colsulta 9. Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M.")
    print("Colsulta 10. Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su disco más nuevo, y el año medio de todos sus discos de su colección")
    print("Colsulta 11. Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos")
    print("Colsulta 12. Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos\n")
    print(" Opción 13. Insertar disco")

def hacer_consultas(opcion):
    if(opcion == 1):
        query =
    elif(opcion == 2):
        query = 
    elif(opcion == 3):
        query = 
    elif(opcion == 4):
        query = 
    elif(opcion == 5):
        query = 
    elif(opcion == 6):
        query = 
    elif(opcion == 7):
        query = 
    elif(opcion == 8):
        query = 
    elif(opcion == 9):
        query = 
    elif(opcion == 10):
        query = 
    elif(opcion == 11):
        query = 
    elif(opcion == 12):
        query = 
    elif(opcion == 13):
        query = 
    else: print("La opción introducida no es valida")
    return query

def main():
    """
        main :: () -> IO None
    """
    try:
        (host, port, user, password, database) = ask_conn_parameters()          #
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}' 
        conn    = psycopg2.connect(connstring)                                  #
                                                                               
        cur     = conn.cursor()                                                 # instacia un cursor
        query   = 'SELECT * FROM discos'                                        # prepara una consulta
        cur.execute(query)                                                      # ejecuta la consulta
        for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
            print(record)                                                       # imprime las filas
        cur.close                                                               # cierra el cursor
        conn.close                                                              # cierra la conexion
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        print("Program finished")

#def prueba_conexion():


if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # chequea el argumento cmdline buscando el modo test
        import doctest                                                          # importa la libreria doctest
        doctest.testmod()                                                       # corre los tests
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal


# CODIGO TUYO PREVIO
# Datos de conexión
host = "localhost"
dbname = "bdpl2" 
user = "gestor_user"  
password = "gestor_password"

try:
    print("Conectando con PostgreSQL...")
    # Conexión
    conn = psycopg2.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password
    )
    print("Conexión exitosa")
    
    # Cursor
    cur = conn.cursor()
    print("Cursor creado")

    # Versión de la base de datos
    cur.execute("SELECT version();")
    db_version = cur.fetchone()
    print(f"Versión de la base de datos: {db_version}")
    
    # Cerrar cursor
    cur.close()
    conn.close()

except Exception as e:
    print(f"Error al conectar: {e}")
