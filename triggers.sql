CREATE TABLE IF NOT EXISTS store.auditorias(
    id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(200),
    tipo_evento VARCHAR(50),
    usuario VARCHAR(200),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Crea una función para registrar las auditorías de las operaciones de inserción, actualización y eliminación en la tabla 'auditorias'.
CREATE OR REPLACE FUNCTION auditoria_trigger_func()
RETURNS trigger AS $$
BEGIN
    INSERT INTO store.auditorias(tabla_afectada, tipo_evento, usuario)
    VALUES (TG_TABLE_NAME, TG_OP, current_user);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auditoria_trigger_usuarios
AFTER INSERT OR UPDATE OR DELETE ON store.usuarios
FOR EACH ROW EXECUTE FUNCTION auditoria_trigger_func();

CREATE TRIGGER auditoria_trigger_u_desea_d
AFTER INSERT OR UPDATE OR DELETE ON store.u_desea_d
FOR EACH ROW EXECUTE FUNCTION auditoria_trigger_func();

CREATE TRIGGER auditoria_trigger_u_desea_d
AFTER INSERT OR UPDATE OR DELETE ON store.u_tiene_e
FOR EACH ROW EXECUTE FUNCTION auditoria_trigger_func();



-- Crea una función para eliminar un disco deseado de un usuario cuando se inserta un disco en la tabla 'u_tiene_e'.
CREATE OR REPLACE FUNCTION eliminar_deseado_trigger_func() RETURNS trigger AS $$
BEGIN
    DELETE FROM store.u_desea_d WHERE nombre_usu = NEW.nombre_usu AND disco_titulo = NEW.disco_titulo AND disco_fecha_publi = NEW.disco_fecha_publi;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Crea un trigger para eliminar los discos deseados de un usuario cuando se inserta un disco en la tabla 'u_tiene_e'.
CREATE TRIGGER eliminar_deseado_trigger
AFTER INSERT ON store.u_tiene_e
FOR EACH ROW EXECUTE FUNCTION eliminar_deseado_trigger_func();

CREATE OR REPLACE FUNCTION gestionar_lista_deseados()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM store.u_desea_d
    WHERE nombre_usu = NEW.nombre_usu AND disco_titulo = NEW.disco_titulo AND disco_fecha_publi = NEW.disco_fecha_publi;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gestionar_lista_deseados
AFTER INSERT OR UPDATE OR DELETE ON store.u_tiene_e
FOR EACH ROW EXECUTE FUNCTION gestionar_lista_deseados();
