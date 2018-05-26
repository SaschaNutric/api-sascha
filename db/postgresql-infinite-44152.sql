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
    id_valoracion integer NOT NULL,
    id_visita integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_calificacion integer DEFAULT nextval('public.id_calificacion_seq'::regclass) NOT NULL
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
    id_tipo_valoracion integer NOT NULL,
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
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
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
    estatus integer DEFAULT 1 NOT NULL
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
-- Name: precio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.precio (
    id_precio integer DEFAULT nextval('public.id_precio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE public.precio OWNER TO postgres;

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
    estatus integer DEFAULT 1 NOT NULL
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
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL
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
    estatus integer DEFAULT 1 NOT NULL
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

CREATE VIEW public.vista_agenda AS
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
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1) AND (d.estatus = 1) AND (d.id_tipo_cita <> 3) AND (g.estatus = 1) AND (g.estado = 1) AND (i.estatus = 1));


ALTER TABLE public.vista_agenda OWNER TO postgres;

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
    d.id_orden_servicio
   FROM ((((((public.visita a
     JOIN public.agenda b ON ((b.id_agenda = a.id_agenda)))
     JOIN public.cliente c ON ((c.id_cliente = b.id_cliente)))
     JOIN public.orden_servicio d ON ((d.id_orden_servicio = b.id_orden_servicio)))
     JOIN public.empleado e ON ((e.id_empleado = b.id_empleado)))
     JOIN public.solicitud_servicio g ON ((g.id_solicitud_servicio = d.id_solicitud_servicio)))
     JOIN public.servicio h ON ((h.id_servicio = g.id_servicio)))
  WHERE ((a.estatus = 1) AND (b.estatus = 1) AND (c.estatus = 1));


ALTER TABLE public.vista_visita OWNER TO postgres;


SELECT pg_catalog.setval('public.id_agenda_seq', 1, true);


--
-- Name: id_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_alimento_seq', 1, true);


--
-- Name: id_app_movil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_app_movil_seq', 1, true);


--
-- Name: id_ayuda_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_ayuda_seq', 1, true);


--
-- Name: id_bloque_horario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_bloque_horario_seq', 1, true);


--
-- Name: id_calificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_calificacion_seq', 1, false);


--
-- Name: id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_cita_seq', 1, true);


--
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_cliente_seq', 1, true);


--
-- Name: id_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_comentario_seq', 1, true);


--
-- Name: id_comida_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_comida_seq', 1, true);


--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_condicion_garantia_seq', 1, true);


--
-- Name: id_contenido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_contenido_seq', 1, true);


--
-- Name: id_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_criterio_seq', 1, true);


--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_plan_dieta_seq', 1, true);


--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_plan_ejercicio_seq', 1, true);


--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_plan_suplemento_seq', 1, true);


--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_regimen_alimento_seq', 1, true);


--
-- Name: id_detalle_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_detalle_visita_seq', 1, true);


--
-- Name: id_dia_laborable_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_dia_laborable_seq', 1, false);


--
-- Name: id_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_ejercicio_seq', 1, true);


--
-- Name: id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_empleado_seq', 1, true);


--
-- Name: id_especialidad_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_especialidad_empleado_seq', 1, false);


--
-- Name: id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_especialidad_seq', 1, true);


--
-- Name: id_especialidad_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_especialidad_servicio_seq', 1, false);


--
-- Name: id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_estado_civil_seq', 1, true);


--
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_estado_seq', 1, true);


--
-- Name: id_frecuencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_frecuencia_seq', 1, true);


--
-- Name: id_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_funcionalidad_seq', 1, true);


--
-- Name: id_garantia_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_garantia_servicio_seq', 1, true);


--
-- Name: id_genero_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_genero_seq', 1, true);


--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_grupo_alimenticio_seq', 1, true);


--
-- Name: id_horario_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_horario_empleado_seq', 1, true);


--
-- Name: id_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_incidencia_seq', 1, true);


--
-- Name: id_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_motivo_seq', 1, true);


--
-- Name: id_negocio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_negocio_seq', 1, true);


--
-- Name: id_orden_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_orden_servicio_seq', 1, true);


--
-- Name: id_parametro_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_cliente_seq', 1, true);


--
-- Name: id_parametro_meta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_meta_seq', 1, true);


--
-- Name: id_parametro_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_promocion_seq', 1, true);


--
-- Name: id_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_seq', 1, true);


--
-- Name: id_parametro_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_parametro_servicio_seq', 1, true);


--
-- Name: id_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_plan_dieta_seq', 1, true);


--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_plan_ejercicio_seq', 1, true);


--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_plan_suplemento_seq', 1, true);


--
-- Name: id_precio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_precio_seq', 1, true);


--
-- Name: id_preferencia_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_preferencia_cliente_seq', 1, false);


--
-- Name: id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_promocion_seq', 1, true);


--
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_rango_edad_seq', 1, true);


--
-- Name: id_reclamo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_reclamo_seq', 1, true);


--
-- Name: id_red_social_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_red_social_seq', 1, true);


--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_regimen_dieta_seq', 1, true);


--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_regimen_ejercicio_seq', 1, true);


--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_regimen_suplemento_seq', 1, true);


--
-- Name: id_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_respuesta_seq', 1, true);


--
-- Name: id_rol_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_rol_funcionalidad_seq', 1, true);


--
-- Name: id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_rol_seq', 1, true);


--
-- Name: id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_servicio_seq', 1, true);


--
-- Name: id_slide_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_slide_seq', 1, true);


--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_solicitud_servicio_seq', 1, true);


--
-- Name: id_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_suplemento_seq', 1, true);


--
-- Name: id_tiempo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tiempo_seq', 1, true);


--
-- Name: id_tipo_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_cita_seq', 1, true);


--
-- Name: id_tipo_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_criterio_seq', 1, true);


--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_dieta_seq', 1, true);


--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_incidencia_seq', 1, true);


--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_motivo_seq', 1, true);


--
-- Name: id_tipo_orden_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_orden_seq', 1, true);


--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_parametro_seq', 1, true);


--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_respuesta_seq', 1, true);


--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_unidad_seq', 1, true);


--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_tipo_valoracion_seq', 1, true);


--
-- Name: id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_unidad_seq', 1, true);


--
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_usuario_seq', 1, true);


--
-- Name: id_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_valoracion_seq', 1, true);


--
-- Name: id_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_visita_seq', 1, true);


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
-- Name: calificacion calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_pkey PRIMARY KEY (id_criterio, id_valoracion, id_visita, id_orden_servicio);


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
-- Name: precio precio_id_precio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.precio
    ADD CONSTRAINT precio_id_precio_pkey PRIMARY KEY (id_precio);


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
-- Name: criterio criterio_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criterio
    ADD CONSTRAINT criterio_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES public.tipo_valoracion(id_tipo_valoracion);


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
-- Name: precio precio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.precio
    ADD CONSTRAINT precio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad(id_unidad);


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

