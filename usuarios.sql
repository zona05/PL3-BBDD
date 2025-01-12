CREATE ROLE adminsRol;

GRANT ALL PRIVILEGES ON DATABASE bdpl2_miguel_angel_y_javier TO adminsRol;
CREATE USER admins WITH PASSWORD 'admin_password';
GRANT adminsRol TO admins;

CREATE ROLE gestorRol;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA store TO gestorRol;
CREATE USER gestor WITH PASSWORD 'gestor_password';
GRANT gestorRol TO gestor;

CREATE ROLE clienteRol;

GRANT SELECT, INSERT ON store.u_tiene_e, store.u_desea_d TO clienteRol;
CREATE USER cliente WITH PASSWORD 'cliente_password';
GRANT clienteRol to cliente;


CREATE ROLE invitadoRol;

GRANT SELECT ON store.grupos, store.discos, store.canciones TO invitadoRol;
CREATE USER invitado WITH PASSWORD 'invitado_password';
GRANT invitadoRol to invitado;


-- User: representa a una persona que interactua en la base de datos
-- Role: perfil de permisos que asignas, como tu persona (PERSONA ES MID) cuando haces rol, no es real


-- Necesito saber e porque de cada select de permisos.