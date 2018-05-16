ALTER TABLE respuesta DROP CONSTRAINT respuesta_id_tipo_respuesta_fkey;
ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_id_tipo_respuesta_fkey FOREIGN KEY (id_tipo_respuesta) REFERENCES tipo_motivo(id_tipo_motivo);
