CREATE TABLE tipo_notificacion (
    id_tipo_notificacion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    mensaje character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL 
);

ALTER TABLE tipo_notificacion OWNER TO postgres;

INSERT INTO tipo_notificacion (id_tipo_notificacion, nombre, mensaje)
VALUES (1, 'Solicitud aprobada', 'Su solicitud para el servicios ha sido aprobada, y se ha agendado su cita'),
(2, 'Solicitud Rechazada', ''),
(3, 'Reclamo rechazado', ''),
(4, 'Reclamo aprobado', ''),
(5, 'Incidencia', '');
