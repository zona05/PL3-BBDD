\pset pager off

SET client_encoding = 'UTF8';
SET search_path TO store;

BEGIN;

\echo 'Prueba ADMIN (puede hacer lo que quiera)'

SET ROLE jefazo;

INSERT INTO discos (titulo_disco, fecha_publicacion, url_portada, nombre_grupo)
VALUES ( 'NuevoDisco', 2022, 'http://somoslosbostadenuevo.com/foto.jpg','Los Bosta');

SELECT * FROM discos WHERE fecha_publicacion = 2022
LIMIT 3;

\echo 'Se actualiza el disco de prueba al año de publicación 2019'

UPDATE discos SET fecha_publicacion = 2021 WHERE nombre_grupo = 'Los Bosta' AND titulo_disco = 'NuevoDisco';

SELECT * FROM discos WHERE fecha_publicacion = 2021
ORDER BY fecha DESC
LIMIT 1;



DELETE FROM discos WHERE nombre_grupo = 'Los Bosta' AND titulo_disco = 'NuevoDisco';


SELECT * FROM auditoria
ORDER BY fecha DESC
LIMIT 1;


\echo 'Se crea una tabla nueva, se inserta valor, y se muestra'

CREATE TABLE test(
    test TEXT
);

INSERT INTO test (test) VALUES ('esto es un ejemplo');
SELECT * FROM test;

\echo 'Se elimina la tabla'
DROP TABLE test;

RESET ROLE;
ROLLBACK; 



BEGIN;
--Prueba de gestores
\echo 'Gestor(puede hacer todo como el jefazo pero sin crear tablas)'
SET ROLE moderador;

INSERT INTO discos (titulo_disco, fecha_publicacion, url_portada, nombre_grupo) VALUES ( 'NuevoDisco', 2022, 'http://somoslosbostadenuevo.com/foto.jpg','Los Bosta');
SELECT * FROM discos WHERE fecha_publicacion = 2022
LIMIT 3;

-- Cambia la fecha

UPDATE discos SET fecha_publicacion = 2021 WHERE nombre_grupo = 'Los Bosta' AND titulo_disco = 'NuevoDisco';
SELECT * FROM discos WHERE fecha_publicacion = 2021
ORDER BY fecha DESC
LIMIT 1;

-- Lo borra

DELETE FROM discos WHERE nombre_grupo = 'Los Bosta' AND titulo_disco = 'NuevoDisco';

SELECT * FROM auditoria
ORDER BY fecha DESC
LIMIT 1;


\echo 'Creara una tabla, pero dara error porque no tiene permisos'

CREATE TABLE test(
    test TEXT
);

INSERT INTO test (test) VALUES ('esto es un ejemplo');
SELECT * FROM test;

\echo 'Se elimina la tabla'
DROP TABLE test;

RESET ROLE;
ROLLBACK; 



BEGIN;
-- Prueba de clientes
\echo 'Cliente (solo consulta tablas e inserta en u_tiene_e, u_desea_d)'
SET ROLE clientes;

-- Consulta las tablas que tiene acceso

SELECT * FROM u_tiene_e WHERE disco_fecha_publi = 2020
LIMIT 3;

SELECT * FROM u_desea_d WHERE nombre_usu = 'juangomez';

-- Probamos a insertar un valor y comprobamos en u_tiene_e y u_desea_d
INSERT INTO u_desea_d (nombre_usu,disco_titulo, disco_fecha_publi)
VALUES ('juangomez', 'PersonaMID', 1990);


SELECT * FROM u_desea_d WHERE nombre_usuario = 'juangomez';

\echo 'Muestra actualización en auditoría: insert desea'
SELECT * FROM auditoria
ORDER BY fecha DESC
LIMIT 1;

INSERT INTO tiene (nombre_usu, disco_titulo, disco_fecha_publi, edicion_fecha_publi,pais_edicion,formato_edicion,estado_edicion)
VALUES ('martamoreno', 'PersonaMID', 1990, 2000,'Chile', 'CD', 'NM');

SELECT * FROM tiene WHERE nombre_usuario = 'martamoreno';

\echo 'Muestra actualización en auditoría: insert desea'
SELECT * FROM auditoria
ORDER BY fecha DESC
LIMIT 1;
RESET ROLE;
ROLLBACK; 

BEGIN;
--Prueba de invitados
\echo 'Invitado(solo puede consultar la tabla de discos y canciones)'
SET ROLE randy;
-- tabla disco
SELECT titulo_disco FROM discos WHERE anio_publicacion = 2020
LIMIT 3;
-- tabla canción
SELECT titulo_disco FROM canciones WHERE anio_publicacion = 2020
LIMIT 3;
-- Intenta acceder a otra tabla pero dara error
SELECT * FROM usuarios WHERE nombre_usuario= 'juangomez';
RESET ROLE;

ROLLBACK;    