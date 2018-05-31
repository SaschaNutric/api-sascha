DROP TABLE precio;
DROP SEQUENCE public.id_precio_seq;

-- Column: id_tipo_valoracion

-- ALTER TABLE public.tipo_criterio DROP COLUMN id_tipo_valoracion;

ALTER TABLE public.tipo_criterio ADD COLUMN id_tipo_valoracion integer;
ALTER TABLE public.tipo_criterio ALTER COLUMN id_tipo_valoracion SET NOT NULL;


-- Foreign Key: public.tipo_criterio_id_tipo_valoracion_fkey

-- ALTER TABLE public.tipo_criterio DROP CONSTRAINT tipo_criterio_id_tipo_valoracion_fkey;

ALTER TABLE public.tipo_criterio
  ADD CONSTRAINT tipo_criterio_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion)
      REFERENCES public.tipo_valoracion (id_tipo_valoracion) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- DROP COLUMN id_tipo_valoracion 

ALTER TABLE public.criterio
  DROP COLUMN id_tipo_valoracion;
