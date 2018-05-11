CREATE TABLE estado_solicitud (
    id_estado_solicitud integer NOT NULL,
    tipo integer NOT NULL,
    nombre character varying(200) DEFAULT '' NOT NULL
);

ALTER TABLE estado_solicitud OWNER TO postgres;

INSERT INTO estado_solicitud 
VALUES (1, 1, 'Aprobado'),
(2, 2, 'Rechazado por horario del empleado ocupado'),
(3, 2, 'Rechazado por horario no laborable del empleado'),
(4, 2, 'Rechazado por no aceptación del precio');

ALTER TABLE solicitud_servicio ADD COLUMN id_estado_solicitud integer DEFAULT 1 NOT NULL;

ALTER TABLE ONLY estado_solicitud 
    ADD CONSTRAINT estado_solicitud_pkey PRIMARY KEY (id_estado_solicitud);

ALTER TABLE ONLY solicitud_servicio 
    ADD CONSTRAINT solicitud_servicio_id_estado_solicitud_fkey 
    FOREIGN KEY (id_estado_solicitud) REFERENCES estado_solicitud(id_estado_solicitud); 


