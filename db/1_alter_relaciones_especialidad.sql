
-- Agrega columna id_especialidad en servicio 
ALTER TABLE servicio ADD COLUMN id_especialidad integer;

-- Crea restricción de clave foranea en servicio con especialidad
ALTER TABLE servicio 
	ADD CONSTRAINT servicio_id_especialidad_fk FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


-- Agrega columna id_especialidad en empleado
ALTER TABLE empleado ADD COLUMN id_especialidad integer;

-- Crea restricción de clave foranea en empleado con especialidad
ALTER TABLE empleado 
	ADD CONSTRAINT empleado_id_especialidad_fk FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


-- Elimina tablas de relación muchos a muchos entre especialidad con servicio y empleado
DROP TABLE especialidad_servicio, especialidad_empleado;
