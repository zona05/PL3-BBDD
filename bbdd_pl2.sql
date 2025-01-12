-- Desactiva la paginación para facilitar la visualización continua de los resultados.
\pset pager off

-- Establece la codificación de caracteres del cliente a UTF-8 para manejar correctamente los caracteres especiales.
SET client_encoding = 'UTF8';

-- Crea una nueva base de datos llamada "bdpl2" con configuraciones personalizadas.
CREATE DATABASE bdpl2_miguel_angel_y_javier;

-- Establece la codificación de caracteres del cliente a UTF-8 de nuevo para solventar los problemas locales con Windows.
WITH 
ENCODING = 'UTF8'
LC_COLLATE = 'es_ES.UTF-8' 
LC_CTYPE = 'es_ES.UTF-8'
TEMPLATE = template0;

BEGIN;

-- Crea el esquema 'store' si no existe, para organizar la base de datos.
\echo 'creando el esquema para la store'
DROP SCHEMA IF EXISTS store CASCADE;
CREATE SCHEMA IF NOT EXISTS store;

-- Crea un esquema temporal 'ddbb' si no existe, donde se alojarán las tablas.
\echo 'creando un esquema temporal'
DROP SCHEMA IF EXISTS ddbb CASCADE;
CREATE SCHEMA IF NOT EXISTS ddbb;

-- Creación de la tabla 'usuarios' en el esquema 'ddbb' para almacenar información de usuarios.
CREATE TABLE IF NOT EXISTS ddbb.usuarios (
    nombre_completo TEXT,
    nombre_usuario TEXT,
    email_usuario TEXT,
    pass TEXT
);

-- Creación de la tabla 'discos' para almacenar información sobre discos musicales.
CREATE TABLE IF NOT EXISTS ddbb.discos(
    id TEXT UNIQUE,
    titulo_disco TEXT,
    fecha_publicacion TEXT,
    id_grupo TEXT,
    nombre_grupo TEXT,
    url_grupo TEXT,
    generos_musicales TEXT,
    url_portada TEXT
);

-- Creación de la tabla 'ediciones' para almacenar las ediciones de los discos.
CREATE TABLE IF NOT EXISTS ddbb.ediciones(
    id_disco TEXT,
    fecha_edicion TEXT,
    pais TEXT,
    formato TEXT
);

-- Creación de la tabla 'u_desea_d' para almacenar discos que los usuarios desean.
CREATE TABLE IF NOT EXISTS ddbb.u_desea_d(
    nombre_usu TEXT,
    disco_titulo TEXT,
    disco_fecha_publi TEXT
);

-- Creación de la tabla 'u_tiene_e' para registrar qué discos y ediciones poseen los usuarios.
CREATE TABLE IF NOT EXISTS ddbb.u_tiene_e(
    nombre_usu TEXT,
    disco_titulo TEXT,
    disco_fecha_publi TEXT,
    edicion_fecha_publi TEXT,
    pais_edicion TEXT,
    formato_edicion TEXT,
    estado_edicion TEXT
);

-- Creación de la tabla 'canciones' para almacenar las canciones de los discos.
CREATE TABLE IF NOT EXISTS ddbb.canciones(
    id_disco TEXT,
    titulo_disco TEXT,
    duracion_cancion TEXT
);

-- Establece el esquema 'ddbb' como el esquema activo para las siguientes operaciones.
SET search_path= ddbb;
\echo 'Cargando datos'

-- Crea tablas temporales para almacenar los datos de cada tabla original sin afectar la base de datos principal.
CREATE TEMP TABLE usuarios_temp AS TABLE ddbb.usuarios WITH NO DATA;
CREATE TEMP TABLE discos_temp AS TABLE ddbb.discos WITH NO DATA;
CREATE TEMP TABLE ediciones_temp AS TABLE ddbb.ediciones WITH NO DATA;
CREATE TEMP TABLE u_desea_d_temp AS TABLE ddbb.u_desea_d WITH NO DATA;
CREATE TEMP TABLE u_tiene_e_temp AS TABLE ddbb.u_tiene_e WITH NO DATA;
CREATE TEMP TABLE canciones_temp AS TABLE ddbb.canciones WITH NO DATA;

-- Carga los datos de archivos CSV a las tablas temporales, con opciones para manejar formato CSV y valores nulos.
\COPY usuarios_temp FROM 'usuarios.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY discos_temp FROM 'discos.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY canciones_temp FROM 'canciones.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY u_desea_d_temp FROM 'usuario_desea_disco.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY ediciones_temp FROM 'ediciones.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY u_tiene_e_temp FROM 'usuario_tiene_edicion.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

-- Inserta los datos cargados de las tablas temporales a las tablas definitivas, asegurando que no se dupliquen los registros.
INSERT INTO ddbb.usuarios
SELECT DISTINCT * FROM usuarios_temp;

INSERT INTO ddbb.discos
SELECT DISTINCT * FROM discos_temp;

INSERT INTO ddbb.ediciones
SELECT DISTINCT * FROM ediciones_temp;

INSERT INTO ddbb.u_desea_d
SELECT DISTINCT * FROM u_desea_d_temp;

INSERT INTO ddbb.u_tiene_e
SELECT * FROM u_tiene_e_temp;

INSERT INTO ddbb.canciones
SELECT DISTINCT * FROM canciones_temp;

-- Elimina las tablas temporales después de haber insertado los datos en las tablas principales, limpiando el entorno.
DROP TABLE usuarios_temp;
DROP TABLE discos_temp;
DROP TABLE ediciones_temp; 
DROP TABLE u_desea_d_temp;
DROP TABLE u_tiene_e_temp;
DROP TABLE canciones_temp; 


\echo 'Creando tablas finales del esquema store'

-- Creación de la tabla 'usuarios' en el esquema 'store' con restricciones para validar el correo y la contraseña.
CREATE TABLE IF NOT EXISTS store.usuarios (
    nombre_usuario TEXT,
    email_usuario TEXT NOT NULL CHECK (email_usuario ~ '^[A-Za-z0-9áÁéÉíÍóÓúÚüÜñÑ._%+-]+@[A-Za-z0-9áÁéÉíÍóÓúÚüÜñÑ.-]+\.[A-Za-z]{2,}$'),
    nombre_completo TEXT NOT NULL,
    pass TEXT NOT NULL,
    PRIMARY KEY (nombre_usuario)
);

-- Creación de la tabla 'grupos' con validación de URL para asegurar que sea una dirección web válida.
CREATE TABLE IF NOT EXISTS store.grupos (
    nombre_completo TEXT,
    url_g TEXT CHECK (url_g ~ '^(http|https):\/\/[^\s/$.?#].[^\s]*$'),
    PRIMARY KEY (nombre_completo)
);

-- Creación de la tabla 'discos' que almacena información sobre discos, vinculada a la tabla 'grupos' mediante la clave foránea.
CREATE TABLE IF NOT EXISTS store.discos(
    titulo_disco TEXT,
    fecha_publicacion INTEGER,
    url_portada TEXT CHECK (url_portada IS NULL OR url_portada ~ '^(http|https):\/\/[^\s/$.?#].[^\s]*$'),
    nombre_grupo TEXT,
    PRIMARY KEY (titulo_disco, fecha_publicacion),
    FOREIGN KEY (nombre_grupo) REFERENCES store.grupos(nombre_completo)
);

-- Creación de la tabla 'generos_disco' para asociar géneros musicales a los discos.
CREATE TABLE IF NOT EXISTS store.generos_disco(
    disco_titulo TEXT,
    disco_fecha_publi INTEGER,
    genero TEXT,
    PRIMARY KEY (disco_titulo, disco_fecha_publi, genero),
    FOREIGN KEY (disco_titulo, disco_fecha_publi) REFERENCES store.discos(titulo_disco, fecha_publicacion)
);

-- Creación de un tipo enumerado para los formatos de las ediciones de los discos.
CREATE TYPE enumeracion_formato AS ENUM ('CD', 'Vinyl', 'Cassette', 'Flexi-disc', 'CDr', 'Box Set', 'File', 'All Media', 'Lathe Cut', 'DVD', 'VHS', 'Reel-To-Reel', 'Shellac', 'Blu-ray', 'SACD', '8-Track Cartridge', 'Floppy Disk');

-- Creación de la tabla 'ediciones' para almacenar las ediciones de los discos en diferentes formatos y países.
CREATE TABLE IF NOT EXISTS store.ediciones(
    pais TEXT,
    fecha_edicion INTEGER,
    formato enumeracion_formato,
    disco_titulo TEXT,
    disco_fecha_publi INTEGER,
    PRIMARY KEY (pais, fecha_edicion, formato, disco_titulo, disco_fecha_publi),
    FOREIGN KEY (disco_titulo, disco_fecha_publi) REFERENCES store.discos(titulo_disco, fecha_publicacion)
);

-- Creación de la tabla 'canciones' para almacenar las canciones de los discos.
CREATE TABLE IF NOT EXISTS store.canciones(
    titulo_disco TEXT,
    duracion_cancion INTEGER CHECK (duracion_cancion >= 0),
    disco_titulo TEXT,
    disco_fecha_publi INTEGER,
    PRIMARY KEY (titulo_disco, disco_titulo, disco_fecha_publi),
    FOREIGN KEY (disco_titulo, disco_fecha_publi) REFERENCES store.discos(titulo_disco, fecha_publicacion)
);

-- Creación de la tabla 'u_desea_d' para almacenar los discos que los usuarios desean.
CREATE TABLE IF NOT EXISTS store.u_desea_d(
    nombre_usu TEXT,
    disco_titulo TEXT,
    disco_fecha_publi INTEGER,
    PRIMARY KEY (nombre_usu, disco_titulo, disco_fecha_publi),
    FOREIGN KEY (nombre_usu) REFERENCES store.usuarios(nombre_usuario),
    FOREIGN KEY (disco_titulo, disco_fecha_publi) REFERENCES store.discos(titulo_disco, fecha_publicacion)
);

-- Creación de un tipo enumerado para los estados de las ediciones de los discos.
CREATE TYPE enumeracion_estado AS ENUM ('M', 'NM', 'EX', 'VG+', 'VG', 'G', 'F');

-- Creación de la tabla 'u_tiene_e' para almacenar las ediciones de discos que poseen los usuarios.
CREATE TABLE IF NOT EXISTS store.u_tiene_e(
    nombre_usu TEXT,
    disco_titulo TEXT,
    disco_fecha_publi INTEGER,
    pais_edicion TEXT,
    edicion_fecha_publi INTEGER,
    formato_edicion enumeracion_formato,
    estado_edicion enumeracion_estado NOT NULL,
    id INTEGER CHECK(id > 0) NOT NULL,
    PRIMARY KEY (nombre_usu, disco_titulo, disco_fecha_publi, pais_edicion, edicion_fecha_publi, formato_edicion,id),
    FOREIGN KEY (nombre_usu) REFERENCES store.usuarios(nombre_usuario),
    FOREIGN KEY (disco_titulo, disco_fecha_publi) REFERENCES store.discos(titulo_disco, fecha_publicacion),
    FOREIGN KEY (pais_edicion, edicion_fecha_publi, formato_edicion, disco_titulo, disco_fecha_publi) REFERENCES store.ediciones(pais, fecha_edicion, formato, disco_titulo, disco_fecha_publi)
);

-- Creación de la tabla 'auditorias' para registrar las operaciones de inserción, actualización y eliminación en las tablas finales.
CREATE TABLE IF NOT EXISTS store.auditorias(
    id SERIAL PRIMARY KEY,
    tabla_afectada TEXT NOT NULL,
    tipo_evento TEXT NOT NULL,
    usuario TEXT NOT NULL,
    fecha_hora TIMESTAMP
);

\echo 'Insertando datos en las tablas finales'

-- Insertación de datos del esquema 'ddbb' a 'store' con las transformaciones necesarias.
INSERT INTO store.usuarios
SELECT nombre_usuario, email_usuario, nombre_completo, pass
FROM ddbb.usuarios;

INSERT INTO store.grupos
SELECT DISTINCT nombre_grupo, url_grupo
FROM ddbb.discos;

INSERT INTO store.discos
SELECT DISTINCT titulo_disco, fecha_publicacion::INTEGER, url_portada, nombre_grupo
FROM ddbb.discos;

INSERT INTO store.ediciones
SELECT e.pais, e.fecha_edicion::INTEGER, e.formato::enumeracion_formato, d.titulo_disco, d.fecha_publicacion::INTEGER
FROM ddbb.ediciones e
JOIN ddbb.discos d ON e.id_disco = d.id;

-- Elimina las canciones con una duración NULL
DELETE FROM ddbb.canciones
USING ddbb.canciones c2
WHERE ddbb.canciones.titulo_disco = c2.titulo_disco
  AND ddbb.canciones.id_disco = c2.id_disco
  AND ddbb.canciones.duracion_cancion IS NULL
  AND c2.duracion_cancion IS NOT NULL;

-- Elimina las canciones duplicadas con duración no NULL
DELETE FROM ddbb.canciones a
USING ddbb.canciones b
WHERE a.ctid < b.ctid
  AND a.titulo_disco = b.titulo_disco
  AND a.id_disco = b.id_disco
  AND a.duracion_cancion IS NOT NULL
  AND b.duracion_cancion IS NOT NULL;

INSERT INTO store.canciones
SELECT DISTINCT c.titulo_disco, (CAST(split_part(c.duracion_cancion, ':', 1) AS INTEGER) * 60) + CAST(split_part(c.duracion_cancion, ':', 2) AS INTEGER), d.titulo_disco, d.fecha_publicacion::INTEGER
FROM ddbb.canciones c
JOIN ddbb.discos d ON c.id_disco = d.id;


INSERT INTO store.generos_disco
SELECT DISTINCT titulo_disco, fecha_publicacion::INTEGER, trim(both ' ' from replace(trim(both '[]' from unnest(string_to_array(replace(trim(both '[]' from generos_musicales), ' & ', ''), ','))), '''', ''))
FROM ddbb.discos;


INSERT INTO store.u_desea_d
SELECT nombre_usu, disco_titulo, disco_fecha_publi::INTEGER
FROM ddbb.u_desea_d
WHERE nombre_usu IN (SELECT nombre_usuario FROM store.usuarios);

-- Crea una secuencia para el identificador único de las ediciones que los usuarios poseen en 'store'.
CREATE SEQUENCE store.u_tiene_e_id_seq;

INSERT INTO store.u_tiene_e
SELECT nombre_usu, disco_titulo, disco_fecha_publi::INTEGER, pais_edicion, edicion_fecha_publi::INTEGER, formato_edicion::enumeracion_formato, estado_edicion::enumeracion_estado, nextval('store.u_tiene_e_id_seq')
FROM ddbb.u_tiene_e
WHERE nombre_usu IN (SELECT nombre_usuario FROM store.usuarios);

-- Crea una función para registrar las auditorías de las operaciones de inserción, actualización y eliminación en la tabla 'auditorias'.
CREATE OR REPLACE FUNCTION store.auditoria_trigger_func() RETURNS trigger AS $$
BEGIN
    INSERT INTO store.auditorias(tabla_afectada, tipo_evento, usuario)
    VALUES (TG_TABLE_NAME, TG_OP, current_user);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crea una función para eliminar un disco deseado de un usuario cuando se inserta un disco en la tabla 'u_tiene_e'.
CREATE OR REPLACE FUNCTION store.eliminar_deseado_trigger_func() RETURNS trigger AS $$
BEGIN
    DELETE FROM store.u_desea_d WHERE nombre_usu = NEW.nombre_usu AND disco_titulo = NEW.disco_titulo AND disco_fecha_publi = NEW.disco_fecha_publi;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crea un trigger para registrar las auditorías de las operaciones de inserción, actualización y eliminación en la tabla 'auditorias'.
CREATE TRIGGER auditoria_trigger
AFTER INSERT OR UPDATE OR DELETE ON store.usuarios
FOR EACH ROW EXECUTE FUNCTION store.auditoria_trigger_func();

-- Crea un trigger para eliminar los discos deseados de un usuario cuando se inserta un disco en la tabla 'u_tiene_e'.
CREATE TRIGGER eliminar_deseado_trigger
AFTER INSERT ON store.u_tiene_e
FOR EACH ROW EXECUTE FUNCTION store.eliminar_deseado_trigger_func();

-- Crea una vista para mostrar los discos deseados, poseídos y sus respectivas fechas de disponibilidad.
CREATE OR REPLACE VIEW store.usuario_c_cliente AS 
SELECT 
    u.nombre_usuario,
    u.nombre_completo,
    u.email_usuario,
    u.pass,
    CASE 
        WHEN ud.disco_titulo IS NULL THEN '' 
        ELSE ud.disco_titulo 
    END AS disco_deseado,
    
    CASE 
        WHEN ud.disco_fecha_publi IS NULL THEN 0 
        ELSE ud.disco_fecha_publi 
    END AS fecha_disponibilidad_deseado,
    
    CASE 
        WHEN ut.disco_titulo IS NULL THEN '' 
        ELSE ut.disco_titulo 
    END AS disco_poseido,
    
    CASE 
        WHEN ut.disco_fecha_publi IS NULL THEN 0 
        ELSE ut.disco_fecha_publi 
    END AS fecha_disponibilidad_poseído
FROM 
    store.usuarios u
LEFT JOIN store.u_desea_d ud 
    ON u.nombre_usuario = ud.nombre_usu
LEFT JOIN store.u_tiene_e ut 
    ON u.nombre_usuario = ut.nombre_usu;

-- Crea los diferentes tipos de usuario con sus respectivos permisos.
CREATE ROLE admin_user LOGIN PASSWORD 'admin_password';
GRANT ALL PRIVILEGES ON DATABASE bdpl2_miguel_angel_y_javier TO admin_user;

CREATE ROLE gestor_user LOGIN PASSWORD 'gestor_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA store TO gestor_user;

CREATE ROLE cliente_user LOGIN PASSWORD 'cliente_password';
GRANT SELECT, INSERT ON store.u_tiene_e, store.u_desea_d TO cliente_user;

CREATE ROLE invitado_user LOGIN PASSWORD 'invitado_password';
GRANT SELECT ON store.grupos, store.discos, store.canciones TO invitado_user;

-- Establece el esquema 'store' como el esquema activo para las siguientes consultas.
SET search_path= store;

\echo 'Comienzo de consultas'

-- Cuenta el número de canciones por disco, considerando solo aquellos discos que tienen más de 5 canciones.
\echo 'Consulta 1: '
SELECT d.titulo_disco, d.fecha_publicacion, COUNT(*) AS numero_canciones
FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi
GROUP BY d.titulo_disco, d.fecha_publicacion
HAVING COUNT(*) > 5
ORDER BY numero_canciones;

-- Obtiene los discos en formato Vinyl de un usuario específico.
\echo 'Consulta 2: '
SELECT u.nombre_usuario, u.nombre_completo, e.disco_titulo, e.disco_fecha_publi, e.pais_edicion, e.edicion_fecha_publi, e.formato_edicion, e.estado_edicion
FROM u_tiene_e e
JOIN usuarios u ON e.nombre_usu = u.nombre_usuario
WHERE u.nombre_completo LIKE 'Juan García Gómez' AND e.formato_edicion = 'Vinyl';

-- Obtiene los discos con la mayor duración total de canciones, considerando solo aquellos discos con duración total no nula.
\echo 'Consulta 3: '
WITH Disco_Length AS (
    SELECT d.titulo_disco, d.fecha_publicacion, SUM(c.duracion_cancion) AS total_length
    FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi
    GROUP BY d.titulo_disco, d.fecha_publicacion
    HAVING SUM(c.duracion_cancion) IS NOT NULL
)
SELECT d.titulo_disco, d.fecha_publicacion, SUM(c.duracion_cancion) AS total_length
FROM discos d JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi
GROUP BY d.titulo_disco, d.fecha_publicacion
HAVING SUM(c.duracion_cancion) >= ALL(SELECT total_length FROM Disco_Length);

-- Obtiene los discos deseados por un usuario específico con el nombre completo 'Juan García Gómez'.
\echo 'Consulta 4: '
SELECT u.nombre_usuario, u.nombre_completo, udd.disco_titulo, udd.disco_fecha_publi, d.nombre_grupo
FROM usuarios u JOIN u_desea_d udd ON u.nombre_usuario = udd.nombre_usu
JOIN discos d ON udd.disco_titulo = d.titulo_disco AND udd.disco_fecha_publi = d.fecha_publicacion
WHERE u.nombre_completo LIKE 'Juan García Gómez';

-- Obtiene los discos publicados entre 1970 y 1972, ordenados por fecha de publicación y título.
\echo 'Consulta 5: '
SELECT e.disco_titulo, e.disco_fecha_publi, e.fecha_edicion, e.pais, e.formato
FROM ediciones e
WHERE e.disco_fecha_publi BETWEEN 1970 AND 1972
ORDER BY e.disco_fecha_publi, e.disco_titulo;

-- Obtiene los grupos musicales que han publicado discos de género 'Electronic'.
\echo 'Consulta 6: '
SELECT DISTINCT d.nombre_grupo
FROM discos d JOIN generos_disco gd ON d.titulo_disco = gd.disco_titulo AND d.fecha_publicacion = gd.disco_fecha_publi
WHERE gd.genero = 'Electronic';

-- Obtiene los discos con la mayor duración total de canciones, considerando solo aquellos discos publicados antes de 2000.
\echo 'Consulta 7: '
SELECT DISTINCT d.titulo_disco, d.fecha_publicacion, SUM(c.duracion_cancion) AS total_length
FROM discos d
JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_publicacion = c.disco_fecha_publi
JOIN ediciones e ON d.titulo_disco = e.disco_titulo AND d.fecha_publicacion = e.disco_fecha_publi
WHERE e.fecha_edicion < 2000
GROUP BY d.titulo_disco, d.fecha_publicacion;

-- Obtiene los discos que el usuario 'Juan García Gómez' posee y que 'Lorena Sáez Pérez' desea.
\echo 'Consulta 8: '
SELECT ul.nombre_completo AS es_de, ur.nombre_completo AS es_deseado_por, ute.disco_titulo, ute.disco_fecha_publi, ute.pais_edicion, ute.edicion_fecha_publi, ute.formato_edicion, ute.estado_edicion
FROM u_tiene_e ute JOIN u_desea_d udd ON ute.disco_titulo = udd.disco_titulo AND ute.disco_fecha_publi = udd.disco_fecha_publi JOIN usuarios ur ON udd.nombre_usu = ur.nombre_usuario JOIN usuarios ul ON ute.nombre_usu = ul.nombre_usuario
WHERE ul.nombre_completo LIKE 'Juan García Gómez' AND ur.nombre_completo LIKE 'Lorena Sáez Pérez';

-- Obtiene los discos que el usuario 'Juan García Gómez' posee en estado 'NM' o 'M'.
\echo 'Consulta 9: '
SELECT u.nombre_completo AS nombre_de_usuario, ute.disco_titulo, ute.disco_fecha_publi, ute.pais_edicion, ute.edicion_fecha_publi, ute.formato_edicion, ute.estado_edicion, ute.id
FROM u_tiene_e ute JOIN usuarios u ON ute.nombre_usu = u.nombre_usuario
WHERE u.nombre_completo LIKE '%Gómez García%' AND (ute.estado_edicion = 'NM' OR ute.estado_edicion = 'M');

-- Obtiene el nombre de usuario, el número de discos que posee, la fecha de publicación más antigua, la más reciente y la media de las fechas de publicación de los discos.
\echo 'Consulta 10: '
SELECT u.nombre_usuario, COUNT(ute.id),MIN(ute.disco_fecha_publi)::INTEGER, MAX(ute.disco_fecha_publi)::INTEGER, AVG(ute.disco_fecha_publi)::INTEGER
FROM usuarios u JOIN u_tiene_e ute ON u.nombre_usuario = ute.nombre_usu
GROUP BY u.nombre_usuario;

-- Obtiene los grupos musicales con más de 5 discos publicados.
\echo 'Consulta 11: '
SELECT d.nombre_grupo, COUNT(*)
FROM discos d JOIN ediciones e ON d.titulo_disco = e.disco_titulo AND d.fecha_publicacion = e.disco_fecha_publi
GROUP BY d.nombre_grupo
HAVING COUNT(*) > 5;

-- Obtiene los usuarios que poseen más discos que cualquier otro usuario.
\echo 'Consulta 12: '
WITH discos_ussuario AS (
    SELECT nombre_usu, COUNT(id) AS numero_discos
    FROM u_tiene_e
    GROUP BY nombre_usu
)
SELECT nombre_usu, COUNT(id)
FROM u_tiene_e
GROUP BY nombre_usu
HAVING COUNT(id) >= ALL(SELECT numero_discos FROM discos_ussuario);

-- Revertir todos los cambios realizados durante la transacción.
ROLLBACK;                       