\pset pager off

SET client_encoding = 'UTF8';
SET search_path TO store;

BEGIN;

SELECT * FROM tienda.auditoria
\echo '-----------------------MOSTRANDO CONSULTAS--------------------'


SELECT * FROM store.u_desea_d WHERE nombre_usu = 'martamoreno' AND disco_titulo = 'II'  ;
INSERT INTO store.u_tiene_e VALUES ('martamoreno', 'II','1989','UK', '2005','CD', 'NM'  )

SELECT * FROM store.auditoria
ORDER BY fecha DESC
LIMIT 1;

SELECT * FROM store.u_desea_d WHERE nombre_usu = 'martamoreno' AND disco_titulo = 'II'  ;


INSERT INTO store.discos (titulo_disco, fecha_publicacion, url_portada, nombre_grupo)
VALUES 
('Somos los bosta', 2022, 'http://estapaginawebnoexiste.com/losbosta.jpg', 'Los bosta');

INSERT INTO store.ediciones ( pais, fecha_edicion, enumeracion_formato, disco_titulo, disco_fecha_publi,)
VALUES 
('CD', 2022, 'Spain', 'Somos los bosta', 2022);

SELECT * FROM store.discos WHERE titulo_disco = 'Somos los bosta';
SELECT * FROM store.ediciones  WHERE disco_titulo = 'Somos los bosta';

UPDATE store.discos
SET url_portada = 'http://estapaginawebesnueva.com/losnuevosbosta.jpg'
WHERE titulo_disco = 'Somos los bosta';

SELECT * FROM store.discos WHERE titulo_disco = 'Somos los bosta';

INSERT INTO store.u_desea_d VALUES ('juangomez','Somos los bosta', 2022 )
SELECT * FROM store.u_desea_d WHERE nombre_usu = 'juangomez' AND disco_titulo = 'Somos los bosta';

INSERT INTO store.u_tiene_e VALUES ('martamoreno', 'Somos los bosta','2022','Spain', '2022','CD', 'NM'  )
SELECT * FROM store.u_tiene_e WHERE usuario_nombre_usuario = 'martamoreno' AND disco_titulo = 'Somos los bosta';

SELECT * FROM store.auditoria
ORDER BY fecha DESC
LIMIT 2;
INSERT INTO store.usuarios VALUES ('iglekirk', 'ejemploiglekirk@gmail.com', 'Jorge Avellaneda Cerro', 'passwordindescifrable');


DELETE * FROM store.discos WHERE titulo_disco = 'Somos los bosta';
DELETE * FROM store.ediciones  WHERE disco_titulo = 'Somos los bosta';

ROLLBACK;
