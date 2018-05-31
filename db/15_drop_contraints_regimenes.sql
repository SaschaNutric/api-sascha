ALTER TABLE regimen_suplemento DROP CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey;
ALTER TABLE regimen_ejercicio DROP CONSTRAINT regimen_ejercicio_id_plan_ejercicio_fkey;

ALTER TABLE regimen_suplemento DROP COLUMN id_plan_suplemento;
ALTER TABLE regimen_ejercicio DROP COLUMN id_plan_ejercicio;

ALTER TABLE regimen_suplemento ADD COLUMN id_suplemento integer NOT NULL;
ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES suplemento(id_suplemento);

ALTER TABLE regimen_ejercicio ADD COLUMN id_ejercicio integer;
ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES ejercicio(id_ejercicio);
