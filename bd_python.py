import psycopg2

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