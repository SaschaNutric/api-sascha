ALTER TABLE servicio DROP COLUMN precio;
ALTER TABLE servicio ADD COLUMN precio numeric(15, 2) NOT NULL;