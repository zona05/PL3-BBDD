\pset pager off

SET client_encoding = 'UTF8';
CREATE DATABASE store_db;
\c store_db
BEGIN;
\echo 'creando el esquema para la tienda de discos.'
CREATE SCHEMA IF NOT EXISTS store;

CREATE SCHEMA IF NOT EXISTS ddbb;

\echo 'creando un esquema temporal de discos'
CREATE TABLE IF NOT EXISTS ddbb.discos(
     id TEXT UNIQUE 
    ,titulo_disco       TEXT 
    ,fecha_disco        TEXT
    ,id_grupo           TEXT
    ,grupo_disco        TEXT
    ,url_grupo          TEXT
    ,genero_disco       TEXT
    ,url_portada        TEXT
);


\echo 'creando un esquema temporal de canciones'
CREATE TABLE IF NOT EXISTS ddbb.canciones(
     id_disco           TEXT 
    ,titulo_cancion     TEXT 
    ,duracion           TEXT
);


\echo 'creando un esquema temporal de usuario desea disco'
CREATE TABLE IF NOT EXISTS ddbb.u_desea_d(
     nombre_usuario           TEXT 
    ,titulo_disco             TEXT 
    ,lanzamiento_discos       TEXT
);


\echo 'creando un esquema tempora de usuarios'
CREATE TABLE IF NOT EXISTS ddbb.usuarios(
     nombre_completo           TEXT 
    ,nombre_usuario            TEXT 
    ,email_usuario             TEXT
    ,pass_usuario              TEXT
);


\echo 'creando un esquema temporal de ediciones'
CREATE TABLE IF NOT EXISTS ddbb.ediciones(
     id_disco             TEXT 
    ,lanzamiento_edicion  TEXT 
    ,pais_edicion         TEXT
    ,formato              TEXT
);


\echo 'creando un esquema temporal de usuario tiene edicion'
CREATE TABLE IF NOT EXISTS ddbb.u_tiene_e(
     nombre_usuario           TEXT 
    ,titulo_disco             TEXT 
    ,lanzamiento_discos       TEXT
    ,lanzamiento_edicion      TEXT
    ,pais_edicion             TEXT
    ,edicion_formato                  TEXT
    ,estado                   TEXT
);

SET search_path= ddbb;
\echo 'Cargando datos'

CREATE TEMP TABLE temp_usuarios AS TABLE ddbb.usuarios WITH NO DATA;
CREATE TEMP TABLE temp_discos AS TABLE ddbb.discos WITH NO DATA;
CREATE TEMP TABLE temp_canciones AS TABLE ddbb.canciones WITH NO DATA;
CREATE TEMP TABLE temp_udesead AS TABLE ddbb.u_desea_d WITH NO DATA;
CREATE TEMP TABLE temp_ediciones AS TABLE ddbb.ediciones WITH NO DATA;
CREATE TEMP TABLE temp_utienee AS TABLE ddbb.u_tiene_e WITH NO DATA;

\COPY temp_usuarios FROM 'J:\BBDD_PL2/usuarios.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY temp_discos FROM 'J:\BBDD_PL2/discos.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY temp_canciones FROM 'J:\BBDD_PL2/canciones.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY temp_udesead FROM 'J:\BBDD_PL2/usuario_desea_disco.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY temp_ediciones FROM 'J:\BBDD_PL2/ediciones.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY temp_utienee FROM 'J:\BBDD_PL2/usuario_tiene_edicion.csv' WITH(FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');

INSERT INTO ddbb.usuarios
SELECT DISTINCT * FROM temp_usuarios;

INSERT INTO ddbb.discos
SELECT DISTINCT * FROM temp_discos;

INSERT INTO ddbb.canciones
SELECT DISTINCT * FROM temp_canciones;

INSERT INTO ddbb.u_desea_d
SELECT DISTINCT * FROM temp_udesead;

INSERT INTO ddbb.ediciones
SELECT DISTINCT * FROM temp_ediciones;

INSERT INTO ddbb.u_tiene_e
SELECT DISTINCT * FROM temp_utienee;

DROP TABLE temp_usuarios;
DROP TABLE temp_discos;
DROP TABLE temp_canciones;
DROP TABLE temp_udesead;
DROP TABLE temp_ediciones;
DROP TABLE temp_utienee;


\echo insertando datos en el esquema final



CREATE TABLE IF NOT EXISTS store.usuarios (
    nombre_usuario TEXT,
    email_usuario TEXT NOT NULL CHECK (email_usuario ~ '^[A-Za-z0-9áÁéÉíÍóÓúÚüÜñÑ._%+-]+@[A-Za-z0-9áÁéÉíÍóÓúÚüÜñÑ.-]+\.[A-Za-z]{2,}$'),
    nombre_completo TEXT NOT NULL,
    pass_usuario TEXT NOT NULL,
    PRIMARY KEY (nombre_usuario)
);


CREATE TABLE IF NOT EXISTS store.grupos (
    nombre_grupo TEXT,
    enlace_grupo TEXT CHECK (enlace_grupo ~ '^(https)://[^\s/$.?#].[^\s]$'),
    PRIMARY KEY (nombre_grupo)
);


CREATE TABLE IF NOT EXISTS store.discos(
    titulo_disco TEXT,
    fecha_disco INTEGER,
    url_portada TEXT CHECK (url_portada IS NULL OR url_portada ~ '^(https)://[^\s/$.?#].[^\s]$-_'),
    grupo_disco TEXT,
    PRIMARY KEY (titulo_disco, fecha_disco),
    FOREIGN KEY (grupo_disco) REFERENCES store.grupos(nombre_grupo)
);


CREATE TABLE IF NOT EXISTS store.generos_disco(
    disco_titulo TEXT,
    disco_anno_publicacion INTEGER,
    genero TEXT,
    PRIMARY KEY (disco_titulo, disco_anno_publicacion, genero),
    FOREIGN KEY (disco_titulo, disco_anno_publicacion) REFERENCES store.discos(titulo_disco, fecha_disco)
);

CREATE TYPE formato_enumerado AS ENUM ('CD', 'Vinyl', 'Cassette', 'Flexi-disc', 'CDr', 'Box Set', 'File', 'All Media', 'Lathe Cut', 'DVD', 'VHS', 'Reel-To-Reel', 'Shellac', 'Blu-ray', 'SACD', '8-Track Cartridge', 'Floppy Disk');
CREATE TABLE IF NOT EXISTS store.ediciones(
    pais_edicion TEXT,
    lanzamiento_edicion INTEGER,
    formato formato_enumerado,
    disco_titulo TEXT,
    disco_anno_publicacion INTEGER,
    PRIMARY KEY (pais_edicion, lanzamiento_edicion, formato, disco_titulo, disco_anno_publicacion),
    FOREIGN KEY (disco_titulo, disco_anno_publicacion) REFERENCES store.discos(titulo_disco, fecha_disco)
);

CREATE TABLE IF NOT EXISTS store.canciones(
    titulo_cancion TEXT,
    duracion INTEGER CHECK (duracion >= 0),
    disco_titulo TEXT,
    disco_anno_publicacion INTEGER,
    PRIMARY KEY (titulo_cancion, disco_titulo, disco_anno_publicacion),
    FOREIGN KEY (disco_titulo, disco_anno_publicacion) REFERENCES store.discos(titulo_disco, fecha_disco)
);

CREATE TABLE IF NOT EXISTS store.u_desea_d(
    nombre_usuario TEXT,
    disco_titulo TEXT,
    disco_anno_publicacion INTEGER,
    PRIMARY KEY (nombre_usuario, disco_titulo, disco_anno_publicacion),
    FOREIGN KEY (nombre_usuario) REFERENCES store.usuarios(nombre_usuario),
    FOREIGN KEY (disco_titulo, disco_anno_publicacion) REFERENCES store.discos(titulo_disco, fecha_disco)
);

CREATE TYPE estado_enumerado AS ENUM ('M', 'NM', 'EX', 'VG+', 'VG', 'G', 'F');
CREATE TABLE IF NOT EXISTS store.u_tiene_e(
    nombre_usuario TEXT,
    disco_titulo TEXT,
    disco_anno_publicacion INTEGER,
    pais_edicion TEXT,
    lanzamiento_edicion INTEGER,
    edicion_formato formato_enumerado,
    estado estado_enumerado NOT NULL,
    id INTEGER CHECK(id > 0) NOT NULL,
    PRIMARY KEY (nombre_usuario, disco_titulo, disco_anno_publicacion, pais_edicion, lanzamiento_edicion, edicion_formato,id),
    FOREIGN KEY (nombre_usuario) REFERENCES store.usuarios(nombre_usuario),
    FOREIGN KEY (disco_titulo, disco_anno_publicacion) REFERENCES store.discos(titulo_disco, fecha_disco),
    FOREIGN KEY (pais_edicion, lanzamiento_edicion, edicion_formato, disco_titulo, disco_anno_publicacion) REFERENCES store.ediciones(pais_edicion, lanzamiento_edicion, formato, disco_titulo, disco_anno_publicacion)
);

INSERT INTO store.usuarios
SELECT nombre_usuario, email_usuario, nombre_completo, pass_usuario
FROM ddbb.usuarios;

INSERT INTO store.grupos
SELECT DISTINCT nombre_grupo, enlace_grupo
FROM ddbb.discos;

INSERT INTO store.discos
SELECT DISTINCT titulo_disco, fecha_disco::INTEGER, url_portada, grupo_disco
FROM ddbb.discos;

INSERT INTO store.ediciones
SELECT e.pais_edicion, e.lanzamiento_edicion::INTEGER, e.formato::formato_enumerado, d.titulo_disco, d.fecha_disco::INTEGER
FROM ddbb.ediciones e
JOIN ddbb.discos d ON e.id_disco = d.id;

INSERT INTO store.canciones
SELECT DISTINCT c.titulo_cancion, (CAST(split_part(c.duracion, ':', 1) AS INTEGER) * 60) + CAST(split_part(c.duracion, ':', 2) AS INTEGER), d.titulo_disco, d.fecha_disco::INTEGER
FROM ddbb.canciones c
JOIN ddbb.discos d ON c.id_disco= d.id;

INSERT INTO store.generos_disco
SELECT DISTINCT titulo_disco, fecha_disco::INTEGER, trim(both ' ' from replace(trim(both '[]' from unnest(string_to_array(replace(trim(both '[]' from generos), ' & ', ''), ','))), '''', ''))
FROM ddbb.discos;

INSERT INTO store.u_desea_d
SELECT nombre_usuario, titulo_disco, lanzamiento_discos::INTEGER
FROM store.u_desea_d
WHERE nombre_usuario IN (SELECT nombre_usuario FROM store.usuarios);

CREATE SEQUENCE store.u_tiene_e_id_seq;

INSERT INTO store.u_tiene_e
SELECT nombre_usuario, titulo_disco, lanzamiento_discos::INTEGER, pais_edicion, lanzamiento_edicion::INTEGER, edicion_formato::formato_enumerado, estado::estado_enumerado, nextval('store.u_tiene_e_id_seq')
FROM ddbb.u_tiene_e
WHERE nombre_usuario IN (SELECT nombre_usuario FROM store.usuarios); 

SET search_path= store;

\echo 'Consulta 1:'
SELECT d.titulo_disco, d.fecha_disco, COUNT(*) AS num_canciones
FROM discos d 
JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_disco = c.disco_anno_publicacion
GROUP BY d.titulo_disco, d.fecha_disco
HAVING COUNT(*) > 5
ORDER BY num_canciones;


\echo 'Consulta 2:'
SELECT u.nombre_usuario, u.nombre_completo, e.disco_titulo, e.disco_anno_publicacion, e.pais_edicion, e.lanzamiento_edicion, e.edicion_formato, e.estado
FROM u_tiene_e e
JOIN usuarios u ON e.nombre_usuario = u.nombre_usuario
WHERE u.nombre_completo LIKE 'Juan García Gómez' AND e.edicion_formato = 'Vinyl';

\echo 'Consulta 3:'
WITH DuracionesDisco AS (
    SELECT d.titulo_disco, d.fecha_disco, SUM(c.duracion) AS duracion_total
    FROM discos d 
    JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_disco = c.disco_anno_publicacion
    GROUP BY d.titulo_disco, d.fecha_disco
    HAVING SUM(c.duracion) IS NOT NULL
)
SELECT d.titulo_disco, d.fecha_disco, SUM(c.duracion) AS duracion_total
FROM discos d 
JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_disco = c.disco_anno_publicacion
GROUP BY d.titulo_disco, d.fecha_disco
HAVING SUM(c.duracion) >= ALL(SELECT duracion_total FROM DuracionesDisco);

\echo 'Consulta 4:'
SELECT u.nombre_usuario, u.nombre_completo, udd.disco_titulo, udd.disco_anno_publicacion, d.grupo_disco
FROM usuarios u 
JOIN u_desea_d udd ON u.nombre_usuario = udd.nombre_usuario
JOIN discos d ON udd.disco_titulo = d.titulo_disco AND udd.disco_anno_publicacion = d.fecha_disco
WHERE u.nombre_completo LIKE 'Juan García Gómez';

\echo 'Consulta 5:'
SELECT disco_titulo, disco_anno_publicacion, lanzamiento_edicion, pais_edicion, formato
FROM ediciones
WHERE disco_anno_publicacion BETWEEN 1970 AND 1972
ORDER BY disco_anno_publicacion, disco_titulo;

\echo 'Consulta 6:'
SELECT DISTINCT d.grupo_disco
FROM discos d 
JOIN generos_disco gd ON d.titulo_disco = gd.disco_titulo AND d.fecha_disco = gd.disco_anno_publicacion
WHERE gd.genero = 'Electronic';

\echo 'Consulta 7:'
SELECT DISTINCT d.titulo_disco, d.fecha_disco, SUM(c.duracion) AS duracion_total
FROM discos d
JOIN canciones c ON d.titulo_disco = c.disco_titulo AND d.fecha_disco = c.disco_anno_publicacion
JOIN ediciones e ON d.titulo_disco = e.disco_titulo AND d.fecha_disco = e.disco_anno_publicacion
WHERE e.lanzamiento_edicion < 2000
GROUP BY d.titulo_disco, d.fecha_disco;

\echo 'Consulta 8:'
SELECT ut.nombre_completo AS lo_tiene, ud.nombre_completo AS lo_desea, ute.disco_titulo, ute.disco_anno_publicacion, ute.pais_edicion, ute.lanzamiento_edicion, ute.edicion_formato, ute.estado
FROM u_tiene_e ute 
JOIN u_desea_d udd ON ute.disco_titulo = udd.disco_titulo AND ute.disco_anno_publicacion = udd.disco_anno_publicacion 
JOIN usuarios ud ON udd.nombre_usuario = ud.nombre_usuario 
JOIN usuarios ut ON ute.nombre_usuario = ut.nombre_usuario
WHERE ut.nombre_completo LIKE 'Juan García Gómez' AND ud.nombre_completo LIKE 'Lorena Sáez Pérez';

\echo 'Consulta 9:'
SELECT u.nombre_completo AS nombre_del_usuario, ute.disco_titulo, ute.disco_anno_publicacion, ute.pais_edicion, ute.lanzamiento_edicion, ute.edicion_formato, ute.estado, ute.id
FROM u_tiene_e ute 
JOIN usuarios u ON ute.nombre_usuario = u.nombre_usuario
WHERE u.nombre_completo LIKE '%Gómez García%' AND (ute.estado = 'NM' OR ute.estado = 'M');

\echo 'Consulta 10:'
SELECT u.nombre_usuario, COUNT(ute.id), MIN(ute.disco_anno_publicacion)::INTEGER, MAX(ute.disco_anno_publicacion)::INTEGER, AVG(ute.disco_anno_publicacion)::INTEGER
FROM usuarios u 
JOIN u_tiene_e ute ON u.nombre_usuario = ute.nombre_usuario
GROUP BY u.nombre_usuario;

\echo 'Consulta 11:'
SELECT d.grupo_disco, COUNT(*)
FROM discos d 
JOIN ediciones e ON d.titulo_disco = e.disco_titulo AND d.fecha_disco = e.disco_anno_publicacion
GROUP BY d.grupo_disco;

\echo 'Consulta 12:'
WITH discos_por_usuario AS (
    SELECT nombre_usuario, COUNT(id) AS num_discos
    FROM u_tiene_e
    GROUP BY nombre_usuario
)
SELECT nombre_usuario, COUNT(id) AS num_discos
FROM u_tiene_e
GROUP BY nombre_usuario
HAVING COUNT(id) >= ALL(SELECT num_discos FROM discos_por_usuario);



ROLLBACK;                       -- importante! permite correr el script multiples veces...p