--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3 (Ubuntu 10.3-1.pgdg14.04+1)
-- Dumped by pg_dump version 10.4 (Ubuntu 10.4-2.pgdg16.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fun_asignar_rango_edad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_asignar_rango_edad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
    UPDATE cliente SET id_rango_edad=(
        SELECT id_rango_edad FROM rango_edad r 
        WHERE date_part('years', age(NEW.fecha_nacimiento)) >= r.minimo 
        AND date_part('years', age(NEW.fecha_nacimiento)) <= r.maximo 
        AND estatus = 1
        LIMIT 1
    ) WHERE cliente.id_cliente = NEW.id_cliente;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_asignar_rango_edad() OWNER TO postgres;

--
-- Name: fun_eliminar_cliente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_eliminar_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
UPDATE cliente SET estatus = 0 WHERE cliente.id_usuario = OLD.id_usuario;
RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_eliminar_cliente() OWNER TO postgres;

--
-- Name: fun_notificar_agenda(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_notificar_agenda() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
        
        INSERT INTO notificacion (id_usuario, tipo_notificacion, titulo, mensaje)
        SELECT v.id_usuario_cliente, 3, 'Cita agendada', 
        'Hola ' || v.nombre_cliente || ', tienes una cita de ' || v.tipo_cita || ' con ' || 
        v.nombre_empleado || ' el d├¡a ' || v.fecha || ' a las ' || v.hora_inicio   
        FROM   vista_agenda v WHERE id_agenda = NEW.id_agenda;
    CASE WHEN (SELECT id_tipo_cita FROM vista_agenda WHERE id_agenda = NEW.id_agenda) = 1 THEN
        INSERT INTO notificacion (id_usuario, tipo_notificacion, titulo, mensaje)
        SELECT v.id_usuario_empleado, 1, 'Nueva orden de servicio aprobada', 
        v.nombre_cliente || ' es tu nuevo cliente, y tendr├í su cita de diagn├│stico' || 
        ' el d├¡a ' || v.fecha || ' a las ' || v.hora_inicio || ' para el servicio ' || v.nombre_servicio   
        FROM vista_agenda v WHERE id_agenda = NEW.id_agenda;
    ELSE 
    END CASE;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_notificar_agenda() OWNER TO postgres;

--
-- Name: fun_notificar_comentario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_notificar_comentario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
    INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
    SELECT v.id_usuario, NULL, 8, 'Nuevo comentario',
           (SELECT nombre_cliente FROM vista_comentario_cliente WHERE id_comentario = NEW.id_comentario) 
           || ' coment├│ ' || NEW.contenido
    FROM vista_usuarios_canal_escucha v;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_notificar_comentario() OWNER TO postgres;

--
-- Name: fun_notificar_incidencia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_notificar_incidencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
    CASE WHEN NEW.id_tipo_incidencia = 1 THEN    
        INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
        SELECT v.id_usuario_empleado, NULL, 4, v.nombre_cliente || ' tuvo una incidencia', v.descripcion 
        FROM   vista_incidencia v WHERE id_incidencia = NEW.id_incidencia;
         WHEN NEW.id_tipo_incidencia = 2 THEN
        INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
        (SELECT v.id_usuario_cliente, NULL, 4, 'Ha ocurrido una incidencia', v.descripcion 
        FROM   vista_incidencia v WHERE id_incidencia = NEW.id_incidencia);
    END CASE;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_notificar_incidencia() OWNER TO postgres;

--
-- Name: fun_notificar_reclamo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_notificar_reclamo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
    INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
    SELECT v.id_usuario, NULL, 8, 'Nuevo Reclamo',
           (SELECT nombre_cliente FROM vista_reclamo_registrado WHERE id_reclamo = NEW.id_reclamo) 
           || ' reclam├│, ' || (SELECT motivo_descripcion FROM vista_reclamo_registrado WHERE id_reclamo = NEW.id_reclamo)
    FROM vista_usuarios_reclamos v;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_notificar_reclamo() OWNER TO postgres;

--
-- Name: fun_notificar_respuesta_comentario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_notificar_respuesta_comentario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
    INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
    SELECT v.id_usuario, NULL, 9, 'Respuesta a ' || v.contenido, v.respuesta 
    FROM   vista_comentario_cliente v
    WHERE  id_comentario = NEW.id_comentario;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_notificar_respuesta_comentario() OWNER TO postgres;

--
-- Name: fun_notificar_respuesta_reclamo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_notificar_respuesta_reclamo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
    CASE WHEN (SELECT aprobado FROM vista_reclamo WHERE id_reclamo = NEW.id_reclamo) THEN    
        INSERT INTO notificacion (id_usuario, tipo_notificacion, titulo, mensaje, id_servicio)
        SELECT v.id_usuario, 7, 'Reclamo Aprobado, garant├¡a disponible', v.respuesta_descripcion, v.id_servicio 
        FROM   vista_reclamo v WHERE id_reclamo = NEW.id_reclamo;
    ELSE 
        INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
        (SELECT v.id_usuario, NULL, 6, 'Reclamo Rechazado', v.respuesta_descripcion 
        FROM   vista_reclamo v WHERE id_reclamo = NEW.id_reclamo);
    END CASE;
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_notificar_respuesta_reclamo() OWNER TO postgres;

--
-- Name: fun_promocion_cliente(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fun_promocion_cliente(id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE BEGIN
    	INSERT INTO notificacion (id_usuario, id_promocion, tipo_notificacion, titulo, mensaje)
        SELECT id_usuario, id_promocion, 2, 'Promoci├│n',
        v.nombre_cliente || ' tenemos la promoci├│n ' || v.nombre_promocion 
        || ' adaptada para ti, con un descuento del ' || v.descuento || '% en el servicio ' || v.nombre_servicio 
        FROM vista_promocion_cliente v
        WHERE v.id_promocion = id;
      RETURN 1;
    END $$;


ALTER FUNCTION public.fun_promocion_cliente(id integer) OWNER TO postgres;

--
-- Name: id_agenda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_agenda_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_agenda_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agenda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agenda (
    id_agenda integer DEFAULT nextval('public.id_agenda_seq'::regclass) NOT NULL,
    id_empleado integer NOT NULL,
    id_cliente integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_cita integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.agenda OWNER TO postgres;

--
-- Name: id_alimento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_alimento_seq OWNER TO postgres;

--
-- Name: alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alimento (
    id_alimento integer DEFAULT nextval('public.id_alimento_seq'::regclass) NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.alimento OWNER TO postgres;

--
-- Name: id_app_movil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_app_movil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_app_movil_seq OWNER TO postgres;

--
-- Name: app_movil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_movil (
    id_app_movil integer DEFAULT nextval('public.id_app_movil_seq'::regclass) NOT NULL,
    sistema_operativo character varying(50) DEFAULT ''::character varying NOT NULL,
    url_descarga character varying(500) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.app_movil OWNER TO postgres;

--
-- Name: id_ayuda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_ayuda_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_ayuda_seq OWNER TO postgres;

--
-- Name: ayuda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ayuda (
    id_ayuda integer DEFAULT nextval('public.id_ayuda_seq'::regclass) NOT NULL,
    pregunta character varying(100) DEFAULT ''::character varying NOT NULL,
    respuesta character varying(250) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.ayuda OWNER TO postgres;

--
-- Name: id_bloque_horario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_bloque_horario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_bloque_horario_seq OWNER TO postgres;

--
-- Name: bloque_horario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bloque_horario (
    id_bloque_horario integer DEFAULT nextval('public.id_bloque_horario_seq'::regclass) NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.bloque_horario OWNER TO postgres;

--
-- Name: id_calificacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_calificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_calificacion_seq OWNER TO postgres;

--
-- Name: calificacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calificacion (
    id_criterio integer NOT NULL,
    id_visita integer,
    id_orden_servicio integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_calificacion integer DEFAULT nextval('public.id_calificacion_seq'::regclass) NOT NULL,
    id_valoracion integer NOT NULL
);


ALTER TABLE public.calificacion OWNER TO postgres;

--
-- Name: id_cita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_cita_seq OWNER TO postgres;

--
-- Name: cita; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cita (
    id_cita integer DEFAULT nextval('public.id_cita_seq'::regclass) NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_tipo_cita integer NOT NULL,
    id_bloque_horario integer NOT NULL,
    fecha date NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.cita OWNER TO postgres;

--
-- Name: id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_cliente_seq OWNER TO postgres;

--
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    id_cliente integer DEFAULT nextval('public.id_cliente_seq'::regclass) NOT NULL,
    id_usuario integer NOT NULL,
    id_genero integer NOT NULL,
    id_estado_civil integer NOT NULL,
    id_rango_edad integer,
    cedula character varying(10) DEFAULT ''::character varying NOT NULL,
    nombres character varying(50) DEFAULT ''::character varying NOT NULL,
    apellidos character varying(50) DEFAULT ''::character varying NOT NULL,
    telefono character varying(12) DEFAULT ''::character varying NOT NULL,
    direccion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_nacimiento date NOT NULL,
    tipo_cliente integer DEFAULT 1 NOT NULL,
    fecha_consolidado timestamp without time zone,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- Name: id_comentario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_comentario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_comentario_seq OWNER TO postgres;

--
-- Name: comentario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comentario (
    id_comentario integer DEFAULT nextval('public.id_comentario_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_respuesta integer,
    contenido character varying(500) DEFAULT ''::character varying NOT NULL,
    mensaje character varying(500),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_motivo integer NOT NULL
);


ALTER TABLE public.comentario OWNER TO postgres;

--
-- Name: id_comida_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_comida_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_comida_seq OWNER TO postgres;

--
-- Name: comida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comida (
    id_comida integer DEFAULT nextval('public.id_comida_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.comida OWNER TO postgres;

--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_condicion_garantia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_condicion_garantia_seq OWNER TO postgres;

--
-- Name: condicion_garantia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.condicion_garantia (
    id_condicion_garantia integer DEFAULT nextval('public.id_condicion_garantia_seq'::regclass) NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.condicion_garantia OWNER TO postgres;

--
-- Name: id_contenido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_contenido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_contenido_seq OWNER TO postgres;

--
-- Name: contenido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contenido (
    id_contenido integer DEFAULT nextval('public.id_contenido_seq'::regclass) NOT NULL,
    titulo character varying(100) DEFAULT ''::character varying NOT NULL,
    texto character varying(500) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.contenido OWNER TO postgres;

--
-- Name: id_criterio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_criterio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_criterio_seq OWNER TO postgres;

--
-- Name: criterio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criterio (
    id_criterio integer DEFAULT nextval('public.id_criterio_seq'::regclass) NOT NULL,
    id_tipo_criterio integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.criterio OWNER TO postgres;

--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_detalle_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_detalle_plan_dieta_seq OWNER TO postgres;

--
-- Name: detalle_plan_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_plan_dieta (
    id_detalle_plan_dieta integer DEFAULT nextval('public.id_detalle_plan_dieta_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_comida integer NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.detalle_plan_dieta OWNER TO postgres;

--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_detalle_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_detalle_plan_ejercicio_seq OWNER TO postgres;

--
-- Name: detalle_plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_plan_ejercicio (
    id_detalle_plan_ejercicio integer DEFAULT nextval('public.id_detalle_plan_ejercicio_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_ejercicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.detalle_plan_ejercicio OWNER TO postgres;

--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_detalle_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_detalle_plan_suplemento_seq OWNER TO postgres;

--
-- Name: detalle_plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_plan_suplemento (
    id_detalle_plan_suplemento integer DEFAULT nextval('public.id_detalle_plan_suplemento_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_suplemento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.detalle_plan_suplemento OWNER TO postgres;

--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_detalle_regimen_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_detalle_regimen_alimento_seq OWNER TO postgres;

--
-- Name: detalle_regimen_alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_regimen_alimento (
    id_regimen_dieta integer NOT NULL,
    id_alimento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_detalle_regimen_alimento integer DEFAULT nextval('public.id_detalle_regimen_alimento_seq'::regclass) NOT NULL
);


ALTER TABLE public.detalle_regimen_alimento OWNER TO postgres;

--
-- Name: id_detalle_visita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_detalle_visita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_detalle_visita_seq OWNER TO postgres;

--
-- Name: detalle_visita; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_visita (
    id_visita integer NOT NULL,
    id_parametro integer NOT NULL,
    valor numeric(12,4),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_detalle_visita integer DEFAULT nextval('public.id_detalle_visita_seq'::regclass) NOT NULL
);


ALTER TABLE public.detalle_visita OWNER TO postgres;

--
-- Name: id_dia_laborable_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_dia_laborable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_dia_laborable_seq OWNER TO postgres;

--
-- Name: dia_laborable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dia_laborable (
    id_dia_laborable integer DEFAULT nextval('public.id_dia_laborable_seq'::regclass) NOT NULL,
    dia character varying(20) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.dia_laborable OWNER TO postgres;

--
-- Name: id_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_ejercicio_seq OWNER TO postgres;

--
-- Name: ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ejercicio (
    id_ejercicio integer DEFAULT nextval('public.id_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.ejercicio OWNER TO postgres;

--
-- Name: id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_empleado_seq OWNER TO postgres;

--
-- Name: empleado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empleado (
    id_empleado integer DEFAULT nextval('public.id_empleado_seq'::regclass) NOT NULL,
    id_usuario integer,
    id_genero integer NOT NULL,
    cedula character varying(10) DEFAULT ''::character varying NOT NULL,
    nombres character varying(50) DEFAULT ''::character varying NOT NULL,
    apellidos character varying(50) DEFAULT ''::character varying NOT NULL,
    telefono character varying(12) DEFAULT ''::character varying NOT NULL,
    correo character varying(50) DEFAULT ''::character varying NOT NULL,
    direccion character varying(100) DEFAULT ''::character varying NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    id_especialidad integer
);


ALTER TABLE public.empleado OWNER TO postgres;

--
-- Name: id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_especialidad_seq OWNER TO postgres;

--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especialidad (
    id_especialidad integer DEFAULT nextval('public.id_especialidad_seq'::regclass) NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.especialidad OWNER TO postgres;

--
-- Name: id_estado_civil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_estado_civil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_estado_civil_seq OWNER TO postgres;

--
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado_civil (
    id_estado_civil integer DEFAULT nextval('public.id_estado_civil_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.estado_civil OWNER TO postgres;

--
-- Name: estado_solicitud; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado_solicitud (
    id_estado_solicitud integer NOT NULL,
    tipo integer NOT NULL,
    nombre character varying(200) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.estado_solicitud OWNER TO postgres;

--
-- Name: id_frecuencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_frecuencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_frecuencia_seq OWNER TO postgres;

--
-- Name: frecuencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frecuencia (
    id_frecuencia integer DEFAULT nextval('public.id_frecuencia_seq'::regclass) NOT NULL,
    id_tiempo integer NOT NULL,
    repeticiones integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.frecuencia OWNER TO postgres;

--
-- Name: id_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_funcionalidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_funcionalidad_seq OWNER TO postgres;

--
-- Name: funcionalidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.funcionalidad (
    id_funcionalidad integer DEFAULT nextval('public.id_funcionalidad_seq'::regclass) NOT NULL,
    id_funcionalidad_padre integer,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    icono character varying(100),
    orden integer NOT NULL,
    nivel integer NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    url_vista character varying(200) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.funcionalidad OWNER TO postgres;

--
-- Name: id_garantia_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_garantia_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_garantia_servicio_seq OWNER TO postgres;

--
-- Name: garantia_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.garantia_servicio (
    id_condicion_garantia integer NOT NULL,
    id_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_garantia_servicio integer DEFAULT nextval('public.id_garantia_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE public.garantia_servicio OWNER TO postgres;

--
-- Name: id_genero_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_genero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_genero_seq OWNER TO postgres;

--
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genero (
    id_genero integer DEFAULT nextval('public.id_genero_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.genero OWNER TO postgres;

--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_grupo_alimenticio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_grupo_alimenticio_seq OWNER TO postgres;

--
-- Name: grupo_alimenticio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupo_alimenticio (
    id_grupo_alimenticio integer DEFAULT nextval('public.id_grupo_alimenticio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.grupo_alimenticio OWNER TO postgres;

--
-- Name: id_horario_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_horario_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_horario_empleado_seq OWNER TO postgres;

--
-- Name: horario_empleado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.horario_empleado (
    id_empleado integer NOT NULL,
    id_bloque_horario integer NOT NULL,
    id_dia_laborable integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_horario_empleado integer DEFAULT nextval('public.id_horario_empleado_seq'::regclass) NOT NULL
);


ALTER TABLE public.horario_empleado OWNER TO postgres;

--
-- Name: id_especialidad_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_especialidad_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_especialidad_empleado_seq OWNER TO postgres;

--
-- Name: id_especialidad_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_especialidad_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_especialidad_servicio_seq OWNER TO postgres;

--
-- Name: id_estado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_estado_seq OWNER TO postgres;

--
-- Name: id_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_incidencia_seq OWNER TO postgres;

--
-- Name: id_motivo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_motivo_seq OWNER TO postgres;

--
-- Name: id_negocio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_negocio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_negocio_seq OWNER TO postgres;

--
-- Name: id_notificacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_notificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_notificacion_seq OWNER TO postgres;

--
-- Name: id_orden_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_orden_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_orden_servicio_seq OWNER TO postgres;

--
-- Name: id_parametro_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_parametro_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_parametro_cliente_seq OWNER TO postgres;

--
-- Name: id_parametro_meta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_parametro_meta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_parametro_meta_seq OWNER TO postgres;

--
-- Name: id_parametro_promocion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_parametro_promocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_parametro_promocion_seq OWNER TO postgres;

--
-- Name: id_parametro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_parametro_seq OWNER TO postgres;

--
-- Name: id_parametro_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_parametro_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_parametro_servicio_seq OWNER TO postgres;

--
-- Name: id_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_plan_dieta_seq OWNER TO postgres;

--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_plan_ejercicio_seq OWNER TO postgres;

--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_plan_suplemento_seq OWNER TO postgres;

--
-- Name: id_precio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_precio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_precio_seq OWNER TO postgres;

--
-- Name: id_preferencia_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_preferencia_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_preferencia_cliente_seq OWNER TO postgres;

--
-- Name: id_promocion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_promocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_promocion_seq OWNER TO postgres;

--
-- Name: id_rango_edad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_rango_edad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_rango_edad_seq OWNER TO postgres;

--
-- Name: id_reclamo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_reclamo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_reclamo_seq OWNER TO postgres;

--
-- Name: id_red_social_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_red_social_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_red_social_seq OWNER TO postgres;

--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_regimen_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_regimen_dieta_seq OWNER TO postgres;

--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_regimen_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_regimen_ejercicio_seq OWNER TO postgres;

--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_regimen_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_regimen_suplemento_seq OWNER TO postgres;

--
-- Name: id_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_respuesta_seq OWNER TO postgres;

--
-- Name: id_rol_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_rol_funcionalidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_rol_funcionalidad_seq OWNER TO postgres;

--
-- Name: id_rol_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_rol_seq OWNER TO postgres;

--
-- Name: id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_servicio_seq OWNER TO postgres;

--
-- Name: id_slide_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_slide_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_slide_seq OWNER TO postgres;

--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_solicitud_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_solicitud_servicio_seq OWNER TO postgres;

--
-- Name: id_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_suplemento_seq OWNER TO postgres;

--
-- Name: id_tiempo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tiempo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tiempo_seq OWNER TO postgres;

--
-- Name: id_tipo_cita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_cita_seq OWNER TO postgres;

--
-- Name: id_tipo_criterio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_criterio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_criterio_seq OWNER TO postgres;

--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_dieta_seq OWNER TO postgres;

--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_incidencia_seq OWNER TO postgres;

--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_motivo_seq OWNER TO postgres;

--
-- Name: id_tipo_orden_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_orden_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_orden_seq OWNER TO postgres;

--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_parametro_seq OWNER TO postgres;

--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_respuesta_seq OWNER TO postgres;

--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_unidad_seq OWNER TO postgres;

--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_tipo_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_tipo_valoracion_seq OWNER TO postgres;

--
-- Name: id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_unidad_seq OWNER TO postgres;

--
-- Name: id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_usuario_seq OWNER TO postgres;

--
-- Name: id_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_valoracion_seq OWNER TO postgres;

--
-- Name: id_visita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_visita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_visita_seq OWNER TO postgres;

--
-- Name: incidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidencia (
    id_incidencia integer DEFAULT nextval('public.id_incidencia_seq'::regclass) NOT NULL,
    id_tipo_incidencia integer NOT NULL,
    id_motivo integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_agenda integer NOT NULL
);


ALTER TABLE public.incidencia OWNER TO postgres;

--
-- Name: motivo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.motivo (
    id_motivo integer DEFAULT nextval('public.id_motivo_seq'::regclass) NOT NULL,
    id_tipo_motivo integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.motivo OWNER TO postgres;

--
-- Name: negocio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.negocio (
    id_negocio integer DEFAULT nextval('public.id_negocio_seq'::regclass) NOT NULL,
    razon_social character varying(150) DEFAULT ''::character varying NOT NULL,
    rif character varying(20) DEFAULT ''::character varying NOT NULL,
    url_logo character varying(200),
    mision character varying(500) DEFAULT ''::character varying NOT NULL,
    vision character varying(500) DEFAULT ''::character varying NOT NULL,
    objetivo character varying(500) DEFAULT ''::character varying NOT NULL,
    telefono character varying(12) DEFAULT ''::character varying NOT NULL,
    correo character varying(50) DEFAULT ''::character varying NOT NULL,
    latitud numeric(9,7) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.negocio OWNER TO postgres;

--
-- Name: notificacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notificacion (
    id_notificacion integer DEFAULT nextval('public.id_notificacion_seq'::regclass) NOT NULL,
    id_usuario integer,
    id_promocion integer,
    titulo character varying(500) DEFAULT ''::character varying NOT NULL,
    mensaje character varying(500) DEFAULT ''::character varying NOT NULL,
    tipo_notificacion integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    id_servicio integer
);


ALTER TABLE public.notificacion OWNER TO postgres;

--
-- Name: orden_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orden_servicio (
    id_orden_servicio integer DEFAULT nextval('public.id_orden_servicio_seq'::regclass) NOT NULL,
    id_solicitud_servicio integer NOT NULL,
    id_tipo_orden integer DEFAULT 1 NOT NULL,
    id_meta integer,
    fecha_emision date DEFAULT now() NOT NULL,
    fecha_caducidad date DEFAULT date_trunc('day'::text, (now() + '1 mon'::interval)) NOT NULL,
    id_reclamo integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    estado integer DEFAULT 1
);


ALTER TABLE public.orden_servicio OWNER TO postgres;

--
-- Name: parametro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parametro (
    id_parametro integer DEFAULT nextval('public.id_parametro_seq'::regclass) NOT NULL,
    id_tipo_parametro integer NOT NULL,
    id_unidad integer,
    tipo_valor integer DEFAULT 1 NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.parametro OWNER TO postgres;

--
-- Name: COLUMN parametro.tipo_valor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.parametro.tipo_valor IS '1: Nominal  2: Numerico';


--
-- Name: parametro_cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parametro_cliente (
    id_cliente integer NOT NULL,
    id_parametro integer NOT NULL,
    valor numeric(12,4),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_parametro_cliente integer DEFAULT nextval('public.id_parametro_cliente_seq'::regclass) NOT NULL
);


ALTER TABLE public.parametro_cliente OWNER TO postgres;

--
-- Name: parametro_meta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parametro_meta (
    id_parametro_meta integer DEFAULT nextval('public.id_parametro_meta_seq'::regclass) NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_parametro integer NOT NULL,
    valor_minimo integer NOT NULL,
    valor_maximo integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    signo integer DEFAULT 0 NOT NULL,
    cumplida boolean DEFAULT false
);


ALTER TABLE public.parametro_meta OWNER TO postgres;

--
-- Name: parametro_promocion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parametro_promocion (
    id_parametro integer NOT NULL,
    id_promocion integer NOT NULL,
    valor_minimo integer,
    valor_maximo integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_parametro_promocion integer DEFAULT nextval('public.id_parametro_promocion_seq'::regclass) NOT NULL
);


ALTER TABLE public.parametro_promocion OWNER TO postgres;

--
-- Name: parametro_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parametro_servicio (
    id_servicio integer NOT NULL,
    id_parametro integer NOT NULL,
    valor_minimo integer,
    valor_maximo integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_parametro_servicio integer DEFAULT nextval('public.id_parametro_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE public.parametro_servicio OWNER TO postgres;

--
-- Name: plan_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plan_dieta (
    id_plan_dieta integer DEFAULT nextval('public.id_plan_dieta_seq'::regclass) NOT NULL,
    id_tipo_dieta integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(250) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.plan_dieta OWNER TO postgres;

--
-- Name: plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plan_ejercicio (
    id_plan_ejercicio integer DEFAULT nextval('public.id_plan_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(250) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.plan_ejercicio OWNER TO postgres;

--
-- Name: plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plan_suplemento (
    id_plan_suplemento integer DEFAULT nextval('public.id_plan_suplemento_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(250) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.plan_suplemento OWNER TO postgres;

--
-- Name: preferencia_cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preferencia_cliente (
    id_cliente integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_preferencia_cliente integer DEFAULT nextval('public.id_preferencia_cliente_seq'::regclass) NOT NULL
);


ALTER TABLE public.preferencia_cliente OWNER TO postgres;

--
-- Name: promocion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promocion (
    id_promocion integer DEFAULT nextval('public.id_promocion_seq'::regclass) NOT NULL,
    id_servicio integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    valido_desde date DEFAULT now() NOT NULL,
    valido_hasta date DEFAULT date_trunc('day'::text, (now() + '1 mon'::interval)) NOT NULL,
    id_genero integer,
    id_estado_civil integer,
    id_rango_edad integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    descuento integer,
    url_imagen character varying(200)
);


ALTER TABLE public.promocion OWNER TO postgres;

--
-- Name: COLUMN promocion.id_estado_civil; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.promocion.id_estado_civil IS '
';


--
-- Name: rango_edad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rango_edad (
    id_rango_edad integer DEFAULT nextval('public.id_rango_edad_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL,
    minimo integer NOT NULL,
    maximo integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.rango_edad OWNER TO postgres;

--
-- Name: reclamo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reclamo (
    id_reclamo integer DEFAULT nextval('public.id_reclamo_seq'::regclass) NOT NULL,
    id_motivo integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_respuesta integer,
    respuesta character varying(500),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.reclamo OWNER TO postgres;

--
-- Name: red_social; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.red_social (
    id_red_social integer DEFAULT nextval('public.id_red_social_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    url_base character varying(200) DEFAULT ''::character varying NOT NULL,
    url_logo character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    usuario character varying(100) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.red_social OWNER TO postgres;

--
-- Name: regimen_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regimen_dieta (
    id_regimen_dieta integer DEFAULT nextval('public.id_regimen_dieta_seq'::regclass) NOT NULL,
    id_detalle_plan_dieta integer NOT NULL,
    id_cliente integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.regimen_dieta OWNER TO postgres;

--
-- Name: regimen_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regimen_ejercicio (
    id_regimen_ejercicio integer DEFAULT nextval('public.id_regimen_ejercicio_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_frecuencia integer NOT NULL,
    id_tiempo integer NOT NULL,
    duracion integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_ejercicio integer
);


ALTER TABLE public.regimen_ejercicio OWNER TO postgres;

--
-- Name: regimen_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regimen_suplemento (
    id_regimen_suplemento integer DEFAULT nextval('public.id_regimen_suplemento_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_frecuencia integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_suplemento integer NOT NULL
);


ALTER TABLE public.regimen_suplemento OWNER TO postgres;

--
-- Name: respuesta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.respuesta (
    id_respuesta integer DEFAULT nextval('public.id_respuesta_seq'::regclass) NOT NULL,
    id_tipo_respuesta integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    aprobado boolean
);


ALTER TABLE public.respuesta OWNER TO postgres;

--
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol (
    id_rol integer DEFAULT nextval('public.id_rol_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    dashboard integer DEFAULT 0
);


ALTER TABLE public.rol OWNER TO postgres;

--
-- Name: rol_funcionalidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol_funcionalidad (
    id_rol integer NOT NULL,
    id_funcionalidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_rol_funcionalidad integer DEFAULT nextval('public.id_rol_funcionalidad_seq'::regclass) NOT NULL
);


ALTER TABLE public.rol_funcionalidad OWNER TO postgres;

--
-- Name: servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicio (
    id_servicio integer DEFAULT nextval('public.id_servicio_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_plan_ejercicio integer,
    id_plan_suplemento integer,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(500) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(200) DEFAULT ''::character varying NOT NULL,
    numero_visitas integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_especialidad integer,
    precio numeric(15,2) DEFAULT 1000000 NOT NULL
);


ALTER TABLE public.servicio OWNER TO postgres;

--
-- Name: slide; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slide (
    id_slide integer DEFAULT nextval('public.id_slide_seq'::regclass) NOT NULL,
    titulo character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    orden integer NOT NULL,
    url_imagen character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.slide OWNER TO postgres;

--
-- Name: solicitud_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.solicitud_servicio (
    id_solicitud_servicio integer DEFAULT nextval('public.id_solicitud_servicio_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_motivo integer NOT NULL,
    id_respuesta integer,
    id_servicio integer NOT NULL,
    respuesta character varying(500),
    id_promocion integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_estado_solicitud integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.solicitud_servicio OWNER TO postgres;

--
-- Name: suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suplemento (
    id_suplemento integer DEFAULT nextval('public.id_suplemento_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.suplemento OWNER TO postgres;

--
-- Name: tiempo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tiempo (
    id_tiempo integer DEFAULT nextval('public.id_tiempo_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tiempo OWNER TO postgres;

--
-- Name: tipo_cita; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_cita (
    id_tipo_cita integer DEFAULT nextval('public.id_tipo_cita_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_cita OWNER TO postgres;

--
-- Name: tipo_criterio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_criterio (
    id_tipo_criterio integer DEFAULT nextval('public.id_tipo_criterio_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    id_tipo_valoracion integer NOT NULL
);


ALTER TABLE public.tipo_criterio OWNER TO postgres;

--
-- Name: tipo_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_dieta (
    id_tipo_dieta integer DEFAULT nextval('public.id_tipo_dieta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_dieta OWNER TO postgres;

--
-- Name: tipo_incidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_incidencia (
    id_tipo_incidencia integer DEFAULT nextval('public.id_tipo_incidencia_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_incidencia OWNER TO postgres;

--
-- Name: tipo_motivo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_motivo (
    id_tipo_motivo integer DEFAULT nextval('public.id_tipo_motivo_seq'::regclass) NOT NULL,
    nombre character(50) DEFAULT ''::bpchar NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    canal_escucha boolean DEFAULT true
);


ALTER TABLE public.tipo_motivo OWNER TO postgres;

--
-- Name: tipo_notificacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_notificacion (
    id_tipo_notificacion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    mensaje character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_notificacion OWNER TO postgres;

--
-- Name: tipo_orden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_orden (
    id_tipo_orden integer DEFAULT nextval('public.id_tipo_orden_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_orden OWNER TO postgres;

--
-- Name: tipo_parametro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_parametro (
    id_tipo_parametro integer DEFAULT nextval('public.id_tipo_parametro_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    filtrable boolean DEFAULT false
);


ALTER TABLE public.tipo_parametro OWNER TO postgres;

--
-- Name: tipo_respuesta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_respuesta (
    id_tipo_respuesta integer DEFAULT nextval('public.id_tipo_respuesta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_respuesta OWNER TO postgres;

--
-- Name: tipo_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_unidad (
    id_tipo_unidad integer DEFAULT nextval('public.id_tipo_unidad_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_unidad OWNER TO postgres;

--
-- Name: tipo_valoracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_valoracion (
    id_tipo_valoracion integer DEFAULT nextval('public.id_tipo_valoracion_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.tipo_valoracion OWNER TO postgres;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad (
    id_unidad integer DEFAULT nextval('public.id_unidad_seq'::regclass) NOT NULL,
    id_tipo_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    simbolo character varying(3)
);


ALTER TABLE public.unidad OWNER TO postgres;

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer DEFAULT nextval('public.id_usuario_seq'::regclass) NOT NULL,
    nombre_usuario character varying(100) DEFAULT ''::character varying,
    correo character varying(100) DEFAULT ''::character varying NOT NULL,
    contrasenia character varying DEFAULT ''::character varying NOT NULL,
    salt character varying DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    ultimo_acceso timestamp without time zone,
    estatus integer DEFAULT 1 NOT NULL,
    id_rol integer,
    tipo_usuario integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.usuario.estatus IS '1: Activo 0: Eliminado';


--
-- Name: valoracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valoracion (
    id_valoracion integer DEFAULT nextval('public.id_valoracion_seq'::regclass) NOT NULL,
    id_tipo_valoracion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    valor integer DEFAULT 0
);


ALTER TABLE public.valoracion OWNER TO postgres;

--
-- Name: visita; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visita (
    id_visita integer DEFAULT nextval('public.id_visita_seq'::regclass) NOT NULL,
    numero integer NOT NULL,
    fecha_atencion date NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_agenda integer NOT NULL
);


ALTER TABLE public.visita OWNER TO postgres;

--
-- Name: vista_agenda; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_agenda WITH (security_barrier='false') AS
 SELECT a.id_agenda,
    g.id_orden_servicio,
    j.id_visita,
    i.id_empleado,
    (((i.nombres)::text || ' '::text) || (i.apellidos)::text) AS nombre_empleado,
    b.id_cliente,
    (((b.nombres)::text || ' '::text) || (b.apellidos)::text) AS nombre_cliente,
    b.direccion AS direccion_cliente,
    b.telefono AS telefono_cliente,
    b.fecha_nacimiento AS fecha_nacimiento_cliente,
    date_part('years'::text, age((b.fecha_nacimiento)::timestamp with time zone)) AS edad_cliente,
    c.id_servicio,
    c.nombre AS nombre_servicio,
    c.numero_visitas AS duracion_servicio,
    ( SELECT count(visita.id_visita) AS count
           FROM (public.visita
             JOIN public.agenda ON ((agenda.id_agenda = visita.id_agenda)))
          WHERE (agenda.id_orden_servicio = g.id_orden_servicio)) AS visitas_realizadas,
    c.id_plan_dieta,
    c.id_plan_ejercicio,
    c.id_plan_suplemento,
    d.id_cita,
    d.id_tipo_cita,
    e.nombre AS tipo_cita,
    d.fecha,
    f.hora_inicio,
    f.hora_fin,
    a.fecha_creacion,
    b.id_usuario AS id_usuario_cliente,
    i.id_usuario AS id_usuario_empleado
   FROM (((((((((public.agenda a
     JOIN public.cliente b ON ((a.id_cliente = b.id_cliente)))
     JOIN public.orden_servicio g ON ((a.id_orden_servicio = g.id_orden_servicio)))
     JOIN public.solicitud_servicio h ON ((g.id_solicitud_servicio = h.id_solicitud_servicio)))
     JOIN public.servicio c ON ((c.id_servicio = h.id_servicio)))
     JOIN public.cita d ON ((d.id_cita = a.id_cita)))
     JOIN public.tipo_cita e ON ((d.id_tipo_cita = e.id_tipo_cita)))
     JOIN public.bloque_horario f ON ((d.id_bloque_horario = f.id_bloque_horario)))
     JOIN public.empleado i ON ((i.id_empleado = a.id_empleado)))
     LEFT JOIN public.visita j ON ((j.id_agenda = a.id_agenda)))
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1) AND (d.estatus = 1) AND (d.id_tipo_cita <> 3) AND (g.estatus = 1) AND (g.estado = 1) AND (i.estatus = 1));


ALTER TABLE public.vista_agenda OWNER TO postgres;

--
-- Name: vista_calificacion_servicio; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_calificacion_servicio AS
 SELECT ca.id_calificacion,
    ca.id_visita,
    ca.id_orden_servicio,
    ca.fecha_creacion,
    cri.nombre AS nombre_criterio,
    cri.id_tipo_criterio,
    val.valor AS ponderacion,
    val.nombre AS valor,
    ser.id_servicio,
    ser.nombre AS nombre_servicio,
    es.id_especialidad,
    es.nombre AS especialidad
   FROM public.calificacion ca,
    public.orden_servicio o,
    public.solicitud_servicio s,
    public.servicio ser,
    public.especialidad es,
    public.valoracion val,
    public.criterio cri
  WHERE ((ca.id_orden_servicio = o.id_orden_servicio) AND (o.id_solicitud_servicio = s.id_solicitud_servicio) AND (s.id_servicio = ser.id_servicio) AND (ser.id_especialidad = es.id_especialidad) AND (ca.id_criterio = cri.id_criterio) AND (ca.id_valoracion = val.id_valoracion));


ALTER TABLE public.vista_calificacion_servicio OWNER TO postgres;

--
-- Name: vista_calificacion_visita; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_calificacion_visita AS
 SELECT ca.id_calificacion,
    ca.id_visita,
    ca.id_orden_servicio,
    ca.fecha_creacion,
    cri.nombre AS nombre_criterio,
    cri.id_tipo_criterio,
    val.valor AS ponderacion,
    val.nombre AS valor,
    ser.id_servicio,
    ser.nombre AS nombre_servicio,
    es.id_especialidad,
    es.nombre AS especialidad,
    emp.id_empleado,
    emp.nombres AS nombre_empleado
   FROM public.calificacion ca,
    public.agenda ag,
    public.orden_servicio o,
    public.solicitud_servicio s,
    public.empleado emp,
    public.servicio ser,
    public.especialidad es,
    public.valoracion val,
    public.criterio cri,
    public.visita vi
  WHERE ((ca.id_visita = vi.id_visita) AND (ag.id_agenda = vi.id_agenda) AND (ag.id_orden_servicio = o.id_orden_servicio) AND (o.id_solicitud_servicio = s.id_solicitud_servicio) AND (emp.id_empleado = ag.id_empleado) AND (s.id_servicio = ser.id_servicio) AND (ser.id_especialidad = es.id_especialidad) AND (ca.id_criterio = cri.id_criterio) AND (ca.id_valoracion = val.id_valoracion));


ALTER TABLE public.vista_calificacion_visita OWNER TO postgres;

--
-- Name: vista_canal_escucha; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_canal_escucha AS
 SELECT co.id_comentario,
    co.id_cliente,
    (((cli.nombres)::text || ' '::text) || (cli.apellidos)::text) AS nombre_cliente,
    mo.id_tipo_motivo,
    tm.nombre AS tipo_motivo,
    co.id_motivo,
    mo.descripcion AS motivo_descripcion,
    res.id_respuesta,
    res.descripcion AS respuesta,
    co.mensaje AS respuesta_personalizada,
    co.fecha_creacion,
    cli.id_genero,
    cli.id_rango_edad,
    cli.id_estado_civil,
    ARRAY( SELECT pc.id_parametro
           FROM public.parametro_cliente pc
          WHERE (pc.id_cliente = cli.id_cliente)) AS perfil_cliente
   FROM public.comentario co,
    public.cliente cli,
    public.motivo mo,
    public.tipo_motivo tm,
    public.respuesta res
  WHERE ((co.id_cliente = cli.id_cliente) AND (co.id_motivo = mo.id_motivo) AND (mo.id_tipo_motivo = tm.id_tipo_motivo) AND (co.id_respuesta = res.id_respuesta))
  ORDER BY co.fecha_creacion DESC;


ALTER TABLE public.vista_canal_escucha OWNER TO postgres;

--
-- Name: vista_cita; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_cita AS
 SELECT a.id_agenda,
    g.id_orden_servicio,
    j.id_visita,
    i.id_empleado,
    (((i.nombres)::text || ' '::text) || (i.apellidos)::text) AS nombre_empleado,
    b.id_cliente,
    (((b.nombres)::text || ' '::text) || (b.apellidos)::text) AS nombre_cliente,
    b.direccion AS direccion_cliente,
    b.telefono AS telefono_cliente,
    b.fecha_nacimiento AS fecha_nacimiento_cliente,
    date_part('years'::text, age((b.fecha_nacimiento)::timestamp with time zone)) AS edad_cliente,
    c.id_servicio,
    c.nombre AS nombre_servicio,
    c.numero_visitas AS duracion_servicio,
    ( SELECT count(visita.id_visita) AS count
           FROM (public.visita
             JOIN public.agenda ON ((agenda.id_agenda = visita.id_agenda)))
          WHERE (agenda.id_orden_servicio = g.id_orden_servicio)) AS visitas_realizadas,
    c.id_plan_dieta,
    c.id_plan_ejercicio,
    c.id_plan_suplemento,
    d.id_cita,
    d.id_tipo_cita,
    e.nombre AS tipo_cita,
    d.fecha,
    f.hora_inicio,
    f.hora_fin,
    a.fecha_creacion
   FROM (((((((((public.agenda a
     JOIN public.cliente b ON ((a.id_cliente = b.id_cliente)))
     JOIN public.orden_servicio g ON ((a.id_orden_servicio = g.id_orden_servicio)))
     JOIN public.solicitud_servicio h ON ((g.id_solicitud_servicio = h.id_solicitud_servicio)))
     JOIN public.servicio c ON ((c.id_servicio = h.id_servicio)))
     JOIN public.cita d ON ((d.id_cita = a.id_cita)))
     JOIN public.tipo_cita e ON ((d.id_tipo_cita = e.id_tipo_cita)))
     JOIN public.bloque_horario f ON ((d.id_bloque_horario = f.id_bloque_horario)))
     JOIN public.empleado i ON ((i.id_empleado = a.id_empleado)))
     LEFT JOIN public.visita j ON ((j.id_agenda = a.id_agenda)))
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1) AND (d.estatus = 1) AND (g.estatus = 1) AND (g.estado = 1) AND (i.estatus = 1));


ALTER TABLE public.vista_cita OWNER TO postgres;

--
-- Name: vista_cliente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_cliente AS
 SELECT a.id_cliente,
    a.id_usuario,
    a.cedula,
    a.nombres,
    a.apellidos,
    b.id_genero,
    b.nombre AS genero,
    c.id_estado_civil,
    c.nombre AS estado_civil,
    a.fecha_nacimiento,
    a.telefono,
    a.direccion,
    a.tipo_cliente,
    e.nombre AS rango_edad,
    e.id_rango_edad
   FROM (((public.cliente a
     JOIN public.genero b ON ((a.id_genero = b.id_genero)))
     JOIN public.estado_civil c ON ((a.id_estado_civil = c.id_estado_civil)))
     LEFT JOIN public.rango_edad e ON ((a.id_rango_edad = e.id_rango_edad)))
  WHERE (a.estatus = 1);


ALTER TABLE public.vista_cliente OWNER TO postgres;

--
-- Name: vista_cliente_metas_cumplidas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_cliente_metas_cumplidas AS
 SELECT d.id_orden_servicio,
    c.id_cliente,
    (((c.nombres)::text || ' '::text) || (c.apellidos)::text) AS nombre_cliente,
    f.id_parametro,
    f.nombre,
    a.id_parametro_meta,
        CASE
            WHEN (a.signo = 1) THEN 'Aumentar'::text
            WHEN (a.signo = 0) THEN 'Disminuir'::text
            ELSE NULL::text
        END AS signo,
    a.valor_minimo AS valor_meta,
    b.id_parametro_cliente,
    b.valor AS valor_cliente
   FROM public.parametro_meta a,
    public.parametro_cliente b,
    public.cliente c,
    public.orden_servicio d,
    public.solicitud_servicio e,
    public.parametro f
  WHERE ((c.id_cliente = e.id_cliente) AND (d.id_solicitud_servicio = e.id_solicitud_servicio) AND (a.id_orden_servicio = d.id_orden_servicio) AND (b.id_cliente = c.id_cliente) AND (a.id_parametro = b.id_parametro) AND (a.id_parametro = f.id_parametro) AND (((a.signo = 1) AND (b.valor >= (a.valor_minimo)::numeric)) OR ((a.signo = 0) AND (b.valor <= (a.valor_minimo)::numeric))) AND (c.estatus = 1) AND (d.estatus = 1) AND (e.estatus = 1) AND (f.estatus = 1));


ALTER TABLE public.vista_cliente_metas_cumplidas OWNER TO postgres;

--
-- Name: vista_cliente_ordenes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_cliente_ordenes AS
 SELECT a.id_cliente,
    a.id_usuario,
    ARRAY( SELECT b.id_orden_servicio
           FROM (public.orden_servicio b
             JOIN public.solicitud_servicio c ON ((b.id_solicitud_servicio = c.id_solicitud_servicio)))
          WHERE ((c.id_cliente = a.id_cliente) AND (b.estado = 1))) AS ordenes
   FROM public.cliente a
  WHERE (a.estatus = 1);


ALTER TABLE public.vista_cliente_ordenes OWNER TO postgres;

--
-- Name: vista_cliente_servicio_activo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_cliente_servicio_activo AS
 SELECT a.id_orden_servicio,
    b.id_solicitud_servicio,
    d.id_cliente,
    (((d.nombres)::text || ' '::text) || (d.apellidos)::text) AS nombre_cliente,
    c.id_servicio,
    c.nombre AS nombre_servicio
   FROM (((public.orden_servicio a
     JOIN public.solicitud_servicio b ON ((a.id_solicitud_servicio = b.id_solicitud_servicio)))
     JOIN public.servicio c ON ((b.id_servicio = c.id_servicio)))
     JOIN public.cliente d ON ((b.id_cliente = d.id_cliente)))
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1) AND (d.estatus = 1));


ALTER TABLE public.vista_cliente_servicio_activo OWNER TO postgres;

--
-- Name: vista_comentario_cliente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_comentario_cliente AS
 SELECT a.id_cliente,
    a.id_usuario,
    (((a.nombres)::text || ' '::text) || (a.apellidos)::text) AS nombre_cliente,
    c.id_comentario,
    c.contenido,
    c.id_respuesta,
        CASE
            WHEN (c.mensaje IS NOT NULL) THEN c.mensaje
            WHEN (c.id_respuesta IS NOT NULL) THEN d.descripcion
            ELSE NULL::character varying
        END AS respuesta
   FROM (((public.cliente a
     JOIN public.usuario b ON ((b.id_usuario = a.id_usuario)))
     JOIN public.comentario c ON ((a.id_cliente = c.id_cliente)))
     LEFT JOIN public.respuesta d ON ((c.id_respuesta = d.id_respuesta)))
  WHERE ((b.estatus = 1) AND (a.estatus = 1) AND (c.estatus = 1));


ALTER TABLE public.vista_comentario_cliente OWNER TO postgres;

--
-- Name: vista_estadistico_clientes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_estadistico_clientes AS
 SELECT o.id_orden_servicio,
    s.id_cliente,
    cli.id_genero,
    cli.id_rango_edad,
    cli.id_estado_civil,
    s.id_servicio,
    se.id_especialidad,
    s.id_motivo,
    mo.descripcion AS motivo_descripcion,
    o.fecha_creacion
   FROM public.orden_servicio o,
    public.solicitud_servicio s,
    public.motivo mo,
    public.cliente cli,
    public.servicio se
  WHERE ((o.id_solicitud_servicio = s.id_solicitud_servicio) AND (s.id_motivo = mo.id_motivo) AND (s.id_cliente = cli.id_cliente) AND (s.id_servicio = se.id_servicio));


ALTER TABLE public.vista_estadistico_clientes OWNER TO postgres;

--
-- Name: vista_frecuencia; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_frecuencia AS
 SELECT a.id_frecuencia,
    ((a.repeticiones || ' veces por '::text) || (b.nombre)::text) AS frecuencia
   FROM (public.frecuencia a
     JOIN public.tiempo b ON ((a.id_tiempo = b.id_tiempo)))
  WHERE (a.estatus = 1);


ALTER TABLE public.vista_frecuencia OWNER TO postgres;

--
-- Name: vista_incidencia; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_incidencia WITH (security_barrier='false') AS
 SELECT a.id_incidencia,
        CASE
            WHEN (a.descripcion IS NULL) THEN e.descripcion
            ELSE a.descripcion
        END AS descripcion,
    a.id_tipo_incidencia,
    e.id_motivo,
    e.descripcion AS motivo,
    c.id_usuario AS id_usuario_cliente,
    (((c.nombres)::text || ' '::text) || (c.apellidos)::text) AS nombre_cliente,
    d.id_usuario AS id_usuario_empleado,
    (((d.nombres)::text || ' '::text) || (d.apellidos)::text) AS nombre_empleado,
    a.id_agenda
   FROM ((((public.incidencia a
     JOIN public.agenda b ON ((a.id_agenda = b.id_agenda)))
     JOIN public.cliente c ON ((b.id_cliente = c.id_cliente)))
     JOIN public.empleado d ON ((b.id_empleado = d.id_empleado)))
     JOIN public.motivo e ON ((e.id_motivo = a.id_motivo)))
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1) AND (d.estatus = 1) AND (e.estatus = 1));


ALTER TABLE public.vista_incidencia OWNER TO postgres;

--
-- Name: vista_metas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_metas AS
 SELECT d.id_orden_servicio,
    d.fecha_creacion,
    c.id_servicio,
    c.nombre AS servicio,
    g.id_especialidad,
    g.nombre AS especialidad,
    f.id_parametro,
    f.nombre,
    a.id_parametro_meta,
        CASE
            WHEN (a.signo = 1) THEN 'Aumentar'::text
            WHEN (a.signo = 0) THEN 'Disminuir'::text
            ELSE NULL::text
        END AS signo,
    a.valor_minimo AS valor_meta,
    a.cumplida
   FROM public.parametro_meta a,
    public.servicio c,
    public.especialidad g,
    public.orden_servicio d,
    public.solicitud_servicio e,
    public.parametro f
  WHERE ((c.id_servicio = e.id_servicio) AND (d.id_solicitud_servicio = e.id_solicitud_servicio) AND (a.id_orden_servicio = d.id_orden_servicio) AND (a.id_parametro = f.id_parametro) AND (c.id_especialidad = g.id_especialidad) AND (c.estatus = 1) AND (d.estatus = 1) AND (e.estatus = 1) AND (f.estatus = 1));


ALTER TABLE public.vista_metas OWNER TO postgres;

--
-- Name: vista_nutricionista; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_nutricionista AS
 SELECT ag.id_agenda,
    ci.id_tipo_cita,
    tc.nombre AS tipo_cita,
    e.id_empleado,
    (((e.nombres)::text || ' '::text) || (e.apellidos)::text) AS nombre_empleado,
    ci.fecha_creacion,
    e.id_especialidad,
    es.nombre AS especialidad,
    o.id_orden_servicio
   FROM public.cita ci,
    public.tipo_cita tc,
    public.orden_servicio o,
    public.solicitud_servicio s,
    public.empleado e,
    public.agenda ag,
    public.especialidad es
  WHERE ((ci.id_cita = ag.id_cita) AND (ag.id_orden_servicio = o.id_orden_servicio) AND (o.id_solicitud_servicio = s.id_solicitud_servicio) AND (ag.id_empleado = e.id_empleado) AND (ci.id_tipo_cita = tc.id_tipo_cita) AND (e.id_especialidad = es.id_especialidad) AND (tc.id_tipo_cita <> 3));


ALTER TABLE public.vista_nutricionista OWNER TO postgres;

--
-- Name: vista_orden_servicio; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_orden_servicio AS
 SELECT DISTINCT o.id_orden_servicio,
    (((cli.nombres)::text || ' '::text) || (cli.apellidos)::text) AS nombre_cliente,
    s.id_servicio,
    ser.nombre AS nombre_servicio,
    e.id_empleado,
    (((e.nombres)::text || ' '::text) || (e.apellidos)::text) AS nombre_empleado,
    o.fecha_emision,
    o.id_tipo_orden,
    tio.nombre AS tipo_orden,
    o.estado,
    cli.id_genero,
    cli.id_estado_civil,
    cli.id_rango_edad,
    ser.id_especialidad,
    ARRAY( SELECT ps.id_parametro
           FROM public.parametro_servicio ps
          WHERE (ps.id_servicio = ser.id_servicio)) AS paremtros_servicio
   FROM public.orden_servicio o,
    public.solicitud_servicio s,
    public.cliente cli,
    public.servicio ser,
    public.tipo_orden tio,
    public.agenda ag,
    public.empleado e
  WHERE ((s.id_solicitud_servicio = o.id_solicitud_servicio) AND (s.id_cliente = cli.id_cliente) AND (s.id_servicio = ser.id_servicio) AND (o.id_tipo_orden = tio.id_tipo_orden) AND (o.id_orden_servicio = ag.id_orden_servicio) AND (e.id_empleado = ag.id_empleado))
  ORDER BY o.fecha_emision DESC;


ALTER TABLE public.vista_orden_servicio OWNER TO postgres;

--
-- Name: vista_promocion_cliente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_promocion_cliente AS
 SELECT a.id_cliente,
    a.id_usuario,
    (((a.nombres)::text || ' '::text) || (a.apellidos)::text) AS nombre_cliente,
    b.id_promocion,
    b.nombre AS nombre_promocion,
    b.descuento,
    d.id_servicio,
    d.nombre AS nombre_servicio
   FROM public.cliente a,
    public.promocion b,
    public.usuario c,
    public.servicio d
  WHERE ((d.id_servicio = b.id_servicio) AND ((a.id_rango_edad = b.id_rango_edad) OR (b.id_rango_edad IS NULL)) AND ((a.id_genero = b.id_genero) OR (b.id_genero IS NULL)) AND ((a.id_estado_civil = b.id_estado_civil) OR (b.id_estado_civil IS NULL)) AND (c.id_usuario = a.id_usuario) AND (ARRAY( SELECT pp.id_parametro
           FROM public.parametro_promocion pp
          WHERE (pp.id_promocion = b.id_promocion)) <@ ARRAY( SELECT pc.id_parametro
           FROM public.parametro_cliente pc
          WHERE (pc.id_cliente = a.id_cliente))) AND (b.estatus = 1) AND (a.estatus = 1) AND (c.estatus = 1) AND (d.estatus = 1));


ALTER TABLE public.vista_promocion_cliente OWNER TO postgres;

--
-- Name: vista_reclamo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_reclamo AS
 SELECT DISTINCT r.id_reclamo,
    res.aprobado,
    cli.id_usuario,
    (((cli.nombres)::text || ' '::text) || (cli.apellidos)::text) AS nombre_cliente,
    e.id_empleado,
    (((e.nombres)::text || ' '::text) || (e.apellidos)::text) AS nombre_empleado,
    s.id_servicio,
    serv.nombre AS nombre_servicio,
    serv.id_especialidad,
    mo.descripcion AS motivo_descripcion,
    mo.id_motivo,
    r.id_respuesta,
    res.descripcion AS respuesta_descripcion,
    r.fecha_creacion,
    cli.id_genero,
    cli.id_estado_civil,
    cli.id_rango_edad
   FROM public.reclamo r,
    public.orden_servicio o,
    public.solicitud_servicio s,
    public.agenda ag,
    public.empleado e,
    public.cliente cli,
    public.servicio serv,
    public.motivo mo,
    public.respuesta res
  WHERE ((r.id_orden_servicio = o.id_orden_servicio) AND (o.id_solicitud_servicio = s.id_solicitud_servicio) AND (s.id_cliente = cli.id_cliente) AND (s.id_servicio = serv.id_servicio) AND (r.id_respuesta = res.id_respuesta) AND (r.id_motivo = mo.id_motivo) AND (ag.id_orden_servicio = o.id_orden_servicio) AND (ag.id_empleado = e.id_empleado) AND (r.id_respuesta IS NOT NULL))
  ORDER BY r.fecha_creacion DESC;


ALTER TABLE public.vista_reclamo OWNER TO postgres;

--
-- Name: vista_reclamo_registrado; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_reclamo_registrado AS
 SELECT DISTINCT r.id_reclamo,
    cli.id_usuario,
    (((cli.nombres)::text || ' '::text) || (cli.apellidos)::text) AS nombre_cliente,
    e.id_empleado,
    (((e.nombres)::text || ' '::text) || (e.apellidos)::text) AS nombre_empleado,
    s.id_servicio,
    serv.nombre AS nombre_servicio,
    serv.id_especialidad,
    mo.descripcion AS motivo_descripcion,
    mo.id_motivo,
    r.id_respuesta,
    r.fecha_creacion
   FROM public.reclamo r,
    public.orden_servicio o,
    public.solicitud_servicio s,
    public.agenda ag,
    public.empleado e,
    public.cliente cli,
    public.servicio serv,
    public.motivo mo
  WHERE ((r.id_orden_servicio = o.id_orden_servicio) AND (o.id_solicitud_servicio = s.id_solicitud_servicio) AND (s.id_cliente = cli.id_cliente) AND (s.id_servicio = serv.id_servicio) AND (r.id_motivo = mo.id_motivo) AND (ag.id_orden_servicio = o.id_orden_servicio) AND (ag.id_empleado = e.id_empleado))
  ORDER BY r.fecha_creacion DESC;


ALTER TABLE public.vista_reclamo_registrado OWNER TO postgres;

--
-- Name: vista_reporte_solicitud; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_reporte_solicitud AS
 SELECT a.id_solicitud_servicio,
    a.id_estado_solicitud AS id_respuesta,
        CASE
            WHEN (a.id_estado_solicitud = 1) THEN 'Aprobado'::text
            WHEN (a.id_estado_solicitud = 2) THEN 'Rechazado, nutricionista tiene agendado el dia y horario'::text
            WHEN (a.id_estado_solicitud = 3) THEN 'Rechazado, nutricionista no trabaja en el dia y horario especificado'::text
            WHEN (a.id_estado_solicitud = 4) THEN 'Rechazado, precio no aceptado'::text
            ELSE NULL::text
        END AS respuesta,
    a.fecha_creacion,
    b.id_cliente,
    (((b.nombres)::text || ' '::text) || (b.apellidos)::text) AS nombre_cliente,
    b.id_rango_edad,
    b.id_genero,
    b.id_estado_civil,
    d.id_especialidad,
    d.nombre AS nombres_especialidad,
    c.id_servicio,
    c.nombre AS nombre_servicio,
    e.id_motivo,
    e.descripcion AS motivo
   FROM ((((public.solicitud_servicio a
     JOIN public.cliente b ON ((a.id_cliente = b.id_cliente)))
     JOIN public.servicio c ON ((a.id_servicio = c.id_servicio)))
     JOIN public.especialidad d ON ((d.id_especialidad = c.id_especialidad)))
     JOIN public.motivo e ON ((e.id_motivo = a.id_motivo)))
  WHERE (a.estatus = 1);


ALTER TABLE public.vista_reporte_solicitud OWNER TO postgres;

--
-- Name: vista_roles_canal_escucha; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_roles_canal_escucha AS
 SELECT a.id_rol,
    a.nombre
   FROM public.rol a,
    public.rol_funcionalidad rf,
    public.funcionalidad b
  WHERE ((rf.id_rol = a.id_rol) AND (rf.id_funcionalidad = b.id_funcionalidad) AND (b.id_funcionalidad = 58) AND (a.estatus = 1));


ALTER TABLE public.vista_roles_canal_escucha OWNER TO postgres;

--
-- Name: vista_usuarios_canal_escucha; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_usuarios_canal_escucha AS
 SELECT c.id_usuario,
    a.id_rol,
    a.nombre
   FROM public.rol a,
    public.rol_funcionalidad rf,
    public.funcionalidad b,
    public.usuario c
  WHERE ((rf.id_rol = a.id_rol) AND (rf.id_funcionalidad = b.id_funcionalidad) AND (c.id_rol = a.id_rol) AND (b.id_funcionalidad = 58) AND (a.estatus = 1));


ALTER TABLE public.vista_usuarios_canal_escucha OWNER TO postgres;

--
-- Name: vista_usuarios_reclamos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_usuarios_reclamos AS
 SELECT c.id_usuario,
    a.id_rol,
    a.nombre
   FROM public.rol a,
    public.rol_funcionalidad rf,
    public.funcionalidad b,
    public.usuario c
  WHERE ((rf.id_rol = a.id_rol) AND (rf.id_funcionalidad = b.id_funcionalidad) AND (c.id_rol = a.id_rol) AND (b.id_funcionalidad = 57) AND (a.estatus = 1));


ALTER TABLE public.vista_usuarios_reclamos OWNER TO postgres;

--
-- Name: vista_visita; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_visita AS
 SELECT a.id_visita,
    a.numero,
    a.fecha_atencion,
    b.id_agenda,
    e.id_empleado,
    (((e.nombres)::text || ' '::text) || (e.apellidos)::text) AS nombre_empleado,
    h.id_servicio,
    h.nombre AS nombre_servicio,
    h.numero_visitas,
    c.id_cliente,
    d.id_orden_servicio,
    ARRAY( SELECT f.id_calificacion
           FROM public.calificacion f
          WHERE (f.id_visita = a.id_visita)) AS calificaciones
   FROM ((((((public.visita a
     JOIN public.agenda b ON ((b.id_agenda = a.id_agenda)))
     JOIN public.cliente c ON ((c.id_cliente = b.id_cliente)))
     JOIN public.orden_servicio d ON ((d.id_orden_servicio = b.id_orden_servicio)))
     JOIN public.empleado e ON ((e.id_empleado = b.id_empleado)))
     JOIN public.solicitud_servicio g ON ((g.id_solicitud_servicio = d.id_solicitud_servicio)))
     JOIN public.servicio h ON ((h.id_servicio = g.id_servicio)))
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1));


ALTER TABLE public.vista_visita OWNER TO postgres;

--
-- Data for Name: agenda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 2, 30, 3, 2, '2018-05-27 14:43:27.654822', '2018-05-27 14:43:27.654822', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 3, 16, 4, 3, '2018-05-27 15:14:16.678696', '2018-05-27 15:14:16.678696', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (90, 3, 18, 47, 90, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (91, 3, 18, 47, 91, '2018-06-05 07:45:17.60096', '2018-06-05 07:45:17.60096', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (92, 5, 59, 48, 92, '2018-06-05 08:42:37.542818', '2018-06-05 08:42:37.542818', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (93, 5, 59, 48, 93, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 3, 37, 2, 1, '2018-05-27 14:28:38.912499', '2018-05-27 14:28:38.912499', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 3, 37, 2, 4, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (94, 5, 59, 48, 94, '2018-06-05 09:25:04.904924', '2018-06-05 09:25:04.904924', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 3, 37, 2, 5, '2018-05-27 16:07:50.332594', '2018-05-27 16:07:50.332594', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 5, 54, 5, 6, '2018-05-27 18:21:13.531347', '2018-05-27 18:21:13.531347', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 5, 54, 5, 7, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 2, 1, 6, 8, '2018-05-29 00:44:11.240641', '2018-05-29 00:44:11.240641', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 2, 2, 7, 9, '2018-05-29 00:46:54.167265', '2018-05-29 00:46:54.167265', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 2, 4, 8, 10, '2018-05-29 01:14:47.108441', '2018-05-29 01:14:47.108441', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 4, 3, 9, 11, '2018-05-29 01:18:36.565882', '2018-05-29 01:18:36.565882', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 4, 6, 10, 12, '2018-05-29 01:34:50.117839', '2018-05-29 01:34:50.117839', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 4, 8, 11, 13, '2018-05-29 01:51:29.261905', '2018-05-29 01:51:29.261905', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 5, 54, 5, 14, '2018-05-29 01:56:09.282494', '2018-05-29 01:56:09.282494', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 3, 33, 12, 15, '2018-05-29 20:37:46.092464', '2018-05-29 20:37:46.092464', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 3, 33, 12, 16, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 3, 33, 12, 17, '2018-05-29 21:11:50.521174', '2018-05-29 21:11:50.521174', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 4, 7, 13, 18, '2018-05-30 19:35:26.143224', '2018-05-30 19:35:26.143224', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 2, 9, 14, 19, '2018-05-30 19:41:00.311832', '2018-05-30 19:41:00.311832', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 3, 10, 15, 20, '2018-05-30 19:45:17.097513', '2018-05-30 19:45:17.097513', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 4, 11, 16, 21, '2018-05-30 19:49:05.950677', '2018-05-30 19:49:05.950677', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 4, 12, 17, 22, '2018-05-30 19:55:01.86682', '2018-05-30 19:55:01.86682', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 4, 15, 18, 23, '2018-05-30 20:12:43.998593', '2018-05-30 20:12:43.998593', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 3, 17, 19, 24, '2018-05-30 20:23:18.607635', '2018-05-30 20:23:18.607635', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 3, 18, 20, 25, '2018-05-30 20:28:05.812934', '2018-05-30 20:28:05.812934', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 5, 19, 21, 26, '2018-05-30 20:38:46.023439', '2018-05-30 20:38:46.023439', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 5, 20, 22, 27, '2018-05-30 20:47:23.921972', '2018-05-30 20:47:23.921972', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 5, 21, 23, 28, '2018-05-30 20:59:07.481534', '2018-05-30 20:59:07.481534', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 5, 23, 24, 29, '2018-05-30 21:55:35.692019', '2018-05-30 21:55:35.692019', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 5, 24, 25, 30, '2018-05-30 22:01:13.244598', '2018-05-30 22:01:13.244598', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 5, 23, 24, 31, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 3, 25, 26, 32, '2018-05-31 07:16:47.582042', '2018-05-31 07:16:47.582042', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 3, 40, 27, 33, '2018-05-31 08:18:37.936665', '2018-05-31 08:18:37.936665', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 3, 10, 15, 34, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 5, 23, 24, 35, '2018-05-31 11:02:01.399888', '2018-05-31 11:02:01.399888', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 5, 23, 24, 36, '2018-05-31 11:03:47.758069', '2018-05-31 11:03:47.758069', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 5, 55, 28, 37, '2018-05-31 11:40:05.155587', '2018-05-31 11:40:05.155587', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 5, 55, 28, 38, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 3, 25, 26, 39, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 3, 40, 27, 40, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 5, 24, 25, 41, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 5, 28, 29, 42, '2018-06-01 07:12:29.375298', '2018-06-01 07:12:29.375298', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 4, 56, 30, 43, '2018-06-01 07:50:39.640549', '2018-06-01 07:50:39.640549', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 4, 56, 30, 44, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 4, 57, 31, 45, '2018-06-01 13:27:56.268999', '2018-06-01 13:27:56.268999', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 4, 57, 31, 54, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 4, 57, 31, 55, '2018-06-01 13:47:27.831542', '2018-06-01 13:47:27.831542', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 4, 57, 31, 56, '2018-06-01 13:59:46.532712', '2018-06-01 13:59:46.532712', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 2, 1, 6, 57, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 4, 11, 16, 58, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 3, 10, 15, 59, '2018-06-01 22:32:10.973988', '2018-06-01 22:32:10.973988', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (60, 3, 25, 26, 60, '2018-06-01 22:59:39.774842', '2018-06-01 22:59:39.774842', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (61, 5, 23, 24, 61, '2018-06-03 05:43:13.904244', '2018-06-03 05:43:13.904244', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (62, 5, 23, 24, 62, '2018-06-03 06:19:56.632807', '2018-06-03 06:19:56.632807', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (63, 3, 16, 37, 63, '2018-06-03 22:42:51.297514', '2018-06-03 22:42:51.297514', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (64, 5, 44, 38, 64, '2018-06-03 22:59:39.418328', '2018-06-03 22:59:39.418328', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (65, 5, 25, 39, 65, '2018-06-04 00:49:00.953408', '2018-06-04 00:49:00.953408', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (66, 2, 9, 14, 66, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (67, 2, 4, 8, 67, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (68, 2, 2, 7, 68, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (69, 4, 6, 10, 69, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (70, 4, 8, 11, 70, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (71, 4, 12, 17, 71, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (72, 4, 15, 18, 72, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (73, 4, 15, 18, 73, '2018-06-04 07:45:57.75244', '2018-06-04 07:45:57.75244', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (74, 4, 56, 30, 74, '2018-06-04 07:48:20.813483', '2018-06-04 07:48:20.813483', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (75, 4, 12, 17, 75, '2018-06-04 07:49:26.509683', '2018-06-04 07:49:26.509683', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (76, 4, 8, 11, 76, '2018-06-04 07:54:10.223961', '2018-06-04 07:54:10.223961', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (77, 4, 11, 16, 77, '2018-06-04 07:55:44.276057', '2018-06-04 07:55:44.276057', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (78, 5, 37, 43, 78, '2018-06-04 11:48:07.755443', '2018-06-04 11:48:07.755443', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (79, 5, 33, 44, 79, '2018-06-04 13:38:16.74193', '2018-06-04 13:38:16.74193', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (81, 3, 18, 20, 81, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (82, 3, 36, 45, 82, '2018-06-05 01:10:14.699716', '2018-06-05 01:10:14.699716', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (83, 2, 2, 7, 83, '2018-06-05 02:39:03.229541', '2018-06-05 02:39:03.229541', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (84, 3, 18, 20, 84, '2018-06-05 02:46:11.00669', '2018-06-05 02:46:11.00669', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (85, 3, 26, 46, 85, '2018-06-05 04:11:37.388533', '2018-06-05 04:11:37.388533', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (86, 3, 26, 46, 86, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (87, 3, 18, 47, 87, '2018-06-05 06:01:37.784926', '2018-06-05 06:01:37.784926', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (88, 3, 26, 46, 88, '2018-06-05 06:05:49.81802', '2018-06-05 06:05:49.81802', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (89, 3, 26, 46, 89, '2018-06-05 06:16:57.771066', '2018-06-05 06:16:57.771066', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (95, 5, 59, 49, 95, '2018-06-05 09:46:30.430025', '2018-06-05 09:46:30.430025', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (96, 5, 59, 49, 96, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (97, 5, 59, 49, 97, '2018-06-05 10:52:46.301159', '2018-06-05 10:52:46.301159', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (98, 5, 37, 43, 98, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (99, 2, 25, 50, 99, '2018-06-05 17:05:39.950113', '2018-06-05 17:05:39.950113', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (100, 5, 59, 51, 100, '2018-06-05 20:33:46.433739', '2018-06-05 20:33:46.433739', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (101, 5, 23, 24, 101, '2018-06-05 21:01:40.561131', '2018-06-05 21:01:40.561131', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (102, 3, 16, 52, 102, '2018-06-05 21:16:59.072292', '2018-06-05 21:16:59.072292', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (103, 5, 59, 53, 103, '2018-06-05 22:48:49.922917', '2018-06-05 22:48:49.922917', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (104, 5, 59, 54, 104, '2018-06-06 00:01:54.216693', '2018-06-06 00:01:54.216693', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (105, 5, 59, 55, 105, '2018-06-06 00:22:47.783451', '2018-06-06 00:22:47.783451', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (106, 5, 59, 55, 106, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (107, 5, 59, 55, 107, '2018-06-06 00:37:53.481441', '2018-06-06 00:37:53.481441', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (108, 5, 59, 56, 108, '2018-06-06 02:44:15.71823', '2018-06-06 02:44:15.71823', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (109, 5, 59, 57, 109, '2018-06-06 02:53:07.0047', '2018-06-06 02:53:07.0047', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (110, 5, 59, 57, 110, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (115, 5, 45, 62, 115, '2018-06-06 03:55:51.548749', '2018-06-06 03:55:51.548749', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (117, 5, 45, 62, 117, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (118, 5, 45, 63, 118, '2018-06-06 04:47:31.727616', '2018-06-06 04:47:31.727616', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (120, 5, 45, 63, 120, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (121, 5, 45, 63, 121, '2018-06-06 05:00:11.407749', '2018-06-06 05:00:11.407749', 1);
INSERT INTO public.agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_cita, fecha_creacion, fecha_actualizacion, estatus) VALUES (122, 2, 16, 64, 122, '2018-06-06 14:48:39.764145', '2018-06-06 14:48:39.764145', 1);


--
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 2, 'Arroz', '2018-05-27 03:16:05.268875', '2018-05-27 03:16:05.268875', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 2, 'Avena', '2018-05-27 03:16:21.687904', '2018-05-27 03:16:21.687904', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 2, 'Cereales de caja', '2018-05-27 03:16:48.603425', '2018-05-27 03:16:48.603425', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 2, 'Pan', '2018-05-27 03:17:03.664041', '2018-05-27 03:17:03.664041', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 2, 'Tortilla', '2018-05-27 03:18:29.156537', '2018-05-27 03:18:29.156537', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 2, 'Galletas', '2018-05-27 03:18:40.182637', '2018-05-27 03:18:40.182637', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 2, 'Pasta', '2018-05-27 03:18:53.648946', '2018-05-27 03:18:53.648946', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 2, 'Centeno', '2018-05-27 03:19:35.82084', '2018-05-27 03:19:35.82084', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 2, 'Cebada', '2018-05-27 03:19:52.074331', '2018-05-27 03:19:52.074331', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 1, 'Frijoles', '2018-05-27 03:24:22.638083', '2018-05-27 03:24:22.638083', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 1, 'Lentejas', '2018-05-27 03:25:49.205604', '2018-05-27 03:25:49.205604', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 1, 'Soja', '2018-05-27 03:26:10.158831', '2018-05-27 03:26:10.158831', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 1, 'Guisantes', '2018-05-27 03:26:36.352539', '2018-05-27 03:26:36.352539', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 1, 'Garbanzos', '2018-05-27 03:26:57.155376', '2018-05-27 03:26:57.155376', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 3, 'Fresa', '2018-05-27 03:38:11.54701', '2018-05-27 03:38:11.54701', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 3, 'Cambur', '2018-05-27 03:38:56.237474', '2018-05-27 03:38:56.237474', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 3, 'Uva', '2018-05-27 03:40:41.103791', '2018-05-27 03:40:41.103791', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 3, 'Mango', '2018-05-27 03:40:57.859517', '2018-05-27 03:40:57.859517', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 3, 'Pi├▒a', '2018-05-27 03:41:11.717197', '2018-05-27 03:41:11.717197', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 3, 'Cereza', '2018-05-27 03:41:28.380517', '2018-05-27 03:41:28.380517', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 3, 'Naranja', '2018-05-27 03:41:47.725238', '2018-05-27 03:41:47.725238', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 3, 'Durazno', '2018-05-27 03:42:04.380252', '2018-05-27 03:42:04.380252', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 3, 'Patilla', '2018-05-27 03:42:20.207039', '2018-05-27 03:42:20.207039', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 3, 'Mel├│n', '2018-05-27 03:42:32.148876', '2018-05-27 03:42:32.148876', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 3, 'Lechoza', '2018-05-27 03:42:52.921751', '2018-05-27 03:42:52.921751', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 3, 'Arandanos', '2018-05-27 03:43:02.306552', '2018-05-27 03:43:02.306552', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 3, 'Lim├│n', '2018-05-27 03:43:55.700717', '2018-05-27 03:43:55.700717', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 3, 'Melocot├│n', '2018-05-27 03:44:08.34826', '2018-05-27 03:44:08.34826', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 3, 'Manzana', '2018-05-27 03:44:20.592775', '2018-05-27 03:44:20.592775', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 3, 'Pera', '2018-05-27 03:44:29.633849', '2018-05-27 03:44:29.633849', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 3, 'Guanabana', '2018-05-27 03:44:43.209908', '2018-05-27 03:44:43.209908', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 3, 'Higo', '2018-05-27 03:44:53.67077', '2018-05-27 03:44:53.67077', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 4, 'Leche', '2018-05-27 03:47:41.734099', '2018-05-27 03:47:41.734099', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 4, 'Yogurt', '2018-05-27 03:48:08.794741', '2018-05-27 03:48:08.794741', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 4, 'Queso', '2018-05-27 03:48:18.917667', '2018-05-27 03:48:18.917667', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 4, 'Mantequilla', '2018-05-27 03:48:31.68005', '2018-05-27 03:48:31.68005', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 4, 'Nata', '2018-05-27 03:48:50.924736', '2018-05-27 03:48:50.924736', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 6, 'Huevos', '2018-05-27 03:52:23.675324', '2018-05-27 03:52:23.675324', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 5, 'Lechuga', '2018-05-27 04:03:21.896934', '2018-05-27 04:03:21.896934', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 5, 'Tomate', '2018-05-27 04:04:08.434577', '2018-05-27 04:04:08.434577', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 5, 'Batata', '2018-05-27 04:04:33.081413', '2018-05-27 04:04:33.081413', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 5, 'Aguacate', '2018-05-27 04:05:37.658187', '2018-05-27 04:05:37.658187', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 5, 'Papa', '2018-05-27 04:07:48.055127', '2018-05-27 04:07:48.055127', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 5, 'Apio', '2018-05-27 04:08:51.834302', '2018-05-27 04:08:51.834302', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (46, 5, 'Berenjena', '2018-05-27 04:09:16.951102', '2018-05-27 04:09:16.951102', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (47, 5, 'Pepino', '2018-05-27 04:09:42.321526', '2018-05-27 04:09:42.321526', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (48, 5, 'Platano', '2018-05-27 04:10:02.648644', '2018-05-27 04:10:02.648644', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (49, 5, 'Coliflor', '2018-05-27 04:10:17.267081', '2018-05-27 04:10:17.267081', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (50, 5, 'Brocoli', '2018-05-27 04:10:37.2768', '2018-05-27 04:10:37.2768', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (51, 5, 'Yuca', '2018-05-27 04:11:01.127358', '2018-05-27 04:11:01.127358', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (52, 5, 'Calabac├¡n', '2018-05-27 04:12:10.798787', '2018-05-27 04:12:10.798787', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (53, 5, 'Zanahoria', '2018-05-27 04:16:09.83', '2018-05-27 04:16:09.83', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 5, 'Alcachofa', '2018-05-27 04:18:04.92318', '2018-05-27 04:18:04.92318', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 5, 'Espinaca', '2018-05-27 04:18:55.649164', '2018-05-27 04:18:55.649164', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 5, 'Cebolla', '2018-05-27 04:19:06.716437', '2018-05-27 04:19:06.716437', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 5, 'Pimenton', '2018-05-27 04:19:37.449059', '2018-05-27 04:19:37.449059', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 5, 'Remolacha', '2018-05-27 04:20:07.652248', '2018-05-27 04:20:07.652248', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 5, 'Champi├▒on', '2018-05-27 04:22:07.065679', '2018-05-27 04:22:07.065679', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (60, 7, 'Salmon', '2018-05-27 04:25:39.887667', '2018-05-27 04:25:39.887667', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (61, 7, 'Merluza', '2018-05-27 04:25:51.459915', '2018-05-27 04:25:51.459915', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (62, 7, 'Rodaballo', '2018-05-27 04:27:32.014', '2018-05-27 04:27:32.014', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (63, 7, 'Bacalao', '2018-05-27 04:28:42.753681', '2018-05-27 04:28:42.753681', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (64, 7, 'Lenguado', '2018-05-27 04:29:17.113974', '2018-05-27 04:29:17.113974', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (65, 7, 'Sardina', '2018-05-27 04:29:27.491767', '2018-05-27 04:29:27.491767', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (66, 7, 'At├║n', '2018-05-27 04:30:00.368004', '2018-05-27 04:30:00.368004', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (67, 7, 'Trucha', '2018-05-27 04:30:28.093096', '2018-05-27 04:30:28.093096', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (68, 7, 'Anchoa', '2018-05-27 04:31:32.463682', '2018-05-27 04:31:32.463682', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (69, 8, 'Coco', '2018-05-27 04:33:57.585896', '2018-05-27 04:33:57.585896', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (70, 8, 'Oliva', '2018-05-27 04:34:09.64023', '2018-05-27 04:34:09.64023', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (71, 8, 'Ma├¡z', '2018-05-27 04:34:27.151036', '2018-05-27 04:34:27.151036', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (72, 5, 'Ma├¡z', '2018-05-27 04:34:42.433921', '2018-05-27 04:34:42.433921', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (73, 8, 'Soya', '2018-05-27 04:39:10.780517', '2018-05-27 04:39:10.780517', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (75, 8, 'Girasol', '2018-05-27 04:41:30.962307', '2018-05-27 04:41:30.962307', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (74, 8, 'Palma', '2018-05-27 04:40:37.156', '2018-05-27 04:40:37.156', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (76, 9, 'Gelatina', '2018-05-27 05:12:43.626523', '2018-05-27 05:12:43.626523', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (77, 9, 'Pud├¡n', '2018-05-27 06:54:22.006357', '2018-05-27 06:54:22.006357', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (79, 6, 'Carne roja', '2018-05-27 06:58:14.727673', '2018-05-27 06:58:14.727673', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (78, 6, 'Carne blanca', '2018-05-27 06:55:31.294', '2018-05-27 06:55:31.294', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 5, 'Auyama', '2018-05-27 04:05:17.155', '2018-05-27 04:05:17.155', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (80, 3, 'Ciruela', '2018-06-04 01:19:16.24948', '2018-06-04 01:19:16.24948', 1);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (81, 2, 'Fororo', '2018-06-06 02:26:12.566', '2018-06-06 02:26:12.566', 0);
INSERT INTO public.alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (82, 2, 'Fororo', '2018-06-06 02:30:19.66', '2018-06-06 02:30:19.66', 1);


--
-- Data for Name: app_movil; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ayuda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, '┬┐Para calcular bien el IMC hay que tomar en cuenta la edad?', 'El IMC (├¡ndice de masa corporal) es un dato objetivo independiente de la edad puesto que es la relaci├│n entre la masa corporal de una persona y su estatura, y se calcula dividiendo el peso en kilogramos por la talla en metros elevada al cuadrado.', '2018-05-27 06:19:19.600866', '2018-05-27 06:19:19.600866', 1);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, ' ┬┐Como puedo ver el plan que me fue asignado?', ' Debes ingresar en la opci├│n del men├║ Mi Plan', '2018-05-27 06:29:00.95743', '2018-05-27 06:29:00.95743', 1);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, '┬┐Como puedo reclamar mi servicio? ', 'Localiza tu servicio activo y luego selecciona la opci├│n reclamar en la aplicaci├│n m├│vil', '2018-05-27 06:46:47.777333', '2018-05-27 06:46:47.777333', 1);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Como puedo reclamar mi servicio? ', 'Localiza tu servicio activo y luego selecciona la opci├│n reclamar en la aplicaci├│n m├│vil', '2018-05-27 06:45:51.415', '2018-05-27 06:45:51.415', 0);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, ' ┬┐Por qu├® decimos que es tan bueno comer fruta?', 'Las frutas son ricas en nutrientes, vitaminas y minerales, de ah├¡ que se incluyan dentro de nuestra base de la alimentaci├│n y que se recomiende consumir entre 3 y 5 piezas al d├¡a. ', '2018-05-27 06:54:44.787987', '2018-05-27 06:54:44.787987', 1);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, '┬┐Como puedo solicitar un servicio?', ' Suscribete a Sascha y descarga la app, una vez dentro selecciona la opci├│n Solicitar Servicio', '2018-05-27 07:10:32.090211', '2018-05-27 07:10:32.090211', 1);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, '┬┐C├│mo puedo valorar mi servicio?', 'Entra en Mi Evolucion/Visitas y ver├ís una tarjeta que dice "Valora tu Servicio"', '2018-06-05 04:32:14.513887', '2018-06-05 04:32:14.513887', 1);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 'asasasa', 'asasa', '2018-06-06 01:10:04.066', '2018-06-06 01:10:04.066', 0);
INSERT INTO public.ayuda (id_ayuda, pregunta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, ' asasasa', ' ', '2018-06-06 01:10:24.896081', '2018-06-06 01:10:24.896081', 1);


--
-- Data for Name: bloque_horario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, '08:00:00', '09:00:00', '2018-05-27 03:27:33.85132+00', '2018-05-27 03:27:33.85132', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, '10:00:00', '11:00:00', '2018-05-27 03:30:12.363654+00', '2018-05-27 03:30:12.363654', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, '11:00:00', '12:00:00', '2018-05-27 03:31:57.860889+00', '2018-05-27 03:31:57.860889', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, '09:00:00', '10:00:00', '2018-05-27 03:45:39.446049+00', '2018-05-27 03:45:39.446049', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, '12:00:00', '13:00:00', '2018-05-27 03:46:57.141281+00', '2018-05-27 03:46:57.141281', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, '13:00:00', '14:00:00', '2018-05-27 03:47:21.402429+00', '2018-05-27 03:47:21.402429', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, '14:00:00', '15:00:00', '2018-05-27 03:53:59.427963+00', '2018-05-27 03:53:59.427963', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, '15:00:00', '16:00:00', '2018-05-27 03:54:54.476942+00', '2018-05-27 03:54:54.476942', 1);
INSERT INTO public.bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, '16:00:00', '17:00:00', '2018-05-27 03:55:39.334537+00', '2018-05-27 03:55:39.334537', 1);


--
-- Data for Name: calificacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 1, NULL, '2018-06-03 18:26:28.187819', '2018-06-03 18:26:28.187819', 1, 9, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 1, NULL, '2018-06-03 18:26:28.187819', '2018-06-03 18:26:28.187819', 1, 10, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 2, NULL, '2018-06-03 18:28:19.418845', '2018-06-03 18:28:19.418845', 1, 13, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 2, NULL, '2018-06-03 18:28:19.418845', '2018-06-03 18:28:19.418845', 1, 14, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 7, NULL, '2018-06-03 18:29:34.978631', '2018-06-03 18:29:34.978631', 1, 15, 7);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 7, NULL, '2018-06-03 18:29:34.978631', '2018-06-03 18:29:34.978631', 1, 16, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 8, NULL, '2018-06-03 18:30:13.561638', '2018-06-03 18:30:13.561638', 1, 19, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 8, NULL, '2018-06-03 18:30:13.561638', '2018-06-03 18:30:13.561638', 1, 20, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 2, '2018-06-03 18:37:16.398315', '2018-06-03 18:37:16.398315', 1, 23, 5);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 2, '2018-06-03 18:37:16.398315', '2018-06-03 18:37:16.398315', 1, 24, 4);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 12, '2018-06-03 18:37:58.670875', '2018-06-03 18:37:58.670875', 1, 25, 3);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 12, '2018-06-03 18:37:58.670875', '2018-06-03 18:37:58.670875', 1, 26, 4);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 53, NULL, '2018-06-05 02:24:06.779932', '2018-06-05 02:24:06.779932', 1, 27, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 53, NULL, '2018-06-05 02:24:06.779932', '2018-06-05 02:24:06.779932', 1, 28, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 55, NULL, '2018-06-05 03:04:23.545042', '2018-06-05 03:04:23.545042', 1, 29, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 55, NULL, '2018-06-05 03:04:23.545042', '2018-06-05 03:04:23.545042', 1, 30, 7);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 56, NULL, '2018-06-05 03:38:50.736302', '2018-06-05 03:38:50.736302', 1, 31, 16);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 56, NULL, '2018-06-05 03:38:50.736302', '2018-06-05 03:38:50.736302', 1, 32, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 20, '2018-06-05 05:59:30.549842', '2018-06-05 05:59:30.549842', 1, 33, 3);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 20, '2018-06-05 05:59:30.549842', '2018-06-05 05:59:30.549842', 1, 34, 3);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 57, NULL, '2018-06-05 06:03:09.761522', '2018-06-05 06:03:09.761522', 1, 35, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 57, NULL, '2018-06-05 06:03:09.761522', '2018-06-05 06:03:09.761522', 1, 36, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 58, NULL, '2018-06-05 06:27:07.120046', '2018-06-05 06:27:07.120046', 1, 37, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 58, NULL, '2018-06-05 06:27:07.120046', '2018-06-05 06:27:07.120046', 1, 38, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 59, NULL, '2018-06-05 07:44:35.677886', '2018-06-05 07:44:35.677886', 1, 39, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 59, NULL, '2018-06-05 07:44:35.677886', '2018-06-05 07:44:35.677886', 1, 40, 7);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 60, NULL, '2018-06-05 07:52:11.672173', '2018-06-05 07:52:11.672173', 1, 41, 7);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 60, NULL, '2018-06-05 07:52:11.672173', '2018-06-05 07:52:11.672173', 1, 42, 16);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 61, NULL, '2018-06-05 07:55:32.619126', '2018-06-05 07:55:32.619126', 1, 43, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 61, NULL, '2018-06-05 07:55:32.619126', '2018-06-05 07:55:32.619126', 1, 44, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 62, NULL, '2018-06-05 08:09:13.3243', '2018-06-05 08:09:13.3243', 1, 45, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 62, NULL, '2018-06-05 08:09:13.3243', '2018-06-05 08:09:13.3243', 1, 46, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 46, '2018-06-05 08:24:03.594633', '2018-06-05 08:24:03.594633', 1, 47, 4);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 46, '2018-06-05 08:24:03.594633', '2018-06-05 08:24:03.594633', 1, 48, 3);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 64, NULL, '2018-06-05 09:30:18.614436', '2018-06-05 09:30:18.614436', 1, 49, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 64, NULL, '2018-06-05 09:30:18.614436', '2018-06-05 09:30:18.614436', 1, 50, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 65, NULL, '2018-06-05 09:30:49.008388', '2018-06-05 09:30:49.008388', 1, 51, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 65, NULL, '2018-06-05 09:30:49.008388', '2018-06-05 09:30:49.008388', 1, 52, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 48, '2018-06-05 09:36:20.885118', '2018-06-05 09:36:20.885118', 1, 53, 4);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 48, '2018-06-05 09:36:20.885118', '2018-06-05 09:36:20.885118', 1, 54, 4);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 9, NULL, '2018-06-05 10:24:16.01546', '2018-06-05 10:24:16.01546', 1, 55, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 9, NULL, '2018-06-05 10:24:16.01546', '2018-06-05 10:24:16.01546', 1, 56, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 67, NULL, '2018-06-05 10:51:14.757211', '2018-06-05 10:51:14.757211', 1, 57, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 67, NULL, '2018-06-05 10:51:14.757211', '2018-06-05 10:51:14.757211', 1, 58, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 68, NULL, '2018-06-05 11:11:53.907297', '2018-06-05 11:11:53.907297', 1, 59, 6);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 68, NULL, '2018-06-05 11:11:53.907297', '2018-06-05 11:11:53.907297', 1, 60, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 69, NULL, '2018-06-05 11:12:13.077248', '2018-06-05 11:12:13.077248', 1, 61, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 69, NULL, '2018-06-05 11:12:13.077248', '2018-06-05 11:12:13.077248', 1, 62, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 49, '2018-06-05 11:12:49.449133', '2018-06-05 11:12:49.449133', 1, 63, 5);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 49, '2018-06-05 11:12:49.449133', '2018-06-05 11:12:49.449133', 1, 64, 5);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 71, NULL, '2018-06-06 00:40:24.956736', '2018-06-06 00:40:24.956736', 1, 65, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 71, NULL, '2018-06-06 00:40:24.956736', '2018-06-06 00:40:24.956736', 1, 66, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 72, NULL, '2018-06-06 02:40:23.421886', '2018-06-06 02:40:23.421886', 1, 67, 8);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 72, NULL, '2018-06-06 02:40:23.421886', '2018-06-06 02:40:23.421886', 1, 68, 16);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 55, '2018-06-06 02:40:54.726439', '2018-06-06 02:40:54.726439', 1, 69, 3);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 55, '2018-06-06 02:40:54.726439', '2018-06-06 02:40:54.726439', 1, 70, 4);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 73, NULL, '2018-06-06 03:17:46.890212', '2018-06-06 03:17:46.890212', 1, 71, 7);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 73, NULL, '2018-06-06 03:17:46.890212', '2018-06-06 03:17:46.890212', 1, 72, 16);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 57, '2018-06-06 03:18:06.63317', '2018-06-06 03:18:06.63317', 1, 73, 3);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 57, '2018-06-06 03:18:06.63317', '2018-06-06 03:18:06.63317', 1, 74, 15);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 28, NULL, '2018-06-06 03:41:42.844391', '2018-06-06 03:41:42.844391', 1, 75, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 28, NULL, '2018-06-06 03:41:42.844391', '2018-06-06 03:41:42.844391', 1, 76, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 74, NULL, '2018-06-06 04:46:23.795661', '2018-06-06 04:46:23.795661', 1, 77, 16);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (15, NULL, 62, '2018-06-06 04:46:36.774441', '2018-06-06 04:46:36.774441', 1, 78, 14);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (13, NULL, 62, '2018-06-06 04:46:36.774441', '2018-06-06 04:46:36.774441', 1, 79, 14);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (16, 76, NULL, '2018-06-06 05:09:03.430058', '2018-06-06 05:09:03.430058', 1, 80, 17);
INSERT INTO public.calificacion (id_criterio, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion, id_valoracion) VALUES (14, 76, NULL, '2018-06-06 05:09:03.430058', '2018-06-06 05:09:03.430058', 1, 81, 17);


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 2, 1, 1, '2018-05-29', '2018-05-27 14:28:38.912499', '2018-05-27 14:28:38.912499', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 4, 1, 2, '2018-06-14', '2018-05-27 15:14:16.678696', '2018-05-27 15:14:16.678696', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 2, 2, 4, '2018-06-15', '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 2, 2, 4, '2018-07-20', '2018-05-27 16:07:50.332594', '2018-05-27 16:07:50.332594', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 3, 3, 3, '2018-06-05', '2018-05-27 14:43:27.654', '2018-05-27 14:43:27.654', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 5, 1, 2, '2018-05-30', '2018-05-27 18:21:13.531347', '2018-05-27 18:21:13.531347', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 5, 2, 2, '2018-06-06', '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 6, 1, 2, '2018-05-30', '2018-05-29 00:44:11.240641', '2018-05-29 00:44:11.240641', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 7, 1, 3, '2018-05-30', '2018-05-29 00:46:54.167265', '2018-05-29 00:46:54.167265', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 8, 1, 1, '2018-05-30', '2018-05-29 01:14:47.108441', '2018-05-29 01:14:47.108441', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 10, 1, 3, '2018-05-30', '2018-05-29 01:34:50.117839', '2018-05-29 01:34:50.117839', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 11, 1, 5, '2018-05-30', '2018-05-29 01:51:29.261905', '2018-05-29 01:51:29.261905', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 5, 2, 2, '2018-06-12', '2018-05-29 01:56:09.282494', '2018-05-29 01:56:09.282494', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 12, 1, 2, '2018-05-31', '2018-05-29 20:37:46.092464', '2018-05-29 20:37:46.092464', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 12, 2, 2, '2018-06-07', '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 12, 2, 3, '2018-06-21', '2018-05-29 21:11:50.521174', '2018-05-29 21:11:50.521174', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 14, 1, 2, '2018-06-05', '2018-05-30 19:41:00.311832', '2018-05-30 19:41:00.311832', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 15, 1, 4, '2018-05-30', '2018-05-30 19:45:17.097513', '2018-05-30 19:45:17.097513', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 16, 1, 3, '2018-06-06', '2018-05-30 19:49:05.950677', '2018-05-30 19:49:05.950677', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 17, 1, 1, '2018-06-06', '2018-05-30 19:55:01.86682', '2018-05-30 19:55:01.86682', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 18, 1, 2, '2018-06-06', '2018-05-30 20:12:43.998593', '2018-05-30 20:12:43.998593', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 20, 1, 2, '2018-06-01', '2018-05-30 20:28:05.812934', '2018-05-30 20:28:05.812934', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 21, 1, 1, '2018-06-01', '2018-05-30 20:38:46.023439', '2018-05-30 20:38:46.023439', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 22, 1, 2, '2018-06-01', '2018-05-30 20:47:23.921972', '2018-05-30 20:47:23.921972', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 23, 1, 3, '2018-06-01', '2018-05-30 20:59:07.481534', '2018-05-30 20:59:07.481534', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 24, 1, 6, '2018-05-31', '2018-05-30 21:55:35.692019', '2018-05-30 21:55:35.692019', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 25, 1, 4, '2018-05-31', '2018-05-30 22:01:13.244598', '2018-05-30 22:01:13.244598', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 24, 2, 4, '2018-06-06', '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 26, 1, 5, '2018-05-31', '2018-05-31 07:16:47.582042', '2018-05-31 07:16:47.582042', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 27, 1, 7, '2018-05-31', '2018-05-31 08:18:37.936665', '2018-05-31 08:18:37.936665', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 15, 2, 8, '2018-05-31', '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 24, 2, 5, '2018-05-31', '2018-05-31 11:02:01.399888', '2018-05-31 11:02:01.399888', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 24, 2, 4, '2018-06-27', '2018-05-31 11:03:47.758069', '2018-05-31 11:03:47.758069', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 28, 1, 2, '2018-05-31', '2018-05-31 11:40:05.155587', '2018-05-31 11:40:05.155587', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 26, 2, 3, '2018-06-05', '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 27, 2, 3, '2018-06-01', '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 25, 2, 2, '2018-07-04', '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 9, 3, 2, '2018-05-30', '2018-05-29 01:18:36.565', '2018-05-29 01:18:36.565', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 13, 3, 1, '2018-05-30', '2018-05-30 19:35:26.143', '2018-05-30 19:35:26.143', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 29, 1, 4, '2018-06-01', '2018-06-01 07:12:29.375298', '2018-06-01 07:12:29.375298', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 30, 1, 8, '2018-06-01', '2018-06-01 07:50:39.640549', '2018-06-01 07:50:39.640549', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 30, 2, 7, '2018-06-09', '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 31, 1, 7, '2018-06-01', '2018-06-01 13:27:56.268999', '2018-06-01 13:27:56.268999', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 31, 2, 7, '2018-06-08', '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 31, 2, 3, '2018-06-14', '2018-06-01 13:47:27.831542', '2018-06-01 13:47:27.831542', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 31, 2, 8, '2018-06-15', '2018-06-01 13:59:46.532712', '2018-06-01 13:59:46.532712', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 6, 2, 2, '2018-06-06', '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 16, 2, 2, '2018-06-20', '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 15, 2, 3, '2018-07-12', '2018-06-01 22:32:10.973988', '2018-06-01 22:32:10.973988', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (60, 26, 2, 8, '2018-06-08', '2018-06-01 22:59:39.774842', '2018-06-01 22:59:39.774842', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (62, 24, 2, 2, '2018-06-13', '2018-06-03 06:19:56.632807', '2018-06-03 06:19:56.632807', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (63, 37, 1, 4, '2018-06-12', '2018-06-03 22:42:51.297514', '2018-06-03 22:42:51.297514', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (64, 38, 1, 5, '2018-06-19', '2018-06-03 22:59:39.418328', '2018-06-03 22:59:39.418328', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (65, 39, 1, 3, '2018-06-21', '2018-06-04 00:49:00.953408', '2018-06-04 00:49:00.953408', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (66, 14, 2, 3, '2018-06-07', '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (67, 8, 2, 5, '2018-06-07', '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (68, 7, 2, 1, '2018-05-31', '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (69, 10, 2, 2, '2018-05-31', '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (70, 11, 2, 4, '2018-06-14', '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (71, 17, 2, 9, '2018-06-09', '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (72, 18, 2, 6, '2018-06-08', '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (73, 18, 2, 5, '2018-06-12', '2018-06-04 07:45:57.75244', '2018-06-04 07:45:57.75244', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (74, 30, 2, 4, '2018-06-13', '2018-06-04 07:48:20.813483', '2018-06-04 07:48:20.813483', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (75, 17, 2, 9, '2018-06-16', '2018-06-04 07:49:26.509683', '2018-06-04 07:49:26.509683', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (76, 11, 2, 7, '2018-06-15', '2018-06-04 07:54:10.223961', '2018-06-04 07:54:10.223961', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (77, 16, 2, 5, '2018-06-21', '2018-06-04 07:55:44.276057', '2018-06-04 07:55:44.276057', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (78, 43, 1, 1, '2018-06-05', '2018-06-04 11:48:07.755443', '2018-06-04 11:48:07.755443', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (79, 44, 1, 2, '2018-06-14', '2018-06-04 13:38:16.74193', '2018-06-04 13:38:16.74193', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (81, 20, 2, 1, '2018-06-07', '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 19, 3, 1, '2018-06-01', '2018-05-30 20:23:18.607', '2018-05-30 20:23:18.607', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (83, 7, 2, 2, '2018-06-13', '2018-06-05 02:39:03.229541', '2018-06-05 02:39:03.229541', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (84, 20, 2, 3, '2018-06-08', '2018-06-05 02:46:11.00669', '2018-06-05 02:46:11.00669', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (85, 46, 1, 2, '2018-06-05', '2018-06-05 04:11:37.388533', '2018-06-05 04:11:37.388533', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (86, 46, 2, 5, '2018-06-15', '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (87, 47, 1, 5, '2018-06-21', '2018-06-05 06:01:37.784926', '2018-06-05 06:01:37.784926', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (88, 46, 2, 6, '2018-06-22', '2018-06-05 06:05:49.81802', '2018-06-05 06:05:49.81802', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (89, 46, 2, 7, '2018-06-29', '2018-06-05 06:16:57.771066', '2018-06-05 06:16:57.771066', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (90, 47, 2, 3, '2018-07-19', '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (91, 47, 2, 2, '2018-07-24', '2018-06-05 07:45:17.60096', '2018-06-05 07:45:17.60096', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (92, 48, 1, 2, '2018-06-05', '2018-06-05 08:42:37.542818', '2018-06-05 08:42:37.542818', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (93, 48, 2, 3, '2018-06-07', '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (94, 48, 2, 2, '2018-06-15', '2018-06-05 09:25:04.904924', '2018-06-05 09:25:04.904924', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (95, 49, 1, 2, '2018-06-08', '2018-06-05 09:46:30.430025', '2018-06-05 09:46:30.430025', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (96, 49, 2, 2, '2018-06-19', '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (97, 49, 2, 3, '2018-06-22', '2018-06-05 10:52:46.301159', '2018-06-05 10:52:46.301159', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (98, 43, 2, 3, '2018-06-15', '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (99, 50, 1, 5, '2018-06-20', '2018-06-05 17:05:39.950113', '2018-06-05 17:05:39.950113', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (82, 45, 3, 2, '2018-06-06', '2018-06-05 01:10:14.699', '2018-06-05 01:10:14.699', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (100, 51, 1, 8, '2018-06-08', '2018-06-05 20:33:46.433739', '2018-06-05 20:33:46.433739', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (101, 24, 2, 5, '2018-06-22', '2018-06-05 21:01:40.561131', '2018-06-05 21:01:40.561131', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (102, 52, 1, 1, '2018-06-19', '2018-06-05 21:16:59.072292', '2018-06-05 21:16:59.072292', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (103, 53, 1, 8, '2018-06-29', '2018-06-05 22:48:49.922917', '2018-06-05 22:48:49.922917', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (104, 54, 1, 5, '2018-06-29', '2018-06-06 00:01:54.216693', '2018-06-06 00:01:54.216693', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (105, 55, 1, 3, '2018-07-03', '2018-06-06 00:22:47.783451', '2018-06-06 00:22:47.783451', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (106, 55, 2, 1, '2018-07-05', '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (107, 55, 3, 1, '2018-07-06', '2018-06-06 00:37:53.481', '2018-06-06 00:37:53.481', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (108, 56, 1, 4, '2018-07-31', '2018-06-06 02:44:15.71823', '2018-06-06 02:44:15.71823', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (109, 57, 1, 7, '2018-07-27', '2018-06-06 02:53:07.0047', '2018-06-06 02:53:07.0047', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (110, 57, 3, 2, '2018-07-31', '2018-06-06 02:57:39.653', '2018-06-06 02:57:39.653', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (61, 24, 3, 4, '2018-06-05', '2018-06-03 05:43:13.904', '2018-06-03 05:43:13.904', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 28, 3, 4, '2018-06-08', '2018-05-31 11:45:38.064', '2018-05-31 11:45:38.064', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (115, 62, 1, 9, '2018-06-08', '2018-06-06 03:55:51.548749', '2018-06-06 03:55:51.548749', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (117, 62, 3, 2, '2018-07-05', '2018-06-06 04:15:17.561', '2018-06-06 04:15:17.561', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (118, 63, 1, 4, '2018-06-29', '2018-06-06 04:47:31.727616', '2018-06-06 04:47:31.727616', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (120, 63, 3, 2, '2018-08-01', '2018-06-06 04:55:27.563', '2018-06-06 04:55:27.563', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (121, 63, 2, 3, '2018-07-19', '2018-06-06 05:00:11.407749', '2018-06-06 05:00:11.407749', 1);
INSERT INTO public.cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) VALUES (122, 64, 1, 2, '2018-06-27', '2018-06-06 14:48:39.764145', '2018-06-06 14:48:39.764145', 1);


--
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 1, 2, 1, 3, '22323291', 'Nury', 'Amaro', '04141234567', 'Calle 1', '1995-10-05', 1, NULL, '2018-05-27 02:28:28.041404', '2018-05-27 02:28:28.041404', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 2, 2, 1, 3, '23484708', 'Magdaly', 'Atacho', '04241234567', 'Calle 2', '1994-01-02', 1, NULL, '2018-05-27 02:33:53.014106', '2018-05-27 02:33:53.014106', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 3, 1, 1, 3, '22270191', 'Valmore', 'Canelon', '04143456789', 'Cabudare', '1994-03-06', 1, NULL, '2018-05-27 02:36:27.542244', '2018-05-27 02:36:27.542244', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 4, 1, 1, 3, '19827297', 'Rhonal', 'Chirinos', '04142345678', 'Calle 19', '1990-03-07', 1, NULL, '2018-05-27 02:40:49.998144', '2018-05-27 02:40:49.998144', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 5, 2, 1, 3, '22329125', 'Conni', 'Duarte', '04121234567', 'Carrera 15 con calle 50', '1995-02-01', 1, NULL, '2018-05-27 02:43:43.707956', '2018-05-27 02:43:43.707956', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 6, 2, 1, 3, '23482323', 'Yuri', 'Freitez', '04144567890', 'Quibor', '1992-05-10', 1, NULL, '2018-05-27 02:45:31.454609', '2018-05-27 02:45:31.454609', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 7, 2, 1, 3, '23549519', 'Wualter', '', '04143456789', 'Calle 19 entre carreras 42 y 43', '1994-02-01', 1, NULL, '2018-05-27 02:47:49.532789', '2018-05-27 02:47:49.532789', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 8, 2, 1, 3, '22263583', 'Jaimary', '', '04145678123', 'Residencias Arco iris', '1995-09-08', 1, NULL, '2018-05-27 02:50:09.183388', '2018-05-27 02:50:09.183388', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 9, 2, 1, 3, '24159026', 'Jose', 'Rodriguez', '04142345629', 'Residencias Taha', '1994-09-07', 1, NULL, '2018-05-27 02:52:12.637335', '2018-05-27 02:52:12.637335', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 10, 2, 1, 3, '23489072', 'Marianceli', 'Subero', '04145436789', 'Cabudare', '1993-07-05', 1, NULL, '2018-05-27 02:54:29.307968', '2018-05-27 02:54:29.307968', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 11, 1, 1, 3, '19572137', 'Kenderson', 'Torrealba', '04143452678', 'Carrera 18 con calle 15', '1991-12-04', 1, NULL, '2018-05-27 02:56:36.410331', '2018-05-27 02:56:36.410331', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 12, 1, 1, 3, '23508485', 'Richard', 'Velasquez', '04243456789', 'Cabudare', '1995-01-03', 1, NULL, '2018-05-27 02:58:36.943664', '2018-05-27 02:58:36.943664', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 13, 2, 1, 4, '17308743', 'Yorneydis', 'Vivas', '04245738359', 'El Manzano', '1985-12-06', 1, NULL, '2018-05-27 03:01:41.806896', '2018-05-27 03:01:41.806896', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 14, 1, 1, 3, '23010230', 'Ruben', 'Alvarado', '04245546642', 'Barinas', '1995-10-06', 1, NULL, '2018-05-27 03:03:56.144299', '2018-05-27 03:03:56.144299', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 15, 1, 1, 3, '20467471', 'Ivan', 'Brice├▒o', '04261179621', 'Yaracuy', '1995-09-06', 1, NULL, '2018-05-27 03:05:44.092337', '2018-05-27 03:05:44.092337', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 16, 1, 1, 3, '24142636', 'Orlando', 'Cuervo', '04245711543', 'Av Los Leones', '1994-06-04', 1, NULL, '2018-05-27 03:07:50.852588', '2018-05-27 03:07:50.852588', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 17, 2, 1, 3, '16861581', 'Desiree', 'Dorantes', '04245379818', 'Residencias Las Do├▒as', '1990-09-10', 1, NULL, '2018-05-27 03:10:14.91612', '2018-05-27 03:10:14.91612', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 18, 2, 1, 3, '22316470', 'Austria', 'Loyo Villalobos', '04143732956', 'Urb La Solana', '1994-01-11', 1, NULL, '2018-05-27 03:12:48.422966', '2018-05-27 03:12:48.422966', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 19, 2, 1, 3, '20926496', 'Edarling', 'Mendoza', '04263589183', 'Av La Salle', '1994-12-04', 1, NULL, '2018-05-27 03:15:06.694285', '2018-05-27 03:15:06.694285', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 20, 1, 1, 3, '21506424', 'Luis David', 'Orozco', '04243462251', 'Residencias Arca del Norte', '1992-02-04', 1, NULL, '2018-05-27 03:18:17.991151', '2018-05-27 03:18:17.991151', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 21, 1, 1, 3, '23918174', 'Julio Cesar', 'Paredes', '04145109825', 'Calle 20 Pueblo Nuevo', '1995-05-12', 1, NULL, '2018-05-27 03:22:16.690062', '2018-05-27 03:22:16.690062', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 22, 1, 1, 3, '23918174', 'Julio Cesar', 'Paredes', '04145109825', 'Calle 20 Pueblo Nuevo', '1995-05-12', 1, NULL, '2018-05-27 03:22:18.001364', '2018-05-27 03:22:18.001364', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 23, 2, 3, 3, '19455044', 'Josmary', 'Pulgar', '04121512632', 'Calle 50 con carrera 15', '1988-05-26', 1, NULL, '2018-05-27 03:25:28.729874', '2018-05-27 03:25:28.729874', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 24, 2, 3, 3, '23706880', 'Yosbely', 'Ramos', '04245657120', 'Urb San Felix', '1995-09-26', 1, NULL, '2018-05-27 03:27:37.264777', '2018-05-27 03:27:37.264777', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 25, 2, 4, 3, '20924092', 'Mayed', 'Salas Castillo', '04245224568', 'Residencias Yucatan', '1992-07-22', 1, NULL, '2018-05-27 03:30:05.831327', '2018-05-27 03:30:05.831327', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 27, 2, 3, 3, '20009568', 'Gessimar', 'Yagua', '04160364354', 'El Tocuyo', '1990-07-22', 1, NULL, '2018-05-27 03:34:57.503012', '2018-05-27 03:34:57.503012', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 28, 2, 1, 3, '24339727', 'Karem', 'Alvarado', '04263075234', 'Calle 8 con carrera 19', '1994-09-20', 1, NULL, '2018-05-27 03:37:12.098882', '2018-05-27 03:37:12.098882', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 26, 1, 3, 3, '23815460', 'Francisco', 'Velasquez', '04120716866', 'Cabudare', '1994-03-15', 1, NULL, '2018-05-27 03:32:17.741', '2018-05-27 03:32:17.741', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 29, 2, 1, 3, '23487734', 'Ana Victoria', 'De Palma', '04245344747', 'Residencias Don Felix', '1995-08-29', 1, NULL, '2018-05-27 03:39:24.341825', '2018-05-27 03:39:24.341825', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 30, 1, 3, 3, '22316437', 'Abdel', 'Gainza', '04163577290', 'San Felipe Yaracuy', '1994-01-20', 1, NULL, '2018-05-27 03:41:32.468809', '2018-05-27 03:41:32.468809', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 31, 1, 3, 3, '24160052', 'Jose Alberto', 'Guerrero', '04145495292', 'Cabudare', '1995-03-22', 1, NULL, '2018-05-27 03:43:39.412549', '2018-05-27 03:43:39.412549', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 32, 2, 1, 3, '22181168', 'Brisleidy', 'Lugo Mujica', '04126797150', 'Urb Fundalara', '1994-05-14', 1, NULL, '2018-05-27 03:45:43.919328', '2018-05-27 03:45:43.919328', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 33, 2, 1, 3, '14399538', 'Hilmary', 'Nieto', '04126702000', 'Urb Los Crepusculos', '1990-09-12', 1, NULL, '2018-05-27 03:47:14.035393', '2018-05-27 03:47:14.035393', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 34, 1, 1, 3, '22272210', 'Pedro', 'Orellana', '04268565880', 'Cabudare', '1994-06-18', 1, NULL, '2018-05-27 03:49:19.941986', '2018-05-27 03:49:19.941986', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 35, 2, 1, 3, '21302860', 'Gabriela', 'Perez', '04145573793', 'Av Libertador', '1992-08-30', 1, NULL, '2018-05-27 03:51:05.234844', '2018-05-27 03:51:05.234844', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 38, 1, 2, 3, '20666187', 'Luis Enrique', 'Puerta', '0426-4585193', 'Calle 42', '1993-04-20', 1, NULL, '2018-05-27 03:57:31.488912', '2018-05-27 03:57:31.488912', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 39, 2, 2, 3, '24164375', 'Skarly', 'Ruiz Marquez', '04121507528', 'Calle 8', '1994-03-20', 1, NULL, '2018-05-27 04:00:14.83273', '2018-05-27 04:00:14.83273', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 40, 1, 2, 3, '22200900', 'Jose', 'Silva Graterol', '04245271275', 'Av Las Industrias', '1994-01-24', 1, NULL, '2018-05-27 04:02:43.473847', '2018-05-27 04:02:43.473847', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 41, 1, 2, 3, '21459681', 'Ricardo Amin', 'Abunassar', '04145085073', 'Urb La Rosaleda', '1994-07-20', 1, NULL, '2018-05-27 04:05:45.175211', '2018-05-27 04:05:45.175211', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 42, 1, 1, 3, '20188775', 'Juan Carlos', 'Aldana', '04168564038', 'Calle 20', '1995-08-18', 1, NULL, '2018-05-27 04:07:49.747979', '2018-05-27 04:07:49.747979', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 43, 2, 1, 3, '20351780', 'Sohecdy', 'ALvarado', '04245292303', 'Av La Salle', '1992-06-20', 1, NULL, '2018-05-27 04:09:33.294028', '2018-05-27 04:09:33.294028', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 44, 2, 1, 3, '24141340', 'Maria Nathali', 'Anzola', '04145098957', 'Cabudare', '1995-06-03', 1, NULL, '2018-05-27 04:12:04.793958', '2018-05-27 04:12:04.793958', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 45, 1, 1, 4, '19591753', 'Ruben', 'Bello', '02514468097', 'Av Venezuela', '1986-06-18', 1, NULL, '2018-05-27 04:14:18.93636', '2018-05-27 04:14:18.93636', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (46, 46, 1, 1, 3, '21125820', 'Jose Alfredo', 'Encinoza', '04266549556', 'Calle 38', '1994-12-12', 1, NULL, '2018-05-27 04:16:48.228753', '2018-05-27 04:16:48.228753', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (47, 47, 1, 1, 3, '23481367', 'Javier', 'Escalona', '02514480778', 'Av Vargas', '1995-11-25', 1, NULL, '2018-05-27 04:18:47.243397', '2018-05-27 04:18:47.243397', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (48, 48, 2, 1, 3, '20924368', 'Laurymar', 'Luque', '04265542041', 'Barrio El Carmen', '1992-05-30', 1, NULL, '2018-05-27 04:21:39.036227', '2018-05-27 04:21:39.036227', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (49, 49, 2, 1, 3, '22271356', 'Joselyn', 'Serrano', '04123004727', 'Calle 15', '1994-07-24', 1, NULL, '2018-05-27 04:24:16.233937', '2018-05-27 04:24:16.233937', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (50, 50, 1, 2, 3, '22025994', 'Jose', 'Vaamonde', '04269529774', 'Av Las Industrias', '1993-04-09', 1, NULL, '2018-05-27 04:26:17.325275', '2018-05-27 04:26:17.325275', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (51, 51, 2, 4, 4, '16749974', 'Rocio', 'Vargas', '04145130203', 'Av Los Horcones', '1984-03-12', 1, NULL, '2018-05-27 04:28:56.856793', '2018-05-27 04:28:56.856793', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (52, 52, 1, 1, 3, '22316644', 'Yanior', 'Zambrano', '04126793611', 'Residencias Cristal', '1993-04-25', 1, NULL, '2018-05-27 04:31:09.732585', '2018-05-27 04:31:09.732585', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (53, 53, 1, 1, 3, '17654321', 'Luis', 'Alvarado', '04140710100', 'El Tocuyo', '1992-09-09', 1, NULL, '2018-05-27 04:33:02.930308', '2018-05-27 04:33:02.930308', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 58, 2, 3, 4, 'v-22202319', 'Maria Franchezka', 'Perez Sanchez', '04260561381', 'Urb El Sisal Av casa numero 75', '1986-05-02', 1, NULL, '2018-05-27 16:13:53.57097', '2018-05-27 16:13:53.57097', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 60, 2, 3, 4, '12345678', 'Sascha', 'Barboza', '0231232422', 'Miami', '1986-08-24', 1, NULL, '2018-05-31 11:36:45.14389', '2018-05-31 11:36:45.14389', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 61, 2, 1, 3, '7460769', 'belinda', 'Riera', '04121540000', 'Carrera 23 entre calles 8 y 9', '1990-08-11', 1, NULL, '2018-06-01 07:29:58.050532', '2018-06-01 07:29:58.050532', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 63, 1, 3, 4, '112232344', 'Manuel', 'Crespo', '04122346574', 'Carrera 23 con calle 4', '1982-02-23', 1, NULL, '2018-06-01 13:17:22.392646', '2018-06-01 13:17:22.392646', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 62, 1, 3, 4, '112232344', 'Manuel de jesus', 'Crespo', '04122346574', 'Carrera 23 con calle 4', '1982-02-23', 1, NULL, '2018-06-01 13:17:20.926', '2018-06-01 13:17:20.926', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 36, 2, 1, 3, '20268748', 'Indira', 'Perez Flores', '04269442200', 'Residencias Cristal', '1994-10-23', 1, NULL, '2018-05-27 03:52:58.349', '2018-05-27 03:52:58.349', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 37, 2, 1, 3, '19727835', 'Leonardo', 'Pineda', '0424-5042292', 'El Carmen calle 5', '1992-05-13', 1, NULL, '2018-05-27 03:55:22.851', '2018-05-27 03:55:22.851', 1);
INSERT INTO public.cliente (id_cliente, id_usuario, id_genero, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 64, 2, 3, 4, '29493248', 'Yerika', 'Gil', '01412345656', 'Argentina', '1985-08-19', 1, NULL, '2018-06-05 08:34:06.222761', '2018-06-05 08:34:06.222761', 1);


--
-- Data for Name: comentario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (21, 54, 11, 'Me encanto el servicio', 'Nos encanta tener clientes felices', '2018-05-29 23:15:46.249', '2018-05-29 23:15:46.249', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (20, 54, 14, 'Hacen un excelente trabajo', 'Nos encanta atenderte', '2018-05-29 22:51:44.796', '2018-05-29 22:51:44.796', 1, 36);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (15, 33, 11, 'Me encanta el servicio', 'Tu comentario es valioso para nuestro crecimiento', '2018-05-28 21:21:09.094', '2018-05-28 21:21:09.094', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (34, 17, 14, 'excelente', 'Nos encanta satisfacer a nuestros clientes.', '2018-05-30 20:23:52.832', '2018-05-30 20:23:52.832', 1, 36);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (35, 18, 8, 'necesitan un plan para personas jovenes', 'su opini├│n es importante.', '2018-05-30 20:26:58.888', '2018-05-30 20:26:58.888', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (16, 33, 11, 'Excelente atenci├│n, sigan trabajando asi.', 'Gracias por tus palabras Hilmary, esperamos que continues disfrutando de nuestros servicios', '2018-05-28 21:22:20.085', '2018-05-28 21:22:20.085', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (17, 33, 9, 'Deberian tener un plan para parejas', NULL, '2018-05-28 21:23:34.01', '2018-05-28 21:23:34.01', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (43, 56, 1, 'Crear los planes que sean mas apropiados a para mi salud', 'Belinda, tu sugerencia es valiosa para nosotros', '2018-06-01 08:11:17.327', '2018-06-01 08:11:17.327', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (26, 11, 10, 'recomendacion', 'Queremos mejorar nuestros servicios es por eso que tu recomendaci├│n sera tomada en cuenta', '2018-05-30 19:49:50.464', '2018-05-30 19:49:50.464', 1, 21);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (22, 7, 14, 'Felicidades!', 'dsfdsf', '2018-05-30 19:36:20.416', '2018-05-30 19:36:20.416', 1, 36);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (44, 57, 9, 'Agregar productos mas baratos', 'hhhhhhhhhhhhhhhhhhhhhhh', '2018-06-01 14:06:46.228', '2018-06-01 14:06:46.228', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (14, 48, 1, 'seria un novedoso servicio', NULL, '2018-05-27 19:15:08.248', '2018-05-27 19:15:08.248', 1, 21);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (13, 48, 7, 'no cumplieron con mi horario de atencion', 'Mil disculpas, trabajaremos para que no vuelva a suceder', '2018-05-27 19:14:24.63', '2018-05-27 19:14:24.63', 1, 18);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (11, 48, 2, 'no me informaron que debia reprogramar', NULL, '2018-05-27 19:13:23.714', '2018-05-27 19:13:23.714', 1, 3);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (12, 48, 7, 'el nutricionista es grosero', NULL, '2018-05-27 19:13:51.876', '2018-05-27 19:13:51.876', 1, 4);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (45, 25, 1, 'el plan para adelgazar deberia tener mas ejercicios  ', NULL, '2018-06-04 01:17:28.104', '2018-06-04 01:17:28.104', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (9, 49, 1, 'hagan una promocion', 'Lo tomaremos en cuenta, Joselyn', '2018-05-27 19:10:38.924', '2018-05-27 19:10:38.924', 1, 21);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (10, 49, 15, 'me parece que no me esta funcionando mi plan actual', 'puede hacerlo una vez el servicio sea valorado y proceda a solicitar un nuevo servicio acorde a sus necesidades', '2018-05-27 19:11:18.497', '2018-05-27 19:11:18.497', 1, 26);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (4, 53, 15, 'me recomendaron otro', 'Es recomendable que continu├® y culmine su servicio con el nutricionista seleccionado', '2018-05-27 19:04:46.504', '2018-05-27 19:04:46.504', 1, 19);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (2, 53, 2, 'La recepcionista fue grosera', 'Le daremos una repuesta que cubra las molestias ocacionadas', '2018-05-27 19:03:42.246', '2018-05-27 19:03:42.246', 1, 4);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (8, 49, 7, 'la recepcionista paso otro paciente cuando me tocaba a mi', 'Perdone atenderemos su queja.', '2018-05-27 19:10:07.465', '2018-05-27 19:10:07.465', 1, 18);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (6, 51, 1, 'agreguen este servicio', 'Tomaremos en cuenta su comentario.', '2018-05-27 19:07:14.069', '2018-05-27 19:07:14.069', 1, 21);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (23, 9, 12, 'Excelente servicio.', 'Nos encanta que te sientas conforme.', '2018-05-30 19:41:41.509', '2018-05-30 19:41:41.509', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (1, 30, 2, 'espere por una hora y el nutricionista no llego, ademas nadie me notifico la razon por la cual el nutricionista no asistio', 'Pedimos disculpas por las molestias ocacionadas', '2018-05-27 15:04:53.751', '2018-05-27 15:04:53.751', 1, 3);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (27, 12, 1, 'Necesitan un plan para parejas', 'tomaremos en cuenta su comentario', '2018-05-30 19:57:05.793', '2018-05-30 19:57:05.793', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (42, 23, 15, 'llevar examenes', 'Lo ideal seria que entregara sus resultados el dia que este programado.', '2018-05-31 10:53:15.043', '2018-05-31 10:53:15.043', 1, 28);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (24, 9, 2, 'No me avisaron', 'disculpes las molestias ocasionadas.', '2018-05-30 19:42:45.497', '2018-05-30 19:42:45.497', 1, 3);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (40, 23, 11, 'me encanta el servicio', 'Nos encanta servirte.', '2018-05-31 10:16:04.785', '2018-05-31 10:16:04.785', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (38, 33, 11, 'Excelente servicio', 'Nos encanta servirte.', '2018-05-31 02:00:03.583', '2018-05-31 02:00:03.583', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (36, 20, 14, 'buen servicio', 'Nos encanta servirte.', '2018-05-30 20:53:26.785', '2018-05-30 20:53:26.785', 1, 36);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (37, 21, 11, 'Excelente servicio', 'Nos encanta que est├®s satisfecho estamos para servirte.', '2018-05-30 21:00:34.258', '2018-05-30 21:00:34.258', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (25, 9, 15, 'quisiera cambiar mi plan', 'sino estas satisfecho o quieres retirarte debes reclamar el servicio ,para obtener otro plan.', '2018-05-30 19:43:17.185', '2018-05-30 19:43:17.185', 1, 26);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (41, 23, 1, 'quiero un plan para esposos', 'tomaremos en cuenta su sugerencia.', '2018-05-31 10:16:56.292', '2018-05-31 10:16:56.292', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (39, 33, 15, 'quisiera que me atendiera Jose', 'evaluaremos su solicitud.', '2018-05-31 09:33:14.174', '2018-05-31 09:33:14.174', 1, 19);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (3, 53, 1, 'deseo ir con mi familia', 'Su sugerencias son importantes ser├ín tomadas en cuenta.', '2018-05-27 19:04:14.627', '2018-05-27 19:04:14.627', 1, 21);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (29, 13, 15, 'como puedo cambiarlo?', 'evaluaremos su solicitud y daremos una respuesta apropiada muy pronto', '2018-05-30 20:03:38.818', '2018-05-30 20:03:38.818', 1, 19);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (18, 33, 10, 'Deberian tener un servicio para parejas', 'Su opini├│n es importante , sera tomada en cuenta.', '2018-05-28 21:23:58.996', '2018-05-28 21:23:58.996', 1, 33);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (33, 16, 1, 'Necesitan un servicio para parejas', 'pronto implementaremos este servicio en nuestro catalogo', '2018-05-30 20:18:50.759', '2018-05-30 20:18:50.759', 1, 33);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (31, 15, 15, 'Este plan ya no me funciona', 'debe reclamar el plan que posee actualmente para poder terminar su recorrido y solicitar un nuevo servicio.', '2018-05-30 20:13:54.596', '2018-05-30 20:13:54.596', 1, 26);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (28, 13, 11, 'Felicidades!', 'Nos encanta complacerte .', '2018-05-30 20:02:01.768', '2018-05-30 20:02:01.768', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (5, 51, 2, 'no me avisaron que el nutricionista no vendria', 'Pedimos disculpas por las molestias ocasionadas.', '2018-05-27 19:06:28.037', '2018-05-27 19:06:28.037', 1, 3);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (30, 14, 8, 'podrian tener un plan para celiacos', 'Le daremos una respuesta  a la brevedad posible.', '2018-05-30 20:06:18.339', '2018-05-30 20:06:18.339', 1, 32);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (7, 51, 15, 'quiero saber que dias trabaja', NULL, '2018-05-27 19:07:56.188', '2018-05-27 19:07:56.188', 1, 20);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (19, 33, 15, 'Mi nutricionista trabaja los sabados?', NULL, '2018-05-28 21:24:54.613', '2018-05-28 21:24:54.613', 1, 20);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (32, 15, 11, 'Excelente ejercicio', NULL, '2018-05-30 20:14:39.73', '2018-05-30 20:14:39.73', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (46, 25, 11, 'me encanto el servicio', NULL, '2018-06-05 17:00:31.426', '2018-06-05 17:00:31.426', 1, 34);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (47, 16, NULL, 'deberian mejorar el servicio', NULL, '2018-06-06 03:43:52.808798', '2018-06-06 03:43:52.808798', 1, 29);
INSERT INTO public.comentario (id_comentario, id_cliente, id_respuesta, contenido, mensaje, fecha_creacion, fecha_actualizacion, estatus, id_motivo) VALUES (48, 45, NULL, 'Que pueda atender a toda mi familia', NULL, '2018-06-06 06:18:10.760785', '2018-06-06 06:18:10.760785', 1, 21);


--
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Desayuno', '2018-05-27 03:15:19.223228', '2018-05-27 03:15:19.223228', 1);
INSERT INTO public.comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Almuerzo', '2018-05-27 03:15:37.280004', '2018-05-27 03:15:37.280004', 1);
INSERT INTO public.comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Cena', '2018-05-27 03:15:42.004584', '2018-05-27 03:15:42.004584', 1);
INSERT INTO public.comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Merienda', '2018-05-27 03:16:06.12', '2018-05-27 03:16:06.12', 1);


--
-- Data for Name: condicion_garantia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.condicion_garantia (id_condicion_garantia, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'El paciente se obliga a adoptar ├║nicamente comportamientos que no infrinjan que lesionen de alguna forma posiciones jur├¡dicamente protegida.', '2018-05-27 04:31:24.605582', '2018-05-27 04:31:24.605582', 1);
INSERT INTO public.condicion_garantia (id_condicion_garantia, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Si el reclamo no procede la empresa se encargara de dar una respuesta oportuna a la solicitud.', '2018-05-27 04:32:07.995292', '2018-05-27 04:32:07.995292', 1);
INSERT INTO public.condicion_garantia (id_condicion_garantia, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Al aceptar estos t├®rminos y condiciones de uso, el usuario acepta expresamente las pol├¡ticas de privacidad declarada por Sascha.', '2018-05-27 04:29:53.267', '2018-05-27 04:29:53.267', 1);
INSERT INTO public.condicion_garantia (id_condicion_garantia, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'El paciente no podr├í reclamar garant├¡as fuera de la fecha que el servicio estableci├│. ', '2018-05-27 04:31:47.842', '2018-05-27 04:31:47.842', 1);


--
-- Data for Name: contenido; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, '┬íNo olvides las leguminosas!', 'Son una fuente de prote├¡na vegetal, baja en grasas y alta en fibra diet├®tica. Consume 3 tazas a la semana o 1/2 tz diariamente de frijoles, garbanzos, lentejas o habas.', 'http://res.cloudinary.com/saschanutric/image/upload/v1527401396/gdxf7r1ghnbgnzouk2wd.jpg', '2018-05-27 06:09:56.859624', '2018-05-27 06:09:56.859624', 1);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Come frutas y verduras', 'Las frutas y verduras nos proporcionan una buen aporte de fibra diet├®tica y nutrientes que necesitamos diariamente.', 'http://res.cloudinary.com/saschanutric/image/upload/v1527401545/vntfihuhcvr09kpd9rsy.jpg', '2018-05-27 06:12:25.478818', '2018-05-27 06:12:25.478818', 1);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, '', '', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-05 16:46:13.117', '2018-06-05 16:46:13.117', 0);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, ' ', ' asasasa', 'http://res.cloudinary.com/saschanutric/image/upload/v1528247282/wts0liuhfqjpkjjdoqhl.jpg', '2018-06-06 01:08:03.358', '2018-06-06 01:08:03.358', 0);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, '', '', 'http://res.cloudinary.com/saschanutric/image/upload/v1528247368/w4xdptyxxymmmzzh1jmd.jpg', '2018-06-06 01:09:28.569', '2018-06-06 01:09:28.569', 0);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, '', '', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-06 01:12:24.722', '2018-06-06 01:12:24.722', 0);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'asasa', '', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-06 01:11:46.143', '2018-06-06 01:11:46.143', 0);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 'asasas', 'asasasa', 'http://res.cloudinary.com/saschanutric/image/upload/v1528248412/q89jbhuj27brs7dvmkqu.jpg', '2018-06-06 01:26:53.092', '2018-06-06 01:26:53.092', 0);
INSERT INTO public.contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'asasasa', '', 'http://res.cloudinary.com/saschanutric/image/upload/v1528247204/mtk9ertgedgb4bikydqh.jpg', '2018-06-06 01:06:44.401', '2018-06-06 01:06:44.401', 0);


--
-- Data for Name: criterio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 1, 'Buen Servicio3', 'Sastisfecho con el servicio que obtuve3', '2018-05-28 20:04:11.229', '2018-05-28 20:04:11.229', 0);
INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 1, 'Buen Servicio2', 'Sastisfecho con el servicio que obtuve2', '2018-05-28 20:08:10.211', '2018-05-28 20:08:10.211', 0);
INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 2, 'Buen Servicio', 'Sastisfecho con el servicio que obtuve', '2018-05-28 20:13:40.36', '2018-05-28 20:13:40.36', 0);
INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 1, 'Atenci├│n', '┬┐Te gustan los servicios que ofrecemos?', '2018-05-28 20:43:20.862304', '2018-05-28 20:43:20.862304', 1);
INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 2, 'Atenci├│n del nutricionista', '┬┐C├│mo fu├® el trato del nutricionista?', '2018-06-03 17:54:52.007', '2018-06-03 17:54:52.007', 1);
INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 2, 'Experiencia con el Plan Nutricional', '┬┐C├│mo ves tu evoluci├│n con el plan nutricional asignado?', '2018-05-28 20:15:43.85', '2018-05-28 20:15:43.85', 1);
INSERT INTO public.criterio (id_criterio, id_tipo_criterio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 1, 'Pr├║eba', '┬┐Que te pareci├│ el servicio brindado por el Nutricionista?', '2018-05-28 20:14:48.668', '2018-05-28 20:14:48.668', 1);


--
-- Data for Name: detalle_plan_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 1, 1, 3, '2018-05-27 04:08:44.538203', '2018-05-27 04:08:44.538203', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 1, 1, 4, '2018-05-27 04:08:44.538593', '2018-05-27 04:08:44.538593', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 1, 4, 3, '2018-05-27 04:08:44.540866', '2018-05-27 04:08:44.540866', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 1, 2, 1, '2018-05-27 04:08:44.541261', '2018-05-27 04:08:44.541261', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 1, 2, 5, '2018-05-27 04:08:44.544273', '2018-05-27 04:08:44.544273', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 1, 3, 2, '2018-05-27 04:08:44.54517', '2018-05-27 04:08:44.54517', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 1, 3, 4, '2018-05-27 04:08:44.548343', '2018-05-27 04:08:44.548343', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 2, 1, 2, '2018-05-27 04:11:07.109085', '2018-05-27 04:11:07.109085', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 2, 2, 6, '2018-05-27 04:11:07.109358', '2018-05-27 04:11:07.109358', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 2, 2, 2, '2018-05-27 04:11:07.110847', '2018-05-27 04:11:07.110847', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 2, 3, 4, '2018-05-27 04:11:07.11326', '2018-05-27 04:11:07.11326', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 2, 3, 3, '2018-05-27 04:11:07.112989', '2018-05-27 04:11:07.112989', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 3, 3, 2, '2018-05-27 04:14:12.861264', '2018-05-27 04:14:12.861264', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 3, 2, 5, '2018-05-27 04:14:12.861282', '2018-05-27 04:14:12.861282', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 3, 1, 2, '2018-05-27 04:14:12.860156', '2018-05-27 04:14:12.860156', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 3, 3, 6, '2018-05-27 04:14:12.865274', '2018-05-27 04:14:12.865274', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 3, 2, 6, '2018-05-27 04:14:12.864688', '2018-05-27 04:14:12.864688', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 3, 1, 4, '2018-05-27 04:14:12.859877', '2018-05-27 04:14:12.859877', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 4, 3, 2, '2018-05-27 04:18:22.012683', '2018-05-27 04:18:22.012683', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 4, 2, 7, '2018-05-27 04:18:22.013616', '2018-05-27 04:18:22.013616', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 4, 2, 2, '2018-05-27 04:18:22.013276', '2018-05-27 04:18:22.013276', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 5, 1, 2, '2018-05-27 04:24:50.009589', '2018-05-27 04:24:50.009589', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 5, 1, 3, '2018-05-27 04:24:50.009993', '2018-05-27 04:24:50.009993', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 5, 2, 7, '2018-05-27 04:24:50.011418', '2018-05-27 04:24:50.011418', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 5, 2, 2, '2018-05-27 04:24:50.01239', '2018-05-27 04:24:50.01239', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 5, 3, 3, '2018-05-27 04:24:50.013262', '2018-05-27 04:24:50.013262', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 6, 1, 6, '2018-05-27 04:34:22.739305', '2018-05-27 04:34:22.739305', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 6, 2, 6, '2018-05-27 04:34:22.739693', '2018-05-27 04:34:22.739693', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 6, 3, 6, '2018-05-27 04:34:22.741271', '2018-05-27 04:34:22.741271', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 6, 2, 2, '2018-05-27 04:34:22.743284', '2018-05-27 04:34:22.743284', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 7, 1, 3, '2018-05-27 04:38:57.761792', '2018-05-27 04:38:57.761792', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 7, 2, 2, '2018-05-27 04:38:57.76265', '2018-05-27 04:38:57.76265', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 7, 3, 2, '2018-05-27 04:38:57.764988', '2018-05-27 04:38:57.764988', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 7, 2, 7, '2018-05-27 04:38:57.766134', '2018-05-27 04:38:57.766134', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 8, 1, 3, '2018-05-27 04:40:37.934199', '2018-05-27 04:40:37.934199', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 8, 2, 3, '2018-05-27 04:40:37.934556', '2018-05-27 04:40:37.934556', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 8, 3, 2, '2018-05-27 04:40:37.937262', '2018-05-27 04:40:37.937262', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 9, 1, 4, '2018-05-27 04:41:59.122185', '2018-05-27 04:41:59.122185', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 9, 3, 4, '2018-05-27 04:41:59.122663', '2018-05-27 04:41:59.122663', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 9, 2, 4, '2018-05-27 04:41:59.124122', '2018-05-27 04:41:59.124122', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 10, 1, 2, '2018-05-27 04:46:23.586134', '2018-05-27 04:46:23.586134', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 10, 1, 4, '2018-05-27 04:46:23.586489', '2018-05-27 04:46:23.586489', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 10, 2, 5, '2018-05-27 04:46:23.589263', '2018-05-27 04:46:23.589263', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 10, 2, 2, '2018-05-27 04:46:23.589509', '2018-05-27 04:46:23.589509', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 10, 2, 7, '2018-05-27 04:46:23.592271', '2018-05-27 04:46:23.592271', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (46, 10, 3, 2, '2018-05-27 04:46:23.59345', '2018-05-27 04:46:23.59345', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (47, 10, 3, 3, '2018-05-27 04:46:23.595922', '2018-05-27 04:46:23.595922', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (48, 11, 1, 2, '2018-05-27 04:53:25.42359', '2018-05-27 04:53:25.42359', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (49, 11, 2, 2, '2018-05-27 04:53:25.424779', '2018-05-27 04:53:25.424779', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (50, 11, 3, 2, '2018-05-27 04:53:25.424954', '2018-05-27 04:53:25.424954', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (51, 11, 1, 3, '2018-05-27 04:53:25.423939', '2018-05-27 04:53:25.423939', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (52, 11, 2, 4, '2018-05-27 04:53:25.424432', '2018-05-27 04:53:25.424432', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (53, 11, 3, 4, '2018-05-27 04:53:25.425319', '2018-05-27 04:53:25.425319', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 12, 1, 3, '2018-05-27 04:54:58.284416', '2018-05-27 04:54:58.284416', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 12, 2, 2, '2018-05-27 04:54:58.285264', '2018-05-27 04:54:58.285264', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 12, 1, 2, '2018-05-27 04:54:58.284154', '2018-05-27 04:54:58.284154', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 12, 3, 2, '2018-05-27 04:54:58.288764', '2018-05-27 04:54:58.288764', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 12, 2, 4, '2018-05-27 04:54:58.290405', '2018-05-27 04:54:58.290405', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 13, 2, 2, '2018-05-27 05:05:24.012684', '2018-05-27 05:05:24.012684', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (60, 13, 1, 5, '2018-05-27 05:05:24.014901', '2018-05-27 05:05:24.014901', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (61, 13, 3, 2, '2018-05-27 05:05:24.015076', '2018-05-27 05:05:24.015076', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (62, 13, 1, 6, '2018-05-27 05:05:24.014916', '2018-05-27 05:05:24.014916', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (63, 13, 1, 2, '2018-05-27 05:05:24.014759', '2018-05-27 05:05:24.014759', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (64, 13, 3, 4, '2018-05-27 05:05:24.015087', '2018-05-27 05:05:24.015087', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (65, 13, 2, 7, '2018-05-27 05:05:24.012435', '2018-05-27 05:05:24.012435', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (67, 14, 2, 6, '2018-05-27 05:06:48.681263', '2018-05-27 05:06:48.681263', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (68, 14, 3, 2, '2018-05-27 05:06:48.682588', '2018-05-27 05:06:48.682588', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (69, 14, 3, 4, '2018-05-27 05:06:48.68462', '2018-05-27 05:06:48.68462', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (70, 14, 1, 4, '2018-05-27 05:06:48.680482', '2018-05-27 05:06:48.680482', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (71, 14, 1, 2, '2018-05-27 05:06:48.680208', '2018-05-27 05:06:48.680208', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (66, 14, 2, 5, '2018-05-27 05:06:48.681263', '2018-05-27 05:06:48.681263', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (72, 15, 1, 3, '2018-05-27 05:08:52.730451', '2018-05-27 05:08:52.730451', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (73, 15, 2, 5, '2018-05-27 05:08:52.730733', '2018-05-27 05:08:52.730733', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (74, 15, 3, 4, '2018-05-27 05:08:52.733264', '2018-05-27 05:08:52.733264', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (75, 15, 2, 7, '2018-05-27 05:08:52.733907', '2018-05-27 05:08:52.733907', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (76, 15, 3, 2, '2018-05-27 05:08:52.737338', '2018-05-27 05:08:52.737338', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (77, 16, 1, 6, '2018-05-30 21:40:37.685798', '2018-05-30 21:40:37.685798', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (78, 16, 1, 2, '2018-05-30 21:40:37.686177', '2018-05-30 21:40:37.686177', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (79, 16, 2, 6, '2018-05-30 21:40:37.687136', '2018-05-30 21:40:37.687136', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (80, 16, 3, 4, '2018-05-30 21:40:37.688259', '2018-05-30 21:40:37.688259', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (81, 16, 2, 2, '2018-05-30 21:40:37.687625', '2018-05-30 21:40:37.687625', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (82, 16, 3, 5, '2018-05-30 21:40:37.690459', '2018-05-30 21:40:37.690459', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (83, 16, 3, 3, '2018-05-30 21:40:37.689265', '2018-05-30 21:40:37.689265', 1);
INSERT INTO public.detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) VALUES (84, 16, 2, 5, '2018-05-30 21:40:37.688535', '2018-05-30 21:40:37.688535', 1);


--
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 1, 10, '2018-05-27 05:17:33.15107', '2018-05-27 05:17:33.15107', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 1, 3, '2018-05-27 05:17:33.151884', '2018-05-27 05:17:33.151884', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 1, 6, '2018-05-27 05:17:33.153909', '2018-05-27 05:17:33.153909', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 2, 4, '2018-05-27 05:19:37.303282', '2018-05-27 05:19:37.303282', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 2, 1, '2018-05-27 05:19:37.305004', '2018-05-27 05:19:37.305004', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 2, 8, '2018-05-27 05:19:37.304811', '2018-05-27 05:19:37.304811', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 3, 9, '2018-05-27 05:20:25.629364', '2018-05-27 05:20:25.629364', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 3, 6, '2018-05-27 05:20:25.630679', '2018-05-27 05:20:25.630679', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 3, 4, '2018-05-27 05:20:25.631463', '2018-05-27 05:20:25.631463', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 5, 10, '2018-06-05 04:57:42.29171', '2018-06-05 04:57:42.29171', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 5, 7, '2018-06-05 04:57:42.293354', '2018-06-05 04:57:42.293354', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 5, 3, '2018-06-05 04:57:42.294742', '2018-06-05 04:57:42.294742', 1);
INSERT INTO public.detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 5, 1, '2018-06-05 04:57:42.295925', '2018-06-05 04:57:42.295925', 1);


--
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 1, 1, '2018-05-27 05:17:19.96899', '2018-05-27 05:17:19.96899', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 1, 4, '2018-05-27 05:17:19.969596', '2018-05-27 05:17:19.969596', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 1, 7, '2018-05-27 05:17:19.971926', '2018-05-27 05:17:19.971926', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 2, 6, '2018-05-27 05:18:31.140242', '2018-05-27 05:18:31.140242', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 2, 9, '2018-05-27 05:18:31.141277', '2018-05-27 05:18:31.141277', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 2, 3, '2018-05-27 05:18:31.143054', '2018-05-27 05:18:31.143054', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 3, 10, '2018-05-27 05:19:28.983491', '2018-05-27 05:19:28.983491', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 3, 2, '2018-05-27 05:19:28.987364', '2018-05-27 05:19:28.987364', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 3, 4, '2018-05-27 05:19:28.988287', '2018-05-27 05:19:28.988287', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 3, 8, '2018-05-27 05:19:28.991358', '2018-05-27 05:19:28.991358', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 4, 11, '2018-05-28 23:58:08.918767', '2018-05-28 23:58:08.918767', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 4, 14, '2018-05-28 23:58:08.920542', '2018-05-28 23:58:08.920542', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 4, 6, '2018-05-28 23:58:08.92101', '2018-05-28 23:58:08.92101', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 5, 13, '2018-05-29 00:01:00.05072', '2018-05-29 00:01:00.05072', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 5, 12, '2018-05-29 00:01:00.051164', '2018-05-29 00:01:00.051164', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 5, 6, '2018-05-29 00:01:00.053601', '2018-05-29 00:01:00.053601', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 6, 5, '2018-05-29 00:05:50.661286', '2018-05-29 00:05:50.661286', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 6, 3, '2018-05-29 00:05:50.69524', '2018-05-29 00:05:50.69524', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 7, 8, '2018-05-29 00:08:55.995832', '2018-05-29 00:08:55.995832', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 7, 10, '2018-05-29 00:08:55.996772', '2018-05-29 00:08:55.996772', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 7, 11, '2018-05-29 00:08:55.998431', '2018-05-29 00:08:55.998431', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 8, 1, '2018-05-29 00:12:05.825275', '2018-05-29 00:12:05.825275', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 8, 4, '2018-05-29 00:12:05.829281', '2018-05-29 00:12:05.829281', 1);
INSERT INTO public.detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 8, 8, '2018-05-29 00:12:05.832081', '2018-05-29 00:12:05.832081', 1);


--
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (1, 34, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 1);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (2, 16, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 2);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (3, 15, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 3);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (3, 16, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 4);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (4, 39, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 5);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (4, 40, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 6);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (4, 41, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 7);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (4, 44, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 8);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (4, 42, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 9);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (5, 11, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 10);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (5, 14, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 11);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (6, 33, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 12);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (7, 1, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 13);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (7, 2, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 14);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (7, 3, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 15);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (9, 78, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 20);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (10, 34, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 21);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (11, 3, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 22);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (12, 2, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 23);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (12, 5, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 24);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (13, 33, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 25);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (13, 34, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 26);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (8, 43, '2018-05-29 03:20:35.942393', '2018-05-29 03:20:35.942393', 1, 27);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (8, 44, '2018-05-29 03:20:35.942393', '2018-05-29 03:20:35.942393', 1, 28);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (8, 49, '2018-05-29 03:20:35.942393', '2018-05-29 03:20:35.942393', 1, 29);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (8, 53, '2018-05-29 03:20:35.942393', '2018-05-29 03:20:35.942393', 1, 30);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 15, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 31);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 16, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 32);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 17, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 33);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 18, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 34);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 19, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 35);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 20, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 36);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (14, 21, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 37);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (15, 60, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 38);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (15, 62, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 39);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (15, 63, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 40);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 39, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 41);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 40, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 42);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 41, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 43);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 43, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 44);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 44, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 45);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 45, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 46);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 46, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 47);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 47, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 48);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (16, 48, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 49);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (17, 2, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 50);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (17, 3, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 51);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (17, 4, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 52);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (17, 6, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 53);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (18, 34, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 54);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (19, 3, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 55);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (19, 4, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 56);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (19, 5, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 57);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (20, 79, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 58);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (20, 78, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 59);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (21, 39, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 60);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (21, 40, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 61);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (21, 41, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 62);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (21, 43, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 63);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (21, 44, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 64);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (21, 45, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 65);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (22, 3, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 66);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (22, 5, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 67);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (22, 6, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 68);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (22, 7, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 69);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (23, 78, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 70);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 15, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 71);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 16, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 72);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 17, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 73);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 18, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 74);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 19, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 75);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 20, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 76);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (24, 21, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 77);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (25, 40, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 78);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (25, 41, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 79);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (25, 43, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 80);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (25, 44, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 81);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (25, 45, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 82);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (25, 46, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 83);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (26, 34, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 84);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (26, 35, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 85);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (26, 36, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 86);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (26, 37, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 87);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (27, 19, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 88);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (27, 20, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 89);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (27, 21, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 90);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (27, 22, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 91);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (29, 7, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 95);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (30, 66, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 96);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (31, 26, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 97);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (31, 29, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 98);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (31, 30, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 99);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (31, 31, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 100);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (32, 38, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 101);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (33, 2, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 102);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (33, 5, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 103);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (34, 79, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 104);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (35, 78, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 105);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (36, 15, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 106);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (36, 16, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 107);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (36, 17, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 108);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (36, 18, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 109);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (36, 20, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 110);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (36, 21, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 111);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (37, 60, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 112);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (37, 61, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 113);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (37, 63, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 114);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (37, 66, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 115);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 39, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 116);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 40, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 117);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 45, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 118);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 46, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 119);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 47, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 120);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 49, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 121);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (38, 50, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 122);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (39, 2, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 123);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (39, 3, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 124);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (39, 5, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 125);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (39, 6, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 126);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (40, 33, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 127);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (40, 34, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 128);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (41, 33, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 129);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (41, 34, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 130);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (41, 35, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 131);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 15, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 132);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 16, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 133);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 18, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 134);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 19, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 135);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 22, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 136);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 23, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 137);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (42, 25, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 138);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 18, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 139);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 20, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 140);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 22, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 141);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 23, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 142);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 28, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 143);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 29, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 144);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (43, 30, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 145);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 41, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 146);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 43, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 147);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 44, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 148);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 45, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 149);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 48, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 150);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 49, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 151);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (44, 51, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 152);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (45, 10, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 153);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (45, 11, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 154);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (45, 14, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 155);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (46, 33, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 156);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (46, 34, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 157);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (47, 1, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 158);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (47, 4, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 159);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (47, 7, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 160);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (48, 3, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 161);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (48, 4, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 162);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (48, 5, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 163);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (49, 78, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 164);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (50, 44, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 165);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (50, 45, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 166);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (50, 46, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 167);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (50, 47, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 168);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (51, 3, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 169);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (51, 5, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 170);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (51, 6, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 171);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (52, 79, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 172);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 20, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 173);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 21, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 174);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 22, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 175);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 23, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 176);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 24, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 177);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 25, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 178);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (53, 26, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 179);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (54, 41, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 180);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (54, 43, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 181);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (54, 44, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 182);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (54, 45, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 183);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (55, 35, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 184);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (55, 36, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 185);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (55, 37, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 186);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (56, 38, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 187);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (56, 78, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 188);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (57, 1, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 189);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (57, 2, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 190);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (57, 7, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 191);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (57, 8, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 192);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (58, 79, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 193);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (58, 78, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 194);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (59, 38, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 195);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (61, 66, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 200);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (61, 67, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 201);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (61, 68, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 202);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (62, 1, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 203);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (63, 4, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 204);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (63, 5, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 205);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (63, 7, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 206);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (63, 8, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 207);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (60, 18, '2018-06-01 13:46:35.21042', '2018-06-01 13:46:35.21042', 1, 208);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (60, 19, '2018-06-01 13:46:35.21042', '2018-06-01 13:46:35.21042', 1, 209);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (60, 20, '2018-06-01 13:46:35.21042', '2018-06-01 13:46:35.21042', 1, 210);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (60, 21, '2018-06-01 13:46:35.21042', '2018-06-01 13:46:35.21042', 1, 211);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (60, 26, '2018-06-01 13:46:35.21042', '2018-06-01 13:46:35.21042', 1, 212);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (64, 17, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 213);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (64, 18, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 214);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (64, 19, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 215);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (64, 20, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 216);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (65, 1, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 217);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (65, 2, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 218);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (65, 3, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 219);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (65, 4, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 220);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (66, 1, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 221);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (66, 2, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 222);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (66, 3, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 223);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (66, 4, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 224);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (67, 60, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 225);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (67, 61, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 226);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (67, 62, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 227);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (67, 63, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 228);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (68, 15, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 229);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (68, 16, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 230);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (68, 17, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 231);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (69, 38, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 232);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (69, 79, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 233);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (70, 1, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 234);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (70, 2, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 235);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (70, 3, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 236);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (71, 38, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 237);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (71, 79, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 238);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (71, 78, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 239);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (72, 38, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 240);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (72, 79, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 241);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (72, 78, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 242);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (28, 1, '2018-06-01 22:33:35.617399', '2018-06-01 22:33:35.617399', 1, 243);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (28, 2, '2018-06-01 22:33:35.617399', '2018-06-01 22:33:35.617399', 1, 244);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (28, 7, '2018-06-01 22:33:35.617399', '2018-06-01 22:33:35.617399', 1, 245);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (28, 9, '2018-06-01 22:33:35.617399', '2018-06-01 22:33:35.617399', 1, 246);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (73, 38, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 247);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (73, 78, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 248);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (74, 1, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 249);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (74, 2, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 250);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (74, 9, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 251);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (75, 78, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 252);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (76, 43, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 253);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (76, 44, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 254);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (76, 46, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 255);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (76, 48, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 256);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (77, 34, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 257);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (77, 37, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 258);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (78, 3, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 259);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (78, 4, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 260);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (78, 9, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 261);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (79, 34, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 262);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (79, 36, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 263);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (80, 16, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 264);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (80, 19, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 265);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (80, 21, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 266);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (80, 23, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 267);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (81, 29, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 268);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (82, 44, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 269);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (82, 46, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 270);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (82, 48, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 271);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (82, 55, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 272);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (83, 11, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 273);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (83, 13, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 274);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (84, 33, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 275);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (84, 34, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 276);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (85, 5, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 277);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (85, 6, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 278);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (85, 9, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 279);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (86, 38, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 280);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (86, 79, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 281);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (87, 1, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 282);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (87, 5, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 283);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (87, 8, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 284);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (88, 79, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 285);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (88, 78, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 286);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (89, 38, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 287);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (89, 78, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 288);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (90, 38, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 289);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (90, 78, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 290);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (91, 2, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 291);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (91, 4, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 292);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (91, 9, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 293);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (92, 79, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 294);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (92, 78, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 295);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (93, 44, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 296);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (93, 46, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 297);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (93, 49, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 298);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (93, 50, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 299);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (93, 72, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 300);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (94, 34, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 301);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (94, 35, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 302);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (95, 2, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 303);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (95, 3, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 304);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (95, 4, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 305);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (95, 9, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 306);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (96, 38, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 307);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (96, 78, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 308);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (97, 1, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 309);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (97, 4, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 310);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (97, 7, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 311);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (98, 79, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 312);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (98, 78, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 313);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (99, 38, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 314);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (99, 78, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 315);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (100, 38, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 316);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (100, 78, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 317);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (101, 3, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 318);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (101, 5, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 319);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (101, 6, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 320);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (102, 79, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 321);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (102, 78, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 322);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (103, 41, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 323);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (103, 48, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 324);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (103, 49, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 325);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (104, 33, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 326);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (104, 34, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 327);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (105, 2, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 328);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (105, 3, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 329);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (105, 9, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 330);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (106, 38, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 331);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (106, 79, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 332);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (107, 1, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 333);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (107, 4, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 334);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (107, 5, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 335);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (108, 79, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 336);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (108, 78, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 337);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (109, 53, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 338);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (109, 56, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 339);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (109, 59, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 340);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (109, 72, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 341);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (110, 34, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 342);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (110, 35, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 343);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (110, 36, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 344);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (111, 3, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 345);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (111, 6, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 346);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (111, 8, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 347);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (111, 9, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 348);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (115, 38, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 349);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (117, 38, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 351);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (117, 79, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 352);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (118, 39, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 353);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (118, 41, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 354);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (119, 34, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 355);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (120, 3, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 356);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (116, 2, '2018-06-05 02:50:58.723272', '2018-06-05 02:50:58.723272', 1, 357);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (116, 4, '2018-06-05 02:50:58.723272', '2018-06-05 02:50:58.723272', 1, 358);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (122, 16, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 361);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (122, 18, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 362);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (122, 20, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 363);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (123, 16, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 364);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (123, 19, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 365);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (123, 21, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 366);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (124, 39, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 367);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (124, 41, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 368);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (124, 45, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 369);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (125, 11, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 370);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (125, 14, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 371);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (126, 33, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 372);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (126, 36, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 373);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (127, 1, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 374);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (127, 3, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 375);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (127, 5, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 376);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (121, 33, '2018-06-05 07:00:33.223107', '2018-06-05 07:00:33.223107', 1, 377);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (121, 35, '2018-06-05 07:00:33.223107', '2018-06-05 07:00:33.223107', 1, 378);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (128, 2, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 379);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (128, 3, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 380);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (129, 38, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 381);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (130, 40, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 382);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (130, 41, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 383);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (130, 43, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 384);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (130, 44, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 385);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (130, 45, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 386);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (132, 79, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 389);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (132, 78, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 390);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (133, 16, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 391);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (133, 17, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 392);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (133, 18, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 393);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (133, 19, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 394);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (134, 51, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 395);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (134, 52, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 396);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (134, 53, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 397);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (134, 54, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 398);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (134, 55, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 399);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (134, 56, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 400);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (135, 33, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 401);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (135, 34, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 402);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (135, 35, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 403);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (131, 1, '2018-06-05 07:47:02.316622', '2018-06-05 07:47:02.316622', 1, 404);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (131, 7, '2018-06-05 07:47:02.316622', '2018-06-05 07:47:02.316622', 1, 405);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (136, 38, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 406);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (137, 3, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 407);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (137, 4, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 408);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (138, 38, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 409);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (139, 43, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 410);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (139, 44, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 411);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (139, 45, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 412);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (139, 46, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 413);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (139, 47, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 414);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (140, 34, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 415);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (140, 35, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 416);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (141, 5, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 417);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (141, 6, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 418);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (142, 21, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 419);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (142, 22, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 420);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (142, 23, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 421);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (142, 24, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 422);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (143, 3, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 423);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (143, 5, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 424);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (143, 6, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 425);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (144, 2, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 426);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (144, 3, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 427);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (144, 4, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 428);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (145, 62, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 429);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (145, 63, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 430);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (145, 64, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 431);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (146, 16, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 432);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (146, 17, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 433);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (146, 18, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 434);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (147, 19, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 435);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (147, 20, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 436);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (147, 21, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 437);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (147, 22, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 438);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (148, 63, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 439);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (148, 64, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 440);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (148, 65, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 441);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (148, 66, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 442);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (149, 4, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 443);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (149, 5, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 444);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (149, 7, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 445);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (150, 4, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 446);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (150, 5, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 447);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (150, 7, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 448);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (151, 38, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 449);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (152, 4, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 450);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (152, 7, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 451);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (152, 8, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 452);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (153, 78, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 453);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (154, 38, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 454);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (155, 38, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 455);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (156, 4, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 456);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (156, 7, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 457);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (156, 8, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 458);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (157, 78, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 459);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (158, 38, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 460);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (159, 79, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 461);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (159, 78, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 462);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (160, 1, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 463);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (160, 2, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 464);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (160, 3, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 465);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (160, 4, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 466);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (161, 79, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 467);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (162, 41, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 468);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (162, 43, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 469);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (162, 44, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 470);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (162, 45, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 471);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (163, 35, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 472);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (163, 36, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 473);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (163, 37, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 474);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (164, 2, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 475);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (164, 3, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 476);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (164, 4, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 477);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (164, 5, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 478);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (172, 34, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 479);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (172, 35, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 480);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (172, 36, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 481);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (173, 17, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 482);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (173, 18, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 483);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (173, 19, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 484);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (174, 19, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 485);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (174, 20, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 486);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (174, 21, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 487);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (174, 22, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 488);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (175, 41, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 489);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (175, 43, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 490);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (175, 44, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 491);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (175, 45, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 492);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (175, 46, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 493);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (175, 47, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 494);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (176, 13, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 495);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (176, 14, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 496);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (177, 35, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 497);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (177, 36, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 498);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (177, 37, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 499);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (178, 3, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 500);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (178, 5, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 501);
INSERT INTO public.detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) VALUES (178, 6, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 502);


--
-- Data for Name: detalle_visita; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 76, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 1);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 33, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 2);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 44, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 3);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 15, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 4);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 28, 70.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 5);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 29, 180.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 6);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 30, 70.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 7);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (1, 31, 21.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 8);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (2, 1, 120.0000, '2018-05-27 16:06:16.178159', '2018-05-27 16:06:16.178159', 1, 9);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (2, 5, 89.0000, '2018-05-27 16:06:32.819584', '2018-05-27 16:06:32.819584', 1, 10);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (2, 8, 180.0000, '2018-05-27 16:06:48.635818', '2018-05-27 16:06:48.635818', 1, 11);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 34, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 12);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 36, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 13);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 32, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 14);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 28, 50.0000, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 15);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 29, 160.0000, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 16);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 30, 68.0000, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 17);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (4, 43, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 18);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (3, 28, 85.0000, '2018-05-27 23:31:18.374947', '2018-05-27 23:31:18.374947', 1, 19);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (5, 28, 55.0000, '2018-05-29 01:52:06.657091', '2018-05-29 01:52:06.657091', 1, 20);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (6, 28, 60.0000, '2018-05-29 03:13:25.063259', '2018-05-29 03:13:25.063259', 1, 21);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 28, 57.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 22);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 29, 164.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 23);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 31, 18.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 24);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 30, 65.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 25);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 33, NULL, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 26);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 35, NULL, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 27);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (7, 15, NULL, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 28);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (8, 28, 56.0000, '2018-05-29 21:10:00.404878', '2018-05-29 21:10:00.404878', 1, 29);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (8, 80, NULL, '2018-05-29 21:10:31.536322', '2018-05-29 21:10:31.536322', 1, 30);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (8, 2, 85.0000, '2018-05-29 21:10:51.37067', '2018-05-29 21:10:51.37067', 1, 31);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (8, 68, 10.0000, '2018-05-29 21:11:29.564135', '2018-05-29 21:11:29.564135', 1, 32);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (9, 80, NULL, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 33);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (9, 81, NULL, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 34);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (9, 29, 160.0000, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 35);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (9, 28, 55.0000, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 36);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (10, 28, 56.0000, '2018-05-31 06:58:00.507882', '2018-05-31 06:58:00.507882', 1, 37);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (11, 80, NULL, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 38);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (11, 24, NULL, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 39);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (11, 25, NULL, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 40);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (12, 81, NULL, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 41);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (12, 28, 55.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 42);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (12, 29, 170.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 43);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (12, 30, 60.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 44);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (12, 31, 19.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 45);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 32, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 46);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 34, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 47);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 28, 65.0000, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 48);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 29, 158.0000, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 49);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 30, 70.0000, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 50);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 15, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 51);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (13, 44, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 52);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (14, 80, NULL, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 53);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (14, 25, NULL, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 54);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (14, 43, NULL, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 55);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (14, 30, 70.0000, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 56);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (14, 29, 175.0000, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 57);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (14, 28, 77.0000, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 58);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 80, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 59);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 81, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 60);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 32, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 61);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 33, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 62);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 28, 60.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 63);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 29, 160.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 64);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 30, 60.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 65);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 31, 18.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 66);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 2, 150.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 67);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 1, 120.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 68);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 3, 24.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 69);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 4, 130.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 70);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (15, 5, 200.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 71);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (16, 80, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 72);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (16, 81, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 73);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (16, 35, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 74);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (16, 15, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 75);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (16, 82, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 76);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (25, 80, NULL, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 77);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (26, 28, 78.0000, '2018-06-01 13:44:51.786825', '2018-06-01 13:44:51.786825', 1, 78);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (26, 29, 175.0000, '2018-06-01 13:45:09.771081', '2018-06-01 13:45:09.771081', 1, 79);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (27, 28, 75.0000, '2018-06-01 14:09:59.002907', '2018-06-01 14:09:59.002907', 1, 80);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (27, 2, 10.0000, '2018-06-01 14:10:33.213548', '2018-06-01 14:10:33.213548', 1, 81);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (28, 80, NULL, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 82);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (28, 81, NULL, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 83);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (28, 83, NULL, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 84);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (28, 28, 123.0000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 85);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (28, 29, 168.0000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 86);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (28, 30, 55.0000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 87);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (29, 9, 100.0000, '2018-06-01 21:18:26.815383', '2018-06-01 21:18:26.815383', 1, 88);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (29, 4, 100.0000, '2018-06-01 21:21:23.411149', '2018-06-01 21:21:23.411149', 1, 89);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (30, 29, 170.0000, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 90);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (30, 30, 70.0000, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 91);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (31, 28, 60.0000, '2018-06-01 22:32:27.243156', '2018-06-01 22:32:27.243156', 1, 92);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (31, 4, 132.0000, '2018-06-01 22:32:49.343389', '2018-06-01 22:32:49.343389', 1, 93);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (31, 49, 2.3000, '2018-06-01 22:33:16.722586', '2018-06-01 22:33:16.722586', 1, 94);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (32, 1, 60.0000, '2018-06-01 23:00:05.87043', '2018-06-01 23:00:05.87043', 1, 95);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 81, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 96);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 28, 60.0000, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 97);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 29, 169.0000, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 98);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 30, 70.0000, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 99);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 77, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 100);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 79, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 101);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (33, 20, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 102);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (34, 81, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 103);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (34, 22, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 104);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (34, 20, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 105);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (34, 44, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 106);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (34, 84, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 107);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 28, 60.0000, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 108);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 29, 170.0000, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 109);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 30, 60.0000, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 110);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 17, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 111);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 41, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 112);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 40, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 113);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 43, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 114);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 82, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 115);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 33, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 116);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (35, 37, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 117);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (36, 81, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 118);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (36, 15, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 119);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (36, 43, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 120);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (36, 16, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 121);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (36, 38, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 122);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (36, 42, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 123);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 32, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 124);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 34, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 125);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 37, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 126);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 29, 160.0000, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 127);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 28, 50.0000, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 128);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 30, 60.0000, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 129);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 44, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 130);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 39, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 131);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (37, 20, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 132);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (38, 80, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 133);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (38, 25, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 134);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (38, 84, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 135);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (38, 22, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 136);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (38, 21, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 137);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (38, 42, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 138);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 35, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 139);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 37, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 140);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 23, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 141);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 25, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 142);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 44, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 143);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 43, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 144);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 22, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 145);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 20, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 146);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 19, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 147);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (39, 38, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 148);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (40, 37, NULL, '2018-06-04 07:42:59.379537', '2018-06-04 07:42:59.379537', 1, 149);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (40, 28, 60.0000, '2018-06-04 07:43:50.862752', '2018-06-04 07:43:50.862752', 1, 150);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (41, 30, 78.0000, '2018-06-04 07:46:15.866026', '2018-06-04 07:46:15.866026', 1, 151);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (42, 30, 55.0000, '2018-06-04 07:47:12.591992', '2018-06-04 07:47:12.591992', 1, 152);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (42, 5, 95.0000, '2018-06-04 07:47:35.746912', '2018-06-04 07:47:35.746912', 1, 153);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (42, 4, 70.0000, '2018-06-04 07:47:49.434461', '2018-06-04 07:47:49.434461', 1, 154);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (43, 28, 75.0000, '2018-06-04 07:48:51.40138', '2018-06-04 07:48:51.40138', 1, 155);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (44, 30, 73.0000, '2018-06-04 07:49:59.676883', '2018-06-04 07:49:59.676883', 1, 156);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (45, 30, 60.0000, '2018-06-04 07:52:46.530425', '2018-06-04 07:52:46.530425', 1, 158);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (45, 5, 85.0000, '2018-06-04 07:52:53.161853', '2018-06-04 07:52:53.161853', 1, 159);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (45, 4, 60.0000, '2018-06-04 07:53:02.314003', '2018-06-04 07:53:02.314003', 1, 160);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (46, 28, 55.0000, '2018-06-04 07:53:52.24328', '2018-06-04 07:53:52.24328', 1, 161);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (47, 28, 60.0000, '2018-06-04 07:54:42.183491', '2018-06-04 07:54:42.183491', 1, 162);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (48, 28, 72.0000, '2018-06-04 07:55:05.988859', '2018-06-04 07:55:05.988859', 1, 163);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (49, 30, 78.0000, '2018-06-04 07:55:32.688578', '2018-06-04 07:55:32.688578', 1, 164);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (50, 30, 75.0000, '2018-06-04 07:55:59.174174', '2018-06-04 07:55:59.174174', 1, 165);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (51, 28, 67.0000, '2018-06-04 09:50:15.78851', '2018-06-04 09:50:15.78851', 1, 176);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (53, 81, NULL, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 178);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (54, 12, 180.0000, '2018-06-05 02:40:00.391768', '2018-06-05 02:40:00.391768', 1, 179);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (54, 20, NULL, '2018-06-05 02:41:19.995048', '2018-06-05 02:41:19.995048', 1, 180);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (55, 28, 58.0000, '2018-06-05 02:47:01.886865', '2018-06-05 02:47:01.886865', 1, 181);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (55, 4, 210.0000, '2018-06-05 02:50:26.96668', '2018-06-05 02:50:26.96668', 1, 182);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (57, 80, NULL, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 183);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (57, 81, NULL, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 184);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (58, 28, 65.0000, '2018-06-05 06:18:05.785745', '2018-06-05 06:18:05.785745', 1, 186);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (59, 29, 160.0000, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 187);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (59, 30, 60.0000, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 188);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (59, 25, NULL, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 189);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (59, 77, NULL, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 190);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (59, 2, 70.0000, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 191);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (61, 4, 79.0000, '2018-06-05 07:48:31.30533', '2018-06-05 07:48:31.30533', 1, 192);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (61, 2, 101.0000, '2018-06-05 07:48:42.03678', '2018-06-05 07:48:42.03678', 1, 193);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (62, 28, 75.0000, '2018-06-05 08:07:17.658173', '2018-06-05 08:07:17.658173', 1, 194);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (64, 28, 75.0000, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 195);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (64, 29, 167.0000, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 196);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (64, 85, NULL, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 197);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (64, 2, 80.0000, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 198);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (65, 28, 72.0000, '2018-06-05 09:25:31.364421', '2018-06-05 09:25:31.364421', 1, 199);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (65, 81, NULL, '2018-06-05 09:25:41.941829', '2018-06-05 09:25:41.941829', 1, 200);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (66, 28, 68.0000, '2018-06-05 09:26:58.560484', '2018-06-05 09:26:58.560484', 1, 201);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (67, 38, NULL, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 202);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (67, 20, NULL, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 203);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (68, 28, 72.0000, '2018-06-05 10:53:06.644083', '2018-06-05 10:53:06.644083', 1, 204);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (69, 24, NULL, '2018-06-05 10:53:33.668226', '2018-06-05 10:53:33.668226', 1, 205);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (70, 80, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 206);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (70, 81, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 207);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (70, 83, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 208);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (70, 85, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 209);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 80, NULL, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 210);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 83, NULL, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 211);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 32, NULL, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 212);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 3, 100.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 213);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 1, 80.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 214);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 4, 87.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 215);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (71, 5, 96.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 216);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (72, 28, 67.0000, '2018-06-06 00:38:23.608559', '2018-06-06 00:38:23.608559', 1, 217);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (72, 4, 79.0000, '2018-06-06 00:38:51.463549', '2018-06-06 00:38:51.463549', 1, 218);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (73, 6, 14.0000, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 219);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (73, 7, 1.0000, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 220);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (73, 8, 12.0000, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 221);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (74, 21, NULL, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 222);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (74, 28, 70.0000, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 223);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (74, 29, 178.0000, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 224);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (74, 81, NULL, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 225);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (76, 24, NULL, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 230);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (76, 43, NULL, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 231);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (76, 25, NULL, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 232);
INSERT INTO public.detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) VALUES (76, 53, 200.0000, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 233);


--
-- Data for Name: dia_laborable; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Domingo', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);
INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Lunes', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);
INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Martes', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);
INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Miercoles', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);
INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Jueves', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);
INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 'Viernes', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);
INSERT INTO public.dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'S├íbado', '2018-05-27 04:20:00.679681', '2018-05-27 04:20:00.679681', 1);


--
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Flexiones', '', '2018-05-27 03:19:43.831992', '2018-05-27 03:19:43.831992', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Caminar', '', '2018-05-27 03:27:03.515765', '2018-05-27 03:27:03.515765', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 'Nadar', '', '2018-05-27 03:27:40.961416', '2018-05-27 03:27:40.961416', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 'Practicar yoga', '', '2018-05-27 03:28:07.697147', '2018-05-27 03:28:07.697147', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Abdominales', '', '2018-05-27 03:22:43.333786', '2018-05-27 03:22:43.333786', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 'Trotar', '', '2018-05-27 03:27:17.643707', '2018-05-27 03:27:17.643707', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Sentadillas', '', '2018-05-27 03:22:30.292847', '2018-05-27 03:22:30.292847', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 'Estiramientos', '', '2018-05-27 03:52:19.169825', '2018-05-27 03:52:19.169825', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'Bailar', '', '2018-05-27 03:27:28.10541', '2018-05-27 03:27:28.10541', 1);
INSERT INTO public.ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Plancha', '', '2018-05-27 03:19:13.300073', '2018-05-27 03:19:13.300073', 1);


--
-- Data for Name: empleado; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion, id_especialidad) VALUES (2, 56, 1, 'V-24164375', 'Skarly', 'Ruiz', '04345345545', 'skarlyruiz@gmail.com', 'Mi casa', 1, '2018-05-27 06:59:33.527', '2018-05-27 06:59:33.527', 2);
INSERT INTO public.empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion, id_especialidad) VALUES (3, 57, 1, 'V-22181168', 'Brisleidy', 'Lugo', '04345376545', 'brisleidy@gmail.com', 'Mi casa', 1, '2018-05-27 07:01:28.405', '2018-05-27 07:01:28.405', 1);
INSERT INTO public.empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion, id_especialidad) VALUES (1, 55, 1, 'V-23487734', 'Ana', 'De Palma', '0434535545', 'ana_veck@hotmail.com', 'Mi casa', 1, '2018-05-27 06:58:28.902', '2018-05-27 06:58:28.902', 1);
INSERT INTO public.empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion, id_especialidad) VALUES (5, 59, 2, 'V-12345678', 'Rodrigo', 'Fuentes', '0424-555555', 'rodrigofuentes@gmail.com', 'Mi casa', 1, '2018-05-27 17:48:34.18', '2018-05-27 17:48:34.18', 1);
INSERT INTO public.empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion, id_especialidad) VALUES (4, 54, 1, 'V-21302860', 'Gabriela', 'Perez', '043553789', 'gabrielaperez@gmail.com', 'Mi casa', 1, '2018-05-27 07:02:24.425', '2018-05-27 07:02:24.425', 2);


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (1, 'Deportiva', '2018-05-27 03:55:00.637856', '2018-05-27 03:55:00.637856', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (2, 'Pre-Natal', '2018-05-27 03:56:24.750661', '2018-05-27 03:56:24.750661', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (3, 'Geri├ítrica', '2018-05-27 03:56:53.334369', '2018-05-27 03:56:53.334369', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (4, 'Post-Parto', '2018-05-27 03:57:47.142728', '2018-05-27 03:57:47.142728', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (5, 'Trastornos Alimentarios', '2018-05-27 03:58:22.009477', '2018-05-27 03:58:22.009477', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (6, 'Vegetariana', '2018-05-27 03:59:23.377536', '2018-05-27 03:59:23.377536', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (7, 'Infantil', '2018-05-27 04:01:04.245208', '2018-05-27 04:01:04.245208', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (8, 'Sobrepeso y Obesidad', '2018-05-27 04:02:05.552712', '2018-05-27 04:02:05.552712', 1);
INSERT INTO public.especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) VALUES (9, 'Patolog├¡a', '2018-05-28 22:18:30.383276', '2018-05-28 22:18:30.383276', 1);


--
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.estado_civil (id_estado_civil, nombre, estatus) VALUES (1, 'Soltero/a', 1);
INSERT INTO public.estado_civil (id_estado_civil, nombre, estatus) VALUES (2, 'Comprometido/a', 1);
INSERT INTO public.estado_civil (id_estado_civil, nombre, estatus) VALUES (3, 'Casado/a', 1);
INSERT INTO public.estado_civil (id_estado_civil, nombre, estatus) VALUES (4, 'Divorciado/a', 1);
INSERT INTO public.estado_civil (id_estado_civil, nombre, estatus) VALUES (5, 'Viudo/a', 1);


--
-- Data for Name: estado_solicitud; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.estado_solicitud (id_estado_solicitud, tipo, nombre) VALUES (1, 1, 'Aprobado');
INSERT INTO public.estado_solicitud (id_estado_solicitud, tipo, nombre) VALUES (2, 2, 'Rechazado por horario del empleado ocupado');
INSERT INTO public.estado_solicitud (id_estado_solicitud, tipo, nombre) VALUES (3, 2, 'Rechazado por horario no laborable del empleado');
INSERT INTO public.estado_solicitud (id_estado_solicitud, tipo, nombre) VALUES (4, 2, 'Rechazado por no aceptaci├│n del precio');


--
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 3, 2, '2018-05-27 15:10:15.214611', '2018-05-27 15:10:15.214611', 1);
INSERT INTO public.frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 5, 30, '2018-05-27 15:10:15.214611', '2018-05-27 15:10:15.214611', 1);
INSERT INTO public.frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 3, 1, '2018-05-27 15:10:15.214611', '2018-05-27 15:10:15.214611', 1);


--
-- Data for Name: funcionalidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (1, NULL, 'Dashboard', 'fa fa-leaf', 1, 1, 1, 'dashboard.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (2, NULL, 'Registros B├ísicos', 'fa fa-edit', 2, 1, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (3, NULL, 'Configuraci├│n', 'fa fa-cogs', 3, 1, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (4, NULL, 'Visitas', 'fa fa-calendar', 4, 1, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (5, NULL, 'Ofertas y promociones', 'fa fa-tags', 5, 1, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (6, NULL, 'Reportes', 'fa fa-bar-chart-o', 6, 1, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (7, NULL, 'Administraci├│n del Sistema', 'fa fa-wrench', 7, 1, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (8, 2, 'Unidades', 'fa fa-chevron-right', 1, 2, 1, 'regi_unidad.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (10, 2, 'Tipos de Contacto', 'fa fa-chevron-right', 3, 2, 1, 'regi_tipo_contacto.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (12, 11, 'Alimentos', NULL, 1, 3, 1, 'regi_alimentos.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (13, 11, 'Comidas', NULL, 2, 3, 1, 'regi_comidas.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (14, 11, 'Suplementos', NULL, 3, 3, 1, 'regi_suplementos.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (15, 11, 'Ejercicios', NULL, 4, 3, 1, 'regi_ejercicios.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (16, 11, 'Tipos de Dieta', NULL, 5, 3, 1, 'regi_tipo_dieta.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (17, 2, 'Horario', 'fa fa-chevron-right', 5, 2, 1, 'regi_horario.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (18, 2, 'Condiciones de Garant├¡a', 'fa fa-chevron-right', 6, 2, 1, 'regi_condiciones_garantia.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (19, 2, 'Tipos de Valoraci├│n', 'fa fa-chevron-right', 7, 2, 1, 'regi_tipo_valoracion.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (20, 2, 'Especialidades', 'fa fa-chevron-right', 8, 2, 1, 'regi_especialidad.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (21, 3, 'Par├ímetros', 'fa fa-chevron-right', 1, 2, 1, 'conf_parametros.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (22, 3, 'Sistema', 'fa fa-chevron-right', 2, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (23, 22, 'Motivos y Respuestas', NULL, 1, 3, 1, 'conf_sist_mensajes.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (24, 22, 'Notificaciones', NULL, 2, 3, 1, 'conf_sist_notificacion.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (25, 22, 'Agenda', NULL, 3, 3, 1, 'conf_agenda.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (26, 22, 'Criterios de Valoraci├│n', NULL, 4, 3, 1, 'conf_sist_valoracion.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (27, 22, 'Filtros', NULL, 5, 3, 1, 'conf_sist_filtros.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (28, 3, 'Servicios', 'fa fa-chevron-right', 3, 2, 1, 'conf_servicios.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (29, 3, 'Planes', 'fa fa-chevron-right', 4, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (30, 29, 'Dietas', NULL, 1, 3, 1, 'conf_plan_dieta.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (31, 29, 'Plan de Suplemento', NULL, 2, 3, 1, 'conf_plan_suplemento.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (33, 4, 'Atender', 'fa fa-chevron-right', 1, 2, 1, 'visitas.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (34, NULL, 'Dashboard General', 'fa fa-leaf', 1, 1, 1, 'dashboard2.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (35, 4, 'Incidencias', 'fa fa-chevron-right', 2, 2, 1, 'visi_registrarIncidencia.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (37, 5, 'Reenviar', 'fa fa-chevron-right', 2, 2, 1, 'ofertasYPromocionesReenviar.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (38, 6, 'Estructurados', 'fa fa-chevron-right', 1, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (39, 6, 'Estadisticos', 'fa fa-chevron-right', 2, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (40, 38, 'Solicitudes', '', 1, 3, 1, 'repo_solicitudes.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (46, 39, 'Clientes', '', 3, 3, 1, 'esta_clientes.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (49, 39, 'Valoraciones', '', 6, 3, 1, 'esta_valoracion.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (50, 7, 'Permisologia', 'fa fa-chevron-right', 1, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (51, 7, 'Portal Web', 'fa fa-chevron-right', 2, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (52, 7, 'Comunicacion', 'fa fa-chevron-right', 3, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (55, 51, 'Negocio', '', 1, 3, 1, 'admi_portalWeb-negocio.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (56, 51, 'Contenido', '', 2, 3, 1, 'admi_portalWeb-contenido.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (58, 52, 'Canal de Escucha', '', 2, 3, 1, 'comu_canal_escucha.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (53, 50, 'Roles', '', 1, 3, 1, 'permi_roles.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (54, 50, 'Usuarios', '', 2, 3, 1, 'permi_usuarios.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (36, 5, 'Agregar', 'fa fa-chevron-right', 1, 2, 1, 'ofertasYPromocionesRegistrar.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (32, 29, 'Plan de Entrenamiento', NULL, 3, 3, 1, 'conf_plan_actividad.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (45, 39, 'Efectividad del Servicio', '', 2, 3, 1, 'esta_servicios.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (42, 38, 'Estado de Reclamos', '', 3, 3, 1, 'repo_reclamos.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (47, 39, 'Reclamos Procesados', '', 4, 3, 1, 'esta_reclamos.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (43, 38, 'Contactos', '', 4, 3, 1, 'repo_canalEscucha.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (48, 39, 'Conexi├│n con el cliente', '', 5, 3, 1, 'esta_canalEscucha.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (11, 2, 'Nutrici├│n', 'fa fa-chevron-right', 4, 2, 1, '');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (41, 38, 'Estado del Servicio', '', 2, 3, 1, 'repo_servicios.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (9, 2, 'Tipos de Par├ímetro', 'fa fa-chevron-right', 2, 2, 1, 'regi_tipo_parametro.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (57, 52, 'Atenci├│n de Reclamos', '', 1, 3, 1, 'comu_reclamos.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (60, 7, 'Base de Datos', 'fa fa-chevron-right', 4, 2, 1, 'permi_datos.html');
INSERT INTO public.funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) VALUES (44, 39, 'Empleados', '', 1, 3, 1, 'esta_visitas.html');


--
-- Data for Name: garantia_servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (4, 2, '2018-05-27 05:33:30.338313', '2018-05-27 05:33:30.338313', 1, 3);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (3, 2, '2018-05-27 05:33:30.338177', '2018-05-27 05:33:30.338177', 1, 4);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (2, 3, '2018-05-27 05:37:55.346853', '2018-05-27 05:37:55.346853', 1, 5);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (2, 6, '2018-06-05 05:17:34.789164', '2018-06-05 05:17:34.789164', 1, 22);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (4, 3, '2018-05-27 05:37:55.347151', '2018-05-27 05:37:55.347151', 1, 6);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (3, 6, '2018-06-05 05:17:34.789787', '2018-06-05 05:17:34.789787', 1, 23);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (4, 12, '2018-06-05 05:20:35.084703', '2018-06-05 05:20:35.084703', 1, 25);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (1, 4, '2018-05-27 05:44:48.814992', '2018-05-27 05:44:48.814992', 1, 7);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (4, 13, '2018-06-01 13:22:38.973865', '2018-06-01 13:22:38.973865', 1, 20);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (2, 12, '2018-06-05 05:20:35.084371', '2018-06-05 05:20:35.084371', 1, 24);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (2, 5, '2018-05-27 05:51:09.854955', '2018-05-27 05:51:09.854955', 1, 8);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (1, 13, '2018-06-01 13:22:38.974466', '2018-06-01 13:22:38.974466', 1, 21);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (2, 7, '2018-05-28 17:46:48.051114', '2018-05-28 17:46:48.051114', 1, 11);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (1, 1, '2018-05-28 17:57:15.979704', '2018-05-28 17:57:15.979704', 1, 13);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (3, 1, '2018-05-28 17:57:15.980004', '2018-05-28 17:57:15.980004', 1, 14);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (3, 8, '2018-05-28 22:10:18.623693', '2018-05-28 22:10:18.623693', 1, 15);
INSERT INTO public.garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) VALUES (2, 9, '2018-05-28 22:27:57.815746', '2018-05-28 22:27:57.815746', 1, 17);


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.genero (id_genero, nombre, estatus) VALUES (1, 'Masculino', 1);
INSERT INTO public.genero (id_genero, nombre, estatus) VALUES (2, 'Femenino', 1);


--
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 14, 'Leche y lacteos', '2018-05-27 03:34:47.013629', '2018-05-27 03:34:47.013629', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 1, 'Producto azucarado', '2018-05-27 03:51:43.332945', '2018-05-27 03:51:43.332945', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 1, 'Verduras y hortalizas', '2018-05-27 03:50:19.331', '2018-05-27 03:50:19.331', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 14, 'Aceites y grasas', '2018-05-27 03:51:16.506', '2018-05-27 03:51:16.506', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 1, 'Frutas', '2018-05-27 03:33:36.782', '2018-05-27 03:33:36.782', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 1, 'Pescados', '2018-05-27 03:50:58.713', '2018-05-27 03:50:58.713', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 1, 'Legumbres', '2018-05-27 03:15:14.171', '2018-05-27 03:15:14.171', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 1, 'Carnes y huevos', '2018-05-27 03:50:45.76', '2018-05-27 03:50:45.76', 1);
INSERT INTO public.grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 1, 'Cereales y pasta', '2018-05-27 03:15:42.973', '2018-05-27 03:15:42.973', 1);


--
-- Data for Name: horario_empleado; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 1, 2, '2018-05-27 07:02:35.108065', '2018-05-27 07:02:35.108065', 1, 7);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 3, 2, '2018-05-27 07:02:35.108704', '2018-05-27 07:02:35.108704', 1, 8);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 2, 2, '2018-05-27 07:02:35.108811', '2018-05-27 07:02:35.108811', 1, 9);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 5, 2, '2018-05-27 07:02:35.10942', '2018-05-27 07:02:35.10942', 1, 10);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 4, 2, '2018-05-27 07:02:35.109284', '2018-05-27 07:02:35.109284', 1, 11);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 6, 2, '2018-05-27 07:02:35.110711', '2018-05-27 07:02:35.110711', 1, 12);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 1, 3, '2018-05-27 07:05:52.398084', '2018-05-27 07:05:52.398084', 1, 18);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 2, 3, '2018-05-27 07:05:52.398715', '2018-05-27 07:05:52.398715', 1, 19);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 3, 3, '2018-05-27 07:05:52.400523', '2018-05-27 07:05:52.400523', 1, 20);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 4, 3, '2018-05-27 07:05:52.400881', '2018-05-27 07:05:52.400881', 1, 21);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 5, 3, '2018-05-27 07:05:52.404335', '2018-05-27 07:05:52.404335', 1, 22);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 2, 4, '2018-05-27 07:06:37.452003', '2018-05-27 07:06:37.452003', 1, 23);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 3, 4, '2018-05-27 07:06:37.452347', '2018-05-27 07:06:37.452347', 1, 24);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 5, 4, '2018-05-27 07:06:37.453262', '2018-05-27 07:06:37.453262', 1, 25);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 6, 4, '2018-05-27 07:06:37.454698', '2018-05-27 07:06:37.454698', 1, 26);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 1, 4, '2018-05-27 07:06:37.455034', '2018-05-27 07:06:37.455034', 1, 27);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 4, 4, '2018-05-27 07:06:37.455755', '2018-05-27 07:06:37.455755', 1, 28);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 6, 2, '2018-05-27 07:09:34.917909', '2018-05-27 07:09:34.917909', 1, 34);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 7, 2, '2018-05-27 07:09:34.918171', '2018-05-27 07:09:34.918171', 1, 35);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 8, 2, '2018-05-27 07:09:34.918911', '2018-05-27 07:09:34.918911', 1, 36);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 5, 2, '2018-05-27 07:09:34.91965', '2018-05-27 07:09:34.91965', 1, 37);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 9, 2, '2018-05-27 07:09:34.920911', '2018-05-27 07:09:34.920911', 1, 38);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 1, 3, '2018-05-27 07:12:06.974237', '2018-05-27 07:12:06.974237', 1, 39);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 2, 3, '2018-05-27 07:12:06.974603', '2018-05-27 07:12:06.974603', 1, 40);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 3, 3, '2018-05-27 07:12:06.975234', '2018-05-27 07:12:06.975234', 1, 41);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 5, 3, '2018-05-27 07:12:06.977272', '2018-05-27 07:12:06.977272', 1, 42);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 4, 3, '2018-05-27 07:12:06.977205', '2018-05-27 07:12:06.977205', 1, 43);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 2, 4, '2018-05-27 07:12:54.369125', '2018-05-27 07:12:54.369125', 1, 44);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 3, 4, '2018-05-27 07:12:54.370388', '2018-05-27 07:12:54.370388', 1, 45);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 5, 4, '2018-05-27 07:12:54.373931', '2018-05-27 07:12:54.373931', 1, 46);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 4, 4, '2018-05-27 07:12:54.372805', '2018-05-27 07:12:54.372805', 1, 47);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 1, 4, '2018-05-27 07:12:54.368922', '2018-05-27 07:12:54.368922', 1, 48);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 7, 5, '2018-05-27 07:13:39.066891', '2018-05-27 07:13:39.066891', 1, 49);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 9, 5, '2018-05-27 07:13:39.06791', '2018-05-27 07:13:39.06791', 1, 50);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 6, 5, '2018-05-27 07:13:39.066632', '2018-05-27 07:13:39.066632', 1, 51);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 8, 5, '2018-05-27 07:13:39.070525', '2018-05-27 07:13:39.070525', 1, 52);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 6, 6, '2018-05-27 07:14:26.529584', '2018-05-27 07:14:26.529584', 1, 53);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 7, 6, '2018-05-27 07:14:26.529829', '2018-05-27 07:14:26.529829', 1, 54);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 8, 6, '2018-05-27 07:14:26.531474', '2018-05-27 07:14:26.531474', 1, 55);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (4, 9, 6, '2018-05-27 07:14:26.531826', '2018-05-27 07:14:26.531826', 1, 56);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 2, 2, '2018-05-27 07:19:42.106212', '2018-05-27 07:19:42.106212', 1, 57);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 1, 2, '2018-05-27 07:19:42.105426', '2018-05-27 07:19:42.105426', 1, 59);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 4, 2, '2018-05-27 07:19:42.110253', '2018-05-27 07:19:42.110253', 1, 60);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 5, 2, '2018-05-27 07:19:42.10795', '2018-05-27 07:19:42.10795', 1, 58);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 3, 2, '2018-05-27 07:19:42.106217', '2018-05-27 07:19:42.106217', 1, 61);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 7, 2, '2018-05-27 07:19:42.122038', '2018-05-27 07:19:42.122038', 1, 62);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 9, 2, '2018-05-27 07:19:42.125283', '2018-05-27 07:19:42.125283', 1, 63);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 6, 2, '2018-05-27 07:19:42.119646', '2018-05-27 07:19:42.119646', 1, 65);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 8, 2, '2018-05-27 07:19:42.125252', '2018-05-27 07:19:42.125252', 1, 64);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 1, 3, '2018-05-27 07:20:03.882443', '2018-05-27 07:20:03.882443', 1, 66);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 2, 3, '2018-05-27 07:20:03.88272', '2018-05-27 07:20:03.88272', 1, 67);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 3, 3, '2018-05-27 07:20:03.883413', '2018-05-27 07:20:03.883413', 1, 68);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 4, 3, '2018-05-27 07:20:03.883512', '2018-05-27 07:20:03.883512', 1, 69);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 5, 3, '2018-05-27 07:20:03.883786', '2018-05-27 07:20:03.883786', 1, 70);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 1, 4, '2018-05-27 07:20:24.811278', '2018-05-27 07:20:24.811278', 1, 71);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 2, 4, '2018-05-27 07:20:24.811591', '2018-05-27 07:20:24.811591', 1, 72);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 3, 4, '2018-05-27 07:20:24.81196', '2018-05-27 07:20:24.81196', 1, 73);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 4, 4, '2018-05-27 07:20:24.812304', '2018-05-27 07:20:24.812304', 1, 74);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 5, 4, '2018-05-27 07:20:24.812701', '2018-05-27 07:20:24.812701', 1, 75);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 6, 4, '2018-05-27 07:20:24.813012', '2018-05-27 07:20:24.813012', 1, 76);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 8, 4, '2018-05-27 07:20:24.813737', '2018-05-27 07:20:24.813737', 1, 77);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 7, 4, '2018-05-27 07:20:24.813515', '2018-05-27 07:20:24.813515', 1, 78);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 9, 4, '2018-05-27 07:20:24.814056', '2018-05-27 07:20:24.814056', 1, 79);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 1, 5, '2018-05-27 07:21:22.137752', '2018-05-27 07:21:22.137752', 1, 80);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 4, 5, '2018-05-27 07:21:22.138763', '2018-05-27 07:21:22.138763', 1, 81);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 2, 5, '2018-05-27 07:21:22.141264', '2018-05-27 07:21:22.141264', 1, 82);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 6, 5, '2018-05-27 07:21:22.143471', '2018-05-27 07:21:22.143471', 1, 84);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 9, 5, '2018-05-27 07:21:22.144487', '2018-05-27 07:21:22.144487', 1, 85);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 3, 5, '2018-05-27 07:21:22.145259', '2018-05-27 07:21:22.145259', 1, 86);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 8, 5, '2018-05-27 07:21:22.149256', '2018-05-27 07:21:22.149256', 1, 87);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 7, 5, '2018-05-27 07:21:22.148789', '2018-05-27 07:21:22.148789', 1, 88);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 5, 5, '2018-05-27 07:21:22.14127', '2018-05-27 07:21:22.14127', 1, 83);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 1, 6, '2018-05-27 07:22:00.038323', '2018-05-27 07:22:00.038323', 1, 89);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 2, 6, '2018-05-27 07:22:00.038577', '2018-05-27 07:22:00.038577', 1, 90);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 3, 6, '2018-05-27 07:22:00.039052', '2018-05-27 07:22:00.039052', 1, 91);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 4, 6, '2018-05-27 07:22:00.039287', '2018-05-27 07:22:00.039287', 1, 92);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 5, 6, '2018-05-27 07:22:00.039781', '2018-05-27 07:22:00.039781', 1, 93);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 6, 6, '2018-05-27 07:22:00.039957', '2018-05-27 07:22:00.039957', 1, 94);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 7, 6, '2018-05-27 07:22:00.040606', '2018-05-27 07:22:00.040606', 1, 95);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 9, 6, '2018-05-27 07:22:00.040696', '2018-05-27 07:22:00.040696', 1, 96);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (3, 8, 6, '2018-05-27 07:22:00.040549', '2018-05-27 07:22:00.040549', 1, 97);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 1, 2, '2018-05-27 17:55:07.791709', '2018-05-27 17:55:07.791709', 1, 98);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 2, 2, '2018-05-27 17:55:07.792156', '2018-05-27 17:55:07.792156', 1, 99);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 6, 2, '2018-05-27 17:55:07.793925', '2018-05-27 17:55:07.793925', 1, 100);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 5, 2, '2018-05-27 17:55:07.794478', '2018-05-27 17:55:07.794478', 1, 101);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 3, 2, '2018-05-27 17:55:07.796146', '2018-05-27 17:55:07.796146', 1, 102);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 4, 2, '2018-05-27 17:55:07.79718', '2018-05-27 17:55:07.79718', 1, 103);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 7, 2, '2018-05-27 17:55:07.798565', '2018-05-27 17:55:07.798565', 1, 104);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 8, 2, '2018-05-27 17:55:07.799033', '2018-05-27 17:55:07.799033', 1, 105);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 9, 2, '2018-05-27 17:55:07.800922', '2018-05-27 17:55:07.800922', 1, 106);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 1, 3, '2018-05-27 17:55:44.009694', '2018-05-27 17:55:44.009694', 1, 107);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 2, 3, '2018-05-27 17:55:44.010002', '2018-05-27 17:55:44.010002', 1, 108);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 3, 3, '2018-05-27 17:55:44.010358', '2018-05-27 17:55:44.010358', 1, 109);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 4, 3, '2018-05-27 17:55:44.010736', '2018-05-27 17:55:44.010736', 1, 110);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 5, 3, '2018-05-27 17:55:44.010884', '2018-05-27 17:55:44.010884', 1, 111);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 6, 3, '2018-05-27 17:55:44.011495', '2018-05-27 17:55:44.011495', 1, 112);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 7, 3, '2018-05-27 17:55:44.011611', '2018-05-27 17:55:44.011611', 1, 113);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 9, 3, '2018-05-27 17:55:44.012051', '2018-05-27 17:55:44.012051', 1, 114);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 8, 3, '2018-05-27 17:55:44.012263', '2018-05-27 17:55:44.012263', 1, 115);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 1, 4, '2018-05-27 17:56:10.284179', '2018-05-27 17:56:10.284179', 1, 116);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 2, 4, '2018-05-27 17:56:10.284556', '2018-05-27 17:56:10.284556', 1, 117);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 3, 4, '2018-05-27 17:56:10.284903', '2018-05-27 17:56:10.284903', 1, 118);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 4, 4, '2018-05-27 17:56:10.285263', '2018-05-27 17:56:10.285263', 1, 119);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 5, 4, '2018-05-27 17:56:10.285718', '2018-05-27 17:56:10.285718', 1, 120);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 7, 4, '2018-05-27 17:56:10.286322', '2018-05-27 17:56:10.286322', 1, 121);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 6, 4, '2018-05-27 17:56:10.28637', '2018-05-27 17:56:10.28637', 1, 122);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 9, 4, '2018-05-27 17:56:10.287021', '2018-05-27 17:56:10.287021', 1, 123);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 8, 4, '2018-05-27 17:56:10.287074', '2018-05-27 17:56:10.287074', 1, 124);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 1, 5, '2018-05-27 17:56:28.787896', '2018-05-27 17:56:28.787896', 1, 125);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 2, 5, '2018-05-27 17:56:28.788284', '2018-05-27 17:56:28.788284', 1, 126);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 3, 5, '2018-05-27 17:56:28.790226', '2018-05-27 17:56:28.790226', 1, 127);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 4, 5, '2018-05-27 17:56:28.790653', '2018-05-27 17:56:28.790653', 1, 128);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 5, 5, '2018-05-27 17:56:28.792476', '2018-05-27 17:56:28.792476', 1, 129);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 6, 5, '2018-05-27 17:56:28.795179', '2018-05-27 17:56:28.795179', 1, 130);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 7, 5, '2018-05-27 17:56:28.795737', '2018-05-27 17:56:28.795737', 1, 131);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 8, 5, '2018-05-27 17:56:28.796182', '2018-05-27 17:56:28.796182', 1, 132);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 9, 5, '2018-05-27 17:56:28.796681', '2018-05-27 17:56:28.796681', 1, 133);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 1, 6, '2018-05-27 17:56:41.78275', '2018-05-27 17:56:41.78275', 1, 134);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 2, 6, '2018-05-27 17:56:41.783407', '2018-05-27 17:56:41.783407', 1, 136);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 8, 6, '2018-05-27 17:56:41.785567', '2018-05-27 17:56:41.785567', 1, 141);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 9, 6, '2018-05-27 17:56:41.785853', '2018-05-27 17:56:41.785853', 1, 142);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 6, 6, '2018-05-27 17:56:41.784213', '2018-05-27 17:56:41.784213', 1, 138);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 5, 6, '2018-05-27 17:56:41.78459', '2018-05-27 17:56:41.78459', 1, 139);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 7, 6, '2018-05-27 17:56:41.784843', '2018-05-27 17:56:41.784843', 1, 140);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 3, 6, '2018-05-27 17:56:41.783402', '2018-05-27 17:56:41.783402', 1, 135);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 2, 7, '2018-06-03 00:31:00.252508', '2018-06-03 00:31:00.252508', 1, 143);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 5, 7, '2018-06-03 00:31:00.252736', '2018-06-03 00:31:00.252736', 1, 144);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 3, 7, '2018-06-03 00:31:00.252953', '2018-06-03 00:31:00.252953', 1, 145);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 4, 7, '2018-06-03 00:31:00.252013', '2018-06-03 00:31:00.252013', 1, 146);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (2, 1, 7, '2018-06-03 00:31:00.253198', '2018-06-03 00:31:00.253198', 1, 147);
INSERT INTO public.horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) VALUES (5, 4, 6, '2018-05-27 17:56:41.784139', '2018-05-27 17:56:41.784139', 1, 137);


--
-- Data for Name: incidencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (1, 2, 23, 'Disculpe! no podr├® asistir a la visita', '2018-05-27 16:53:31.614384', '2018-05-27 16:53:31.614384', 1, 2);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (2, 2, 22, 'Problemas personales del cliente', '2018-06-01 06:11:52.748295', '2018-06-01 06:11:52.748295', 1, 11);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (3, 2, 17, 'Falla en el servicio electrico', '2018-06-01 06:18:59.768758', '2018-06-01 06:18:59.768758', 1, 18);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (4, 2, 17, 'Presentamos fallas el├®ctricas desde la 7:00 am, Disculpe las molestias', '2018-06-04 20:18:22.10014', '2018-06-04 20:18:22.10014', 1, 24);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (5, 2, 23, 'no habia transporte y pude llegar a tiempo, disculpe las molestias causada', '2018-06-05 20:17:16.96173', '2018-06-05 20:17:16.96173', 1, 82);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (9, 1, 22, NULL, '2018-06-06 02:37:12.56515', '2018-06-06 02:37:12.56515', 1, 107);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (10, 1, 22, NULL, '2018-06-06 02:38:19.124287', '2018-06-06 02:38:19.124287', 1, 107);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (11, 1, 23, NULL, '2018-06-06 03:09:41.896546', '2018-06-06 03:09:41.896546', 1, 110);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (12, 2, 17, 'Lo siento, no puedo atenderte sin luz', '2018-06-06 03:24:22.257471', '2018-06-06 03:24:22.257471', 1, 61);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (13, 2, 23, 'No podre llegar a la cita', '2018-06-06 03:37:47.756137', '2018-06-06 03:37:47.756137', 1, 38);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (14, 1, 22, '  ', '2018-06-06 04:19:17.522723', '2018-06-06 04:19:17.522723', 1, 117);
INSERT INTO public.incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (15, 1, 22, '  ', '2018-06-06 04:59:12.467722', '2018-06-06 04:59:12.467722', 1, 120);


--
-- Data for Name: motivo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 4, 'El nutricionista nunca llego a la visita', '2018-05-27 04:49:54.314', '2018-05-27 04:49:54.314', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 4, 'Me trataron mal', '2018-05-27 05:47:34.665603', '2018-05-27 05:47:34.665603', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 1, 'Deseo recuperar mi peso', '2018-05-27 05:47:58.243565', '2018-05-27 05:47:58.243565', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 1, 'Quiero perder peso', '2018-05-27 05:48:19.602962', '2018-05-27 05:48:19.602962', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 1, 'Quiero cuidar mi salud', '2018-05-27 05:48:34.190767', '2018-05-27 05:48:34.190767', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 1, 'Quiero mejorar mi figura', '2018-05-27 05:49:59.978109', '2018-05-27 05:49:59.978109', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 1, 'Deseo conocer opciones para mi alimentaci├│n', '2018-05-27 05:50:24.931047', '2018-05-27 05:50:24.931047', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 1, 'Deseo aumentar de peso', '2018-05-27 05:52:38.733574', '2018-05-27 05:52:38.733574', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 1, 'Quiero aumentar mi masa muscular', '2018-05-27 05:52:58.970269', '2018-05-27 05:52:58.970269', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 1, 'Quiero recomendaciones para deportistas', '2018-05-27 05:53:34.378199', '2018-05-27 05:53:34.378199', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 2, 'El plan no me funcion├│', '2018-05-27 05:53:59.928', '2018-05-27 05:53:59.928', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 2, 'Termine el servicio y no alcanc├® la meta', '2018-05-27 05:57:41.71346', '2018-05-27 05:57:41.71346', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 2, 'Perdi una visita por el nutricionista', '2018-05-27 05:58:10.474954', '2018-05-27 05:58:10.474954', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 3, 'No hay electricidad', '2018-05-27 05:58:36.559679', '2018-05-27 05:58:36.559679', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 4, 'Atendieron un paciente en mi turno', '2018-05-27 05:59:56.103505', '2018-05-27 05:59:56.103505', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 6, '┬┐ Puedo cambiar de nutricionista?', '2018-05-27 06:00:48.138111', '2018-05-27 06:00:48.138111', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 5, 'Deberian tener un nutricionista familiar', '2018-05-27 06:02:58.155', '2018-05-27 06:02:58.155', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 3, 'Ausencia por paro de transporte', '2018-05-27 06:07:07.235753', '2018-05-27 06:07:07.235753', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 1, 'Padezco una condicion', '2018-05-27 06:10:14.030172', '2018-05-27 06:10:14.030172', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 1, 'Quiero alimentaci├│n para el embarazo', '2018-05-27 06:10:42.536631', '2018-05-27 06:10:42.536631', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 6, '┬┐Puedo cambiar mi plan?', '2018-05-27 06:13:15.172', '2018-05-27 06:13:15.172', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 8, 'Necesitan un local mas amplio', '2018-05-27 19:23:31.540296', '2018-05-27 19:23:31.540296', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 6, 'Puedo llevar mis resultados otro dia que no este programado?', '2018-05-27 19:24:38.844111', '2018-05-27 19:24:38.844111', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 4, 'Acerca del servicio', '2018-05-27 19:24:55.727526', '2018-05-27 19:24:55.727526', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 4, 'Acerca de la atenci├│n', '2018-05-27 19:25:12.4785', '2018-05-27 19:25:12.4785', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 4, 'Acerca de la infraestructura', '2018-05-27 19:25:30.406209', '2018-05-27 19:25:30.406209', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 5, 'Acerca de un plan', '2018-05-27 19:25:45.616091', '2018-05-27 19:25:45.616091', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 5, 'Acerca de un servcicio', '2018-05-27 19:26:03.138619', '2018-05-27 19:26:03.138619', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 8, 'Sobre el servcicio', '2018-05-27 19:26:26.930795', '2018-05-27 19:26:26.930795', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 8, 'Acerca de la infraestructura', '2018-05-27 19:26:50.540704', '2018-05-27 19:26:50.540704', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 6, '┬┐ Puedo conocer el horario de mi nutricionista?', '2018-05-27 06:01:19.574', '2018-05-27 06:01:19.574', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 1, 'Padezco una enfermedad', '2018-05-27 05:51:55.851', '2018-05-27 05:51:55.851', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 7, 'Encantada con el servicio prestado', '2018-05-29 22:47:54.539154', '2018-05-29 22:47:54.539154', 1);
INSERT INTO public.motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 3, 'No puedo asistir, por motivos personales', '2018-05-27 06:06:36.048', '2018-05-27 06:06:36.048', 1);


--
-- Data for Name: negocio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.negocio (id_negocio, razon_social, rif, url_logo, mision, vision, objetivo, telefono, correo, latitud, longitud, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'Sascha Nutric', 'J-13829393-0', 'http://res.cloudinary.com/saschanutric/image/upload/v1527844768/q3b6srkrvymapzyt8kzj.png', 'Aportar valor a la nutrici├│n cl├¡nica cubriendo las necesidades nutricionales y farmacol├│gicas de los pacientes, ofreciendo productos de m├íxima calidad a los profesionales sanitarios para mejorar la salud y el bienestar de la sociedad.', 'Ser la empresa de elecci├│n para nuestros clientes, convirti├®ndonos en referentes de la Nutrici├│n Cl├¡nica, con enfoque en la excelencia e innovaci├│n de nuestros productos.', '', '0424-424430', 'saschanutric@gmail.com', 50.0000000, 50.0000000, '2018-06-01 05:55:15.349', '2018-06-01 05:55:15.349', 1);


--
-- Data for Name: notificacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (268, 62, NULL, 'Respuesta a Agregar productos mas baratos', 'Para la proxima semana puede comer piedras', 9, '2018-06-01 14:07:52.837866', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (269, 1, 10, 'Promoci├│n', 'Nury Amaro tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (270, 2, 10, 'Promoci├│n', 'Magdaly Atacho tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (271, 3, 10, 'Promoci├│n', 'Valmore Canelon tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (272, 4, 10, 'Promoci├│n', 'Rhonal Chirinos tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (273, 5, 10, 'Promoci├│n', 'Conni Duarte tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (274, 6, 10, 'Promoci├│n', 'Yuri Freitez tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (275, 7, 10, 'Promoci├│n', 'Wualter  tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (276, 8, 10, 'Promoci├│n', 'Jaimary  tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (277, 9, 10, 'Promoci├│n', 'Jose Rodriguez tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (278, 10, 10, 'Promoci├│n', 'Marianceli Subero tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (279, 11, 10, 'Promoci├│n', 'Kenderson Torrealba tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (280, 12, 10, 'Promoci├│n', 'Richard Velasquez tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (281, 13, 10, 'Promoci├│n', 'Yorneydis Vivas tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (282, 14, 10, 'Promoci├│n', 'Ruben Alvarado tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (283, 15, 10, 'Promoci├│n', 'Ivan Brice├▒o tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (284, 16, 10, 'Promoci├│n', 'Orlando Cuervo tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (285, 17, 10, 'Promoci├│n', 'Desiree Dorantes tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (286, 18, 10, 'Promoci├│n', 'Austria Loyo Villalobos tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (287, 19, 10, 'Promoci├│n', 'Edarling Mendoza tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (288, 20, 10, 'Promoci├│n', 'Luis David Orozco tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (289, 21, 10, 'Promoci├│n', 'Julio Cesar Paredes tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (290, 22, 10, 'Promoci├│n', 'Julio Cesar Paredes tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (291, 28, 10, 'Promoci├│n', 'Karem Alvarado tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (292, 29, 10, 'Promoci├│n', 'Ana Victoria De Palma tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (293, 32, 10, 'Promoci├│n', 'Brisleidy Lugo Mujica tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (294, 33, 10, 'Promoci├│n', 'Hilmary Nieto tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (295, 34, 10, 'Promoci├│n', 'Pedro Orellana tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (296, 35, 10, 'Promoci├│n', 'Gabriela Perez tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (297, 36, 10, 'Promoci├│n', 'Indira Perez Flores tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (298, 37, 10, 'Promoci├│n', 'Leonardo Pineda tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (299, 42, 10, 'Promoci├│n', 'Juan Carlos Aldana tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (300, 43, 10, 'Promoci├│n', 'Sohecdy ALvarado tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (301, 44, 10, 'Promoci├│n', 'Maria Nathali Anzola tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (302, 45, 10, 'Promoci├│n', 'Ruben Bello tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (303, 46, 10, 'Promoci├│n', 'Jose Alfredo Encinoza tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (304, 47, 10, 'Promoci├│n', 'Javier Escalona tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (305, 48, 10, 'Promoci├│n', 'Laurymar Luque tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (306, 49, 10, 'Promoci├│n', 'Joselyn Serrano tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (307, 52, 10, 'Promoci├│n', 'Yanior Zambrano tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (308, 53, 10, 'Promoci├│n', 'Luis Alvarado tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (309, 61, 10, 'Promoci├│n', 'belinda Riera tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:18:04.716118', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (310, 23, 10, 'Promoci├│n', 'Josmary Pulgar tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (311, 24, 10, 'Promoci├│n', 'Yosbely Ramos tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (312, 26, 10, 'Promoci├│n', 'Francisco Veasquez tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (313, 27, 10, 'Promoci├│n', 'Gessimar Yagua tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (314, 30, 10, 'Promoci├│n', 'Abdel Gainza tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (315, 31, 10, 'Promoci├│n', 'Jose Alberto Guerrero tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (316, 58, 10, 'Promoci├│n', 'Maria Franchezka Perez Sanchez tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (317, 60, 10, 'Promoci├│n', 'Sascha Barboza tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (318, 62, 10, 'Promoci├│n', 'Manuel de jesus Crespo tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (319, 63, 10, 'Promoci├│n', 'Manuel Crespo tenemos la promoci├│n Promocion 01-06 adaptada para ti, con un descuento del 10% en el servicio Adultos mayores', 2, '2018-06-01 14:21:13.228113', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (320, 7, NULL, 'Respuesta a Felicidades!', 'dsfdsf', 9, '2018-06-01 22:12:23.623822', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (321, 62, NULL, 'Respuesta a Agregar productos mas baratos', 'hhhhhhhhhhhhhhhhhhhhhhh', 9, '2018-06-01 22:13:54.969833', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (322, 48, NULL, 'Respuesta a seria un novedoso servicio', 'Gracias por su sugerencia!', 9, '2018-06-02 21:22:21.86529', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (323, 48, NULL, 'Respuesta a no cumplieron con mi horario de atencion', 'Mil disculpas, trabajaremos para que no vuelva a suceder', 9, '2018-06-02 21:23:40.466482', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (324, 48, NULL, 'Respuesta a no me informaron que debia reprogramar', 'Sera contactado a la brevedad', 9, '2018-06-02 21:26:29.889927', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (325, 48, NULL, 'Respuesta a el nutricionista es grosero', 'Su comentario nos ayuda a mejorar', 9, '2018-06-02 21:27:05.186802', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (328, 25, NULL, 'Respuesta a el plan para adelgazar deberia tener mas ejercicios  ', 'Gracias por su sugerencia!', 9, '2018-06-04 01:23:39.107645', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (329, 49, NULL, 'Respuesta a hagan una promocion', 'Lo tomaremos en cuenta, Joselyn', 9, '2018-06-04 06:54:54.386848', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (330, 16, NULL, 'Reclamo Aprobado, garant├¡a disponible', 'Disculpe las molestias causadas, procederemos a habilitar una nueva cita', 7, '2018-06-04 18:55:00.629632', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (331, 62, NULL, 'Reclamo Rechazado', 'Su reclamo no procede, por favor revise las condiciones de garantia.', 6, '2018-06-04 18:55:00.629632', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (332, 28, NULL, 'Reclamo Aprobado, garant├¡a disponible', 'Disculpe las molestias ocasionadas. Le sera asignado un nuevo nutricionista.', 7, '2018-06-04 18:55:00.629632', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (333, 17, NULL, 'Ha ocurrido una incidencia', 'Presentamos fallas el├®ctricas desde la 7:00 am, Disculpe las molestias', 4, '2018-06-04 20:18:22.10014', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (334, 49, NULL, 'Respuesta a me parece que no me esta funcionando mi plan actual', 'puede hacerlo una vez el servicio sea valorado y proceda a solicitar un nuevo servicio acorde a sus necesidades', 9, '2018-06-05 02:53:48.171567', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (335, 16, NULL, 'Reclamo Rechazado', 'Disculpe, su reclamo no procede', 6, '2018-06-05 03:08:31.735061', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (336, 25, NULL, 'Reclamo Aprobado, garant├¡a disponible', 'Disculpe las molestias causadas, procederemos a habilitar una nueva cita', 7, '2018-06-05 03:35:04.314742', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (337, 44, NULL, 'Reclamo Rechazado', 'Disculpe, su reclamo no procede', 6, '2018-06-05 03:38:31.53292', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (338, 25, NULL, 'Reclamo Aprobado, garant├¡a disponible', 'Disculpe las molestias ocasionadas. Le sera asignado un nuevo nutricionista.', 7, '2018-06-05 03:39:18.603669', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (339, 53, NULL, 'Respuesta a me recomendaron otro', 'Es recomendable que continu├® y culmine su servicio con el nutricionista seleccionado', 9, '2018-06-05 03:44:29.615579', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (340, 53, NULL, 'Respuesta a La recepcionista fue grosera', 'Le daremos una repuesta que cubra las molestias ocacionadas', 9, '2018-06-05 03:46:12.771215', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (341, 17, NULL, 'Respuesta a excelente', 'Nos encanta satisfacer a nuestros clientes.', 9, '2018-06-05 03:47:51.022129', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (342, 18, NULL, 'Respuesta a necesitan un plan para personas jovenes', 'su opini├│n es importante.', 9, '2018-06-05 03:49:59.439533', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (343, 11, NULL, 'Respuesta a recomendacion', 'Queremos mejorar nuestros servicios es por eso que tu recomendaci├│n sera tomada en cuenta', 9, '2018-06-05 03:59:26.899532', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (344, 49, NULL, 'Respuesta a la recepcionista paso otro paciente cuando me tocaba a mi', 'Perdone atenderemos su queja.', 9, '2018-06-05 04:00:42.837163', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (345, 51, NULL, 'Respuesta a agreguen este servicio', 'Tomaremos en cuenta su comentario.', 9, '2018-06-05 04:01:27.598168', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (346, 9, NULL, 'Respuesta a Excelente servicio.', 'Nos encanta que te sientas conforme.', 9, '2018-06-05 04:04:00.428663', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (347, 30, NULL, 'Respuesta a espere por una hora y el nutricionista no llego, ademas nadie me notifico la razon por la cual el nutricionista no asistio', 'Pedimos disculpas por las molestias ocacionadas', 9, '2018-06-05 04:15:12.74077', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (348, 12, NULL, 'Respuesta a Necesitan un plan para parejas', 'tomaremos en cuenta su comentario', 9, '2018-06-05 04:19:52.972837', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (349, 23, NULL, 'Respuesta a llevar examenes', 'Lo ideal seria que entregara sus resultados el dia que este programado.', 9, '2018-06-05 04:21:59.252751', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (350, 9, NULL, 'Respuesta a No me avisaron', 'disculpes las molestias ocasionadas.', 9, '2018-06-05 04:23:12.445861', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (351, 9, NULL, 'Respuesta a No me avisaron', 'disculpes las molestias ocasionadas.', 9, '2018-06-05 04:23:12.74551', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (352, 23, NULL, 'Respuesta a me encanta el servicio', 'Nos encanta servirte.', 9, '2018-06-05 04:23:57.217357', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (353, 23, NULL, 'Respuesta a me encanta el servicio', 'Nos encanta servirte.', 9, '2018-06-05 04:23:57.559108', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (354, 23, NULL, 'Respuesta a me encanta el servicio', 'Nos encanta servirte.', 9, '2018-06-05 04:23:57.92195', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (355, 33, NULL, 'Respuesta a Excelente servicio', 'Nos encanta servirte.', 9, '2018-06-05 04:24:34.426854', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (356, 20, NULL, 'Respuesta a buen servicio', 'Nos encanta servirte.', 9, '2018-06-05 04:25:16.081293', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (357, 21, NULL, 'Respuesta a Excelente servicio', 'Nos encanta que est├®s satisfecho estamos para servirte.', 9, '2018-06-05 04:25:59.414738', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (358, 9, NULL, 'Respuesta a quisiera cambiar mi plan', 'sino estas satisfecho o quieres retirarte debes reclamar el servicio ,para obtener otro plan.', 9, '2018-06-05 04:27:15.748007', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (359, 23, NULL, 'Respuesta a quiero un plan para esposos', 'tomaremos en cuenta su sugerencia.', 9, '2018-06-05 04:35:50.957377', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (360, 33, NULL, 'Respuesta a quisiera que me atendiera Jose', 'evaluaremos su solicitud.', 9, '2018-06-05 04:36:50.456978', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (365, 16, NULL, 'Respuesta a Necesitan un servicio para parejas', 'pronto implementaremos este servicio en nuestro catalogo', 9, '2018-06-05 04:49:41.339169', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (367, 13, NULL, 'Respuesta a Felicidades!', 'Nos encanta complacerte .', 9, '2018-06-05 04:52:13.345062', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (361, 53, NULL, 'Respuesta a deseo ir con mi familia', 'Su sugerencias son importantes ser├ín tomadas en cuenta.', 9, '2018-06-05 04:46:29.020464', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (369, 14, NULL, 'Respuesta a podrian tener un plan para celiacos', 'Le daremos una respuesta  a la brevedad posible.', 9, '2018-06-05 04:54:58.426547', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (362, 13, NULL, 'Respuesta a como puedo cambiarlo?', 'evaluaremos su solicitud y daremos una respuesta apropiada muy pronto', 9, '2018-06-05 04:47:16.791791', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (363, 33, NULL, 'Respuesta a Deberian tener un servicio para parejas', 'Su opini├│n es importante , sera tomada en cuenta.', 9, '2018-06-05 04:48:48.248232', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (366, 15, NULL, 'Respuesta a Este plan ya no me funciona', 'debe reclamar el plan que posee actualmente para poder terminar su recorrido y solicitar un nuevo servicio.', 9, '2018-06-05 04:51:01.197528', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (368, 51, NULL, 'Respuesta a no me avisaron que el nutricionista no vendria', 'Pedimos disculpas por las molestias ocasionadas.', 9, '2018-06-05 04:52:59.868538', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (370, 51, NULL, 'Respuesta a quiero saber que dias trabaja', 'Gracias por preguntar', 9, '2018-06-05 06:04:59.020125', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (371, 33, NULL, 'Respuesta a Mi nutricionista trabaja los sabados?', 'Gracias por preguntar', 9, '2018-06-05 06:26:00.672101', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (372, 15, NULL, 'Respuesta a Excelente ejercicio', 'Gracias por su opini├│n.', 9, '2018-06-05 16:56:26.888363', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (375, 25, NULL, 'Respuesta a me encanto el servicio', 'Gracias por su opini├│n.', 9, '2018-06-05 17:02:15.131864', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (376, 36, NULL, 'Ha ocurrido una incidencia', 'no habia transporte y pude llegar a tiempo, disculpe las molestias causada', 4, '2018-06-05 20:17:16.96173', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (393, 64, NULL, 'Reclamo Aprobado, garant├¡a disponible', 'Disculpe las molestias ocasionadas. Le sera asignado un nuevo nutricionista.', 7, '2018-06-06 02:50:34.966746', 8);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (395, 23, NULL, 'Ha ocurrido una incidencia', 'Lo siento, no puedo atenderte sin luz', 4, '2018-06-06 03:24:22.257471', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (396, 60, NULL, 'Ha ocurrido una incidencia', 'No podre llegar a la cita', 4, '2018-06-06 03:37:47.756137', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (399, 45, NULL, 'Cita agendada', 'Hola Ruben Bello, tienes una cita de Diagnostico con Rodrigo Fuentes el d├¡a 2018-06-08 a las 16:00:00', 3, '2018-06-06 03:55:51.548749', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (404, 45, NULL, 'Cita agendada', 'Hola Ruben Bello, tienes una cita de Control con Rodrigo Fuentes el d├¡a 2018-07-05 a las 10:00:00', 3, '2018-06-06 04:15:17.561291', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (406, 45, NULL, 'Cita agendada', 'Hola Ruben Bello, tienes una cita de Diagnostico con Rodrigo Fuentes el d├¡a 2018-06-29 a las 09:00:00', 3, '2018-06-06 04:47:31.727616', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (409, 45, NULL, 'Cita agendada', 'Hola Ruben Bello, tienes una cita de Control con Rodrigo Fuentes el d├¡a 2018-08-01 a las 10:00:00', 3, '2018-06-06 04:55:27.56368', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (411, 45, NULL, 'Cita agendada', 'Hola Ruben Bello, tienes una cita de Control con Rodrigo Fuentes el d├¡a 2018-07-19 a las 11:00:00', 3, '2018-06-06 05:00:11.407749', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (412, 12, 13, 'Promoci├│n', 'Richard Velasquez tenemos la promoci├│n Promo Dulce adaptada para ti, con un descuento del 10% en el servicio Diabeticos', 2, '2018-06-06 05:43:14.245374', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (413, 45, 13, 'Promoci├│n', 'Ruben Bello tenemos la promoci├│n Promo Dulce adaptada para ti, con un descuento del 10% en el servicio Diabeticos', 2, '2018-06-06 05:43:14.245374', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (416, 16, NULL, 'Cita agendada', 'Hola Orlando Cuervo, tienes una cita de Diagnostico con Skarly Ruiz el d├¡a 2018-06-27 a las 10:00:00', 3, '2018-06-06 14:48:39.764145', NULL);
INSERT INTO public.notificacion (id_notificacion, id_usuario, id_promocion, titulo, mensaje, tipo_notificacion, fecha_creacion, id_servicio) VALUES (417, 56, NULL, 'Nueva orden de servicio aprobada', 'Orlando Cuervo es tu nuevo cliente, y tendr├í su cita de diagn├│stico el d├¡a 2018-06-27 a las 10:00:00 para el servicio B├ísico', 1, '2018-06-06 14:48:39.764145', NULL);


--
-- Data for Name: orden_servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (3, 16, 1, NULL, '2018-05-27', '2018-06-27', NULL, '2018-05-27 14:43:27.654822', '2018-05-27 14:43:27.654822', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (5, 23, 1, NULL, '2018-05-27', '2018-06-27', NULL, '2018-05-27 18:21:13.531347', '2018-05-27 18:21:13.531347', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (6, 24, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 00:44:11.240641', '2018-05-29 00:44:11.240641', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (7, 25, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 00:46:54.167265', '2018-05-29 00:46:54.167265', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (8, 26, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 01:14:47.108441', '2018-05-29 01:14:47.108441', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (9, 27, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 01:18:36.565882', '2018-05-29 01:18:36.565882', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (10, 29, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 01:34:50.117839', '2018-05-29 01:34:50.117839', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (11, 30, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 01:51:29.261905', '2018-05-29 01:51:29.261905', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (13, 33, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 19:35:26.143224', '2018-05-30 19:35:26.143224', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (14, 34, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 19:41:00.311832', '2018-05-30 19:41:00.311832', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (15, 35, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 19:45:17.097513', '2018-05-30 19:45:17.097513', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (16, 36, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 19:49:05.950677', '2018-05-30 19:49:05.950677', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (17, 38, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 19:55:01.86682', '2018-05-30 19:55:01.86682', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (18, 40, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 20:12:43.998593', '2018-05-30 20:12:43.998593', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (19, 41, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 20:23:18.607635', '2018-05-30 20:23:18.607635', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (21, 45, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 20:38:46.023439', '2018-05-30 20:38:46.023439', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (22, 46, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 20:47:23.921972', '2018-05-30 20:47:23.921972', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (23, 47, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 20:59:07.481534', '2018-05-30 20:59:07.481534', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (24, 48, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 21:55:35.692019', '2018-05-30 21:55:35.692019', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (25, 50, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 22:01:13.244598', '2018-05-30 22:01:13.244598', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (27, 54, 1, NULL, '2018-05-31', '2018-06-30', NULL, '2018-05-31 08:18:37.936665', '2018-05-31 08:18:37.936665', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (28, 55, 1, NULL, '2018-05-31', '2018-06-30', NULL, '2018-05-31 11:40:05.155587', '2018-05-31 11:40:05.155587', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (30, 59, 1, NULL, '2018-06-01', '2018-07-01', NULL, '2018-06-01 07:50:39.640549', '2018-06-01 07:50:39.640549', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (31, 64, 1, NULL, '2018-06-01', '2018-07-01', 9, '2018-06-01 13:27:56.268', '2018-06-01 13:27:56.268', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (4, 20, 1, NULL, '2018-05-27', '2018-06-27', 10, '2018-05-27 15:14:16.678', '2018-05-27 15:14:16.678', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (29, 57, 1, NULL, '2018-06-01', '2018-07-01', 11, '2018-06-01 07:12:29.375', '2018-06-01 07:12:29.375', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (37, 67, 1, NULL, '2018-06-03', '2018-07-03', 12, '2018-06-03 22:42:51.297', '2018-06-03 22:42:51.297', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (38, 69, 1, NULL, '2018-06-03', '2018-07-03', 13, '2018-06-03 22:59:39.418', '2018-06-03 22:59:39.418', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (2, 15, 1, NULL, '2018-05-27', '2018-06-27', NULL, '2018-05-27 14:28:38.912', '2018-05-27 14:28:38.912', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (12, 32, 1, NULL, '2018-05-29', '2018-06-29', NULL, '2018-05-29 20:37:46.092', '2018-05-29 20:37:46.092', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (26, 52, 1, NULL, '2018-05-31', '2018-06-30', 14, '2018-05-31 07:16:47.582', '2018-05-31 07:16:47.582', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (39, 70, 1, NULL, '2018-06-04', '2018-07-04', 15, '2018-06-04 00:49:00.953', '2018-06-04 00:49:00.953', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (43, 71, 1, NULL, '2018-06-04', '2018-07-04', NULL, '2018-06-04 11:48:07.755443', '2018-06-04 11:48:07.755443', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (44, 72, 1, NULL, '2018-06-04', '2018-07-04', NULL, '2018-06-04 13:38:16.74193', '2018-06-04 13:38:16.74193', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (45, 75, 1, NULL, '2018-06-05', '2018-07-05', NULL, '2018-06-05 01:10:14.699716', '2018-06-05 01:10:14.699716', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (20, 42, 1, NULL, '2018-05-30', '2018-06-30', NULL, '2018-05-30 20:28:05.812', '2018-05-30 20:28:05.812', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (47, 77, 1, NULL, '2018-06-05', '2018-07-05', NULL, '2018-06-05 06:01:37.784926', '2018-06-05 06:01:37.784926', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (46, 76, 1, NULL, '2018-06-05', '2018-07-05', NULL, '2018-06-05 04:11:37.388', '2018-06-05 04:11:37.388', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (48, 79, 1, NULL, '2018-06-05', '2018-07-05', NULL, '2018-06-05 08:42:37.542', '2018-06-05 08:42:37.542', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (49, 81, 1, NULL, '2018-06-05', '2018-07-05', NULL, '2018-06-05 09:46:30.43', '2018-06-05 09:46:30.43', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (50, 82, 1, NULL, '2018-06-05', '2018-07-05', NULL, '2018-06-05 17:05:39.950113', '2018-06-05 17:05:39.950113', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (51, 83, 1, NULL, '2018-06-05', '2018-07-05', 24, '2018-06-05 20:33:46.433', '2018-06-05 20:33:46.433', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (53, 85, 1, NULL, '2018-06-05', '2018-07-05', 30, '2018-06-05 22:48:49.922', '2018-06-05 22:48:49.922', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (54, 86, 1, NULL, '2018-06-06', '2018-07-06', 31, '2018-06-06 00:01:54.216', '2018-06-06 00:01:54.216', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (55, 88, 1, NULL, '2018-06-06', '2018-07-06', NULL, '2018-06-06 00:22:47.783', '2018-06-06 00:22:47.783', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (56, 89, 1, NULL, '2018-06-06', '2018-07-06', 32, '2018-06-06 02:44:15.718', '2018-06-06 02:44:15.718', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (57, 90, 1, NULL, '2018-06-06', '2018-07-06', NULL, '2018-06-06 02:53:07.004', '2018-06-06 02:53:07.004', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (52, 84, 1, NULL, '2018-06-05', '2018-07-05', 33, '2018-06-05 21:16:59.072', '2018-06-05 21:16:59.072', 1, 2);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (62, 95, 1, NULL, '2018-06-06', '2018-07-06', NULL, '2018-06-06 03:55:51.548', '2018-06-06 03:55:51.548', 1, 3);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (63, 96, 1, NULL, '2018-06-06', '2018-07-06', NULL, '2018-06-06 04:47:31.727616', '2018-06-06 04:47:31.727616', 1, 1);
INSERT INTO public.orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus, estado) VALUES (64, 97, 1, NULL, '2018-06-06', '2018-07-06', NULL, '2018-06-06 14:48:39.764145', '2018-06-06 14:48:39.764145', 1, 1);


--
-- Data for Name: parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 3, 12, 2, '├ücido folico', '2018-05-27 03:57:09.359505', '2018-05-27 03:57:09.359505', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 3, 12, 2, 'Hierro', '2018-05-27 03:57:57.720671', '2018-05-27 03:57:57.720671', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 3, 10, 2, 'Calcio', '2018-05-27 03:58:22.166829', '2018-05-27 03:58:22.166829', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 3, 10, 2, 'Colesterol', '2018-05-27 03:59:17.299503', '2018-05-27 03:59:17.299503', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 3, 10, 2, 'Trigliceridos', '2018-05-27 03:59:42.048672', '2018-05-27 03:59:42.048672', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 3, 11, 2, 'Hemoglobina', '2018-05-27 04:00:03.854588', '2018-05-27 04:00:03.854588', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 3, 10, 2, '├ücido ├║rico', '2018-05-27 04:00:35.749815', '2018-05-27 04:00:35.749815', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 3, 10, 2, 'HDL', '2018-05-27 04:01:08.02141', '2018-05-27 04:01:08.02141', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 3, 10, 2, 'LDL', '2018-05-27 04:01:32.490049', '2018-05-27 04:01:32.490049', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 3, 10, 2, 'VLDL', '2018-05-27 04:02:36.461353', '2018-05-27 04:02:36.461353', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 3, 11, 2, 'CHCM', '2018-05-27 04:03:12.163204', '2018-05-27 04:03:12.163204', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 3, 10, 2, 'Urea', '2018-05-27 04:04:38.929353', '2018-05-27 04:04:38.929353', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 3, 10, 2, 'Glucosa', '2018-05-27 04:04:56.699077', '2018-05-27 04:04:56.699077', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 6, NULL, 1, 'Osteoporosis', '2018-05-27 04:05:54.452628', '2018-05-27 04:05:54.452628', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 2, NULL, 1, 'Vegetariano', '2018-05-27 04:06:10.885174', '2018-05-27 04:06:10.885174', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 6, NULL, 1, 'Celiaca', '2018-05-27 04:09:08.589682', '2018-05-27 04:09:08.589682', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 6, NULL, 1, 'Colitis ulcerosa', '2018-05-27 04:09:41.346406', '2018-05-27 04:09:41.346406', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 6, NULL, 1, 'Trombosis', '2018-05-27 04:10:35.906099', '2018-05-27 04:10:35.906099', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 6, NULL, 1, 'Hipertensi├│n', '2018-05-27 04:11:53.018656', '2018-05-27 04:11:53.018656', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 6, NULL, 1, 'Arritmias', '2018-05-27 04:12:13.919749', '2018-05-27 04:12:13.919749', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 6, NULL, 1, 'Obesidad', '2018-05-27 04:13:55.877609', '2018-05-27 04:13:55.877609', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 2, NULL, 1, 'Fumador', '2018-05-27 04:14:10.542724', '2018-05-27 04:14:10.542724', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 2, NULL, 1, 'Alcoh├│lico', '2018-05-27 04:15:16.692958', '2018-05-27 04:15:16.692958', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 6, NULL, 1, 'Parkinson', '2018-05-27 04:16:37.460147', '2018-05-27 04:16:37.460147', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 6, NULL, 1, 'Epilesia', '2018-05-27 04:19:28.408176', '2018-05-27 04:19:28.408176', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 1, 3, 2, 'Peso', '2018-05-27 04:26:56.981404', '2018-05-27 04:26:56.981404', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 1, 8, 2, 'Altura', '2018-05-27 04:28:18.63868', '2018-05-27 04:28:18.63868', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 1, 8, 2, 'Cintura', '2018-05-27 04:28:37.220173', '2018-05-27 04:28:37.220173', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 1, 26, 2, 'IMC', '2018-05-27 04:33:03.947019', '2018-05-27 04:33:03.947019', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 4, NULL, 1, 'Asma', '2018-05-27 04:38:01.74619', '2018-05-27 04:38:01.74619', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 4, NULL, 1, 'Rinitis', '2018-05-27 04:39:00.481771', '2018-05-27 04:39:00.481771', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 4, NULL, 1, 'Man├¡', '2018-05-27 04:40:55.685178', '2018-05-27 04:40:55.685178', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 4, NULL, 1, 'Mariscos', '2018-05-27 04:41:14.350728', '2018-05-27 04:41:14.350728', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 4, NULL, 1, 'Nuez', '2018-05-27 04:41:39.426704', '2018-05-27 04:41:39.426704', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 4, NULL, 1, 'Lactosa', '2018-05-27 04:43:32.179917', '2018-05-27 04:43:32.179917', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 2, NULL, 1, 'Embarazo', '2018-05-27 04:14:23.418', '2018-05-27 04:14:23.418', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 6, NULL, 1, 'Hipotiroidismo', '2018-05-27 05:27:21.590385', '2018-05-27 05:27:21.590385', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 6, NULL, 1, 'Varices', '2018-05-27 05:28:12.483825', '2018-05-27 05:28:12.483825', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 6, NULL, 1, 'Inflamaci├│n intestinal', '2018-05-27 05:28:54.619264', '2018-05-27 05:28:54.619264', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 6, NULL, 1, 'Reflujo', '2018-05-27 05:32:15.626736', '2018-05-27 05:32:15.626736', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 6, NULL, 1, 'Gastritis', '2018-05-27 05:32:57.739644', '2018-05-27 05:32:57.739644', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 2, NULL, 1, 'Cafe├¡na', '2018-05-27 05:35:03.994683', '2018-05-27 05:35:03.994683', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 2, NULL, 1, 'Sedentarismo', '2018-05-27 05:35:45.330994', '2018-05-27 05:35:45.330994', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 3, 27, 2, 'Creatinina', '2018-05-27 05:46:08.077271', '2018-05-27 05:46:08.077271', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (47, 3, 10, 2, 'Bilirrubina', '2018-05-27 06:49:33.282567', '2018-05-27 06:49:33.282567', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (48, 3, 28, 2, 'TSH', '2018-05-27 06:50:26.721853', '2018-05-27 06:50:26.721853', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (49, 3, 28, 2, 'T3', '2018-05-27 06:50:54.502021', '2018-05-27 06:50:54.502021', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (50, 3, 28, 2, 'T4 libre', '2018-05-27 06:51:57.646', '2018-05-27 06:51:57.646', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (51, 3, 28, 2, 'T4 total', '2018-05-27 06:52:45.234326', '2018-05-27 06:52:45.234326', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (52, 3, 29, 2, 'Testosterona', '2018-05-27 06:58:24.018563', '2018-05-27 06:58:24.018563', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (53, 3, 10, 2, 'Glicemia Basal', '2018-05-27 07:00:36.23492', '2018-05-27 07:00:36.23492', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 3, 10, 2, 'Glicemia Pospandrial', '2018-05-27 07:01:23.134703', '2018-05-27 07:01:23.134703', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 7, 31, 2, 'Antidepresivos', '2018-05-27 07:02:13.402', '2018-05-27 07:02:13.402', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 7, 30, 2, 'Levotiroxina S├│dica', '2018-05-27 07:06:11.718866', '2018-05-27 07:06:11.718866', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 7, 31, 2, 'Losart├ín P├│tasico', '2018-05-27 07:08:56.753803', '2018-05-27 07:08:56.753803', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 7, 31, 2, 'Nifedipino', '2018-05-27 07:10:03.939142', '2018-05-27 07:10:03.939142', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 7, 31, 2, 'Metformina Clohidrato', '2018-05-27 07:10:57.418584', '2018-05-27 07:10:57.418584', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (60, 7, 31, 2, 'Diaformina', '2018-05-27 07:11:46.309729', '2018-05-27 07:11:46.309729', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (62, 7, 31, 2, 'Ibuprofeno', '2018-05-27 07:13:34.463984', '2018-05-27 07:13:34.463984', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (64, 7, 31, 2, 'Diclofenac S├│dico', '2018-05-27 07:15:03.690451', '2018-05-27 07:15:03.690451', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (65, 7, 31, 2, 'Loratadina', '2018-05-27 07:15:34.252492', '2018-05-27 07:15:34.252492', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (68, 7, 31, 2, 'Valsartan', '2018-05-27 07:17:27.948755', '2018-05-27 07:17:27.948755', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (69, 7, 31, 2, 'Hidrocloritizada', '2018-05-27 07:17:59.804451', '2018-05-27 07:17:59.804451', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (70, 7, 31, 2, 'Amoxicilina', '2018-05-27 08:13:57.242481', '2018-05-27 08:13:57.242481', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (71, 7, 31, 2, 'Omeprazol', '2018-05-27 08:14:29.34989', '2018-05-27 08:14:29.34989', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (74, 7, 31, 2, 'Enalapril', '2018-05-27 08:16:18.954247', '2018-05-27 08:16:18.954247', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (75, 7, 31, 2, 'Captopril', '2018-05-27 08:16:59.431828', '2018-05-27 08:16:59.431828', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (76, 4, NULL, 1, 'Hongos', '2018-05-27 08:17:52.524673', '2018-05-27 08:17:52.524673', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (77, 4, NULL, 1, 'Polen', '2018-05-27 08:18:16.098346', '2018-05-27 08:18:16.098346', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (78, 4, NULL, 1, 'Fresas', '2018-05-27 08:19:19.170222', '2018-05-27 08:19:19.170222', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (79, 4, NULL, 1, 'Pescados', '2018-05-27 08:20:08.307084', '2018-05-27 08:20:08.307084', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 6, NULL, 1, 'Diabetes', '2018-05-27 04:12:54.463', '2018-05-27 04:12:54.463', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (80, 5, NULL, 1, 'Ciclista', '2018-05-28 17:55:20.498149', '2018-05-28 17:55:20.498149', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (81, 5, NULL, 1, 'Corredor', '2018-05-28 17:55:45.005176', '2018-05-28 17:55:45.005176', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (82, 2, NULL, 1, 'Tiene hijos', '2018-05-28 22:32:53.789395', '2018-05-28 22:32:53.789395', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (46, 3, 10, 2, '├ücido ├Ürico', '2018-05-27 06:46:39.028', '2018-05-27 06:46:39.028', 0);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (63, 7, 31, 2, 'Anticonceptivos', '2018-05-27 07:14:19.141', '2018-05-27 07:14:19.141', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (72, 7, 31, 2, 'Antihipertensivos', '2018-05-27 08:15:05.581', '2018-05-27 08:15:05.581', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (66, 7, 31, 2, 'Anticonvulsivos', '2018-05-27 07:16:10.05', '2018-05-27 07:16:10.05', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (85, 5, NULL, 1, 'Yoga', '2018-06-05 08:51:47.881167', '2018-06-05 08:51:47.881167', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (61, 7, 31, 2, 'Ansiol├¡ticos', '2018-05-27 07:12:44.927', '2018-05-27 07:12:44.927', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (73, 7, 31, 2, 'Antipsic├│ticos', '2018-05-27 08:15:44.06', '2018-05-27 08:15:44.06', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (67, 7, 31, 2, 'Levotiroxina', '2018-05-27 07:16:56.127', '2018-05-27 07:16:56.127', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (83, 5, NULL, 1, 'Marat├│n', '2018-06-01 13:06:58.922916', '2018-06-01 13:06:58.922916', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (84, 2, NULL, 1, 'Sobrepeso', '2018-06-01 23:05:40.793791', '2018-06-01 23:05:40.793791', 1);
INSERT INTO public.parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (86, 5, NULL, 1, 'Nadador', '2018-06-06 01:55:55.496622', '2018-06-06 01:55:55.496622', 1);


--
-- Data for Name: parametro_cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 76, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 1);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 33, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 2);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 44, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 3);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 15, NULL, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 4);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 29, 180.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 6);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 30, 70.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 7);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 31, 21.0000, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 8);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 1, 120.0000, '2018-05-27 16:06:16.178159', '2018-05-27 16:06:16.178159', 1, 9);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 5, 89.0000, '2018-05-27 16:06:32.819584', '2018-05-27 16:06:32.819584', 1, 10);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 8, 180.0000, '2018-05-27 16:06:48.635818', '2018-05-27 16:06:48.635818', 1, 11);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (54, 34, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 12);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (54, 36, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 13);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (54, 29, 160.0000, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 16);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (54, 30, 68.0000, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 17);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (54, 43, NULL, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 18);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 28, 85.0000, '2018-05-27 15:54:00.402', '2018-05-27 15:54:00.402', 1, 5);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (57, 29, 175.0000, '2018-06-01 13:45:09.771081', '2018-06-01 13:45:09.771081', 1, 111);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (54, 28, 60.0000, '2018-05-27 21:18:18.304', '2018-05-27 21:18:18.304', 1, 15);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 29, 164.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 20);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 31, 18.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 21);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 30, 65.0000, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 22);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 35, NULL, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 24);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 15, NULL, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 25);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (57, 28, 75.0000, '2018-06-01 13:44:51.786', '2018-06-01 13:44:51.786', 1, 110);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 80, NULL, '2018-05-29 21:10:31.536322', '2018-05-29 21:10:31.536322', 1, 26);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 2, 85.0000, '2018-05-29 21:10:51.37067', '2018-05-29 21:10:51.37067', 1, 27);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 68, 10.0000, '2018-05-29 21:11:29.564135', '2018-05-29 21:11:29.564135', 1, 28);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (23, 80, NULL, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 29);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (23, 81, NULL, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 30);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (23, 29, 160.0000, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 31);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (23, 28, 55.0000, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 32);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (33, 28, 56.0000, '2018-05-29 21:09:11.816', '2018-05-29 21:09:11.816', 1, 19);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (10, 80, NULL, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 33);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (10, 25, NULL, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 35);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (55, 81, NULL, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 36);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (55, 28, 55.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 37);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (55, 29, 170.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 38);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (55, 30, 60.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 39);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (55, 31, 19.0000, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 40);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 32, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 41);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 34, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 42);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 28, 65.0000, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 43);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 29, 158.0000, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 44);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 30, 70.0000, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 45);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 44, NULL, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 47);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 80, NULL, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 48);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 25, NULL, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 49);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 43, NULL, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 50);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 30, 70.0000, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 51);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 29, 175.0000, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 52);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 28, 77.0000, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 53);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 80, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 54);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 81, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 55);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 32, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 56);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 33, NULL, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 57);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 28, 60.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 58);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 29, 160.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 59);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 30, 60.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 60);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 31, 18.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 61);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 2, 150.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 62);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 1, 120.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 63);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 3, 24.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 64);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 4, 130.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 65);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (24, 5, 200.0000, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 66);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 80, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 67);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 81, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 68);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 35, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 69);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 15, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 70);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 82, NULL, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 71);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (57, 80, NULL, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 109);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (57, 2, 10.0000, '2018-06-01 14:10:33.213548', '2018-06-01 14:10:33.213548', 1, 112);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (1, 80, NULL, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 113);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (1, 81, NULL, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 114);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (1, 83, NULL, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 115);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (1, 28, 123.0000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 116);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (1, 29, 168.0000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 117);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (1, 30, 55.0000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 118);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 9, 100.0000, '2018-06-01 21:18:26.815383', '2018-06-01 21:18:26.815383', 1, 119);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (40, 4, 100.0000, '2018-06-01 21:21:23.411149', '2018-06-01 21:21:23.411149', 1, 120);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (11, 29, 170.0000, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 121);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (10, 4, 132.0000, '2018-06-01 22:32:49.343389', '2018-06-01 22:32:49.343389', 1, 124);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (10, 49, 2.3000, '2018-06-01 22:33:16.722586', '2018-06-01 22:33:16.722586', 1, 125);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (25, 1, 60.0000, '2018-06-01 23:00:05.87043', '2018-06-01 23:00:05.87043', 1, 126);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 81, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 128);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 28, 60.0000, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 129);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 29, 169.0000, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 130);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 30, 70.0000, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 131);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 77, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 132);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 79, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 133);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (9, 20, NULL, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 134);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (4, 81, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 135);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (4, 22, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 136);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (4, 20, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 137);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (4, 44, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 138);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (4, 84, NULL, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 139);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 28, 60.0000, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 140);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 29, 170.0000, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 141);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 30, 60.0000, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 142);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 17, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 143);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 41, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 144);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 40, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 145);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 43, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 146);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 82, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 147);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 33, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 148);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 37, NULL, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 149);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 81, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 150);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 15, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 151);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 43, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 152);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 16, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 153);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 38, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 154);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 42, NULL, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 155);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 32, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 156);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 34, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 157);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 37, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 158);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 29, 160.0000, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 159);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 30, 60.0000, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 161);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 44, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 162);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 39, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 163);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 20, NULL, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 164);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 80, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 165);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 25, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 166);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (10, 28, 67.0000, '2018-06-01 22:32:27.243', '2018-06-01 22:32:27.243', 1, 123);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (11, 30, 75.0000, '2018-06-01 22:12:09.23', '2018-06-01 22:12:09.23', 1, 122);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 84, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 167);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 22, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 168);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 21, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 169);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 42, NULL, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 170);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 35, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 171);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 37, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 172);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 23, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 173);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 25, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 174);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 44, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 175);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 43, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 176);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 22, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 177);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 20, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 178);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 19, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 179);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 38, NULL, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 180);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 37, NULL, '2018-06-04 07:42:59.379537', '2018-06-04 07:42:59.379537', 1, 181);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (6, 28, 60.0000, '2018-06-04 07:43:50.862752', '2018-06-04 07:43:50.862752', 1, 182);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (15, 30, 73.0000, '2018-06-04 07:46:15.866', '2018-06-04 07:46:15.866', 1, 183);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 30, 60.0000, '2018-06-04 07:47:12.591', '2018-06-04 07:47:12.591', 1, 184);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 5, 85.0000, '2018-06-04 07:47:35.746', '2018-06-04 07:47:35.746', 1, 185);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (56, 4, 60.0000, '2018-06-04 07:47:49.434', '2018-06-04 07:47:49.434', 1, 186);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (8, 28, 60.0000, '2018-06-04 07:35:44.514', '2018-06-04 07:35:44.514', 1, 160);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (12, 28, 72.0000, '2018-06-04 07:48:51.401', '2018-06-04 07:48:51.401', 1, 187);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 81, NULL, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 190);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 12, 180.0000, '2018-06-05 02:40:00.391768', '2018-06-05 02:40:00.391768', 1, 191);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (2, 20, NULL, '2018-06-05 02:41:19.995048', '2018-06-05 02:41:19.995048', 1, 192);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 28, 58.0000, '2018-06-05 02:47:01.886865', '2018-06-05 02:47:01.886865', 1, 193);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 29, 160.0000, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 199);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 30, 60.0000, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 200);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 25, NULL, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 201);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 77, NULL, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 202);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 4, 79.0000, '2018-06-05 02:50:26.966', '2018-06-05 02:50:26.966', 1, 194);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (18, 2, 101.0000, '2018-06-05 07:27:49.188', '2018-06-05 07:27:49.188', 1, 203);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (26, 28, 75.0000, '2018-06-05 06:18:05.785', '2018-06-05 06:18:05.785', 1, 198);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 29, 167.0000, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 205);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 85, NULL, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 206);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 2, 80.0000, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 207);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 81, NULL, '2018-06-05 09:25:41.941829', '2018-06-05 09:25:41.941829', 1, 208);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 38, NULL, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 209);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 20, NULL, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 210);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 80, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 213);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 81, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 214);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 83, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 215);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (37, 85, NULL, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 216);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 80, NULL, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 217);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 83, NULL, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 218);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 3, 100.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 220);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 1, 80.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 221);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 5, 96.0000, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 223);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 28, 67.0000, '2018-06-05 09:23:45.158', '2018-06-05 09:23:45.158', 1, 204);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 4, 79.0000, '2018-06-06 00:32:18.563', '2018-06-06 00:32:18.563', 1, 222);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 6, 14.0000, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 224);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 7, 1.0000, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 225);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (59, 8, 12.0000, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 226);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 21, NULL, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 227);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 28, 70.0000, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 228);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 29, 178.0000, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 229);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 81, NULL, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 230);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 24, NULL, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 235);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 43, NULL, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 236);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 25, NULL, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 237);
INSERT INTO public.parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) VALUES (45, 53, 200.0000, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 238);


--
-- Data for Name: parametro_meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (1, 2, 28, 80, 0, '2018-05-27 15:53:54.710268', '2018-05-27 15:53:54.710268', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (2, 5, 28, 60, 0, '2018-05-27 21:17:39.342897', '2018-05-27 21:17:39.342897', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (5, 8, 30, 3, 0, '2018-05-29 05:27:40.533917', '2018-05-29 05:27:40.533917', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (7, 12, 2, 87, 0, '2018-05-29 20:55:09.889883', '2018-05-29 20:55:09.889883', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (8, 12, 28, 55, 0, '2018-05-29 21:01:24.665209', '2018-05-29 21:01:24.665209', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (9, 24, 4, 65, 0, '2018-05-31 01:55:55.610961', '2018-05-31 01:55:55.610961', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (10, 24, 28, 70, 0, '2018-05-31 01:56:28.695268', '2018-05-31 01:56:28.695268', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (12, 28, 49, 180, 0, '2018-05-31 11:42:33.192756', '2018-05-31 11:42:33.192756', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (13, 26, 28, 60, 0, '2018-06-01 02:31:02.560872', '2018-06-01 02:31:02.560872', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (14, 27, 28, 80, 0, '2018-06-01 02:36:41.750277', '2018-06-01 02:36:41.750277', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (15, 25, 30, 60, 0, '2018-06-01 02:52:42.282058', '2018-06-01 02:52:42.282058', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (16, 30, 30, 60, 0, '2018-06-01 08:08:44.16362', '2018-06-01 08:08:44.16362', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (17, 30, 5, 80, 0, '2018-06-01 08:09:04.04124', '2018-06-01 08:09:04.04124', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (18, 30, 4, 60, 0, '2018-06-01 08:09:24.588008', '2018-06-01 08:09:24.588008', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (19, 31, 28, 75, 0, '2018-06-01 13:36:17.192642', '2018-06-01 13:36:17.192642', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (20, 6, 28, 60, 0, '2018-06-01 17:24:47.65581', '2018-06-01 17:24:47.65581', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (21, 16, 28, 70, 0, '2018-06-01 22:11:47.170962', '2018-06-01 22:11:47.170962', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (22, 14, 28, 70, 0, '2018-06-04 07:17:27.317458', '2018-06-04 07:17:27.317458', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (23, 8, 28, 68, 0, '2018-06-04 07:23:07.472168', '2018-06-04 07:23:07.472168', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (24, 7, 28, 58, 0, '2018-06-04 07:26:19.312145', '2018-06-04 07:26:19.312145', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (25, 10, 28, 62, 0, '2018-06-04 07:31:35.81316', '2018-06-04 07:31:35.81316', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (26, 11, 28, 60, 0, '2018-06-04 07:35:23.970538', '2018-06-04 07:35:23.970538', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (27, 17, 28, 70, 0, '2018-06-04 07:38:52.777503', '2018-06-04 07:38:52.777503', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (28, 18, 30, 70, 0, '2018-06-04 07:42:08.383267', '2018-06-04 07:42:08.383267', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (11, 15, 28, 65, 0, '2018-05-31 08:42:09.398', '2018-05-31 08:42:09.398', 1, 1, true);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (29, 20, 28, 60, 0, '2018-06-04 14:53:38.557352', '2018-06-04 14:53:38.557352', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (32, 47, 4, 80, 0, '2018-06-05 07:26:26.274', '2018-06-05 07:26:26.274', 1, 0, true);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (33, 47, 2, 100, 0, '2018-06-05 07:26:59.795', '2018-06-05 07:26:59.795', 1, 1, true);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (31, 46, 28, 70, 0, '2018-06-05 05:52:03.412', '2018-06-05 05:52:03.412', 1, 1, true);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (34, 48, 28, 68, 0, '2018-06-05 08:53:18.102', '2018-06-05 08:53:18.102', 1, 0, true);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (35, 49, 28, 70, 0, '2018-06-05 09:55:12.958', '2018-06-05 09:55:12.958', 1, 1, true);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (36, 43, 30, 78, 0, '2018-06-05 11:08:51.960122', '2018-06-05 11:08:51.960122', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (37, 55, 4, 50, 0, '2018-06-06 00:31:38.541122', '2018-06-06 00:31:38.541122', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (38, 57, 28, 66, 0, '2018-06-06 02:56:50.130364', '2018-06-06 02:56:50.130364', 1, 0, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (39, 62, 28, 85, 0, '2018-06-06 04:05:18.559979', '2018-06-06 04:05:18.559979', 1, 1, false);
INSERT INTO public.parametro_meta (id_parametro_meta, id_orden_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, signo, cumplida) VALUES (40, 63, 53, 78, 0, '2018-06-06 04:52:20.674727', '2018-06-06 04:52:20.674727', 1, 0, false);


--
-- Data for Name: parametro_promocion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.parametro_promocion (id_parametro, id_promocion, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_promocion) VALUES (82, 3, NULL, NULL, '2018-05-28 22:48:28.124799', '2018-05-28 22:48:28.124799', 1, 1);
INSERT INTO public.parametro_promocion (id_parametro, id_promocion, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_promocion) VALUES (21, 7, NULL, NULL, '2018-05-30 01:06:13.777163', '2018-05-30 01:06:13.777163', 1, 4);
INSERT INTO public.parametro_promocion (id_parametro, id_promocion, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_promocion) VALUES (15, 11, NULL, NULL, '2018-06-05 03:23:01.762124', '2018-06-05 03:23:01.762124', 1, 5);
INSERT INTO public.parametro_promocion (id_parametro, id_promocion, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_promocion) VALUES (21, 13, NULL, NULL, '2018-06-06 05:39:53.508085', '2018-06-06 05:39:53.508085', 1, 6);


--
-- Data for Name: parametro_servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (7, 21, NULL, NULL, '2018-05-28 17:45:27.386885', '2018-05-28 17:45:27.386885', 1, 1);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (7, 37, NULL, NULL, '2018-05-28 17:45:51.908284', '2018-05-28 17:45:51.908284', 1, 2);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (6, 21, NULL, NULL, '2018-05-28 17:51:34.195887', '2018-05-28 17:51:34.195887', 1, 3);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (6, 14, NULL, NULL, '2018-05-28 17:51:51.512842', '2018-05-28 17:51:51.512842', 1, 4);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (1, 80, NULL, NULL, '2018-05-28 17:57:11.274458', '2018-05-28 17:57:11.274458', 1, 5);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (8, 81, NULL, NULL, '2018-05-28 22:12:46.272478', '2018-05-28 22:12:46.272478', 1, 6);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (8, 28, 40, 60, '2018-05-28 22:13:22.993479', '2018-05-28 22:13:22.993479', 1, 7);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (9, 21, NULL, NULL, '2018-05-28 22:23:50.630589', '2018-05-28 22:23:50.630589', 1, 8);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (9, 13, 100, 200, '2018-05-28 22:24:15.240818', '2018-05-28 22:24:15.240818', 1, 9);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (9, 59, 1, 1000, '2018-05-28 22:24:41.45488', '2018-05-28 22:24:41.45488', 1, 10);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (2, 82, NULL, NULL, '2018-05-28 22:36:07.288202', '2018-05-28 22:36:07.288202', 1, 11);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (13, 83, NULL, NULL, '2018-06-01 13:22:55.45769', '2018-06-01 13:22:55.45769', 1, 12);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (6, 19, NULL, NULL, '2018-06-05 05:17:23.807179', '2018-06-05 05:17:23.807179', 1, 13);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (4, 80, NULL, NULL, '2018-06-05 05:19:05.101132', '2018-06-05 05:19:05.101132', 1, 14);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (4, 81, NULL, NULL, '2018-06-05 05:19:18.622972', '2018-06-05 05:19:18.622972', 1, 15);
INSERT INTO public.parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) VALUES (4, 83, NULL, NULL, '2018-06-05 05:19:29.096408', '2018-06-05 05:19:29.096408', 1, 16);


--
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 6, 'Dieta modificada en energ├¡a', 'normalmente se realiza una distribuci├│n en la cantidad de energ├¡a aportada en la dieta. Son las dietas que se aplican en situaciones de sobrepeso y obesidad', '2018-05-27 04:08:44.526621', '2018-05-27 04:08:44.526621', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 6, 'Dieta modificada en prote├¡nas', 'Pueden aportar mayor cantidad de prote├¡nas que las recomendadas para las personas sanas', '2018-05-27 04:11:07.102334', '2018-05-27 04:11:07.102334', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 6, 'Dieta modificada en carbohidratos', 'Cuando se restringe la cantidad de carbohidratos.', '2018-05-27 04:14:12.850902', '2018-05-27 04:14:12.850902', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 6, 'Dieta modificada en fibra alimentaria', 'Pueden ser con altos contenidos en fibra (dieta alta en fibra), indicadas en aquellos casos en los que hay reducci├│n de la motilidad intestinal, o pueden ser con bajos contenidos de fibra (dieta sin residuos)', '2018-05-27 04:18:22.004097', '2018-05-27 04:18:22.004097', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 6, 'Dieta modificada en elementos minerales', 'En el caso de que se reduzca de forma importante la cantidad aportada de sodio (bien eliminando la sal com├║n o bien aportando alimentos pobres en sodio) se tiene la dieta hipos├│dica. ', '2018-05-27 04:24:50.002063', '2018-05-27 04:24:50.002063', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 4, 'Dieta proteica', 'La dieta disociada se basa en la teor├¡a del equilibrio entre ├ícidos y bases en el est├│mago. Esta dieta trabaja en funci├│n de las leyes de la digesti├│n y divide los alimentos en tres categor├¡as principales.', '2018-05-27 04:34:22.720762', '2018-05-27 04:34:22.720762', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 1, 'Dieta blanda', 'Muy usada en la transici├│n de una dieta semil├¡quida a una normal. Los alimentos son de textura blanda, pero enteros, con bajo contenido de fibra y grasas.', '2018-05-27 04:38:57.754651', '2018-05-27 04:38:57.754651', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 1, 'Dieta l├¡quida', 'Indicada a las personas que necesitan muy poca estimulaci├│n gastrointestinal o que est├®n pasando de la alimentaci├│n parental a la oral', '2018-05-27 04:40:37.927707', '2018-05-27 04:40:37.927707', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 1, 'Dieta semil├¡quida', 'Compuesta por alimentos de textura l├¡quida y pastosa, como yogurt o gelatina. Tambi├®n por alimentos triturados.', '2018-05-27 04:41:59.115966', '2018-05-27 04:41:59.115966', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 3, 'Dieta baja en calor├¡as', 'Es la m├ís habitual de las dietas que aplican y diagnostican los m├®dicos en los casos de p├®rdida de peso.', '2018-05-27 04:46:23.579078', '2018-05-27 04:46:23.579078', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 2, 'Dieta baja en hidratos de carbono', 'Implica comer productos naturales con un contenido bajo en hidratos de carbono.', '2018-05-27 04:53:25.411362', '2018-05-27 04:53:25.411362', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 2, 'Dieta baja en grasas', 'Son aquellas dietas que no contienen muchos alimentos con grasas', '2018-05-27 04:54:58.277785', '2018-05-27 04:54:58.277785', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 7, 'Dieta postparto sin lactancia', 'Dieta perfecta para personas que ya no est├ín en lactancia', '2018-05-27 05:05:24.004026', '2018-05-27 05:05:24.004026', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 7, 'Dieta postparto y lactancia', 'Dieta especial para aquellas mujeres en procesos de lactancia', '2018-05-27 05:06:48.672843', '2018-05-27 05:06:48.672843', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 5, 'Dieta vegetariana', 'La dieta macrobi├│tica elimina de la dieta todos los productos refinados como el az├║car blanco, el pan blanco, los embutidos, la carne, los dulces industriales, las bebidas alcoh├│licas y las bebidas industriales.', '2018-05-27 05:08:52.72336', '2018-05-27 05:08:52.72336', 1);
INSERT INTO public.plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 5, 'Dieta Base', 'Dieta b├ísica adaptada a la mayor├¡a de los clientes', '2018-05-30 21:40:37.672613', '2018-05-30 21:40:37.672613', 1);


--
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'B├ísico', 'Este es el plan de entrenamiento b├ísico', '2018-05-27 05:17:33.141724', '2018-05-27 05:17:33.141724', 1);
INSERT INTO public.plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Intermedio', 'Es es un plan de entrenamiento intermedio', '2018-05-27 05:19:37.295046', '2018-05-27 05:19:37.295046', 1);
INSERT INTO public.plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Avanzado', 'Este es un plan de entrenamiento avanzado', '2018-05-27 05:20:25.622473', '2018-05-27 05:20:25.622473', 1);
INSERT INTO public.plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, '', '', '2018-05-31 00:58:46.756994', '2018-05-31 00:58:46.756994', 1);
INSERT INTO public.plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'prueba', '2313', '2018-06-05 04:57:42.274', '2018-06-05 04:57:42.274', 0);


--
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Plan de suplemento 1', 'Este es el plan de suplemento 1', '2018-05-27 05:17:19.957286', '2018-05-27 05:17:19.957286', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Plan de suplemento 2', 'Este es el plan de suplemento 2', '2018-05-27 05:18:31.129535', '2018-05-27 05:18:31.129535', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Plan de suplemento 3', 'Este es el plan de suplemento 3', '2018-05-27 05:19:28.972461', '2018-05-27 05:19:28.972461', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Plan Antioxidantes', 'Ayuda a eliminar radicales libres, potencia el sistema inmunologico y elimina patogenos.', '2018-05-28 23:58:08.885581', '2018-05-28 23:58:08.885581', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Plan Vitaminas y minerales', 'Mejora la flora intestinal y ayuda  al crecimiento', '2018-05-29 00:00:59.998824', '2018-05-29 00:00:59.998824', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 'Plan para articulaciones', 'Proporciona al cuerpo lo que necesita regenerar proporcionando mayor recuperaci├│n.', '2018-05-29 00:05:50.598495', '2018-05-29 00:05:50.598495', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'Plan para diabetes', 'Ayuda en la prevenci├│n de complicaciones, ', '2018-05-29 00:08:55.982709', '2018-05-29 00:08:55.982709', 1);
INSERT INTO public.plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 'Plan para el embarazo', 'Ayuda al crecimiento y desarrollo del bebe y el cuidado de la madre.', '2018-05-29 00:12:05.798467', '2018-05-29 00:12:05.798467', 1);


--
-- Data for Name: preferencia_cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: promocion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (2, 3, 'Promo Navidad', 'En estas Fechas de celebraciones decembrina puedes tener una buena alimentacion.', '2018-01-12', '2020-12-20', 1, 3, 3, '2018-05-28 22:46:19.909', '2018-05-28 22:46:19.909', 1, 15, 'http://res.cloudinary.com/saschanutric/image/upload/v1527556692/mji9sj7oksg9srq4cnpt.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (6, 1, 'Promo Extrema', 'Si eres un atleta de Alto rendimiento debes tener una alimentacion balanceada', '2018-05-31', '2020-06-20', NULL, NULL, NULL, '2018-05-29 21:49:23.13', '2018-05-29 21:49:23.13', 1, 10, 'http://res.cloudinary.com/saschanutric/image/upload/v1527630562/jlho0ovnqpxhtoikzige.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (10, 6, 'Promocion 01-06', 'promo prueba', '2018-06-01', '2019-07-17', NULL, 3, NULL, '2018-06-01 14:17:24.598', '2018-06-01 14:17:24.598', 1, 10, 'http://res.cloudinary.com/saschanutric/image/upload/v1527862644/mawlzvn4n3vd8zvzd3nd.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (5, 3, 'Semana Santa', 'Conoce la alimentacion adecuada durante esta temporada con un descuento especial.', '2018-03-28', '2018-04-05', NULL, NULL, NULL, '2018-05-28 23:26:58.159', '2018-05-28 23:26:58.159', 1, 20, 'http://res.cloudinary.com/saschanutric/image/upload/v1527550017/o9pexhglhnjgyyywvcay.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (11, 5, 'Promo Vive Verde', 'Promocion especialista en personas vegetarianas', '2018-06-06', '2018-07-06', NULL, NULL, NULL, '2018-06-05 03:09:04.931593', '2018-06-05 03:09:04.931593', 1, 10, 'http://res.cloudinary.com/saschanutric/image/upload/v1528168144/yksgb1difsapfn0agqoi.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (8, 6, 'A├▒os dorados', 'Sus a├▒os dorados merecen estar en las mejores manos, con la mejor alimentaci├│n ', '2018-06-13', '2018-08-01', NULL, NULL, 5, '2018-05-30 01:07:37.08', '2018-05-30 01:07:37.08', 0, 30, 'http://res.cloudinary.com/saschanutric/image/upload/v1527642456/gbliyp4w5ymg9zig7a7h.png');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (12, 3, 'dd', 'ff', '2018-06-05', '2018-06-08', NULL, NULL, NULL, '2018-06-05 09:25:21.891', '2018-06-05 09:25:21.891', 0, 30, 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (4, 8, 'Promoci├│n de Vacaciones', 'Disfruta de un descuento especial para tener una excelente figura estas vacaciones.', '2018-06-05', '2018-07-15', 1, 1, 3, '2018-05-28 23:14:09.491', '2018-05-28 23:14:09.491', 1, 10, 'http://res.cloudinary.com/saschanutric/image/upload/v1527630017/ern0yhtl7t36hgaqa3xc.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (13, 9, 'Promo Dulce', 'Porque no comer azucar no hace tu vida amarga, te traemos un descuento para ti.', '2018-06-05', '2018-06-22', NULL, NULL, NULL, '2018-06-06 05:29:31.031145', '2018-06-06 05:29:31.031145', 1, 10, 'http://res.cloudinary.com/saschanutric/image/upload/v1528262970/wmxfhcboxayteh7yb3d4.png');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (9, 7, 'Promo Vive Sano', 'Promocion dirigida a jovenes con trasnornos alimenticios', '2018-11-01', '2018-11-19', NULL, NULL, 3, '2018-05-30 15:17:06.836368', '2018-05-30 15:17:06.836368', 1, 50, 'http://res.cloudinary.com/saschanutric/image/upload/v1527693426/tiupheou3tstknjqpgbb.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (7, 6, 'A├▒os Dorados', 'Sus a├▒os dorados merecen estar en las mejores manos, con la mejor alimentaci├│n', '2018-06-13', '2020-08-20', NULL, NULL, 5, '2018-05-30 01:05:24.896', '2018-05-30 01:05:24.896', 1, 30, 'http://res.cloudinary.com/saschanutric/image/upload/v1527642324/pyfcaxjflhk1hvpocmiu.png');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (3, 3, 'Dia del Padre', 'Promoci├│n especial para el d├¡a del padre. Recibe un descuento especial.', '2018-06-01', '2030-06-20', 1, 3, 4, '2018-05-28 22:46:50.362', '2018-05-28 22:46:50.362', 1, 20, 'http://res.cloudinary.com/saschanutric/image/upload/v1527547610/m9p0lae1arkmfndqsnqd.jpg');
INSERT INTO public.promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, fecha_creacion, fecha_actualizacion, estatus, descuento, url_imagen) VALUES (1, 2, 'Promo Vida Mama', 'Promocion para las madres ', '2018-06-01', '2030-06-20', NULL, NULL, NULL, '2018-05-27 07:46:31.455', '2018-05-27 07:46:31.455', 1, 25, 'http://res.cloudinary.com/saschanutric/image/upload/v1527442456/bwygacwio7acrsavpq6f.jpg');


--
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Adulto mayor', 60, 120, '2018-05-27 02:26:01.067335', '2018-05-27 02:26:01.067335', 1);
INSERT INTO public.rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Niño 1-12 años', 1, 12, '2018-05-27 02:26:01.067335', '2018-05-27 02:26:01.067335', 1);
INSERT INTO public.rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Joven 12-30 años', 12, 30, '2018-05-27 02:26:01.067335', '2018-05-27 02:26:01.067335', 1);
INSERT INTO public.rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Adulto 30-60 años', 30, 60, '2018-05-27 02:26:01.067335', '2018-05-27 02:26:01.067335', 1);
INSERT INTO public.rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Adulto mayor +60años', 0, 1, '2018-05-27 02:26:01.067335', '2018-05-27 02:26:01.067335', 1);


--
-- Data for Name: reclamo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 15, 4, 3, NULL, '2018-06-03 18:58:12.127', '2018-06-03 18:58:12.127', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 14, 31, 5, NULL, '2018-06-03 18:57:19.738', '2018-06-03 18:57:19.738', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 16, 29, 6, NULL, '2018-06-03 19:14:22.471', '2018-06-03 19:14:22.471', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 16, 37, 4, NULL, '2018-06-03 22:45:02.957', '2018-06-03 22:45:02.957', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 15, 26, 3, NULL, '2018-06-03 23:55:13.237', '2018-06-03 23:55:13.237', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 14, 38, 4, NULL, '2018-06-03 23:00:26.83', '2018-06-03 23:00:26.83', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 14, 39, 6, NULL, '2018-06-04 00:49:27.919', '2018-06-04 00:49:27.919', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 16, 53, NULL, NULL, '2018-06-05 23:21:13.699173', '2018-06-05 23:21:13.699173', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 16, 51, 3, NULL, '2018-06-05 22:33:01.203', '2018-06-05 22:33:01.203', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 14, 54, 3, NULL, '2018-06-06 00:07:42.433', '2018-06-06 00:07:42.433', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 16, 56, 6, NULL, '2018-06-06 02:48:15.1', '2018-06-06 02:48:15.1', 1);
INSERT INTO public.reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 14, 52, NULL, NULL, '2018-06-06 03:57:42.438966', '2018-06-06 03:57:42.438966', 1);


--
-- Data for Name: red_social; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (2, 'facebook', 'facebook.com', 'http://res.cloudinary.com/saschanutric/image/upload/v1527833430/vmunjmko4wtq9e1nexb7.png', '2018-06-01 06:10:30.198', '2018-06-01 06:10:30.198', 1, 'SaschaNutric');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (8, '', 'wwww', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-01 06:22:33.362', '2018-06-01 06:22:33.362', 0, '');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (5, 'tqitwe', 'facebook.com', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-01 06:15:21.922', '2018-06-01 06:15:21.922', 0, '');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (3, 'Instagram', 'instagram.com', 'http://res.cloudinary.com/saschanutric/image/upload/v1527833521/yoxxkdtd5tgoxofzryuy.png', '2018-06-01 06:12:02.28', '2018-06-01 06:12:02.28', 1, 'SaschaNutric');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (1, 'Instagram', 'instagram.com', 'http://res.cloudinary.com/saschanutric/image/upload/v1527832966/cj5vwxfabm42n7s1ezu8.png', '2018-06-01 05:54:02.868', '2018-06-01 05:54:02.868', 0, 'SaschaNutric');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (7, '', 'www', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-01 06:19:52.093', '2018-06-01 06:19:52.093', 0, '');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (6, '', 'facebook.com', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-01 06:18:08.323', '2018-06-01 06:18:08.323', 0, '');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (4, 'twitter', 'twitter.com', 'http://res.cloudinary.com/saschanutric/image/upload/v1527834278/wddaqzquixoextbiuvlu.png', '2018-06-01 06:13:36.844', '2018-06-01 06:13:36.844', 1, '@saschaNutric');
INSERT INTO public.red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus, usuario) VALUES (9, '', '', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', '2018-06-05 06:27:47.956', '2018-06-05 06:27:47.956', 0, '');


--
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 2, 37, 150, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 1, 37, 150, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 3, 37, 250, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 5, 37, 300, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 4, 37, 500, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 7, 37, 70, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 6, 37, 80, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 67, 54, 250, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 69, 54, 500, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 68, 54, 150, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 71, 54, 100, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 70, 54, 100, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 66, 54, 200, '2018-05-27 21:18:18.304', '2018-05-27 21:18:18.304', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 72, 33, 80, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 75, 33, 100, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (16, 73, 33, 120, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (17, 76, 33, 100, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (18, 74, 33, 80, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (19, 78, 23, 200, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (20, 77, 23, 130, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (21, 84, 23, 130, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (22, 81, 23, 340, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (23, 79, 23, 200, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (24, 83, 23, 120, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (25, 82, 23, 200, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (26, 80, 23, 400, '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (27, 23, 10, 80, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (29, 25, 10, 100, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (30, 24, 10, 50, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (31, 26, 10, 250, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (32, 27, 55, 500, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (33, 30, 55, 150, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (34, 28, 55, 100, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (35, 29, 55, 200, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (36, 72, 25, 200, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (37, 75, 25, 200, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (38, 73, 25, 200, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (39, 76, 25, 200, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (40, 74, 25, 200, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (41, 2, 40, 250, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (42, 1, 40, 150, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (43, 3, 40, 100, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (44, 5, 40, 250, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (45, 4, 40, 150, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (46, 7, 40, 200, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (47, 6, 40, 150, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (48, 78, 24, 400, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (49, 77, 24, 160, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (50, 84, 24, 180, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (51, 81, 24, 260, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (52, 79, 24, 100, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (53, 83, 24, 200, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (54, 82, 24, 200, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (55, 80, 24, 300, '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (56, 27, 56, 120, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (57, 30, 56, 200, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (58, 28, 56, 150, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (59, 29, 56, 60, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (61, 34, 57, 140, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (62, 32, 57, 100, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (63, 33, 57, 100, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (60, 31, 57, 250, '2018-06-01 13:43:01.421', '2018-06-01 13:43:01.421', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (64, 23, 1, 1000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (65, 22, 1, 140, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (66, 25, 1, 200, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (67, 24, 1, 130, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (68, 26, 1, 200, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (69, 27, 11, 200, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (70, 30, 11, 100, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (71, 28, 11, 100, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (72, 29, 11, 100, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (28, 22, 10, 180, '2018-05-31 08:42:52.191', '2018-05-31 08:42:52.191', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (73, 18, 9, 200, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (74, 14, 9, 300, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (75, 17, 9, 400, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (76, 15, 9, 250, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (77, 13, 9, 100, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (78, 16, 9, 200, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (79, 2, 4, 150, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (80, 1, 4, 100, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (81, 3, 4, 50, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (82, 5, 4, 150, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (83, 4, 4, 300, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (84, 7, 4, 150, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (85, 6, 4, 150, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (86, 27, 2, 200, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (87, 30, 2, 200, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (88, 28, 2, 200, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (89, 29, 2, 150, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (90, 18, 6, 200, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (91, 14, 6, 100, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (92, 17, 6, 200, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (93, 15, 6, 150, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (94, 13, 6, 150, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (95, 16, 6, 150, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (96, 27, 8, 150, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (97, 30, 8, 150, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (98, 28, 8, 200, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (99, 29, 8, 250, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (100, 18, 12, 280, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (101, 14, 12, 100, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (102, 17, 12, 200, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (103, 15, 12, 125, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (104, 13, 12, 200, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (105, 16, 12, 200, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (106, 18, 15, 175, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (107, 14, 15, 110, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (108, 17, 15, 200, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (109, 15, 15, 125, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (110, 13, 15, 350, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (111, 16, 15, 183, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (115, 18, 18, 30, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (117, 17, 18, 30, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (118, 15, 18, 40, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (119, 13, 18, 30, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (120, 16, 18, 60, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (116, 14, 18, 30, '2018-06-04 15:00:55.777', '2018-06-04 15:00:55.777', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (122, 1, 26, 3, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (123, 3, 26, 5, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (124, 5, 26, 3, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (125, 4, 26, 3, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (126, 7, 26, 4, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (127, 6, 26, 400, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (121, 2, 26, 20, '2018-06-05 05:53:15.666', '2018-06-05 05:53:15.666', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (128, 78, 18, 150, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (129, 77, 18, 50, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (130, 84, 18, 150, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (132, 79, 18, 100, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (133, 83, 18, 100, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (134, 82, 18, 80, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (135, 80, 18, 100, '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (131, 81, 18, 141, '2018-06-05 07:27:49.188', '2018-06-05 07:27:49.188', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (136, 18, 59, 30, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (137, 14, 59, 10, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (138, 17, 59, 300, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (139, 15, 59, 20, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (140, 13, 59, 100, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (141, 16, 59, 39, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (142, 23, 59, 20, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (143, 22, 59, 90, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (144, 25, 59, 78, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (145, 24, 59, 80, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (146, 26, 59, 90, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (147, 31, 37, 17, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (148, 34, 37, 43, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (149, 32, 37, 63, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (150, 33, 37, 32, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (151, 27, 59, 200, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (152, 30, 59, 180, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (153, 28, 59, 200, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (154, 29, 59, 100, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (155, 27, 59, 200, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (156, 30, 59, 180, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (157, 28, 59, 200, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (158, 29, 59, 100, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (159, 18, 45, 100, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (160, 14, 45, 90, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (161, 17, 45, 29, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (162, 15, 45, 20, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (163, 13, 45, 299, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (164, 16, 45, 599, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (172, 2, 45, 200, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (173, 1, 45, 100, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (174, 3, 45, 100, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (175, 5, 45, 100, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (176, 4, 45, 100, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (177, 7, 45, 100, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);
INSERT INTO public.regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) VALUES (178, 6, 45, 400, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1);


--
-- Data for Name: regimen_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (2, 37, 2, 1, 10, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (3, 37, 3, 1, 50, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (1, 37, 2, 1, 300, '2018-05-27 15:54:00.402', '2018-05-27 15:54:00.402', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (4, 54, 2, 1, 4, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (5, 54, 2, 1, 20, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (6, 54, 2, 1, 1, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (7, 33, 2, 1, 100, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (8, 33, 2, 1, 25, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (9, 33, 3, 1, 10, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (10, 10, 1, 1, 100, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (11, 10, 3, 1, 50, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (13, 55, 3, 1, 50, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (14, 55, 3, 1, 20, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (15, 55, 3, 1, 20, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (16, 25, 2, 1, 20, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (17, 25, 3, 1, 5, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (18, 25, 2, 1, 20, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (19, 40, 2, 1, 20, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (20, 40, 2, 1, 1, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (21, 40, 2, 1, 1, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (22, 56, 1, 1, 30, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (23, 56, 3, 1, 90, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (24, 56, 2, 1, 45, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (25, 57, 1, 1, 20, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (26, 57, 3, 1, 50, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (27, 57, 2, 1, 20, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (28, 1, 3, 1, 30, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (29, 1, 2, 1, 45, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (30, 1, 3, 1, 25, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (31, 11, 3, 1, 60, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (32, 11, 3, 1, 60, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (33, 11, 3, 1, 60, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (12, 10, 2, 1, 40, '2018-05-31 08:42:52.191', '2018-05-31 08:42:52.191', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (34, 9, 3, 1, 50, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (35, 9, 3, 1, 2, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (36, 9, 3, 1, 50, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (37, 4, 3, 1, 30, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (38, 4, 3, 1, 1, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (39, 4, 3, 1, 30, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (40, 2, 3, 1, 50, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (41, 2, 3, 1, 1, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (42, 2, 3, 1, 30, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (43, 6, 3, 1, 20, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (44, 6, 3, 1, 30, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (45, 6, 3, 1, 30, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (46, 8, 3, 1, 50, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (47, 8, 3, 1, 1, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (48, 8, 3, 1, 30, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (49, 12, 3, 1, 4, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (50, 12, 3, 1, 50, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (51, 12, 3, 1, 30, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (52, 15, 2, 1, 10, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (53, 15, 3, 1, 50, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (54, 15, 3, 1, 90, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (58, 18, 3, 1, 5, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (59, 18, 3, 1, 10, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (60, 18, 3, 1, 1, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (61, 26, 1, 1, 4, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (62, 26, 3, 1, 12, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (63, 26, 3, 1, 23, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (65, 59, 3, 1, 30, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (66, 59, 3, 1, 1, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (64, 59, 1, 1, 30, '2018-06-05 09:23:45.158', '2018-06-05 09:23:45.158', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (67, 59, 3, 1, 30, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (68, 59, 2, 1, 50, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (69, 59, 3, 1, 20, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (70, 37, 3, 1, 30, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (71, 37, 1, 1, 8, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (72, 37, 1, 1, 87, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (73, 59, 1, 1, 30, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (74, 59, 3, 1, 30, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (75, 59, 3, 1, 20, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (76, 59, 1, 1, 30, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (77, 59, 3, 1, 30, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 8);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (78, 59, 3, 1, 1, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 1);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (79, 45, 3, 1, 39, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 10);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (80, 45, 2, 1, 29, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 3);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (81, 45, 3, 1, 28, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 6);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (85, 45, 1, 1, 20, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 4);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (86, 45, 3, 1, 21, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 9);
INSERT INTO public.regimen_ejercicio (id_regimen_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus, id_ejercicio) VALUES (87, 45, 3, 1, 28, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 6);


--
-- Data for Name: regimen_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (1, 37, 2, 2, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (2, 37, 3, 200, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (3, 37, 3, 3, '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (4, 54, 2, 100, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (5, 54, 2, 50, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (6, 54, 2, 10, '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (7, 33, 1, 1, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (8, 33, 2, 5, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (9, 33, 3, 2, '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (11, 10, 2, 20, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (12, 10, 3, 10, '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (13, 55, 1, 200, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (14, 55, 2, 150, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (15, 55, 2, 10, '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (16, 25, 2, 1, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (17, 25, 3, 200, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (18, 25, 2, 1, '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (19, 40, 2, 2, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (20, 40, 2, 30, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (21, 40, 2, 3, '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (22, 56, 1, 1, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 10);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (23, 56, 2, 3000, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (24, 56, 2, 200, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 8);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (25, 56, 1, 400, '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 2);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (26, 57, 2, 10, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (27, 57, 3, 100, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (28, 57, 2, 10, '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (29, 1, 3, 124, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (30, 1, 2, 1000, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (31, 1, 3, 1500, '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (32, 11, 3, 100, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 10);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (33, 11, 3, 100, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (34, 11, 1, 1000, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 8);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (35, 11, 1, 1000, '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 2);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (10, 10, 3, 30, '2018-05-31 08:42:52.191', '2018-05-31 08:42:52.191', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (36, 9, 3, 2, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (37, 9, 3, 100, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (38, 9, 3, 2, '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (39, 4, 2, 1, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (40, 4, 3, 300, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (41, 4, 3, 1, '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (42, 2, 3, 200, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (43, 2, 3, 100, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (44, 2, 3, 200, '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (45, 6, 3, 2, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (46, 6, 2, 100, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (47, 6, 3, 2, '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (48, 8, 3, 200, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (49, 8, 2, 200, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (50, 8, 2, 100, '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (51, 12, 3, 2, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (52, 12, 3, 100, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (53, 12, 3, 3, '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (54, 15, 3, 3, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (55, 15, 2, 100, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (56, 15, 3, 3, '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (60, 18, 3, 1, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (62, 18, 3, 1, '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (61, 18, 2, 30, '2018-06-04 15:00:55.777', '2018-06-04 15:00:55.777', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (63, 26, 1, 3, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (64, 26, 1, 3, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (65, 26, 2, 4, '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (66, 59, 2, 1, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (67, 59, 2, 10, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (68, 59, 3, 2, '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (69, 59, 3, 80, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (70, 59, 3, 50, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (71, 59, 3, 10, '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (72, 37, 1, 26, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (73, 37, 2, 15, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (74, 37, 3, 14, '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (75, 59, 3, 2, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 10);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (76, 59, 2, 20, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (77, 59, 3, 5, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 8);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (78, 59, 3, 10, '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 2);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (79, 59, 3, 80, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 7);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (80, 59, 3, 50, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 4);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (81, 59, 3, 10, '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 1);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (82, 45, 3, 1, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (83, 45, 1, 1, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (84, 45, 2, 1, '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 6);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (88, 45, 3, 1, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 3);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (89, 45, 1, 1, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 9);
INSERT INTO public.regimen_suplemento (id_regimen_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus, id_suplemento) VALUES (90, 45, 2, 1, '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 6);


--
-- Data for Name: respuesta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (1, 5, 'Gracias por su sugerencia!', '2018-05-27 06:15:30.867153', '2018-05-27 06:15:30.867153', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (2, 4, 'Sera contactado a la brevedad', '2018-05-27 06:16:39.085637', '2018-05-27 06:16:39.085637', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (3, 2, 'Disculpe las molestias causadas, procederemos a habilitar una nueva cita', '2018-05-27 06:17:30.457636', '2018-05-27 06:17:30.457636', 1, true);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (4, 2, 'Disculpe, su reclamo no procede', '2018-05-27 06:18:00.660172', '2018-05-27 06:18:00.660172', 1, false);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (6, 2, 'Disculpe las molestias ocasionadas. Le sera asignado un nuevo nutricionista.', '2018-05-27 06:19:37.19835', '2018-05-27 06:19:37.19835', 1, true);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (8, 5, 'Tomaremos en cuenta su sugerencia.', '2018-05-27 06:24:44.321556', '2018-05-27 06:24:44.321556', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (10, 5, 'Tomaremos en cuenta su opini├│n para mejorar.', '2018-05-27 06:26:05.981166', '2018-05-27 06:26:05.981166', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (11, 8, 'Gracias por su opini├│n.', '2018-05-27 06:27:43.642863', '2018-05-27 06:27:43.642863', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (12, 8, 'Gracias, tomaremos en cuenta su opini├│n.', '2018-05-27 06:29:17.508739', '2018-05-27 06:29:17.508739', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (13, 8, 'Tomaremos en cuenta su opini├│n para mejorar.', '2018-05-27 06:29:47.364336', '2018-05-27 06:29:47.364336', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (14, 7, 'Gracias por tu comentario', '2018-05-29 23:17:54.847566', '2018-05-29 23:17:54.847566', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (7, 4, 'Su comentario nos ayuda a mejorar', '2018-05-27 06:21:39.966', '2018-05-27 06:21:39.966', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (9, 5, 'Gracias su  por aporte', '2018-05-27 06:25:24.145', '2018-05-27 06:25:24.145', 1, NULL);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (5, 2, 'Su reclamo no procede, por favor revise las condiciones de garantia.', '2018-05-27 06:18:41.82', '2018-05-27 06:18:41.82', 1, false);
INSERT INTO public.respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus, aprobado) VALUES (15, 6, 'Gracias por preguntar', '2018-06-04 22:21:39.615627', '2018-06-04 22:21:39.615627', 1, false);


--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (2, 'Administrador', 'Todas las funcionalidades', '2018-05-27 06:50:21.286', '2018-05-27 06:50:21.286', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (8, 'Administrador', 'Todo el acceso', '2018-05-29 08:55:07.402', '2018-05-29 08:55:07.402', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (5, 'Gerente', 'Gerente de la organizacion', '2018-05-28 06:09:29.003', '2018-05-28 06:09:29.003', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (1, 'Nutricionista', 'Atencion de pacientes', '2018-05-27 06:49:13.083', '2018-05-27 06:49:13.083', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (7, 'Prueba', 'Rol de prueba', '2018-05-29 04:26:16.927', '2018-05-29 04:26:16.927', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (14, 'prueba 3', '3', '2018-05-30 03:08:01.963', '2018-05-30 03:08:01.963', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (12, 'Prueba 2000', 'prueba', '2018-05-30 02:58:26.293', '2018-05-30 02:58:26.293', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (13, 'prueba', '2', '2018-05-30 03:02:19.735', '2018-05-30 03:02:19.735', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (11, 'Administrador', 'Todo el acceso', '2018-05-30 01:06:03.519', '2018-05-30 01:06:03.519', 0, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (10, 'Nutricionista', 'Atencion de clientes', '2018-05-29 09:09:24.942', '2018-05-29 09:09:24.942', 1, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (9, 'Administrador', 'Todo el acceso', '2018-05-29 09:04:41.389', '2018-05-29 09:04:41.389', 1, 0);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (16, 'Prueba', 'rol de prueba', '2018-06-02 17:27:21.09', '2018-06-02 17:27:21.09', 1, 1);
INSERT INTO public.rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus, dashboard) VALUES (15, 'Gerente', 'Rol de Gerente', '2018-05-31 10:21:23.944', '2018-05-31 10:21:23.944', 1, 1);


--
-- Data for Name: rol_funcionalidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 1, '2018-05-27 06:49:14.143351', '2018-05-27 06:49:14.143351', 1, 1);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 9, '2018-05-27 06:49:14.15549', '2018-05-27 06:49:14.15549', 1, 2);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 8, '2018-05-27 06:49:14.157167', '2018-05-27 06:49:14.157167', 1, 3);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 17, '2018-05-27 06:49:14.20907', '2018-05-27 06:49:14.20907', 1, 4);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 10, '2018-05-27 06:49:14.240705', '2018-05-27 06:49:14.240705', 1, 5);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 18, '2018-05-27 06:49:14.253809', '2018-05-27 06:49:14.253809', 1, 6);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 19, '2018-05-27 06:49:14.262762', '2018-05-27 06:49:14.262762', 1, 7);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 20, '2018-05-27 06:49:14.271829', '2018-05-27 06:49:14.271829', 1, 8);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 13, '2018-05-27 06:49:14.327089', '2018-05-27 06:49:14.327089', 1, 9);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 14, '2018-05-27 06:49:14.358925', '2018-05-27 06:49:14.358925', 1, 10);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 15, '2018-05-27 06:49:14.372301', '2018-05-27 06:49:14.372301', 1, 11);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 30, '2018-05-27 06:49:14.412256', '2018-05-27 06:49:14.412256', 1, 12);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 16, '2018-05-27 06:49:14.420539', '2018-05-27 06:49:14.420539', 1, 13);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 31, '2018-05-27 06:49:14.421454', '2018-05-27 06:49:14.421454', 1, 14);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 32, '2018-05-27 06:49:14.446318', '2018-05-27 06:49:14.446318', 1, 15);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 21, '2018-05-27 06:49:14.477542', '2018-05-27 06:49:14.477542', 1, 16);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 28, '2018-05-27 06:49:14.499575', '2018-05-27 06:49:14.499575', 1, 17);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 23, '2018-05-27 06:49:14.528872', '2018-05-27 06:49:14.528872', 1, 18);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 24, '2018-05-27 06:49:14.570893', '2018-05-27 06:49:14.570893', 1, 19);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 25, '2018-05-27 06:49:14.571825', '2018-05-27 06:49:14.571825', 1, 20);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 26, '2018-05-27 06:49:14.580196', '2018-05-27 06:49:14.580196', 1, 21);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 33, '2018-05-27 06:49:14.611672', '2018-05-27 06:49:14.611672', 1, 22);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 27, '2018-05-27 06:49:14.619881', '2018-05-27 06:49:14.619881', 1, 23);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 35, '2018-05-27 06:49:14.650347', '2018-05-27 06:49:14.650347', 1, 24);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 36, '2018-05-27 06:49:14.685958', '2018-05-27 06:49:14.685958', 1, 25);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 58, '2018-05-27 06:49:14.700699', '2018-05-27 06:49:14.700699', 1, 26);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 57, '2018-05-27 06:49:14.77912', '2018-05-27 06:49:14.77912', 1, 27);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (1, 37, '2018-05-27 06:49:14.895039', '2018-05-27 06:49:14.895039', 1, 28);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 1, '2018-05-27 06:50:22.308797', '2018-05-27 06:50:22.308797', 1, 29);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 8, '2018-05-27 06:50:22.33754', '2018-05-27 06:50:22.33754', 1, 30);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 10, '2018-05-27 06:50:22.557368', '2018-05-27 06:50:22.557368', 1, 31);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 9, '2018-05-27 06:50:22.55772', '2018-05-27 06:50:22.55772', 1, 32);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 18, '2018-05-27 06:50:22.568008', '2018-05-27 06:50:22.568008', 1, 33);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 17, '2018-05-27 06:50:22.568907', '2018-05-27 06:50:22.568907', 1, 34);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 19, '2018-05-27 06:50:22.575217', '2018-05-27 06:50:22.575217', 1, 35);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 20, '2018-05-27 06:50:22.57679', '2018-05-27 06:50:22.57679', 1, 36);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 13, '2018-05-27 06:50:22.671315', '2018-05-27 06:50:22.671315', 1, 37);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 14, '2018-05-27 06:50:22.681139', '2018-05-27 06:50:22.681139', 1, 38);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 16, '2018-05-27 06:50:22.690579', '2018-05-27 06:50:22.690579', 1, 39);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 15, '2018-05-27 06:50:22.691941', '2018-05-27 06:50:22.691941', 1, 40);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 30, '2018-05-27 06:50:22.699986', '2018-05-27 06:50:22.699986', 1, 41);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 31, '2018-05-27 06:50:22.825426', '2018-05-27 06:50:22.825426', 1, 42);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 21, '2018-05-27 06:50:22.826085', '2018-05-27 06:50:22.826085', 1, 43);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 28, '2018-05-27 06:50:22.834563', '2018-05-27 06:50:22.834563', 1, 44);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 23, '2018-05-27 06:50:22.834785', '2018-05-27 06:50:22.834785', 1, 45);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 32, '2018-05-27 06:50:22.841868', '2018-05-27 06:50:22.841868', 1, 46);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 24, '2018-05-27 06:50:22.842853', '2018-05-27 06:50:22.842853', 1, 47);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 26, '2018-05-27 06:50:22.98652', '2018-05-27 06:50:22.98652', 1, 48);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 25, '2018-05-27 06:50:22.993388', '2018-05-27 06:50:22.993388', 1, 49);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 27, '2018-05-27 06:50:23.104452', '2018-05-27 06:50:23.104452', 1, 50);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 33, '2018-05-27 06:50:23.105097', '2018-05-27 06:50:23.105097', 1, 51);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 36, '2018-05-27 06:50:23.111448', '2018-05-27 06:50:23.111448', 1, 52);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 35, '2018-05-27 06:50:23.112044', '2018-05-27 06:50:23.112044', 1, 53);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 58, '2018-05-27 06:50:23.118471', '2018-05-27 06:50:23.118471', 1, 54);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 57, '2018-05-27 06:50:23.126578', '2018-05-27 06:50:23.126578', 1, 55);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 37, '2018-05-27 06:50:23.259213', '2018-05-27 06:50:23.259213', 1, 56);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 40, '2018-05-27 06:50:23.260453', '2018-05-27 06:50:23.260453', 1, 57);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 41, '2018-05-27 06:50:23.261735', '2018-05-27 06:50:23.261735', 1, 58);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 42, '2018-05-27 06:50:23.270258', '2018-05-27 06:50:23.270258', 1, 59);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 43, '2018-05-27 06:50:23.271813', '2018-05-27 06:50:23.271813', 1, 60);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 44, '2018-05-27 06:50:23.282187', '2018-05-27 06:50:23.282187', 1, 61);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 45, '2018-05-27 06:50:23.689301', '2018-05-27 06:50:23.689301', 1, 62);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 46, '2018-05-27 06:50:23.726069', '2018-05-27 06:50:23.726069', 1, 63);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 47, '2018-05-27 06:50:23.727378', '2018-05-27 06:50:23.727378', 1, 64);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 48, '2018-05-27 06:50:23.737717', '2018-05-27 06:50:23.737717', 1, 65);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 49, '2018-05-27 06:50:23.749504', '2018-05-27 06:50:23.749504', 1, 66);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 53, '2018-05-27 06:50:23.762535', '2018-05-27 06:50:23.762535', 1, 67);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 54, '2018-05-27 06:50:24.457601', '2018-05-27 06:50:24.457601', 1, 68);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 55, '2018-05-27 06:50:24.484792', '2018-05-27 06:50:24.484792', 1, 69);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (2, 56, '2018-05-27 06:50:24.495638', '2018-05-27 06:50:24.495638', 1, 70);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 1, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 497);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 8, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 498);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 2, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 499);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 18, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 500);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 19, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 501);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 20, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 502);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 14, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 503);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 11, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 504);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 24, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 505);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 22, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 506);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (11, 3, '2018-05-30 02:50:52.48551', '2018-05-30 02:50:52.48551', 1, 507);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (13, 18, '2018-05-30 03:06:49.936665', '2018-05-30 03:06:49.936665', 1, 514);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (13, 2, '2018-05-30 03:06:49.936665', '2018-05-30 03:06:49.936665', 1, 515);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 1, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 546);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 8, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 547);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 2, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 548);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 9, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 549);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 12, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 550);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 11, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 551);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 13, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 552);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 14, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 553);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 15, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 554);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 16, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 555);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 21, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 556);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 3, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 557);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (5, 19, '2018-05-28 06:35:09.170352', '2018-05-28 06:35:09.170352', 1, 108);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (5, 20, '2018-05-28 06:35:09.170352', '2018-05-28 06:35:09.170352', 1, 109);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 28, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 558);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 1, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 111);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 8, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 112);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 2, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 113);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 18, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 114);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 12, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 115);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 11, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 116);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 13, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 117);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 14, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 118);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 15, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 119);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 21, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 120);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 3, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 121);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 23, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 122);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 22, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 123);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 33, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 124);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 44, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 125);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 36, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 126);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 5, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 127);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 40, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 128);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 38, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 129);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 6, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 130);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 45, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 131);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 39, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 132);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 53, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 133);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 50, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 134);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 7, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 135);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 58, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 136);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 30, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 559);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 29, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 560);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 31, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 561);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 32, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 562);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 33, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 563);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 4, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 564);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 35, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 565);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 37, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 566);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 5, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 567);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 44, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 568);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 39, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 569);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 52, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 137);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 56, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 138);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (7, 51, '2018-05-29 04:26:16.927047', '2018-05-29 04:26:16.927047', 1, 139);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 1, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 140);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 8, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 141);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 2, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 142);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 9, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 143);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 10, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 144);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 17, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 145);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 18, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 146);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 19, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 147);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 20, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 148);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 12, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 149);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 11, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 150);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 13, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 151);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 14, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 152);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 15, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 153);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 16, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 154);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 30, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 155);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 29, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 156);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 3, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 157);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 31, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 158);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 32, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 159);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 21, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 160);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 28, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 161);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 23, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 162);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 22, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 163);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 24, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 164);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 25, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 165);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 26, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 166);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 27, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 167);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 33, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 168);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 44, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 169);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 35, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 170);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 36, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 171);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 5, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 172);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 37, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 173);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 40, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 174);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 38, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 175);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 6, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 176);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 41, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 177);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 42, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 178);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 43, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 179);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 39, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 180);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 45, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 181);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 46, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 182);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 47, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 183);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 48, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 184);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 49, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 185);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 53, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 186);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 50, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 187);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 7, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 188);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 54, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 189);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 55, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 190);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 51, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 191);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 56, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 192);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 57, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 193);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 52, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 194);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 58, '2018-05-29 08:55:07.402405', '2018-05-29 08:55:07.402405', 1, 195);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (8, 4, '2018-05-29 09:02:04.316203', '2018-05-29 09:02:04.316203', 1, 196);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (12, 8, '2018-05-30 02:58:26.293054', '2018-05-30 02:58:26.293054', 1, 508);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (12, 2, '2018-05-30 02:58:26.293054', '2018-05-30 02:58:26.293054', 1, 509);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (12, 9, '2018-05-30 02:58:26.293054', '2018-05-30 02:58:26.293054', 1, 510);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (14, 18, '2018-05-30 03:08:01.96317', '2018-05-30 03:08:01.96317', 1, 516);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (14, 2, '2018-05-30 03:08:01.96317', '2018-05-30 03:08:01.96317', 1, 517);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (10, 6, '2018-05-30 21:34:08.072871', '2018-05-30 21:34:08.072871', 1, 570);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 43, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 883);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 44, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 884);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 39, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 885);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 45, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 886);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 46, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 887);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 47, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 888);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 48, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 889);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 49, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 890);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 53, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 891);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 50, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 892);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 7, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 893);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 54, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 894);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 1, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 895);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 17, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 896);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 2, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 897);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 18, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 898);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 23, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 899);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 22, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 900);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 3, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 901);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 24, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 902);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 25, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 903);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 26, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 904);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 27, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 905);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 36, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 906);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 5, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 907);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 37, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 908);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 40, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 909);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 38, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 910);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 6, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 911);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 41, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 912);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 42, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 913);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 43, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 914);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 44, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 915);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 39, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 916);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 45, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 917);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 46, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 918);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 47, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 919);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 48, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 920);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 49, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 921);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 60, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 922);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 7, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 923);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 53, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 924);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 50, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 925);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 54, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 926);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 55, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 927);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 1, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 666);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 8, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 667);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 2, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 668);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 9, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 669);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 10, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 670);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 17, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 671);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 18, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 672);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 19, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 673);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 20, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 674);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 12, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 675);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 11, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 676);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 13, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 677);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 14, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 678);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 15, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 679);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 16, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 680);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 21, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 681);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 3, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 682);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 28, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 683);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 23, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 684);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 22, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 685);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 25, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 686);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 26, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 687);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 27, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 688);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 30, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 689);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 29, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 690);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 31, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 691);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 32, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 692);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 33, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 693);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 4, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 694);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 35, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 695);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 36, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 696);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 5, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 697);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 37, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 698);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 40, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 699);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 38, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 700);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 6, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 701);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 41, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 702);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 42, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 703);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 43, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 704);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 44, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 705);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 39, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 706);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 45, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 707);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 46, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 708);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 47, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 709);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 48, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 710);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 49, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 711);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 60, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 712);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 7, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 713);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 53, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 714);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 50, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 715);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 54, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 716);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 55, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 717);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 51, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 718);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 56, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 719);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 57, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 720);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 52, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 721);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (9, 58, '2018-06-01 01:50:09.875536', '2018-06-01 01:50:09.875536', 1, 722);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 1, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 868);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 8, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 869);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 2, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 870);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 9, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 871);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 13, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 872);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 11, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 873);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 28, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 874);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 3, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 875);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 24, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 876);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 22, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 877);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 40, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 878);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 38, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 879);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 6, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 880);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 41, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 881);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (16, 42, '2018-06-05 10:03:24.643395', '2018-06-05 10:03:24.643395', 1, 882);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 51, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 928);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 56, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 929);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 57, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 930);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 52, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 931);
INSERT INTO public.rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) VALUES (15, 58, '2018-06-06 06:32:22.048738', '2018-06-06 06:32:22.048738', 1, 932);


--
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (1, 6, 3, 3, 'Deportista', 'Este es un servicio especial para todas las personas que practiquen alg├║n deporte', 'http://res.cloudinary.com/saschanutric/image/upload/v1527398897/nfaszi5lx8ne0rbi0uuq.jpg', 3, '2018-05-27 05:28:17.343695', '2018-05-27 05:28:17.343695', 1, 1, 1000.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (3, 3, 2, 2, 'Control de peso', 'Este es un servicio especial para todas aquellas personas que desean controlar su peso', 'http://res.cloudinary.com/saschanutric/image/upload/v1527399460/lp591cdcjw7menepioor.jpg', 3, '2018-05-27 05:37:40.812392', '2018-05-27 05:37:40.812392', 1, 8, 900.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (4, 1, 3, 2, 'Aumento de masa muscular', 'Este servicio es para todas aquellas personas que deseen aumentar su masa muscular', 'http://res.cloudinary.com/saschanutric/image/upload/v1527399881/ivntxlm6ofjzfrrahbuo.jpg', 3, '2018-05-27 05:44:42.19474', '2018-05-27 05:44:42.19474', 1, 1, 1000.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (5, 15, 2, 2, 'Vegetariano', 'Este es un servicio especial para todas aquellas personas vegetarianas, con planes adaptados a sus caracter├¡sticas ', 'http://res.cloudinary.com/saschanutric/image/upload/v1527400259/caqbuwur9uwxudssw6p8.jpg', 3, '2018-05-27 05:51:00.157095', '2018-05-27 05:51:00.157095', 1, 6, 500.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (6, 11, 1, 1, 'Adultos mayores', 'Este es un servicio especial para aquellas personas mayores', 'http://res.cloudinary.com/saschanutric/image/upload/v1527400548/fng820wm4j591widlvtr.jpg', 3, '2018-05-27 05:55:49.269733', '2018-05-27 05:55:49.269733', 1, 3, 700.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (7, 5, 1, 1, 'Trastornos alimenticios', 'Este servicio es especial para aquellas personas que tengan alg├║n tipo de trastorno alimenticio', 'http://res.cloudinary.com/saschanutric/image/upload/v1527431900/fpyhnkjtot4nntura8fa.jpg', 3, '2018-05-27 14:38:20.434', '2018-05-27 14:38:20.434', 1, 5, 600.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (9, 3, 1, 2, 'Diabeticos', 'Adaptado a la alimentaci├│n que deben tener las personas diabeticas.', 'http://res.cloudinary.com/saschanutric/image/upload/v1527546175/s5p8kwd8hncrcuuxfuhv.jpg', 3, '2018-05-28 22:22:55.282', '2018-05-28 22:22:55.282', 1, 9, 1200.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (8, 6, 2, 1, 'Fitness', 'Nutrici├│n ideal para personas que llevan un estilo de vida saludable.', 'http://res.cloudinary.com/saschanutric/image/upload/v1527545333/cupjwnwvxddnio3rnkah.jpg', 3, '2018-05-28 22:08:54.423', '2018-05-28 22:08:54.423', 1, 1, 2000.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (11, 1, 1, 4, 'Serivicio de Prueba', 'Servicio de prueba', 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png', 10, '2018-05-29 18:41:07.983', '2018-05-29 18:41:07.983', 0, 1, 100.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (2, 14, 1, 1, 'Post-Parto', 'Este es un servicio especial para todas aquellas mujeres que acaban de dar a luz y est├ín en proceso de lactancia', 'http://res.cloudinary.com/saschanutric/image/upload/v1527399205/mxxtpuohikljjujtaygv.jpg', 3, '2018-05-27 05:33:26.106', '2018-05-27 05:33:26.106', 1, 4, 800.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (12, 16, NULL, NULL, 'B├ísico', 'Si lo que buscas es un plan nutricional adaptado a tus necesidades, este servicio es para ti.', 'http://res.cloudinary.com/saschanutric/image/upload/v1527716663/pjpf1we2zfljff2zt4xb.jpg', 3, '2018-05-30 21:44:23.428646', '2018-05-30 21:44:23.428646', 1, 8, 750000.00);
INSERT INTO public.servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, numero_visitas, fecha_creacion, fecha_actualizacion, estatus, id_especialidad, precio) VALUES (13, 7, 2, 1, 'Servicio de Prueba', 'esto es un servicio de prueba', 'http://res.cloudinary.com/saschanutric/image/upload/v1527859329/kdhakiffrcgyrby3h5b0.png', 3, '2018-06-01 13:22:10.404623', '2018-06-01 13:22:10.404623', 1, 9, 1000000.00);


--
-- Data for Name: slide; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Nutrici├│n 1', 'Imagen', 1, 'http://res.cloudinary.com/saschanutric/image/upload/v1527400704/vquwklxztxrzv7scvqjg.jpg', '2018-05-27 05:58:25.215651', '2018-05-27 05:58:25.215651', 1);
INSERT INTO public.slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Nutrici├│n 2', 'Imagen', 2, 'http://res.cloudinary.com/saschanutric/image/upload/v1527400737/ir82mutodlqzuv8jk0av.jpg', '2018-05-27 05:58:57.366255', '2018-05-27 05:58:57.366255', 1);
INSERT INTO public.slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Nutrici├│n 3', 'Imagen', 3, 'http://res.cloudinary.com/saschanutric/image/upload/v1527400787/poew9ygmppldguqn6cno.jpg', '2018-05-27 05:59:47.661392', '2018-05-27 05:59:47.661392', 1);
INSERT INTO public.slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Nutrici├│n 4', 'Imagen', 4, 'http://res.cloudinary.com/saschanutric/image/upload/v1527400820/qen8ofrnvib9wfqpuzg1.jpg', '2018-05-27 06:00:21.196056', '2018-05-27 06:00:21.196056', 1);
INSERT INTO public.slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Nutrici├│n 5', 'Imagen', 5, 'http://res.cloudinary.com/saschanutric/image/upload/v1527400850/nwddjpbuhuvooheabte8.jpg', '2018-05-27 06:00:50.528154', '2018-05-27 06:00:50.528154', 1);


--
-- Data for Name: solicitud_servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (15, 37, 7, NULL, 4, NULL, NULL, '2018-05-27 14:28:38.912499', '2018-05-27 14:28:38.912499', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (16, 30, 8, NULL, 4, NULL, NULL, '2018-05-27 14:43:27.654822', '2018-05-27 14:43:27.654822', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (17, 16, 7, NULL, 3, NULL, NULL, '2018-05-27 15:11:22.840751', '2018-05-27 15:11:22.840751', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (18, 16, 7, NULL, 3, NULL, NULL, '2018-05-27 15:12:36.148621', '2018-05-27 15:12:36.148621', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (19, 16, 7, NULL, 3, NULL, NULL, '2018-05-27 15:13:36.572109', '2018-05-27 15:13:36.572109', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (20, 16, 7, NULL, 3, NULL, NULL, '2018-05-27 15:14:16.678696', '2018-05-27 15:14:16.678696', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (21, 54, 5, NULL, 2, NULL, NULL, '2018-05-27 18:17:55.499008', '2018-05-27 18:17:55.499008', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (22, 54, 5, NULL, 2, NULL, NULL, '2018-05-27 18:19:15.164564', '2018-05-27 18:19:15.164564', 1, 4);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (23, 54, 5, NULL, 2, NULL, NULL, '2018-05-27 18:21:13.531347', '2018-05-27 18:21:13.531347', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (24, 1, 9, NULL, 7, NULL, NULL, '2018-05-29 00:44:11.240641', '2018-05-29 00:44:11.240641', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (25, 2, 7, NULL, 8, NULL, NULL, '2018-05-29 00:46:54.167265', '2018-05-29 00:46:54.167265', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (26, 4, 7, NULL, 4, NULL, NULL, '2018-05-29 01:14:47.108441', '2018-05-29 01:14:47.108441', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (27, 3, 11, NULL, 4, NULL, NULL, '2018-05-29 01:18:36.565882', '2018-05-29 01:18:36.565882', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (28, 6, 8, NULL, 3, NULL, NULL, '2018-05-29 01:33:56.033899', '2018-05-29 01:33:56.033899', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (29, 6, 8, NULL, 3, NULL, NULL, '2018-05-29 01:34:50.117839', '2018-05-29 01:34:50.117839', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (30, 8, 8, NULL, 8, NULL, NULL, '2018-05-29 01:51:29.261905', '2018-05-29 01:51:29.261905', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (31, 33, 8, NULL, 5, NULL, NULL, '2018-05-29 19:53:59.692261', '2018-05-29 19:53:59.692261', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (32, 33, 9, NULL, 5, NULL, NULL, '2018-05-29 20:37:46.092464', '2018-05-29 20:37:46.092464', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (33, 7, 6, NULL, 5, NULL, NULL, '2018-05-30 19:35:26.143224', '2018-05-30 19:35:26.143224', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (34, 9, 24, NULL, 3, NULL, NULL, '2018-05-30 19:41:00.311832', '2018-05-30 19:41:00.311832', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (35, 10, 9, NULL, 7, NULL, NULL, '2018-05-30 19:45:17.097513', '2018-05-30 19:45:17.097513', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (36, 11, 8, NULL, 1, NULL, NULL, '2018-05-30 19:49:05.950677', '2018-05-30 19:49:05.950677', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (37, 12, 8, NULL, 6, NULL, NULL, '2018-05-30 19:52:27.152219', '2018-05-30 19:52:27.152219', 1, 4);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (38, 12, 5, NULL, 9, NULL, NULL, '2018-05-30 19:55:01.86682', '2018-05-30 19:55:01.86682', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (39, 13, 5, NULL, 3, NULL, NULL, '2018-05-30 20:00:55.958753', '2018-05-30 20:00:55.958753', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (40, 15, 10, NULL, 9, NULL, NULL, '2018-05-30 20:12:43.998593', '2018-05-30 20:12:43.998593', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (41, 17, 9, NULL, 3, NULL, NULL, '2018-05-30 20:23:18.607635', '2018-05-30 20:23:18.607635', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (42, 18, 6, NULL, 3, NULL, NULL, '2018-05-30 20:28:05.812934', '2018-05-30 20:28:05.812934', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (43, 19, 6, NULL, 9, NULL, NULL, '2018-05-30 20:31:04.918544', '2018-05-30 20:31:04.918544', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (44, 19, 7, NULL, 9, NULL, NULL, '2018-05-30 20:32:52.063727', '2018-05-30 20:32:52.063727', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (45, 19, 24, NULL, 9, NULL, NULL, '2018-05-30 20:38:46.023439', '2018-05-30 20:38:46.023439', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (46, 20, 24, NULL, 9, NULL, NULL, '2018-05-30 20:47:23.921972', '2018-05-30 20:47:23.921972', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (47, 21, 12, NULL, 4, NULL, NULL, '2018-05-30 20:59:07.481534', '2018-05-30 20:59:07.481534', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (48, 23, 6, NULL, 12, NULL, NULL, '2018-05-30 21:55:35.692019', '2018-05-30 21:55:35.692019', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (49, 24, 8, NULL, 12, NULL, NULL, '2018-05-30 21:58:41.749888', '2018-05-30 21:58:41.749888', 1, 4);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (50, 24, 6, NULL, 12, NULL, NULL, '2018-05-30 22:01:13.244598', '2018-05-30 22:01:13.244598', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (51, 25, 7, NULL, 5, NULL, NULL, '2018-05-31 07:16:10.167875', '2018-05-31 07:16:10.167875', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (52, 25, 7, NULL, 5, NULL, NULL, '2018-05-31 07:16:47.582042', '2018-05-31 07:16:47.582042', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (53, 40, 8, NULL, 4, NULL, NULL, '2018-05-31 08:17:33.902988', '2018-05-31 08:17:33.902988', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (54, 40, 8, NULL, 4, NULL, NULL, '2018-05-31 08:18:37.936665', '2018-05-31 08:18:37.936665', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (55, 55, 7, NULL, 8, NULL, NULL, '2018-05-31 11:40:05.155587', '2018-05-31 11:40:05.155587', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (56, 28, 7, NULL, 3, NULL, NULL, '2018-06-01 07:11:36.808015', '2018-06-01 07:11:36.808015', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (57, 28, 7, NULL, 3, NULL, NULL, '2018-06-01 07:12:29.375298', '2018-06-01 07:12:29.375298', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (58, 56, 5, NULL, 1, NULL, NULL, '2018-06-01 07:49:49.510987', '2018-06-01 07:49:49.510987', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (59, 56, 8, NULL, 1, NULL, NULL, '2018-06-01 07:50:39.640549', '2018-06-01 07:50:39.640549', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (60, 57, 7, NULL, 13, NULL, NULL, '2018-06-01 13:24:03.911451', '2018-06-01 13:24:03.911451', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (61, 57, 7, NULL, 13, NULL, NULL, '2018-06-01 13:25:34.465554', '2018-06-01 13:25:34.465554', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (62, 57, 7, NULL, 13, NULL, NULL, '2018-06-01 13:26:39.306542', '2018-06-01 13:26:39.306542', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (63, 57, 7, NULL, 13, NULL, NULL, '2018-06-01 13:27:27.973592', '2018-06-01 13:27:27.973592', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (64, 57, 7, NULL, 13, NULL, NULL, '2018-06-01 13:27:56.268999', '2018-06-01 13:27:56.268999', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (65, 16, 7, NULL, 9, NULL, NULL, '2018-06-03 22:41:22.177944', '2018-06-03 22:41:22.177944', 1, 4);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (66, 16, 7, NULL, 9, NULL, NULL, '2018-06-03 22:42:11.193842', '2018-06-03 22:42:11.193842', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (67, 16, 7, NULL, 9, NULL, NULL, '2018-06-03 22:42:51.297514', '2018-06-03 22:42:51.297514', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (68, 44, 9, NULL, 12, NULL, NULL, '2018-06-03 22:52:43.095056', '2018-06-03 22:52:43.095056', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (69, 44, 7, NULL, 8, NULL, NULL, '2018-06-03 22:59:39.418328', '2018-06-03 22:59:39.418328', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (70, 25, 7, NULL, 12, NULL, NULL, '2018-06-04 00:49:00.953408', '2018-06-04 00:49:00.953408', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (71, 37, 7, NULL, 13, NULL, NULL, '2018-06-04 11:48:07.755443', '2018-06-04 11:48:07.755443', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (72, 33, 7, NULL, 12, NULL, NULL, '2018-06-04 13:38:16.74193', '2018-06-04 13:38:16.74193', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (73, 36, 7, NULL, 5, NULL, NULL, '2018-06-05 00:55:24.505286', '2018-06-05 00:55:24.505286', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (74, 36, 7, NULL, 5, NULL, NULL, '2018-06-05 00:56:20.338861', '2018-06-05 00:56:20.338861', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (75, 36, 7, NULL, 5, NULL, NULL, '2018-06-05 01:10:14.699716', '2018-06-05 01:10:14.699716', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (76, 26, 7, NULL, 4, NULL, NULL, '2018-06-05 04:11:37.388533', '2018-06-05 04:11:37.388533', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (77, 18, 9, NULL, 12, NULL, NULL, '2018-06-05 06:01:37.784926', '2018-06-05 06:01:37.784926', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (78, 59, 8, NULL, 3, NULL, NULL, '2018-06-05 08:41:06.531511', '2018-06-05 08:41:06.531511', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (79, 59, 8, NULL, 3, NULL, NULL, '2018-06-05 08:42:37.542818', '2018-06-05 08:42:37.542818', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (80, 59, 7, NULL, 7, NULL, NULL, '2018-06-05 09:45:56.9009', '2018-06-05 09:45:56.9009', 1, 2);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (81, 59, 8, NULL, 7, NULL, NULL, '2018-06-05 09:46:30.430025', '2018-06-05 09:46:30.430025', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (82, 25, 8, NULL, 12, NULL, NULL, '2018-06-05 17:05:39.950113', '2018-06-05 17:05:39.950113', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (83, 59, 9, NULL, 5, NULL, NULL, '2018-06-05 20:33:46.433739', '2018-06-05 20:33:46.433739', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (84, 16, 7, NULL, 8, NULL, NULL, '2018-06-05 21:16:59.072292', '2018-06-05 21:16:59.072292', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (85, 59, 9, NULL, 12, NULL, NULL, '2018-06-05 22:48:49.922917', '2018-06-05 22:48:49.922917', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (86, 59, 6, NULL, 1, NULL, NULL, '2018-06-06 00:01:54.216693', '2018-06-06 00:01:54.216693', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (87, 59, 5, NULL, 1, NULL, NULL, '2018-06-06 00:21:51.251211', '2018-06-06 00:21:51.251211', 1, 3);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (88, 59, 9, NULL, 1, NULL, NULL, '2018-06-06 00:22:47.783451', '2018-06-06 00:22:47.783451', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (89, 59, 8, NULL, 8, NULL, NULL, '2018-06-06 02:44:15.71823', '2018-06-06 02:44:15.71823', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (90, 59, 6, NULL, 8, NULL, NULL, '2018-06-06 02:53:07.0047', '2018-06-06 02:53:07.0047', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (95, 45, 9, NULL, 9, NULL, NULL, '2018-06-06 03:55:51.548749', '2018-06-06 03:55:51.548749', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (96, 45, 9, NULL, 4, NULL, NULL, '2018-06-06 04:47:31.727616', '2018-06-06 04:47:31.727616', 1, 1);
INSERT INTO public.solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus, id_estado_solicitud) VALUES (97, 16, 5, NULL, 12, NULL, NULL, '2018-06-06 14:48:39.764145', '2018-06-06 14:48:39.764145', 1, 1);


--
-- Data for Name: suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 5, 'Hierro', '2018-05-27 03:26:07.065239', '2018-05-27 03:26:07.065239', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (9, 5, 'L-Carnitina', '2018-05-27 03:35:23.346986', '2018-05-27 03:35:23.346986', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 5, '├ücido Hialur├│nico', '2018-05-27 03:18:42.618476', '2018-05-27 03:18:42.618476', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (14, 31, 'Vitamina E', '2018-05-28 23:47:04.027602', '2018-05-28 23:47:04.027602', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (13, 31, 'Vitamina D', '2018-05-28 23:41:40.540917', '2018-05-28 23:41:40.540917', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (12, 31, 'Vitamina A', '2018-05-28 23:41:10.513997', '2018-05-28 23:41:10.513997', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 25, 'Zinc', '2018-05-27 03:25:07.698278', '2018-05-27 03:25:07.698278', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (15, 30, 'Vitamina B12', '2018-05-29 00:02:09.126271', '2018-05-29 00:02:09.126271', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 5, 'Calcio', '2018-05-27 03:24:19.372271', '2018-05-27 03:24:19.372271', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 25, 'Col├ígeno', '2018-05-27 03:22:16.057821', '2018-05-27 03:22:16.057821', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (10, 25, 'BCAA', '2018-05-27 03:46:34.002015', '2018-05-27 03:46:34.002015', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (11, 31, 'Vitamina C', '2018-05-28 23:40:45.42975', '2018-05-28 23:40:45.42975', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 5, '├ücido F├│lico', '2018-05-27 03:17:28.676183', '2018-05-27 03:17:28.676183', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 5, 'Omega 3', '2018-05-27 03:22:49.24054', '2018-05-27 03:22:49.24054', 1);
INSERT INTO public.suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (8, 1, 'Prote├¡na', '2018-05-27 03:28:56.165124', '2018-05-27 03:28:56.165124', 1);


--
-- Data for Name: tiempo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'minutos', 'min', '2018-05-27 15:07:24.651941', '2018-05-27 15:07:24.651941', 1);
INSERT INTO public.tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'horas', 'hrs', '2018-05-27 15:07:24.651941', '2018-05-27 15:07:24.651941', 1);
INSERT INTO public.tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'meses', 'mes', '2018-05-27 15:07:24.651941', '2018-05-27 15:07:24.651941', 1);
INSERT INTO public.tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'semana', 'sem', '2018-06-01 09:30:00.780562', '2018-06-01 09:30:00.780562', 1);
INSERT INTO public.tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'd┬ía', 'ds', '2018-05-27 15:07:24.651941', '2018-05-27 15:07:24.651941', 1);


--
-- Data for Name: tipo_cita; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_cita (id_tipo_cita, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Diagnostico', '2018-05-27 04:23:46.508853', '2018-05-27 04:23:46.508853', 1);
INSERT INTO public.tipo_cita (id_tipo_cita, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Control', '2018-05-27 04:23:46.508853', '2018-05-27 04:23:46.508853', 1);
INSERT INTO public.tipo_cita (id_tipo_cita, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Reprogramada', '2018-05-27 04:23:46.508853', '2018-05-27 04:23:46.508853', 1);


--
-- Data for Name: tipo_criterio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_criterio (id_tipo_criterio, nombre, estatus, fecha_actualizacion, fecha_creacion, id_tipo_valoracion) VALUES (1, 'Servicio', 1, '2018-05-27 18:20:31.838', '2018-05-27 18:20:31.838', 1);
INSERT INTO public.tipo_criterio (id_tipo_criterio, nombre, estatus, fecha_actualizacion, fecha_creacion, id_tipo_valoracion) VALUES (2, 'Visita', 1, '2018-05-27 18:20:31.838', '2018-05-27 18:20:31.838', 2);


--
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Dieta de progresi├│n', '2018-05-27 03:56:18.940973', '2018-05-27 03:56:18.940973', 1);
INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Dieta para adelgazar', '2018-05-27 03:56:58.867436', '2018-05-27 03:56:58.867436', 1);
INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Dieta hipocal├│rica ', '2018-05-27 03:59:06.105388', '2018-05-27 03:59:06.105388', 1);
INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Dieta disociada', '2018-05-27 03:59:38.570634', '2018-05-27 03:59:38.570634', 1);
INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Dieta macrobi├│tica', '2018-05-27 04:01:07.3884', '2018-05-27 04:01:07.3884', 1);
INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 'Dieta terap├®utica', '2018-05-27 04:02:13.227364', '2018-05-27 04:02:13.227364', 1);
INSERT INTO public.tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'Alimentaci├│n y lactancia', '2018-05-27 04:48:18.048223', '2018-05-27 04:48:18.048223', 1);


--
-- Data for Name: tipo_incidencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_incidencia (id_tipo_incidencia, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Cliente', '2018-05-27 04:26:46.528974', '2018-05-27 04:26:46.528974', 1);
INSERT INTO public.tipo_incidencia (id_tipo_incidencia, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Nutricionista', '2018-05-27 04:26:46.528974', '2018-05-27 04:26:46.528974', 1);


--
-- Data for Name: tipo_motivo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (1, 'Solicitud                                         ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, false);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (2, 'Reclamo                                           ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, false);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (3, 'Incidencia                                        ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, false);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (4, 'Queja                                             ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, true);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (5, 'Sugerencia                                        ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, true);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (6, 'Pregunta                                          ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, true);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (7, 'Otro                                              ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, true);
INSERT INTO public.tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus, canal_escucha) VALUES (8, 'Opini├│n                                           ', '2018-05-27 04:47:22.817585', '2018-05-27 04:47:22.817585', 1, true);


--
-- Data for Name: tipo_notificacion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tipo_orden; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_orden (id_tipo_orden, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Normal', '2018-05-27 14:27:15.057761', '2018-05-27 14:27:15.057761', 1);
INSERT INTO public.tipo_orden (id_tipo_orden, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Promoci├│n', '2018-05-27 14:27:15.057761', '2018-05-27 14:27:15.057761', 1);
INSERT INTO public.tipo_orden (id_tipo_orden, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Garant├¡a', '2018-05-27 14:27:15.057761', '2018-05-27 14:27:15.057761', 1);


--
-- Data for Name: tipo_parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (1, 'Antropom├®trico', '2018-05-27 02:35:52.2249', '2018-05-27 02:35:52.2249', 1, false);
INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (3, 'Examen', '2018-05-27 02:36:12.261', '2018-05-27 02:36:12.261', 1, false);
INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (7, 'Medicamento', '2018-05-27 03:14:26.851414', '2018-05-27 03:14:26.851414', 1, false);
INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (6, 'Patolog├¡a', '2018-05-27 03:14:00.892', '2018-05-27 03:14:00.892', 1, true);
INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (2, 'Condici├│n', '2018-05-27 02:36:05.94', '2018-05-27 02:36:05.94', 1, true);
INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (5, 'Actividad', '2018-05-27 02:39:51.96', '2018-05-27 02:39:51.96', 1, true);
INSERT INTO public.tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus, filtrable) VALUES (4, 'Alergia', '2018-05-27 02:37:25.355', '2018-05-27 02:37:25.355', 1, true);


--
-- Data for Name: tipo_respuesta; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tipo_unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Masa', '2018-05-27 02:06:30.672517', '2018-05-27 02:06:30.672517', 1);
INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Longitud', '2018-05-27 02:16:31.476321', '2018-05-27 02:16:31.476321', 1);
INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Examen', '2018-05-27 02:23:25.479923', '2018-05-27 02:23:25.479923', 1);
INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (4, 'Volumen', '2018-05-27 02:24:26.035901', '2018-05-27 02:24:26.035901', 1);
INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (5, 'Litro', '2018-05-27 02:26:34.209', '2018-05-27 02:26:34.209', 0);
INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (6, 'Tiempo', '2018-05-27 02:31:38.43122', '2018-05-27 02:31:38.43122', 1);
INSERT INTO public.tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (7, 'Medicamento', '2018-05-27 03:20:55.222398', '2018-05-27 03:20:55.222398', 1);


--
-- Data for Name: tipo_valoracion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_valoracion (id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (1, 'Num├®rica', '2018-05-27 03:51:44.302382', '2018-05-27 03:51:44.302382', 1);
INSERT INTO public.tipo_valoracion (id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (3, 'Estimativa', '2018-05-27 03:52:37.216021', '2018-05-27 03:52:37.216021', 1);
INSERT INTO public.tipo_valoracion (id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) VALUES (2, 'Descriptiva', '2018-05-27 03:52:20.627', '2018-05-27 03:52:20.627', 1);


--
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (1, 1, 'Gramo', 'g', '2018-05-27 02:09:11.652204', '2018-05-27 02:09:11.652204', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (2, 1, 'Gramo', 'g', '2018-05-27 02:09:12.795', '2018-05-27 02:09:12.795', 0, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (3, 1, 'Kilogramo', 'kg', '2018-05-27 02:15:30.619931', '2018-05-27 02:15:30.619931', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (4, 1, 'Decagramo', 'dg', '2018-05-27 02:15:50.959057', '2018-05-27 02:15:50.959057', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (5, 1, 'Miligramo', 'mg', '2018-05-27 02:16:06.943613', '2018-05-27 02:16:06.943613', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (6, 2, 'Metro', 'm', '2018-05-27 02:16:50.880803', '2018-05-27 02:16:50.880803', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (7, 2, 'Kilometro', 'km', '2018-05-27 02:17:35.626175', '2018-05-27 02:17:35.626175', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (8, 2, 'Centimetro', 'cm', '2018-05-27 02:18:50.124791', '2018-05-27 02:18:50.124791', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (9, 2, 'Milimetro', 'mm', '2018-05-27 02:19:12.212163', '2018-05-27 02:19:12.212163', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (10, 3, 'Miligramo por decilitro', 'mg/dL', '2018-05-27 02:24:08.930763', '2018-05-27 02:24:08.930763', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (11, 3, 'Gramo por decilitro', 'g/dL', '2018-05-27 02:24:35.266353', '2018-05-27 02:24:35.266353', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (12, 3, 'Nanogramo por mililitro', 'ng/mL', '2018-05-27 02:25:28.580327', '2018-05-27 02:25:28.580327', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (13, 4, 'Litro', 'l', '2018-05-27 02:27:02.693432', '2018-05-27 02:27:02.693432', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (14, 4, 'Mililitro', 'ml', '2018-05-27 02:27:20.850017', '2018-05-27 02:27:20.850017', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (15, 4, 'Decilitro', 'dl', '2018-05-27 02:27:35.12596', '2018-05-27 02:27:35.12596', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (16, 4, 'Decilitro', 'dl', '2018-05-27 02:27:36.338621', '2018-05-27 02:27:36.338621', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (17, 1, 'Onza', 'oz', '2018-05-27 02:28:56.690333', '2018-05-27 02:28:56.690333', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (19, 1, 'Taza', 'tz', '2018-05-27 02:30:27.011794', '2018-05-27 02:30:27.011794', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (21, 1, 'Cucharada', 'cda', '2018-05-27 02:30:55.46058', '2018-05-27 02:30:55.46058', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (22, 6, 'Hora', 'h', '2018-05-27 02:31:55.145813', '2018-05-27 02:31:55.145813', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (23, 6, 'minuto', 'm', '2018-05-27 02:32:16.025314', '2018-05-27 02:32:16.025314', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (24, 6, 'Segundo', 'sg', '2018-05-27 02:32:39.7767', '2018-05-27 02:32:39.7767', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (18, 1, 'Onza', 'oz', '2018-05-27 02:28:56.759', '2018-05-27 02:28:56.759', 0, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (20, 1, 'Taza', 'tz', '2018-05-27 02:30:27.864', '2018-05-27 02:30:27.864', 0, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (25, 7, 'C├ípsula', 'cap', '2018-05-27 03:21:38.798712', '2018-05-27 03:21:38.798712', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (26, 1, 'Kilogramo por Centimetro', 'kg/cm', '2018-05-27 04:32:07.572801', '2018-05-27 04:32:07.572801', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (27, 3, 'Miligramo por litro', 'mg/l', '2018-05-27 05:44:43.570342', '2018-05-27 05:44:43.570342', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (29, 3, 'Nanogramos por decilitro', 'ng/dL', '2018-05-27 06:56:33.442873', '2018-05-27 06:56:33.442873', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (28, 3, 'Mililitro por microlitros', 'Ml/uL', '2018-05-27 06:41:31.155', '2018-05-27 06:41:31.155', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (30, 7, 'Microgramos', 'Mcg', '2018-05-27 07:04:10.288621', '2018-05-27 07:04:10.288621', 1, NULL);
INSERT INTO public.unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) VALUES (31, 7, 'Miligramos', 'Mg', '2018-05-27 07:04:54.288114', '2018-05-27 07:04:54.288114', 1, NULL);


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (1, '', 'nury.cristi@gmail.com', '$2a$12$N08w4VD7kS4mZGn5.QCu7OcQsQ/LzdslMJ0NVCpzu3sQl/fsLE46a', '$2a$12$N08w4VD7kS4mZGn5.QCu7O', '2018-05-27 02:28:28.041404', '2018-05-27 02:28:28.041404', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (2, '', 'magdalyatacho@gmail.com', '$2a$12$behGlWItaWORWLXPgYIZLuB5REpidukr7yXhqS2vBzvDdEdq8hbFq', '$2a$12$behGlWItaWORWLXPgYIZLu', '2018-05-27 02:33:53.014106', '2018-05-27 02:33:53.014106', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (3, '', 'morejose.15@gmail.com', '$2a$12$bd1gySmphHPvb8PFWGSU7u0Btra5m2sV06xW/3xWujGqZ5jAWNcgu', '$2a$12$bd1gySmphHPvb8PFWGSU7u', '2018-05-27 02:36:27.542244', '2018-05-27 02:36:27.542244', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (4, '', 'rhonalchirinos@gmail.com', '$2a$12$HZpb2wKeTVzN5cgmF9vhu.dTpgIs5WghYtMY38j0x/6TUjSX38yNW', '$2a$12$HZpb2wKeTVzN5cgmF9vhu.', '2018-05-27 02:40:49.998144', '2018-05-27 02:40:49.998144', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (5, '', 'kony1114@gmail.com', '$2a$12$3rGgQ2pRvNjrk3d31Fet/uFuSXsfIEDed3vDcxwlaVK2U2QwkDJbS', '$2a$12$3rGgQ2pRvNjrk3d31Fet/u', '2018-05-27 02:43:43.707956', '2018-05-27 02:43:43.707956', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (6, '', 'yuri.freitez23@gmail.com', '$2a$12$RIxVZcD8mL7pyplaITIO8Oow5IedJveLkmZtOeA3kA/AVFv0HC1k2', '$2a$12$RIxVZcD8mL7pyplaITIO8O', '2018-05-27 02:45:31.454609', '2018-05-27 02:45:31.454609', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (7, '', 'wualter39@gmail.com', '$2a$12$P79nDZyuO3LQvBGA2evMcegEqYs/n0j9tB.Hp21UnTgBKMvfZGfmC', '$2a$12$P79nDZyuO3LQvBGA2evMce', '2018-05-27 02:47:49.532789', '2018-05-27 02:47:49.532789', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (8, '', 'jimenezjaimary14@gmail.com', '$2a$12$Pxf6/jTNeGTTZk8T84.YW.58SmFUGuRgnL9GwXGAvO4APtRWxSd8a', '$2a$12$Pxf6/jTNeGTTZk8T84.YW.', '2018-05-27 02:50:09.183388', '2018-05-27 02:50:09.183388', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (9, '', 'josealiriorodriguezpadilla@gmail.com', '$2a$12$Yxxq/QKNyAVYxReXgQ09dOD9b9JqQoML1SgTCZMWSWcftr.Kdvcuy', '$2a$12$Yxxq/QKNyAVYxReXgQ09dO', '2018-05-27 02:52:12.637335', '2018-05-27 02:52:12.637335', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (10, '', 'mariancelisc@gmail.com', '$2a$12$AUZzVBaRUF9bWmCb4ctds.zznIevICAdYSxkIS5wdR5QdcIy3EOC2', '$2a$12$AUZzVBaRUF9bWmCb4ctds.', '2018-05-27 02:54:29.307968', '2018-05-27 02:54:29.307968', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (11, '', 'kenderson2@gmail.com', '$2a$12$ggFvCEEav4foZqgwnBma9uyWcpMAuWUcWDn6V2ghkuILxbwKwGXjG', '$2a$12$ggFvCEEav4foZqgwnBma9u', '2018-05-27 02:56:36.410331', '2018-05-27 02:56:36.410331', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (12, '', 'rjvelam25@gmail.com', '$2a$12$QTyP.ys7qqGzOH/8.8HBmuTqFewuObFO5dJp1ulnKyTow/Bty1o2u', '$2a$12$QTyP.ys7qqGzOH/8.8HBmu', '2018-05-27 02:58:36.943664', '2018-05-27 02:58:36.943664', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (13, '', 'yorneidys2013@gmail.com', '$2a$12$DNan3Y7Lh/ZoQ3NQXRWiW.iF.3IXj477IU1iyJNp2Ew7d6Kc5fqzy', '$2a$12$DNan3Y7Lh/ZoQ3NQXRWiW.', '2018-05-27 03:01:41.806896', '2018-05-27 03:01:41.806896', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (14, '', 'ruben_2693@hotmail.com', '$2a$12$B0ngqczoftX1DGCJiGg1tudajR/2vjRTQy7WrvIDwICusy6OKDtB2', '$2a$12$B0ngqczoftX1DGCJiGg1tu', '2018-05-27 03:03:56.144299', '2018-05-27 03:03:56.144299', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (15, '', 'alejandroibr9219@gmail.com', '$2a$12$Mb2l1.n6hDRuBbD0P9t1D.dwKP5Zbo3p/eI64MqH/avA03cldXL4G', '$2a$12$Mb2l1.n6hDRuBbD0P9t1D.', '2018-05-27 03:05:44.092337', '2018-05-27 03:05:44.092337', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (16, '', 'ocuervov@gmail.com', '$2a$12$CldyY7AmMxbfNdqup0FDK.StlZIi1n1ctStDMpbiTTEyebsSJWmha', '$2a$12$CldyY7AmMxbfNdqup0FDK.', '2018-05-27 03:07:50.852588', '2018-05-27 03:07:50.852588', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (17, '', 'desi.dorantes17@gmail.com', '$2a$12$G1L.zXc7Ueyj8EhNLV.N3.ClmPQJkKl97Pu7lTlbqRma08Kq2k.by', '$2a$12$G1L.zXc7Ueyj8EhNLV.N3.', '2018-05-27 03:10:14.91612', '2018-05-27 03:10:14.91612', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (18, '', 'ausfran12@gmail.com', '$2a$12$fERAjrn9IggFEjQowrscGe307ZPObxrhm0YgeN.2lVaEWJ74f2LDG', '$2a$12$fERAjrn9IggFEjQowrscGe', '2018-05-27 03:12:48.422966', '2018-05-27 03:12:48.422966', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (19, '', 'edarlingmendoza@gmail.com', '$2a$12$TfBFQERIadpqv5RA5Lw3EOih6f.6Rk7xhUQynQ374rI94P3TRCk42', '$2a$12$TfBFQERIadpqv5RA5Lw3EO', '2018-05-27 03:15:06.694285', '2018-05-27 03:15:06.694285', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (20, '', 'luisorozco3005@gmail.com', '$2a$12$lvxc/hTTwF.0FxQxfYh/LebD33CGoPPcAJ.JupougfHh53jm63YQ6', '$2a$12$lvxc/hTTwF.0FxQxfYh/Le', '2018-05-27 03:18:17.991151', '2018-05-27 03:18:17.991151', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (21, '', 'juliocepar@hotmail.com', '$2a$12$bNrJed0ckQiHg78ZPsJM5.OEyaM7/mvdIEKMzPuYRwXpJqj/And1y', '$2a$12$bNrJed0ckQiHg78ZPsJM5.', '2018-05-27 03:22:16.690062', '2018-05-27 03:22:16.690062', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (22, '', 'juliocepar@hotmail.com', '$2a$12$oUcwAIBBeLZzThVPDX7a8uS9.TreJm.UEJQLhhSC/jj7yzN5Vqisi', '$2a$12$oUcwAIBBeLZzThVPDX7a8u', '2018-05-27 03:22:18.001364', '2018-05-27 03:22:18.001364', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (23, '', 'josmaryteresapulgar@gmail.com', '$2a$12$JihMwxOdYljBA9XKCR1JVukR/AuZjUmG9H7HC6BW2tW2iRUsOgJ9O', '$2a$12$JihMwxOdYljBA9XKCR1JVu', '2018-05-27 03:25:28.729874', '2018-05-27 03:25:28.729874', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (24, '', 'yosbrg@gmail.com', '$2a$12$EFBRZiOLHYGMWcQMQUEQVOKnr9bZlsjK7HQaTeogqoX0sZxjeaW1u', '$2a$12$EFBRZiOLHYGMWcQMQUEQVO', '2018-05-27 03:27:37.264777', '2018-05-27 03:27:37.264777', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (25, '', 'mayedantonieta@gmail.com', '$2a$12$MH0DW8gB2LRVSdsQsbJ0duMjcdWOk/Jx.wig23/cFPABBKJbQ6DCG', '$2a$12$MH0DW8gB2LRVSdsQsbJ0du', '2018-05-27 03:30:05.831327', '2018-05-27 03:30:05.831327', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (26, '', 'francves1711@gmail.com', '$2a$12$rb1u5Z3BEttZwH16Y9jaQOxKgPhcgQu2VgjrKnh5dGkiDxncVyrTy', '$2a$12$rb1u5Z3BEttZwH16Y9jaQO', '2018-05-27 03:32:17.741405', '2018-05-27 03:32:17.741405', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (27, '', 'gessiyyg@gmail.com', '$2a$12$kRyfnGHeqhrAPwVELZ0q/.HOZIgNWfd7A1C9CvmwisaHQKPPRq/mu', '$2a$12$kRyfnGHeqhrAPwVELZ0q/.', '2018-05-27 03:34:57.503012', '2018-05-27 03:34:57.503012', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (28, '', 'sk.karem@gmail.com', '$2a$12$18qAKTAvanudeVhE0vrS.OfIiqyYC2LzaNhsn7kGaauf1cAtb7hs2', '$2a$12$18qAKTAvanudeVhE0vrS.O', '2018-05-27 03:37:12.098882', '2018-05-27 03:37:12.098882', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (29, '', 'anavdepalma@gmail.com', '$2a$12$zabhlxHhgYieTAAa5ZIpZ.JZSYeMNqNccAlzNceM6hezkRA71c5Le', '$2a$12$zabhlxHhgYieTAAa5ZIpZ.', '2018-05-27 03:39:24.341825', '2018-05-27 03:39:24.341825', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (30, '', 'abdelgainza@gmail.com', '$2a$12$AeijYFADCpgD5x.hfbeOo.JIf.5Rf0.q2zIevhUOvxKS78wmRQZQK', '$2a$12$AeijYFADCpgD5x.hfbeOo.', '2018-05-27 03:41:32.468809', '2018-05-27 03:41:32.468809', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (31, '', 'guerrero.c.jose.a@gmail.com', '$2a$12$JoHUMGP9DUN.wCF4/GUSMurGud9pWpDhW64cBLvi/cvldw/hOlus2', '$2a$12$JoHUMGP9DUN.wCF4/GUSMu', '2018-05-27 03:43:39.412549', '2018-05-27 03:43:39.412549', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (32, '', 'franchezka.14@hotmail.com', '$2a$12$JkfBNk1f6rVb2cyQK7GvK.gkoXEmsWnD3R2MPgD2P2H.FDXm0PWcy', '$2a$12$JkfBNk1f6rVb2cyQK7GvK.', '2018-05-27 03:45:43.919328', '2018-05-27 03:45:43.919328', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (33, '', 'hilmarycn@gmail.com', '$2a$12$Zla4XGqIDPEU4tydsotN/.LcRSdef8vn3bJGpZjj8BaRIQSVMrpNW', '$2a$12$Zla4XGqIDPEU4tydsotN/.', '2018-05-27 03:47:14.035393', '2018-05-27 03:47:14.035393', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (34, '', 'pedroaliorellana@gmail.com', '$2a$12$4uSvtQ2rj6.QhRbAd.LVd.oPcqeBrNFchTWxLbG95GhPMsLZFqzgu', '$2a$12$4uSvtQ2rj6.QhRbAd.LVd.', '2018-05-27 03:49:19.941986', '2018-05-27 03:49:19.941986', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (35, '', 'gabrielap2804@hotmail.com', '$2a$12$KfwLOEsMPpPMUJWnaiAnse0jxr2qPlISXH7.XBVVSO0DGXUSgLNVy', '$2a$12$KfwLOEsMPpPMUJWnaiAnse', '2018-05-27 03:51:05.234844', '2018-05-27 03:51:05.234844', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (36, '', 'indiraepf03@gmail.com', '$2a$12$lLrucYC6zP7ano/rMxC84OBwntqNfOe2bXoxyKyesV7Qi5rETmZBe', '$2a$12$lLrucYC6zP7ano/rMxC84O', '2018-05-27 03:52:58.349773', '2018-05-27 03:52:58.349773', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (37, '', 'leo1305pineda@gmail.com', '$2a$12$P9USjNHhVSdkVahoOTn4n.zNCrP2SEpFvbHTcV5nfEAzP3u5eLOJG', '$2a$12$P9USjNHhVSdkVahoOTn4n.', '2018-05-27 03:55:22.851922', '2018-05-27 03:55:22.851922', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (38, '', 'luispuerta7@gmail.com', '$2a$12$T1DdBiU7lVWj513.aKODq.OYNNm8CoDvGbKd13kEhTZp7ZiYdFw.O', '$2a$12$T1DdBiU7lVWj513.aKODq.', '2018-05-27 03:57:31.488912', '2018-05-27 03:57:31.488912', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (39, '', 'skarly.ruiz@gmail.com', '$2a$12$D9AxQ2LFFq1bxUkDjo7zzu5gKg4X9i4HkWqNAts2er2bo5RG2p6OS', '$2a$12$D9AxQ2LFFq1bxUkDjo7zzu', '2018-05-27 04:00:14.83273', '2018-05-27 04:00:14.83273', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (40, '', 'silvas89k@gmail.com', '$2a$12$PBcxmO/v6CALzT9Mx5eo/ecxJwCOUY7mpDZILMOqGRsowkqjPA1h6', '$2a$12$PBcxmO/v6CALzT9Mx5eo/e', '2018-05-27 04:02:43.473847', '2018-05-27 04:02:43.473847', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (41, '', 'amin295@gmail.com', '$2a$12$fG1G06oaEEILLGIP1DTkh.fc6QY0IoWefvWlXR6079oA7zGhIzsKi', '$2a$12$fG1G06oaEEILLGIP1DTkh.', '2018-05-27 04:05:45.175211', '2018-05-27 04:05:45.175211', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (42, '', 'juan_aldana55@hotmail.com', '$2a$12$9yfBwH5gI4jMJDs6oKh0Ku.GqAbHIFaR7M7UXrgYksrxBGwPMv1Ve', '$2a$12$9yfBwH5gI4jMJDs6oKh0Ku', '2018-05-27 04:07:49.747979', '2018-05-27 04:07:49.747979', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (43, '', 'sohecdyavila38@gmail.com', '$2a$12$sszMjNpuDJ696.7WgTKNX.Kv/.ODhDfMAUM/LF42VY9XVH8Y3FICa', '$2a$12$sszMjNpuDJ696.7WgTKNX.', '2018-05-27 04:09:33.294028', '2018-05-27 04:09:33.294028', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (44, '', 'nathalianzola@gmail.com', '$2a$12$Qo4fNbLkGyTnGhWrMFNRkuj7XRR5OCmhQ.nMk.Ht7/9Cb.flz9/gm', '$2a$12$Qo4fNbLkGyTnGhWrMFNRku', '2018-05-27 04:12:04.793958', '2018-05-27 04:12:04.793958', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (45, '', 'acskydc@gmail.com', '$2a$12$dBlFoABSWfXJ4FgFi7b1oubBv9x393lUc8ku.HM/w5jeiXHMysRhG', '$2a$12$dBlFoABSWfXJ4FgFi7b1ou', '2018-05-27 04:14:18.93636', '2018-05-27 04:14:18.93636', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (46, '', 'joseencinoza07@gmail.com', '$2a$12$busQQBPqanQLfP.4mu4wAeal7PAJaHelcqiS6fdl4bkmSkLinsG4q', '$2a$12$busQQBPqanQLfP.4mu4wAe', '2018-05-27 04:16:48.228753', '2018-05-27 04:16:48.228753', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (47, '', 'escalona.40@gmail.com', '$2a$12$QES1IpjjBZcuycJPIFbgiOxX073VGxdD6n95J3b0UDDLQYUc2m2.2', '$2a$12$QES1IpjjBZcuycJPIFbgiO', '2018-05-27 04:18:47.243397', '2018-05-27 04:18:47.243397', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (48, '', 'lauluque02@gmail.com', '$2a$12$S/qlu8wbTdXfNnehluxpLul61QkEFBmKxXPPZtIAoNDGx0RZKePbi', '$2a$12$S/qlu8wbTdXfNnehluxpLu', '2018-05-27 04:21:39.036227', '2018-05-27 04:21:39.036227', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (49, '', 'joselynserranof@gmail.com', '$2a$12$GhzLxazXGYc1cCXxuXhS1OMQ5Gbn160SCqoG9oKN2m2Pr9G7lvunm', '$2a$12$GhzLxazXGYc1cCXxuXhS1O', '2018-05-27 04:24:16.233937', '2018-05-27 04:24:16.233937', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (50, '', 'jose120293@gmail.com', '$2a$12$lAXTD8oQ52zr.493yOVqoeTsmeawPdboRY5gJYh7fZW24MTd5IFDi', '$2a$12$lAXTD8oQ52zr.493yOVqoe', '2018-05-27 04:26:17.325275', '2018-05-27 04:26:17.325275', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (51, '', 'vargasdeyamira.30@gmail.com', '$2a$12$hIs/yC2zwSb348/gLMBxbOQ2QEcp0QUkSJ9RijgCJoA5zCKLnulKm', '$2a$12$hIs/yC2zwSb348/gLMBxbO', '2018-05-27 04:28:56.856793', '2018-05-27 04:28:56.856793', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (52, '', 'yaniorzambrano@gmail.com', '$2a$12$g4PI8XshHXRxYvOMYr8M4ePep9I5I4eHlO9Y1aUuIKUwcEGjm3GV6', '$2a$12$g4PI8XshHXRxYvOMYr8M4e', '2018-05-27 04:31:09.732585', '2018-05-27 04:31:09.732585', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (53, '', 'david280893@gmail.com', '$2a$12$nxv6.EJ5oSCOQ/8Q4B9pSOmiU3Cp8zNnfTP3nQa0zf/Hi2O2iqKN6', '$2a$12$nxv6.EJ5oSCOQ/8Q4B9pSO', '2018-05-27 04:33:02.930308', '2018-05-27 04:33:02.930308', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (58, '', 'mariafranchezka@hotmail.com', '$2a$12$I2AHQax5drR6/9O5526FvOSZJh8k6GAcJS3cXEWOJZ2iUSHIScAnS', '$2a$12$I2AHQax5drR6/9O5526FvO', '2018-05-27 16:13:53.57097', '2018-05-27 16:13:53.57097', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (54, '', 'gabrielaperez@gmail.com', '$2a$12$9IvtmmpgSTs5N6S3o60r9umSfyQTxUA22ci64oRSDwzzDCkZwio3q', '$2a$12$9IvtmmpgSTs5N6S3o60r9u', '2018-05-27 07:12:35.708', '2018-05-27 07:12:35.708', NULL, 1, 10, 2);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (59, '', 'rodrigofuentes@gmail.com', '$2a$12$M5vcXjmHTy/7XSDQmD8lROayAN2qcHeydhfOi22ChIj8Q.KD.8y.a', '$2a$12$M5vcXjmHTy/7XSDQmD8lRO', '2018-05-27 17:49:49.979', '2018-05-27 17:49:49.979', NULL, 1, 10, 2);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (60, '', 'saschanutric@gmail.com', '$2a$12$UTl1Hz4g0k7l6Sso8LQiteW1Zqr1oZU8C7a6U.E2qZHFTjVxkQJZG', '$2a$12$UTl1Hz4g0k7l6Sso8LQite', '2018-05-31 11:36:45.14389', '2018-05-31 11:36:45.14389', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (61, '', 'belinvir@gmail.com', '$2a$12$nSb..Wmvro.2jVyVRbp5pOHYMx.gCAl1INxgdPQajA7F//uknd6aa', '$2a$12$nSb..Wmvro.2jVyVRbp5pO', '2018-06-01 07:29:58.050532', '2018-06-01 07:29:58.050532', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (62, '', 'mcrespog@gmail.com', '$2a$12$B47eXUpMnDRX6dXyJFoPYO00KX709gSIvPiHlQxUN22LfrF.ZvaR.', '$2a$12$B47eXUpMnDRX6dXyJFoPYO', '2018-06-01 13:17:20.926878', '2018-06-01 13:17:20.926878', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (63, '', 'mcrespog@gmail.com', '$2a$12$6dmP.Mz6lVF1nC8AvR1Z5.yR5l2sdYrbXHM71RKbXt/4c1/bq7GCS', '$2a$12$6dmP.Mz6lVF1nC8AvR1Z5.', '2018-06-01 13:17:22.392646', '2018-06-01 13:17:22.392646', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (64, '', 'yerikayeyegil@gmail.com', '$2a$12$T9GDr3DtWqnZMWU11DRJKOBxnMJt24WWZ1lm9AnaF86npyEgUbYu6', '$2a$12$T9GDr3DtWqnZMWU11DRJKO', '2018-06-05 08:34:06.222761', '2018-06-05 08:34:06.222761', NULL, 1, NULL, 1);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (55, '', 'ana_veck@hotmail.com', '$2a$12$kzIyZtGwIjypV9y3SoXisOThBqj7NVURcDPnMcaMcqu9KPLMnOhY.', '$2a$12$kzIyZtGwIjypV9y3SoXisO', '2018-05-27 07:15:47.536', '2018-05-27 07:15:47.536', NULL, 1, 15, 2);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (57, '', 'brisleidy@gmail.com', '$2a$12$7iKASKZbNJdLKm3mnYy/d.rh9HvwHBubxY/OeECdVdSfA2mSMALva', '$2a$12$7iKASKZbNJdLKm3mnYy/d.', '2018-05-27 07:17:26.695', '2018-05-27 07:17:26.695', NULL, 1, 10, 2);
INSERT INTO public.usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol, tipo_usuario) VALUES (56, '', 'skarlyruiz@gmail.com', '$2a$12$PTw1TQKndEEz/FkY8lMp6.JKeV/4vP86caNW.7tE4KV5Ex8cFONZa', '$2a$12$PTw1TQKndEEz/FkY8lMp6.', '2018-05-27 07:16:27.57', '2018-05-27 07:16:27.57', NULL, 1, 10, 2);


--
-- Data for Name: valoracion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (10, 3, 'Mucho', '2018-05-31 05:53:20.84', '2018-05-31 05:53:20.84', 0, 0);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (9, 3, 'Mucho', '2018-05-31 05:53:18.42', '2018-05-31 05:53:18.42', 0, 0);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (12, 3, 'Mucho', '2018-05-31 06:07:40.33', '2018-05-31 06:07:40.33', 0, 0);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (1, 1, '1', '2018-05-27 03:53:05.515', '2018-05-27 03:53:05.515', 0, 0);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (2, 1, '2', '2018-05-27 03:53:29.392', '2018-05-27 03:53:29.392', 0, 0);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (14, 1, '1', '2018-05-31 06:15:26.964', '2018-05-31 06:15:26.964', 1, 1);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (15, 1, '2', '2018-05-31 06:15:55.643', '2018-05-31 06:15:55.643', 1, 2);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (3, 1, '3', '2018-05-27 03:53:34.497', '2018-05-27 03:53:34.497', 1, 3);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (4, 1, '4', '2018-05-27 03:58:17.438', '2018-05-27 03:58:17.438', 1, 4);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (5, 1, '5', '2018-05-27 04:01:47.067', '2018-05-27 04:01:47.067', 1, 5);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (13, 3, 'Mucho', '2018-05-31 06:14:41.117', '2018-05-31 06:14:41.117', 1, 2);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (11, 3, 'Poco', '2018-05-31 06:03:15.875', '2018-05-31 06:03:15.875', 1, 1);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (6, 2, 'Bueno', '2018-05-27 04:03:25.849', '2018-05-27 04:03:25.849', 1, 4);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (7, 2, 'Malo', '2018-05-27 04:03:52.13', '2018-05-27 04:03:52.13', 1, 2);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (8, 2, 'Regular', '2018-05-27 04:04:10.633', '2018-05-27 04:04:10.633', 1, 3);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (16, 2, 'Muy malo', '2018-06-03 07:08:35.032995', '2018-06-03 07:08:35.032995', 1, 1);
INSERT INTO public.valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) VALUES (17, 2, 'Muy bueno', '2018-06-03 07:08:56.934649', '2018-06-03 07:08:56.934649', 1, 5);


--
-- Data for Name: visita; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (1, 1, '2018-05-27', '2018-05-27 15:54:00.402273', '2018-05-27 15:54:00.402273', 1, 1);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (2, 2, '2018-05-27', '2018-05-27 16:06:15.877264', '2018-05-27 16:06:15.877264', 1, 4);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (3, 3, '2018-05-27', '2018-05-27 16:41:22.569148', '2018-05-27 16:41:22.569148', 1, 5);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (4, 1, '2018-05-27', '2018-05-27 21:18:18.304696', '2018-05-27 21:18:18.304696', 1, 6);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (5, 2, '2018-05-28', '2018-05-29 01:27:41.125972', '2018-05-29 01:27:41.125972', 1, 7);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (6, 3, '2018-05-28', '2018-05-29 03:13:24.732787', '2018-05-29 03:13:24.732787', 1, 14);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (7, 1, '2018-05-29', '2018-05-29 21:09:11.816595', '2018-05-29 21:09:11.816595', 1, 15);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (8, 2, '2018-05-29', '2018-05-29 21:10:00.091415', '2018-05-29 21:10:00.091415', 1, 16);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (9, 1, '2018-05-31', '2018-05-31 04:40:48.888343', '2018-05-31 04:40:48.888343', 1, 29);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (10, 3, '2018-05-31', '2018-05-31 06:58:00.21057', '2018-05-31 06:58:00.21057', 1, 17);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (11, 1, '2018-05-31', '2018-05-31 08:42:52.191331', '2018-05-31 08:42:52.191331', 1, 20);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (12, 1, '2018-05-31', '2018-05-31 11:45:38.064135', '2018-05-31 11:45:38.064135', 1, 37);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (13, 1, '2018-05-31', '2018-06-01 02:32:10.900417', '2018-06-01 02:32:10.900417', 1, 32);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (14, 1, '2018-05-31', '2018-06-01 02:38:12.281135', '2018-06-01 02:38:12.281135', 1, 33);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (15, 1, '2018-05-31', '2018-06-01 02:57:45.06359', '2018-06-01 02:57:45.06359', 1, 30);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (16, 1, '2018-06-01', '2018-06-01 08:18:09.861917', '2018-06-01 08:18:09.861917', 1, 43);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (25, 1, '2018-06-01', '2018-06-01 13:43:01.42109', '2018-06-01 13:43:01.42109', 1, 45);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (26, 2, '2018-06-01', '2018-06-01 13:44:51.130777', '2018-06-01 13:44:51.130777', 1, 54);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (27, 3, '2018-06-01', '2018-06-01 14:09:58.600766', '2018-06-01 14:09:58.600766', 1, 56);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (28, 1, '2018-06-01', '2018-06-01 17:25:51.388264', '2018-06-01 17:25:51.388264', 1, 8);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (29, 2, '2018-06-01', '2018-06-01 21:18:26.366935', '2018-06-01 21:18:26.366935', 1, 40);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (30, 1, '2018-06-01', '2018-06-01 22:12:09.230575', '2018-06-01 22:12:09.230575', 1, 21);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (31, 2, '2018-06-01', '2018-06-01 22:32:26.733161', '2018-06-01 22:32:26.733161', 1, 34);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (32, 2, '2018-06-01', '2018-06-01 23:00:04.12162', '2018-06-01 23:00:04.12162', 1, 39);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (33, 1, '2018-06-04', '2018-06-04 07:17:29.70813', '2018-06-04 07:17:29.70813', 1, 19);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (34, 1, '2018-06-04', '2018-06-04 07:23:09.700089', '2018-06-04 07:23:09.700089', 1, 10);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (35, 1, '2018-06-04', '2018-06-04 07:26:20.363607', '2018-06-04 07:26:20.363607', 1, 9);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (36, 1, '2018-06-04', '2018-06-04 07:31:37.918408', '2018-06-04 07:31:37.918408', 1, 12);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (37, 1, '2018-06-04', '2018-06-04 07:35:44.514516', '2018-06-04 07:35:44.514516', 1, 13);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (38, 1, '2018-06-04', '2018-06-04 07:38:55.987712', '2018-06-04 07:38:55.987712', 1, 22);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (39, 1, '2018-06-04', '2018-06-04 07:42:12.230937', '2018-06-04 07:42:12.230937', 1, 23);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (40, 2, '2018-06-04', '2018-06-04 07:42:58.11428', '2018-06-04 07:42:58.11428', 1, 69);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (41, 2, '2018-06-04', '2018-06-04 07:46:15.02718', '2018-06-04 07:46:15.02718', 1, 72);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (42, 2, '2018-06-04', '2018-06-04 07:47:11.760352', '2018-06-04 07:47:11.760352', 1, 44);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (43, 2, '2018-06-04', '2018-06-04 07:48:50.183365', '2018-06-04 07:48:50.183365', 1, 71);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (44, 3, '2018-06-04', '2018-06-04 07:49:58.812983', '2018-06-04 07:49:58.812983', 1, 73);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (45, 3, '2018-06-04', '2018-06-04 07:52:45.686361', '2018-06-04 07:52:45.686361', 1, 74);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (46, 2, '2018-06-04', '2018-06-04 07:53:51.349889', '2018-06-04 07:53:51.349889', 1, 70);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (47, 3, '2018-06-04', '2018-06-04 07:54:41.620264', '2018-06-04 07:54:41.620264', 1, 76);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (48, 3, '2018-06-04', '2018-06-04 07:55:05.44906', '2018-06-04 07:55:05.44906', 1, 75);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (49, 2, '2018-06-04', '2018-06-04 07:55:32.083355', '2018-06-04 07:55:32.083355', 1, 58);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (50, 3, '2018-06-04', '2018-06-04 07:55:58.654664', '2018-06-04 07:55:58.654664', 1, 77);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (51, 3, '2018-06-04', '2018-06-04 09:14:13.155349', '2018-06-04 09:14:13.155349', 1, 59);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (53, 1, '2018-06-04', '2018-06-04 15:00:55.777636', '2018-06-04 15:00:55.777636', 1, 25);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (54, 2, '2018-06-04', '2018-06-05 02:39:57.339502', '2018-06-05 02:39:57.339502', 1, 68);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (55, 2, '2018-06-04', '2018-06-05 02:46:34.523148', '2018-06-05 02:46:34.523148', 1, 81);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (56, 3, '2018-06-04', '2018-06-05 03:05:48.072236', '2018-06-05 03:05:48.072236', 1, 84);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (57, 1, '2018-06-05', '2018-06-05 05:53:15.666802', '2018-06-05 05:53:15.666802', 1, 85);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (58, 2, '2018-06-05', '2018-06-05 06:18:04.294212', '2018-06-05 06:18:04.294212', 1, 88);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (59, 1, '2018-06-05', '2018-06-05 07:27:49.188594', '2018-06-05 07:27:49.188594', 1, 87);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (60, 2, '2018-06-05', '2018-06-05 07:45:41.993144', '2018-06-05 07:45:41.993144', 1, 90);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (61, 3, '2018-06-05', '2018-06-05 07:48:29.306904', '2018-06-05 07:48:29.306904', 1, 91);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (62, 3, '2018-06-05', '2018-06-05 08:07:17.302606', '2018-06-05 08:07:17.302606', 1, 86);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (63, 4, '2018-06-05', '2018-06-05 08:22:59.86731', '2018-06-05 08:22:59.86731', 1, 89);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (64, 1, '2018-06-05', '2018-06-05 09:23:45.158438', '2018-06-05 09:23:45.158438', 1, 92);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (65, 2, '2018-06-05', '2018-06-05 09:25:30.748609', '2018-06-05 09:25:30.748609', 1, 93);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (66, 3, '2018-06-05', '2018-06-05 09:26:57.984453', '2018-06-05 09:26:57.984453', 1, 94);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (67, 1, '2018-06-05', '2018-06-05 09:55:47.406694', '2018-06-05 09:55:47.406694', 1, 95);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (68, 2, '2018-06-05', '2018-06-05 10:53:05.928519', '2018-06-05 10:53:05.928519', 1, 96);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (69, 3, '2018-06-05', '2018-06-05 10:53:31.647266', '2018-06-05 10:53:31.647266', 1, 97);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (70, 1, '2018-06-05', '2018-06-05 11:08:57.378047', '2018-06-05 11:08:57.378047', 1, 78);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (71, 1, '2018-06-05', '2018-06-06 00:32:18.563916', '2018-06-06 00:32:18.563916', 1, 105);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (72, 2, '2018-06-05', '2018-06-06 00:38:20.737252', '2018-06-06 00:38:20.737252', 1, 106);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (73, 1, '2018-06-05', '2018-06-06 02:57:39.653117', '2018-06-06 02:57:39.653117', 1, 109);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (74, 1, '2018-06-06', '2018-06-06 04:15:17.561291', '2018-06-06 04:15:17.561291', 1, 115);
INSERT INTO public.visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) VALUES (76, 1, '2018-06-06', '2018-06-06 04:55:27.56368', '2018-06-06 04:55:27.56368', 1, 118);


--
-- Name: id_agenda_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_agenda_seq', 122, true);


--
-- Name: id_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_alimento_seq', 82, true);


--
-- Name: id_app_movil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_app_movil_seq', 1, false);


--
-- Name: id_ayuda_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_ayuda_seq', 9, true);


--
-- Name: id_bloque_horario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_bloque_horario_seq', 9, true);


--
-- Name: id_calificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_calificacion_seq', 81, true);


--
-- Name: id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_cita_seq', 122, true);


--
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_cliente_seq', 59, true);


--
-- Name: id_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_comentario_seq', 48, true);


--
-- Name: id_comida_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_comida_seq', 4, true);


--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_condicion_garantia_seq', 4, true);


--
-- Name: id_contenido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_contenido_seq', 9, true);


--
-- Name: id_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_criterio_seq', 16, true);


--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_plan_dieta_seq', 84, true);


--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_plan_ejercicio_seq', 13, true);


--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_plan_suplemento_seq', 24, true);


--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_regimen_alimento_seq', 502, true);


--
-- Name: id_detalle_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_visita_seq', 233, true);


--
-- Name: id_dia_laborable_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_dia_laborable_seq', 7, true);


--
-- Name: id_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_ejercicio_seq', 10, true);


--
-- Name: id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_empleado_seq', 5, true);


--
-- Name: id_especialidad_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_especialidad_empleado_seq', 1, false);


--
-- Name: id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_especialidad_seq', 9, true);


--
-- Name: id_especialidad_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_especialidad_servicio_seq', 1, false);


--
-- Name: id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_estado_civil_seq', 5, true);


--
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_estado_seq', 1, false);


--
-- Name: id_frecuencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_frecuencia_seq', 3, true);


--
-- Name: id_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_funcionalidad_seq', 60, true);


--
-- Name: id_garantia_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_garantia_servicio_seq', 25, true);


--
-- Name: id_genero_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_genero_seq', 2, true);


--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_grupo_alimenticio_seq', 9, true);


--
-- Name: id_horario_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_horario_empleado_seq', 147, true);


--
-- Name: id_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_incidencia_seq', 15, true);


--
-- Name: id_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_motivo_seq', 36, true);


--
-- Name: id_negocio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_negocio_seq', 7, true);


--
-- Name: id_notificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_notificacion_seq', 417, true);


--
-- Name: id_orden_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_orden_servicio_seq', 64, true);


--
-- Name: id_parametro_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_cliente_seq', 238, true);


--
-- Name: id_parametro_meta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_meta_seq', 40, true);


--
-- Name: id_parametro_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_promocion_seq', 6, true);


--
-- Name: id_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_seq', 86, true);


--
-- Name: id_parametro_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_servicio_seq', 16, true);


--
-- Name: id_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_plan_dieta_seq', 16, true);


--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_plan_ejercicio_seq', 5, true);


--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_plan_suplemento_seq', 8, true);


--
-- Name: id_precio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_precio_seq', 1, false);


--
-- Name: id_preferencia_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_preferencia_cliente_seq', 1, false);


--
-- Name: id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_promocion_seq', 13, true);


--
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_rango_edad_seq', 5, true);


--
-- Name: id_reclamo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_reclamo_seq', 33, true);


--
-- Name: id_red_social_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_red_social_seq', 9, true);


--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_regimen_dieta_seq', 178, true);


--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_regimen_ejercicio_seq', 87, true);


--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_regimen_suplemento_seq', 90, true);


--
-- Name: id_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_respuesta_seq', 15, true);


--
-- Name: id_rol_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_rol_funcionalidad_seq', 932, true);


--
-- Name: id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_rol_seq', 16, true);


--
-- Name: id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_servicio_seq', 13, true);


--
-- Name: id_slide_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_slide_seq', 6, true);


--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_solicitud_servicio_seq', 97, true);


--
-- Name: id_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_suplemento_seq', 15, true);


--
-- Name: id_tiempo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tiempo_seq', 4, true);


--
-- Name: id_tipo_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_cita_seq', 3, true);


--
-- Name: id_tipo_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_criterio_seq', 2, true);


--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_dieta_seq', 7, true);


--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_incidencia_seq', 2, true);


--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_motivo_seq', 8, true);


--
-- Name: id_tipo_orden_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_orden_seq', 1, false);


--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_parametro_seq', 7, true);


--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_respuesta_seq', 1, false);


--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_unidad_seq', 7, true);


--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_valoracion_seq', 3, true);


--
-- Name: id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_unidad_seq', 31, true);


--
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_usuario_seq', 64, true);


--
-- Name: id_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_valoracion_seq', 17, true);


--
-- Name: id_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_visita_seq', 76, true);


--
-- Name: agenda agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (id_agenda);


--
-- Name: alimento alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alimento
    ADD CONSTRAINT alimento_pkey PRIMARY KEY (id_alimento);


--
-- Name: app_movil app_movil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_movil
    ADD CONSTRAINT app_movil_pkey PRIMARY KEY (id_app_movil);


--
-- Name: ayuda ayuda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ayuda
    ADD CONSTRAINT ayuda_pkey PRIMARY KEY (id_ayuda);


--
-- Name: bloque_horario bloque_horario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloque_horario
    ADD CONSTRAINT bloque_horario_pkey PRIMARY KEY (id_bloque_horario);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: comentario comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_pkey PRIMARY KEY (id_comentario);


--
-- Name: comida comida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comida
    ADD CONSTRAINT comida_pkey PRIMARY KEY (id_comida);


--
-- Name: condicion_garantia condicion_garantia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.condicion_garantia
    ADD CONSTRAINT condicion_garantia_pkey PRIMARY KEY (id_condicion_garantia);


--
-- Name: contenido contenido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenido
    ADD CONSTRAINT contenido_pkey PRIMARY KEY (id_contenido);


--
-- Name: criterio criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criterio
    ADD CONSTRAINT criterio_pkey PRIMARY KEY (id_criterio);


--
-- Name: detalle_plan_dieta detalle_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_pkey PRIMARY KEY (id_detalle_plan_dieta);


--
-- Name: detalle_plan_ejercicio detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- Name: detalle_plan_suplemento detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- Name: detalle_regimen_alimento detalle_regimen_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_pkey PRIMARY KEY (id_regimen_dieta, id_alimento);


--
-- Name: detalle_visita detalle_visita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_visita
    ADD CONSTRAINT detalle_visita_pkey PRIMARY KEY (id_visita, id_parametro);


--
-- Name: dia_laborable dia_laborable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dia_laborable
    ADD CONSTRAINT dia_laborable_pkey PRIMARY KEY (id_dia_laborable);


--
-- Name: ejercicio ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ejercicio
    ADD CONSTRAINT ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: empleado empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: estado_civil estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: estado_solicitud estado_solicitud_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_solicitud
    ADD CONSTRAINT estado_solicitud_pkey PRIMARY KEY (id_estado_solicitud);


--
-- Name: frecuencia frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frecuencia
    ADD CONSTRAINT frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- Name: funcionalidad funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionalidad
    ADD CONSTRAINT funcionalidad_pkey PRIMARY KEY (id_funcionalidad);


--
-- Name: garantia_servicio garantia_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.garantia_servicio
    ADD CONSTRAINT garantia_servicio_pkey PRIMARY KEY (id_condicion_garantia, id_servicio);


--
-- Name: genero genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- Name: grupo_alimenticio grupo_alimenticio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_pkey PRIMARY KEY (id_grupo_alimenticio);


--
-- Name: horario_empleado horario_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horario_empleado
    ADD CONSTRAINT horario_empleado_pkey PRIMARY KEY (id_empleado, id_bloque_horario, id_dia_laborable);


--
-- Name: servicio id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: incidencia incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_pkey PRIMARY KEY (id_incidencia);


--
-- Name: motivo motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motivo
    ADD CONSTRAINT motivo_pkey PRIMARY KEY (id_motivo);


--
-- Name: negocio negocio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.negocio
    ADD CONSTRAINT negocio_pkey PRIMARY KEY (id_negocio);


--
-- Name: orden_servicio orden_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orden_servicio
    ADD CONSTRAINT orden_servicio_pkey PRIMARY KEY (id_orden_servicio);


--
-- Name: parametro_cliente parametro_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_cliente
    ADD CONSTRAINT parametro_cliente_pkey PRIMARY KEY (id_cliente, id_parametro);


--
-- Name: parametro_meta parametro_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_meta
    ADD CONSTRAINT parametro_meta_pkey PRIMARY KEY (id_orden_servicio, id_parametro);


--
-- Name: parametro parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro
    ADD CONSTRAINT parametro_pkey PRIMARY KEY (id_parametro);


--
-- Name: parametro_promocion parametro_promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_promocion
    ADD CONSTRAINT parametro_promocion_pkey PRIMARY KEY (id_parametro, id_promocion);


--
-- Name: parametro_servicio parametro_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_servicio
    ADD CONSTRAINT parametro_servicio_pkey PRIMARY KEY (id_servicio, id_parametro);


--
-- Name: plan_dieta plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_dieta
    ADD CONSTRAINT plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- Name: plan_ejercicio plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- Name: plan_suplemento plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- Name: preferencia_cliente preferencia_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_pkey PRIMARY KEY (id_cliente, id_especialidad);


--
-- Name: promocion promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);


--
-- Name: rango_edad rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- Name: reclamo reclamo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reclamo
    ADD CONSTRAINT reclamo_pkey PRIMARY KEY (id_reclamo);


--
-- Name: red_social red_social_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.red_social
    ADD CONSTRAINT red_social_pkey PRIMARY KEY (id_red_social);


--
-- Name: regimen_dieta regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_dieta
    ADD CONSTRAINT regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- Name: regimen_ejercicio regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- Name: regimen_suplemento regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- Name: respuesta respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (id_respuesta);


--
-- Name: rol_funcionalidad rol_funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_pkey PRIMARY KEY (id_rol, id_funcionalidad);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);


--
-- Name: slide slide_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slide
    ADD CONSTRAINT slide_pkey PRIMARY KEY (id_slide);


--
-- Name: solicitud_servicio solicitud_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_pkey PRIMARY KEY (id_solicitud_servicio);


--
-- Name: suplemento suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suplemento
    ADD CONSTRAINT suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- Name: tiempo tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tiempo
    ADD CONSTRAINT tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- Name: tipo_cita tipo_cita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_cita
    ADD CONSTRAINT tipo_cita_pkey PRIMARY KEY (id_tipo_cita);


--
-- Name: tipo_criterio tipo_criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_criterio
    ADD CONSTRAINT tipo_criterio_pkey PRIMARY KEY (id_tipo_criterio);


--
-- Name: tipo_dieta tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_dieta
    ADD CONSTRAINT tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- Name: tipo_incidencia tipo_incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_incidencia
    ADD CONSTRAINT tipo_incidencia_pkey PRIMARY KEY (id_tipo_incidencia);


--
-- Name: tipo_motivo tipo_motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_motivo
    ADD CONSTRAINT tipo_motivo_pkey PRIMARY KEY (id_tipo_motivo);


--
-- Name: tipo_orden tipo_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_orden
    ADD CONSTRAINT tipo_orden_pkey PRIMARY KEY (id_tipo_orden);


--
-- Name: tipo_parametro tipo_parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_parametro
    ADD CONSTRAINT tipo_parametro_pkey PRIMARY KEY (id_tipo_parametro);


--
-- Name: tipo_respuesta tipo_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_respuesta
    ADD CONSTRAINT tipo_respuesta_pkey PRIMARY KEY (id_tipo_respuesta);


--
-- Name: tipo_unidad tipo_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_unidad
    ADD CONSTRAINT tipo_unidad_pkey PRIMARY KEY (id_tipo_unidad);


--
-- Name: tipo_valoracion tipo_valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_valoracion
    ADD CONSTRAINT tipo_valoracion_pkey PRIMARY KEY (id_tipo_valoracion);


--
-- Name: unidad unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (id_unidad);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: valoracion valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valoracion
    ADD CONSTRAINT valoracion_pkey PRIMARY KEY (id_valoracion);


--
-- Name: visita visita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visita
    ADD CONSTRAINT visita_pkey PRIMARY KEY (id_visita);


--
-- Name: fki_incidencia_id_agenda_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_incidencia_id_agenda_fkey ON public.incidencia USING btree (id_agenda);


--
-- Name: cliente dis_asignar_rango_edad; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_asignar_rango_edad AFTER INSERT ON public.cliente FOR EACH ROW EXECUTE PROCEDURE public.fun_asignar_rango_edad();


--
-- Name: agenda dis_notificar_agenda; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_notificar_agenda AFTER INSERT ON public.agenda FOR EACH ROW EXECUTE PROCEDURE public.fun_notificar_agenda();


--
-- Name: comentario dis_notificar_comentario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_notificar_comentario AFTER INSERT ON public.comentario FOR EACH ROW EXECUTE PROCEDURE public.fun_notificar_comentario();


--
-- Name: incidencia dis_notificar_incidencia; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_notificar_incidencia AFTER INSERT ON public.incidencia FOR EACH ROW EXECUTE PROCEDURE public.fun_notificar_incidencia();


--
-- Name: reclamo dis_notificar_reclamo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_notificar_reclamo AFTER INSERT ON public.reclamo FOR EACH ROW EXECUTE PROCEDURE public.fun_notificar_reclamo();


--
-- Name: comentario dis_notificar_respuesta_comentario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_notificar_respuesta_comentario AFTER UPDATE ON public.comentario FOR EACH ROW EXECUTE PROCEDURE public.fun_notificar_respuesta_comentario();


--
-- Name: reclamo dis_notificar_respuesta_reclamo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_notificar_respuesta_reclamo AFTER UPDATE ON public.reclamo FOR EACH ROW EXECUTE PROCEDURE public.fun_notificar_respuesta_reclamo();


--
-- Name: usuario dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON public.usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE public.fun_eliminar_cliente();


--
-- Name: agenda agenda_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita);


--
-- Name: agenda agenda_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: agenda agenda_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleado(id_empleado);


--
-- Name: agenda agenda_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES public.orden_servicio(id_orden_servicio);


--
-- Name: alimento alimento_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alimento
    ADD CONSTRAINT alimento_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES public.grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: calificacion calificacion_id_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_criterio_fkey FOREIGN KEY (id_criterio) REFERENCES public.criterio(id_criterio);


--
-- Name: calificacion calificacion_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES public.orden_servicio(id_orden_servicio);


--
-- Name: calificacion calificacion_id_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_valoracion_fkey FOREIGN KEY (id_valoracion) REFERENCES public.valoracion(id_valoracion);


--
-- Name: calificacion calificacion_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES public.visita(id_visita);


--
-- Name: cita cita_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES public.bloque_horario(id_bloque_horario);


--
-- Name: cita cita_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES public.orden_servicio(id_orden_servicio);


--
-- Name: cita cita_id_tipo_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_tipo_cita_fkey FOREIGN KEY (id_tipo_cita) REFERENCES public.tipo_cita(id_tipo_cita);


--
-- Name: cliente cliente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES public.estado_civil(id_estado_civil);


--
-- Name: cliente cliente_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.genero(id_genero);


--
-- Name: cliente cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES public.rango_edad(id_rango_edad);


--
-- Name: cliente cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: comentario comentario_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: comentario comentario_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES public.motivo(id_motivo);


--
-- Name: comentario comentario_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.respuesta(id_respuesta);


--
-- Name: criterio criterio_id_tipo_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criterio
    ADD CONSTRAINT criterio_id_tipo_criterio_fkey FOREIGN KEY (id_tipo_criterio) REFERENCES public.tipo_criterio(id_tipo_criterio);


--
-- Name: detalle_plan_dieta detalle_plan_dieta_id_comida_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_comida_fkey FOREIGN KEY (id_comida) REFERENCES public.comida(id_comida);


--
-- Name: detalle_plan_dieta detalle_plan_dieta_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES public.grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: detalle_plan_dieta detalle_plan_dieta_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES public.plan_dieta(id_plan_dieta);


--
-- Name: detalle_plan_ejercicio detalle_plan_ejercicio_id_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES public.ejercicio(id_ejercicio);


--
-- Name: detalle_plan_ejercicio detalle_plan_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES public.plan_ejercicio(id_plan_ejercicio);


--
-- Name: detalle_plan_suplemento detalle_plan_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES public.plan_suplemento(id_plan_suplemento);


--
-- Name: detalle_plan_suplemento detalle_plan_suplemento_id_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES public.suplemento(id_suplemento);


--
-- Name: detalle_regimen_alimento detalle_regimen_alimento_id_alimento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_alimento_fkey FOREIGN KEY (id_alimento) REFERENCES public.alimento(id_alimento);


--
-- Name: detalle_regimen_alimento detalle_regimen_alimento_id_regimen_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_regimen_dieta_fkey FOREIGN KEY (id_regimen_dieta) REFERENCES public.regimen_dieta(id_regimen_dieta);


--
-- Name: detalle_visita detalle_visita_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_visita
    ADD CONSTRAINT detalle_visita_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES public.parametro(id_parametro);


--
-- Name: detalle_visita detalle_visita_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_visita
    ADD CONSTRAINT detalle_visita_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES public.visita(id_visita);


--
-- Name: empleado empleado_id_especialidad_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_id_especialidad_fk FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad);


--
-- Name: empleado empleado_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.genero(id_genero);


--
-- Name: empleado empleado_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: frecuencia frecuencia_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frecuencia
    ADD CONSTRAINT frecuencia_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES public.tiempo(id_tiempo);


--
-- Name: funcionalidad funcionalidad_id_funcionalidad_padre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionalidad
    ADD CONSTRAINT funcionalidad_id_funcionalidad_padre_fkey FOREIGN KEY (id_funcionalidad_padre) REFERENCES public.funcionalidad(id_funcionalidad);


--
-- Name: garantia_servicio garantia_servicio_id_condicion_garantia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_condicion_garantia_fkey FOREIGN KEY (id_condicion_garantia) REFERENCES public.condicion_garantia(id_condicion_garantia);


--
-- Name: garantia_servicio garantia_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio(id_servicio);


--
-- Name: grupo_alimenticio grupo_alimenticio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad(id_unidad);


--
-- Name: horario_empleado horario_empleado_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horario_empleado
    ADD CONSTRAINT horario_empleado_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES public.bloque_horario(id_bloque_horario);


--
-- Name: horario_empleado horario_empleado_id_dia_laborable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horario_empleado
    ADD CONSTRAINT horario_empleado_id_dia_laborable_fkey FOREIGN KEY (id_dia_laborable) REFERENCES public.dia_laborable(id_dia_laborable);


--
-- Name: horario_empleado horario_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horario_empleado
    ADD CONSTRAINT horario_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleado(id_empleado);


--
-- Name: incidencia incidencia_id_agenda_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_id_agenda_fkey FOREIGN KEY (id_agenda) REFERENCES public.agenda(id_agenda);


--
-- Name: incidencia incidencia_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES public.motivo(id_motivo);


--
-- Name: incidencia incidencia_id_tipo_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_id_tipo_incidencia_fkey FOREIGN KEY (id_tipo_incidencia) REFERENCES public.tipo_incidencia(id_tipo_incidencia);


--
-- Name: motivo motivo_id_tipo_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motivo
    ADD CONSTRAINT motivo_id_tipo_motivo_fkey FOREIGN KEY (id_tipo_motivo) REFERENCES public.tipo_motivo(id_tipo_motivo);


--
-- Name: orden_servicio orden_servicio_id_reclamo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orden_servicio
    ADD CONSTRAINT orden_servicio_id_reclamo_fkey FOREIGN KEY (id_reclamo) REFERENCES public.reclamo(id_reclamo);


--
-- Name: orden_servicio orden_servicio_id_solicitud_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orden_servicio
    ADD CONSTRAINT orden_servicio_id_solicitud_servicio_fkey FOREIGN KEY (id_solicitud_servicio) REFERENCES public.solicitud_servicio(id_solicitud_servicio);


--
-- Name: orden_servicio orden_servicio_id_tipo_orden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orden_servicio
    ADD CONSTRAINT orden_servicio_id_tipo_orden_fkey FOREIGN KEY (id_tipo_orden) REFERENCES public.tipo_orden(id_tipo_orden);


--
-- Name: parametro_cliente parametro_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: parametro_cliente parametro_cliente_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES public.parametro(id_parametro);


--
-- Name: parametro_meta parametro_meta_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_meta
    ADD CONSTRAINT parametro_meta_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES public.orden_servicio(id_orden_servicio);


--
-- Name: parametro_meta parametro_meta_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_meta
    ADD CONSTRAINT parametro_meta_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES public.parametro(id_parametro);


--
-- Name: parametro_servicio parametro_servicio_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES public.parametro(id_parametro);


--
-- Name: parametro_servicio parametro_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio(id_servicio);


--
-- Name: parametro parametro_tipo_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro
    ADD CONSTRAINT parametro_tipo_parametro_fkey FOREIGN KEY (id_tipo_parametro) REFERENCES public.tipo_parametro(id_tipo_parametro);


--
-- Name: parametro parametro_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parametro
    ADD CONSTRAINT parametro_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad(id_unidad);


--
-- Name: plan_dieta plan_dieta_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_dieta
    ADD CONSTRAINT plan_dieta_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES public.tipo_dieta(id_tipo_dieta);


--
-- Name: preferencia_cliente preferencia_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: preferencia_cliente preferencia_cliente_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad);


--
-- Name: promocion promocion_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio(id_servicio);


--
-- Name: reclamo reclamo_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reclamo
    ADD CONSTRAINT reclamo_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES public.motivo(id_motivo);


--
-- Name: reclamo reclamo_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reclamo
    ADD CONSTRAINT reclamo_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES public.orden_servicio(id_orden_servicio);


--
-- Name: reclamo reclamo_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reclamo
    ADD CONSTRAINT reclamo_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.respuesta(id_respuesta);


--
-- Name: regimen_dieta regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: regimen_dieta regimen_dieta_id_detalle_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_detalle_plan_dieta_fkey FOREIGN KEY (id_detalle_plan_dieta) REFERENCES public.detalle_plan_dieta(id_detalle_plan_dieta);


--
-- Name: regimen_ejercicio regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: regimen_ejercicio regimen_ejercicio_id_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES public.ejercicio(id_ejercicio);


--
-- Name: regimen_ejercicio regimen_ejercicio_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES public.frecuencia(id_frecuencia);


--
-- Name: regimen_ejercicio regimen_ejercicio_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES public.tiempo(id_tiempo);


--
-- Name: regimen_suplemento regimen_suplemento_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: regimen_suplemento regimen_suplemento_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES public.frecuencia(id_frecuencia);


--
-- Name: regimen_suplemento regimen_suplemento_id_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES public.suplemento(id_suplemento);


--
-- Name: respuesta respuesta_id_tipo_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuesta
    ADD CONSTRAINT respuesta_id_tipo_respuesta_fkey FOREIGN KEY (id_tipo_respuesta) REFERENCES public.tipo_motivo(id_tipo_motivo);


--
-- Name: rol_funcionalidad rol_funcionalidad_id_funcionalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_funcionalidad_fkey FOREIGN KEY (id_funcionalidad) REFERENCES public.funcionalidad(id_funcionalidad);


--
-- Name: rol_funcionalidad rol_funcionalidad_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES public.rol(id_rol);


--
-- Name: servicio servicio_id_especialidad_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_id_especialidad_fk FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad);


--
-- Name: servicio servicio_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES public.plan_dieta(id_plan_dieta);


--
-- Name: servicio servicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES public.plan_ejercicio(id_plan_ejercicio);


--
-- Name: servicio servicio_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES public.plan_suplemento(id_plan_suplemento);


--
-- Name: solicitud_servicio solicitud_servicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- Name: solicitud_servicio solicitud_servicio_id_estado_solicitud_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_estado_solicitud_fkey FOREIGN KEY (id_estado_solicitud) REFERENCES public.estado_solicitud(id_estado_solicitud);


--
-- Name: solicitud_servicio solicitud_servicio_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES public.motivo(id_motivo);


--
-- Name: solicitud_servicio solicitud_servicio_id_promocion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_promocion_fkey FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);


--
-- Name: solicitud_servicio solicitud_servicio_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.respuesta(id_respuesta);


--
-- Name: solicitud_servicio solicitud_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio(id_servicio);


--
-- Name: suplemento suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad(id_unidad);


--
-- Name: tipo_criterio tipo_criterio_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_criterio
    ADD CONSTRAINT tipo_criterio_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES public.tipo_valoracion(id_tipo_valoracion);


--
-- Name: unidad unidad_tipo_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_tipo_unidad_fkey FOREIGN KEY (id_tipo_unidad) REFERENCES public.tipo_unidad(id_tipo_unidad);


--
-- Name: usuario usuario_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES public.rol(id_rol);


--
-- Name: valoracion valoracion_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valoracion
    ADD CONSTRAINT valoracion_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES public.tipo_valoracion(id_tipo_valoracion);


--
-- Name: visita visita_id_agenda_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visita
    ADD CONSTRAINT visita_id_agenda_fkey FOREIGN KEY (id_agenda) REFERENCES public.agenda(id_agenda);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: LANGUAGE plpgsql; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON LANGUAGE plpgsql TO postgres;


--
-- PostgreSQL database dump complete
--

