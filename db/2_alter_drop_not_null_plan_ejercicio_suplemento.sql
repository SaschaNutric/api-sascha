
-- Acepta valores nulos en los campos plan_ejercicio y plan_suplementos del servicio nutricional
ALTER TABLE servicio ALTER COLUMN id_plan_ejercicio DROP NOT NULL;

ALTER TABLE servicio ALTER COLUMN id_plan_suplemento DROP NOT NULL;