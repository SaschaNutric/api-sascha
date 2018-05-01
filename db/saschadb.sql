--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.11
-- Dumped by pg_dump version 9.5.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
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


SET search_path = public, pg_catalog;

--
-- Name: fun_asignar_rango_edad(); Type: FUNCTION; Schema: public; Owner: byqkxhkjgnspco
--

CREATE FUNCTION fun_asignar_rango_edad() RETURNS trigger
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


ALTER FUNCTION public.fun_asignar_rango_edad() OWNER TO byqkxhkjgnspco;

--
-- Name: fun_eliminar_cliente(); Type: FUNCTION; Schema: public; Owner: byqkxhkjgnspco
--

CREATE FUNCTION fun_eliminar_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
	UPDATE cliente SET estatus = 0 WHERE cliente.id_usuario = OLD.id_usuario;
	RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_eliminar_cliente() OWNER TO byqkxhkjgnspco;

--
-- Name: id_agenda_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_agenda_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_agenda_seq OWNER TO byqkxhkjgnspco;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agenda; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE agenda (
    id_agenda integer DEFAULT nextval('id_agenda_seq'::regclass) NOT NULL,
    id_empleado integer NOT NULL,
    id_cliente integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_visita integer,
    id_cita integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE agenda OWNER TO byqkxhkjgnspco;

--
-- Name: id_alimento_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_alimento_seq OWNER TO byqkxhkjgnspco;

--
-- Name: alimento; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE alimento (
    id_alimento integer DEFAULT nextval('id_alimento_seq'::regclass) NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE alimento OWNER TO byqkxhkjgnspco;

--
-- Name: id_app_movil_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_app_movil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_app_movil_seq OWNER TO byqkxhkjgnspco;

--
-- Name: app_movil; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE app_movil (
    id_app_movil integer DEFAULT nextval('id_app_movil_seq'::regclass) NOT NULL,
    sistema_operativo character varying(50) DEFAULT ''::character varying NOT NULL,
    url_descarga character varying(500) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE app_movil OWNER TO byqkxhkjgnspco;

--
-- Name: id_bloque_horario_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_bloque_horario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_bloque_horario_seq OWNER TO byqkxhkjgnspco;

--
-- Name: bloque_horario; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE bloque_horario (
    id_bloque_horario integer DEFAULT nextval('id_bloque_horario_seq'::regclass) NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE bloque_horario OWNER TO byqkxhkjgnspco;

--
-- Name: id_calificacion_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_calificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_calificacion_seq OWNER TO byqkxhkjgnspco;

--
-- Name: calificacion; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE calificacion (
    id_criterio integer NOT NULL,
    id_valoracion integer NOT NULL,
    id_visita integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_calificacion integer DEFAULT nextval('id_calificacion_seq'::regclass) NOT NULL
);


ALTER TABLE calificacion OWNER TO byqkxhkjgnspco;

--
-- Name: id_cita_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_cita_seq OWNER TO byqkxhkjgnspco;

--
-- Name: cita; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE cita (
    id_cita integer DEFAULT nextval('id_cita_seq'::regclass) NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_tipo_cita integer NOT NULL,
    id_bloque_horario integer NOT NULL,
    fecha date NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE cita OWNER TO byqkxhkjgnspco;

--
-- Name: id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_cliente_seq OWNER TO byqkxhkjgnspco;

--
-- Name: cliente; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE cliente (
    id_cliente integer DEFAULT nextval('id_cliente_seq'::regclass) NOT NULL,
    id_usuario integer NOT NULL,
    id_genero integer NOT NULL,
    id_estado integer NOT NULL,
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


ALTER TABLE cliente OWNER TO byqkxhkjgnspco;

--
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: byqkxhkjgnspco
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- Name: id_comentario_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_comentario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_comentario_seq OWNER TO byqkxhkjgnspco;

--
-- Name: comentario; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE comentario (
    id_comentario integer DEFAULT nextval('id_comentario_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_respuesta integer,
    contenido character varying(500) DEFAULT ''::character varying NOT NULL,
    respuesta character varying(500),
    id_tipo_comentario integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE comentario OWNER TO byqkxhkjgnspco;

--
-- Name: id_comida_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_comida_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_comida_seq OWNER TO byqkxhkjgnspco;

--
-- Name: comida; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE comida (
    id_comida integer DEFAULT nextval('id_comida_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE comida OWNER TO byqkxhkjgnspco;

--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_condicion_garantia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_condicion_garantia_seq OWNER TO byqkxhkjgnspco;

--
-- Name: condicion_garantia; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE condicion_garantia (
    id_condicion_garantia integer DEFAULT nextval('id_condicion_garantia_seq'::regclass) NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE condicion_garantia OWNER TO byqkxhkjgnspco;

--
-- Name: id_contenido_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_contenido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_contenido_seq OWNER TO byqkxhkjgnspco;

--
-- Name: contenido; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE contenido (
    id_contenido integer DEFAULT nextval('id_contenido_seq'::regclass) NOT NULL,
    titulo character varying(100) DEFAULT ''::character varying NOT NULL,
    texto character varying(500) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE contenido OWNER TO byqkxhkjgnspco;

--
-- Name: id_criterio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_criterio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_criterio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: criterio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE criterio (
    id_criterio integer DEFAULT nextval('id_criterio_seq'::regclass) NOT NULL,
    id_tipo_criterio integer NOT NULL,
    id_tipo_valoracion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE criterio OWNER TO byqkxhkjgnspco;

--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_detalle_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_dieta_seq OWNER TO byqkxhkjgnspco;

--
-- Name: detalle_plan_dieta; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE detalle_plan_dieta (
    id_detalle_plan_dieta integer DEFAULT nextval('id_detalle_plan_dieta_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_comida integer NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_dieta OWNER TO byqkxhkjgnspco;

--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_detalle_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_ejercicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: detalle_plan_ejercicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE detalle_plan_ejercicio (
    id_detalle_plan_ejercicio integer DEFAULT nextval('id_detalle_plan_ejercicio_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_ejercicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_ejercicio OWNER TO byqkxhkjgnspco;

--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_detalle_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_suplemento_seq OWNER TO byqkxhkjgnspco;

--
-- Name: detalle_plan_suplemento; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE detalle_plan_suplemento (
    id_detalle_plan_suplemento integer DEFAULT nextval('id_detalle_plan_suplemento_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_suplemento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_suplemento OWNER TO byqkxhkjgnspco;

--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_detalle_regimen_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_regimen_alimento_seq OWNER TO postgres;

--
-- Name: detalle_regimen_alimento; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE detalle_regimen_alimento (
    id_regimen_dieta integer NOT NULL,
    id_alimento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_detalle_regimen_alimento integer DEFAULT nextval('id_detalle_regimen_alimento_seq'::regclass) NOT NULL
);


ALTER TABLE detalle_regimen_alimento OWNER TO byqkxhkjgnspco;

--
-- Name: id_detalle_visita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_detalle_visita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_visita_seq OWNER TO postgres;

--
-- Name: detalle_visita; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE detalle_visita (
    id_visita integer NOT NULL,
    id_parametro integer NOT NULL,
    valor numeric(12,4),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_detalle_visita integer DEFAULT nextval('id_detalle_visita_seq'::regclass) NOT NULL
);


ALTER TABLE detalle_visita OWNER TO byqkxhkjgnspco;

--
-- Name: id_dia_laborable_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_dia_laborable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_dia_laborable_seq OWNER TO byqkxhkjgnspco;

--
-- Name: dia_laborable; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE dia_laborable (
    id_dia_laborable integer DEFAULT nextval('id_dia_laborable_seq'::regclass) NOT NULL,
    dia character varying(20) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE dia_laborable OWNER TO byqkxhkjgnspco;

--
-- Name: id_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_ejercicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: ejercicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE ejercicio (
    id_ejercicio integer DEFAULT nextval('id_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE ejercicio OWNER TO byqkxhkjgnspco;

--
-- Name: id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_empleado_seq OWNER TO byqkxhkjgnspco;

--
-- Name: empleado; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE empleado (
    id_empleado integer DEFAULT nextval('id_empleado_seq'::regclass) NOT NULL,
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
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE empleado OWNER TO byqkxhkjgnspco;

--
-- Name: id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_especialidad_seq OWNER TO byqkxhkjgnspco;

--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE especialidad (
    id_especialidad integer DEFAULT nextval('id_especialidad_seq'::regclass) NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE especialidad OWNER TO byqkxhkjgnspco;

--
-- Name: id_especialidad_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_especialidad_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_especialidad_empleado_seq OWNER TO postgres;

--
-- Name: especialidad_empleado; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE especialidad_empleado (
    id_empleado integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_especialidad_empleado integer DEFAULT nextval('id_especialidad_empleado_seq'::regclass) NOT NULL
);


ALTER TABLE especialidad_empleado OWNER TO byqkxhkjgnspco;

--
-- Name: id_especialidad_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_especialidad_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_especialidad_servicio_seq OWNER TO postgres;

--
-- Name: especialidad_servicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE especialidad_servicio (
    id_servicio integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_especialidad_servicio integer DEFAULT nextval('id_especialidad_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE especialidad_servicio OWNER TO byqkxhkjgnspco;

--
-- Name: id_estado_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_estado_seq OWNER TO byqkxhkjgnspco;

--
-- Name: estado; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE estado (
    id_estado integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE estado OWNER TO byqkxhkjgnspco;

--
-- Name: id_estado_civil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_estado_civil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_estado_civil_seq OWNER TO postgres;

--
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE estado_civil (
    id_estado_civil integer DEFAULT nextval('id_estado_civil_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO byqkxhkjgnspco;

--
-- Name: id_frecuencia_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_frecuencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_frecuencia_seq OWNER TO byqkxhkjgnspco;

--
-- Name: frecuencia; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE frecuencia (
    id_frecuencia integer DEFAULT nextval('id_frecuencia_seq'::regclass) NOT NULL,
    id_tiempo integer NOT NULL,
    repeticiones integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE frecuencia OWNER TO byqkxhkjgnspco;

--
-- Name: id_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_funcionalidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_funcionalidad_seq OWNER TO byqkxhkjgnspco;

--
-- Name: funcionalidad; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE funcionalidad (
    id_funcionalidad integer DEFAULT nextval('id_funcionalidad_seq'::regclass) NOT NULL,
    id_funcionalidad_padre integer,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    icono character varying(100),
    orden integer NOT NULL,
    nivel integer NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    url_vista character varying(200) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE funcionalidad OWNER TO byqkxhkjgnspco;

--
-- Name: id_garantia_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_garantia_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_garantia_servicio_seq OWNER TO postgres;

--
-- Name: garantia_servicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE garantia_servicio (
    id_condicion_garantia integer NOT NULL,
    id_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_garantia_servicio integer DEFAULT nextval('id_garantia_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE garantia_servicio OWNER TO byqkxhkjgnspco;

--
-- Name: id_genero_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_genero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_genero_seq OWNER TO postgres;

--
-- Name: genero; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE genero (
    id_genero integer DEFAULT nextval('id_genero_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO byqkxhkjgnspco;

--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_grupo_alimenticio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_grupo_alimenticio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: grupo_alimenticio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE grupo_alimenticio (
    id_grupo_alimenticio integer DEFAULT nextval('id_grupo_alimenticio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE grupo_alimenticio OWNER TO byqkxhkjgnspco;

--
-- Name: id_horario_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_horario_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_horario_empleado_seq OWNER TO postgres;

--
-- Name: horario_empleado; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE horario_empleado (
    id_empleado integer NOT NULL,
    id_bloque_horario integer NOT NULL,
    id_dia_laborable integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_horario_empleado integer DEFAULT nextval('id_horario_empleado_seq'::regclass) NOT NULL
);


ALTER TABLE horario_empleado OWNER TO byqkxhkjgnspco;

--
-- Name: id_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_incidencia_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_motivo_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_motivo_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_negocio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_negocio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_negocio_seq OWNER TO postgres;

--
-- Name: id_orden_servicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_orden_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_orden_servicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_parametro_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_parametro_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_parametro_cliente_seq OWNER TO postgres;

--
-- Name: id_parametro_promocion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_parametro_promocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_parametro_promocion_seq OWNER TO postgres;

--
-- Name: id_parametro_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_parametro_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_parametro_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_parametro_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_parametro_servicio_seq OWNER TO postgres;

--
-- Name: id_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_dieta_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_ejercicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_suplemento_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_precio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_precio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_precio_seq OWNER TO postgres;

--
-- Name: id_preferencia_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_preferencia_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_preferencia_cliente_seq OWNER TO postgres;

--
-- Name: id_promocion_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_promocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_promocion_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_rango_edad_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_rango_edad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rango_edad_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_reclamo_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_reclamo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_reclamo_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_red_social_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_red_social_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_red_social_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_regimen_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_dieta_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_regimen_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_ejercicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_regimen_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_suplemento_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_respuesta_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_rol_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_rol_funcionalidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rol_funcionalidad_seq OWNER TO postgres;

--
-- Name: id_rol_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rol_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_servicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_slide_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_slide_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_slide_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_solicitud_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_solicitud_servicio_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_suplemento_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tiempo_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tiempo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tiempo_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_cita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_cita_seq OWNER TO postgres;

--
-- Name: id_tipo_comentario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_comentario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_comentario_seq OWNER TO postgres;

--
-- Name: id_tipo_criterio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_criterio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_criterio_seq OWNER TO postgres;

--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_dieta_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_incidencia_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_motivo_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_orden_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_orden_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_orden_seq OWNER TO postgres;

--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_parametro_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_respuesta_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_unidad_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_tipo_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_valoracion_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_unidad_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_usuario_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_valoracion_seq OWNER TO byqkxhkjgnspco;

--
-- Name: id_visita_seq; Type: SEQUENCE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE SEQUENCE id_visita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_visita_seq OWNER TO byqkxhkjgnspco;

--
-- Name: incidencia; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE incidencia (
    id_incidencia integer DEFAULT nextval('id_incidencia_seq'::regclass) NOT NULL,
    id_tipo_incidencia integer NOT NULL,
    id_motivo integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_agenda integer NOT NULL
);


ALTER TABLE incidencia OWNER TO byqkxhkjgnspco;

--
-- Name: motivo; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE motivo (
    id_motivo integer DEFAULT nextval('id_motivo_seq'::regclass) NOT NULL,
    id_tipo_motivo integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE motivo OWNER TO byqkxhkjgnspco;

--
-- Name: negocio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE negocio (
    id_negocio integer DEFAULT nextval('id_negocio_seq'::regclass) NOT NULL,
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


ALTER TABLE negocio OWNER TO byqkxhkjgnspco;

--
-- Name: orden_servicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE orden_servicio (
    id_orden_servicio integer DEFAULT nextval('id_orden_servicio_seq'::regclass) NOT NULL,
    id_solicitud_servicio integer NOT NULL,
    id_tipo_orden integer DEFAULT 1 NOT NULL,
    id_meta integer,
    fecha_emision date DEFAULT now() NOT NULL,
    fecha_caducidad date DEFAULT date_trunc('day'::text, (now() + '1 mon'::interval)) NOT NULL,
    id_reclamo integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE orden_servicio OWNER TO byqkxhkjgnspco;

--
-- Name: parametro; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE parametro (
    id_parametro integer DEFAULT nextval('id_parametro_seq'::regclass) NOT NULL,
    id_tipo_parametro integer NOT NULL,
    id_unidad integer,
    tipo_valor integer DEFAULT 1 NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE parametro OWNER TO byqkxhkjgnspco;

--
-- Name: COLUMN parametro.tipo_valor; Type: COMMENT; Schema: public; Owner: byqkxhkjgnspco
--

COMMENT ON COLUMN parametro.tipo_valor IS '1: Nominal  2: Numerico';


--
-- Name: parametro_cliente; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE parametro_cliente (
    id_cliente integer NOT NULL,
    id_parametro integer NOT NULL,
    valor numeric(12,4),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_parametro_cliente integer DEFAULT nextval('id_parametro_cliente_seq'::regclass) NOT NULL
);


ALTER TABLE parametro_cliente OWNER TO byqkxhkjgnspco;

--
-- Name: parametro_promocion; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE parametro_promocion (
    id_parametro integer NOT NULL,
    id_promocion integer NOT NULL,
    valor_minimo integer,
    valor_maximo integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_parametro_promocion integer DEFAULT nextval('id_parametro_promocion_seq'::regclass) NOT NULL
);


ALTER TABLE parametro_promocion OWNER TO byqkxhkjgnspco;

--
-- Name: parametro_servicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE parametro_servicio (
    id_servicio integer NOT NULL,
    id_parametro integer NOT NULL,
    valor_minimo integer NOT NULL,
    valor_maximo integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_parametro_servicio integer DEFAULT nextval('id_parametro_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE parametro_servicio OWNER TO byqkxhkjgnspco;

--
-- Name: plan_dieta; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE plan_dieta (
    id_plan_dieta integer DEFAULT nextval('id_plan_dieta_seq'::regclass) NOT NULL,
    id_tipo_dieta integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_dieta OWNER TO byqkxhkjgnspco;

--
-- Name: plan_ejercicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE plan_ejercicio (
    id_plan_ejercicio integer DEFAULT nextval('id_plan_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_ejercicio OWNER TO byqkxhkjgnspco;

--
-- Name: plan_suplemento; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE plan_suplemento (
    id_plan_suplemento integer DEFAULT nextval('id_plan_suplemento_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_suplemento OWNER TO byqkxhkjgnspco;

--
-- Name: precio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE precio (
    id_precio integer DEFAULT nextval('id_precio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE precio OWNER TO postgres;

--
-- Name: preferencia_cliente; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE preferencia_cliente (
    id_cliente integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_preferencia_cliente integer DEFAULT nextval('id_preferencia_cliente_seq'::regclass) NOT NULL
);


ALTER TABLE preferencia_cliente OWNER TO byqkxhkjgnspco;

--
-- Name: promocion; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE promocion (
    id_promocion integer DEFAULT nextval('id_promocion_seq'::regclass) NOT NULL,
    id_servicio integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    valido_desde date DEFAULT now() NOT NULL,
    valido_hasta date DEFAULT date_trunc('day'::text, (now() + '1 mon'::interval)) NOT NULL,
    id_genero integer,
    id_estado_civil integer,
    id_rango_edad integer,
    id_estado integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE promocion OWNER TO byqkxhkjgnspco;

--
-- Name: COLUMN promocion.id_estado_civil; Type: COMMENT; Schema: public; Owner: byqkxhkjgnspco
--

COMMENT ON COLUMN promocion.id_estado_civil IS '
';


--
-- Name: rango_edad; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE rango_edad (
    id_rango_edad integer DEFAULT nextval('id_rango_edad_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL,
    minimo integer NOT NULL,
    maximo integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE rango_edad OWNER TO byqkxhkjgnspco;

--
-- Name: reclamo; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE reclamo (
    id_reclamo integer DEFAULT nextval('id_reclamo_seq'::regclass) NOT NULL,
    id_motivo integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_respuesta integer,
    respuesta character varying(500),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE reclamo OWNER TO byqkxhkjgnspco;

--
-- Name: red_social; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE red_social (
    id_red_social integer DEFAULT nextval('id_red_social_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    url_base character varying(200) DEFAULT ''::character varying NOT NULL,
    url_logo character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE red_social OWNER TO byqkxhkjgnspco;

--
-- Name: regimen_dieta; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE regimen_dieta (
    id_regimen_dieta integer DEFAULT nextval('id_regimen_dieta_seq'::regclass) NOT NULL,
    id_detalle_plan_dieta integer NOT NULL,
    id_cliente integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_dieta OWNER TO byqkxhkjgnspco;

--
-- Name: regimen_ejercicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE regimen_ejercicio (
    id_regimen_ejercicio integer DEFAULT nextval('id_regimen_ejercicio_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_cliente integer NOT NULL,
    id_frecuencia integer NOT NULL,
    id_tiempo integer NOT NULL,
    duracion integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_ejercicio OWNER TO byqkxhkjgnspco;

--
-- Name: regimen_suplemento; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE regimen_suplemento (
    id_regimen_suplemento integer DEFAULT nextval('id_regimen_suplemento_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_cliente integer NOT NULL,
    id_frecuencia integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_suplemento OWNER TO byqkxhkjgnspco;

--
-- Name: respuesta; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE respuesta (
    id_respuesta integer DEFAULT nextval('id_respuesta_seq'::regclass) NOT NULL,
    id_tipo_respuesta integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE respuesta OWNER TO byqkxhkjgnspco;

--
-- Name: rol; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE rol (
    id_rol integer DEFAULT nextval('id_rol_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE rol OWNER TO byqkxhkjgnspco;

--
-- Name: rol_funcionalidad; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE rol_funcionalidad (
    id_rol integer NOT NULL,
    id_funcionalidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_rol_funcionalidad integer DEFAULT nextval('id_rol_funcionalidad_seq'::regclass) NOT NULL
);


ALTER TABLE rol_funcionalidad OWNER TO byqkxhkjgnspco;

--
-- Name: servicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE servicio (
    id_servicio integer DEFAULT nextval('id_servicio_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_plan_suplemento integer NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(500) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(200) DEFAULT ''::character varying NOT NULL,
    id_precio integer NOT NULL,
    numero_visitas integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE servicio OWNER TO byqkxhkjgnspco;

--
-- Name: slide; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE slide (
    id_slide integer DEFAULT nextval('id_slide_seq'::regclass) NOT NULL,
    titulo character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    orden integer NOT NULL,
    url_imagen character varying(200) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE slide OWNER TO byqkxhkjgnspco;

--
-- Name: solicitud_servicio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE solicitud_servicio (
    id_solicitud_servicio integer DEFAULT nextval('id_solicitud_servicio_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_motivo integer NOT NULL,
    id_respuesta integer,
    id_servicio integer NOT NULL,
    respuesta character varying(500),
    id_promocion integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE solicitud_servicio OWNER TO byqkxhkjgnspco;

--
-- Name: suplemento; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE suplemento (
    id_suplemento integer DEFAULT nextval('id_suplemento_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE suplemento OWNER TO byqkxhkjgnspco;

--
-- Name: tiempo; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tiempo (
    id_tiempo integer DEFAULT nextval('id_tiempo_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tiempo OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_cita; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_cita (
    id_tipo_cita integer DEFAULT nextval('id_tipo_cita_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_cita OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_comentario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_comentario (
    id_tipo_comentario integer DEFAULT nextval('id_tipo_comentario_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE tipo_comentario OWNER TO postgres;

--
-- Name: tipo_criterio; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_criterio (
    id_tipo_criterio integer DEFAULT nextval('id_tipo_criterio_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE tipo_criterio OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_dieta; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_dieta (
    id_tipo_dieta integer DEFAULT nextval('id_tipo_dieta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_dieta OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_incidencia; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_incidencia (
    id_tipo_incidencia integer DEFAULT nextval('id_tipo_incidencia_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_incidencia OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_motivo; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_motivo (
    id_tipo_motivo integer DEFAULT nextval('id_tipo_motivo_seq'::regclass) NOT NULL,
    nombre character(50) DEFAULT ''::bpchar NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_motivo OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_orden; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_orden (
    id_tipo_orden integer DEFAULT nextval('id_tipo_orden_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_orden OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_parametro; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_parametro (
    id_tipo_parametro integer DEFAULT nextval('id_tipo_parametro_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_parametro OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_respuesta; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_respuesta (
    id_tipo_respuesta integer DEFAULT nextval('id_tipo_respuesta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_respuesta OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_unidad; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_unidad (
    id_tipo_unidad integer DEFAULT nextval('id_tipo_unidad_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_unidad OWNER TO byqkxhkjgnspco;

--
-- Name: tipo_valoracion; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE tipo_valoracion (
    id_tipo_valoracion integer DEFAULT nextval('id_tipo_valoracion_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_valoracion OWNER TO byqkxhkjgnspco;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE unidad (
    id_unidad integer DEFAULT nextval('id_unidad_seq'::regclass) NOT NULL,
    id_tipo_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    simbolo character varying(3)
);


ALTER TABLE unidad OWNER TO byqkxhkjgnspco;

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE usuario (
    id_usuario integer DEFAULT nextval('id_usuario_seq'::regclass) NOT NULL,
    nombre_usuario character varying(100) DEFAULT ''::character varying NOT NULL,
    correo character varying(100) DEFAULT ''::character varying NOT NULL,
    contrasenia character varying DEFAULT ''::character varying NOT NULL,
    salt character varying DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    ultimo_acceso timestamp without time zone,
    estatus integer DEFAULT 1 NOT NULL,
    id_rol integer
);


ALTER TABLE usuario OWNER TO byqkxhkjgnspco;

--
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: byqkxhkjgnspco
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo 0: Eliminado';


--
-- Name: valoracion; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE valoracion (
    id_valoracion integer DEFAULT nextval('id_valoracion_seq'::regclass) NOT NULL,
    id_tipo_valoracion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE valoracion OWNER TO byqkxhkjgnspco;

--
-- Name: visita; Type: TABLE; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TABLE visita (
    id_visita integer DEFAULT nextval('id_visita_seq'::regclass) NOT NULL,
    numero integer NOT NULL,
    fecha_atencion date NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE visita OWNER TO byqkxhkjgnspco;

--
-- Name: vista_cliente; Type: VIEW; Schema: public; Owner: byqkxhkjgnspco
--

CREATE VIEW vista_cliente AS
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
    d.id_estado,
    d.nombre AS estado,
    a.tipo_cliente,
    e.nombre AS rango_edad,
    e.id_rango_edad
   FROM ((((cliente a
     JOIN genero b ON ((a.id_genero = b.id_genero)))
     JOIN estado_civil c ON ((a.id_estado_civil = c.id_estado_civil)))
     JOIN estado d ON ((a.id_estado = d.id_estado)))
     LEFT JOIN rango_edad e ON ((a.id_rango_edad = e.id_rango_edad)))
  WHERE (a.estatus = 1);


ALTER TABLE vista_cliente OWNER TO byqkxhkjgnspco;

--
-- Data for Name: agenda; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_visita, id_cita, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
2	1	arroz integral	2018-04-29 16:27:41.153359	2018-04-29 16:27:41.153359	1
3	1	trigo sarraceno	2018-04-29 16:28:02.656932	2018-04-29 16:28:02.656932	1
5	1	harina de avena	2018-04-29 16:28:54.306745	2018-04-29 16:28:54.306745	1
6	1	palomitas de maíz	2018-04-29 16:29:16.69524	2018-04-29 16:29:16.69524	1
7	1	cebada de grano entero	2018-04-29 16:29:44.684614	2018-04-29 16:29:44.684614	1
8	1	harina de maíz integral	2018-04-29 16:30:07.801988	2018-04-29 16:30:07.801988	1
9	1	centeno integral	2018-04-29 16:30:32.348177	2018-04-29 16:30:32.348177	1
10	1	pan integral	2018-04-29 16:30:55.156863	2018-04-29 16:30:55.156863	1
11	1	galletas de trigo integral	2018-04-29 16:31:17.336011	2018-04-29 16:31:17.336011	1
4	1	trigo integral (trigo partido)	2018-04-29 16:28:30.393343	2018-04-29 16:28:30.393343	1
12	1	pasta de trigo integral	2018-04-29 16:31:58.874919	2018-04-29 16:31:58.874919	1
13	1	copos de cereales integrales de trigo	2018-04-29 16:32:37.790184	2018-04-29 16:32:37.790184	1
14	1	tortillas de trigo integral	2018-04-29 16:33:03.356232	2018-04-29 16:33:03.356232	1
15	1	arroz salvaje	2018-04-29 16:33:20.276537	2018-04-29 16:33:20.276537	1
16	1	pan de maíz	2018-04-29 16:34:11.120798	2018-04-29 16:34:11.120798	1
17	1	tortillas de maíz	2018-04-29 16:34:27.684128	2018-04-29 16:34:27.684128	1
18	1	cuscús	2018-04-29 16:34:52.939997	2018-04-29 16:34:52.939997	1
19	1	galletas	2018-04-29 16:35:04.461438	2018-04-29 16:35:04.461438	1
20	2	col china	2018-04-29 16:39:35.143345	2018-04-29 16:39:35.143345	1
21	2	bróculi	2018-04-29 16:39:53.61204	2018-04-29 16:39:53.61204	1
22	2	berza	2018-04-29 16:40:09.163878	2018-04-29 16:40:09.163878	1
23	2	col rizada	2018-04-29 16:40:25.870373	2018-04-29 16:40:25.870373	1
24	2	espinaca	2018-04-29 16:40:38.358102	2018-04-29 16:40:38.358102	1
25	2	calabaza bellota	2018-04-29 16:40:58.447161	2018-04-29 16:40:58.447161	1
26	2	calabaza moscada	2018-04-29 16:45:21.67891	2018-04-29 16:45:21.67891	1
27	2	zanahorias	2018-04-29 16:45:39.220586	2018-04-29 16:45:39.220586	1
28	2	calabaza	2018-04-29 16:45:55.262603	2018-04-29 16:45:55.262603	1
29	2	pimientos rojos	2018-04-29 16:46:09.391247	2018-04-29 16:46:09.391247	1
30	2	batatas	2018-04-29 16:46:22.726523	2018-04-29 16:46:22.726523	1
31	2	tomates	2018-04-29 16:46:40.36571	2018-04-29 16:46:40.36571	1
32	2	jugo de tomate	2018-04-29 16:46:53.26105	2018-04-29 16:46:53.26105	1
33	2	maíz	2018-04-29 16:47:12.057307	2018-04-29 16:47:12.057307	1
34	2	guisantes	2018-04-29 16:47:26.379676	2018-04-29 16:47:26.379676	1
35	2	patatas	2018-04-29 16:47:34.409586	2018-04-29 16:47:34.409586	1
36	2	alcachofas	2018-04-29 16:48:04.336442	2018-04-29 16:48:04.336442	1
37	2	espárragos	2018-04-29 16:48:16.183045	2018-04-29 16:48:16.183045	1
38	2	aguacate	2018-04-29 16:48:25.341223	2018-04-29 16:48:25.341223	1
39	2	brotes de soja	2018-04-29 16:48:36.135112	2018-04-29 16:48:36.135112	1
40	2	remolacha	2018-04-29 16:48:46.922769	2018-04-29 16:48:46.922769	1
41	2	coles de bruselas	2018-04-29 16:49:01.155576	2018-04-29 16:49:01.155576	1
43	2	coliflor	2018-04-29 16:49:33.742891	2018-04-29 16:49:33.742891	1
44	2	apio	2018-04-29 16:49:37.719649	2018-04-29 16:49:37.719649	1
42	2	repollo	2018-04-29 16:49:16.220869	2018-04-29 16:49:16.220869	1
45	2	pepinos	2018-04-29 16:50:11.265928	2018-04-29 16:50:11.265928	1
46	2	berenjenas	2018-04-29 16:50:21.500135	2018-04-29 16:50:21.500135	1
47	2	pimientos verdes y rojos	2018-04-29 16:50:34.725302	2018-04-29 16:50:34.725302	1
48	2	pimientosjícama	2018-04-29 16:50:45.933356	2018-04-29 16:50:45.933356	1
49	2	hongos	2018-04-29 16:50:55.70585	2018-04-29 16:50:55.70585	1
50	2	quimbombó	2018-04-29 16:51:05.137866	2018-04-29 16:51:05.137866	1
51	2	cebollas	2018-04-29 16:51:15.114223	2018-04-29 16:51:15.114223	1
52	2	arveja china	2018-04-29 16:51:29.875766	2018-04-29 16:51:29.875766	1
53	2	judías verdes	2018-04-29 16:51:42.657364	2018-04-29 16:51:42.657364	1
54	2	tomates	2018-04-29 16:52:00.522683	2018-04-29 16:52:00.522683	1
55	2	jugos de verduras	2018-04-29 16:52:18.420366	2018-04-29 16:52:18.420366	1
56	2	calabacín	2018-04-29 16:52:31.068205	2018-04-29 16:52:31.068205	1
57	3	cortes magros de carne de res	2018-04-29 16:52:59.203414	2018-04-29 16:52:59.203414	1
58	3	ternera	2018-04-29 16:53:18.82171	2018-04-29 16:53:18.82171	1
59	3	cerdo	2018-04-29 16:53:27.772636	2018-04-29 16:53:27.772636	1
60	3	jamón y cordero	2018-04-29 16:53:39.810403	2018-04-29 16:53:39.810403	1
61	3	embutidos reducidos en grasa	2018-04-29 16:53:51.561924	2018-04-29 16:53:51.561924	1
62	3	embutidospollo sin piel y pavo	2018-04-29 16:54:05.19889	2018-04-29 16:54:05.19889	1
63	3	carne picada de pollo y pavo	2018-04-29 16:54:26.031908	2018-04-29 16:54:26.031908	1
65	3	trucha	2018-04-29 16:57:01.011359	2018-04-29 16:57:01.011359	1
66	3	almejas	2018-04-29 16:57:07.979398	2018-04-29 16:57:07.979398	1
64	3	salmón	2018-04-29 16:55:41.484795	2018-04-29 16:55:41.484795	1
67	3	arenque	2018-04-29 16:57:42.449435	2018-04-29 16:57:42.449435	1
68	3	cangrejo	2018-04-29 16:58:05.974756	2018-04-29 16:58:05.974756	1
69	3	langosta	2018-04-29 16:58:54.182219	2018-04-29 16:58:54.182219	1
70	3	mejillones	2018-04-29 16:59:02.613682	2018-04-29 16:59:02.613682	1
71	3	pulpo	2018-04-29 16:59:10.706295	2018-04-29 16:59:10.706295	1
72	3	ostras	2018-04-29 16:59:20.535307	2018-04-29 16:59:20.535307	1
73	3	vieiras	2018-04-29 16:59:29.656921	2018-04-29 16:59:29.656921	1
74	3	calamares	2018-04-29 16:59:37.464665	2018-04-29 16:59:37.464665	1
75	3	atún enlatado	2018-04-29 16:59:47.564188	2018-04-29 16:59:47.564188	1
76	3	huevos de pollo	2018-04-29 17:00:28.865386	2018-04-29 17:00:28.865386	1
77	3	huevos de pato	2018-04-29 17:00:43.589687	2018-04-29 17:00:43.589687	1
78	4	Leche baja en grasa	2018-04-29 17:01:27.226608	2018-04-29 17:01:27.226608	1
79	4	yogur	2018-04-29 17:01:40.891922	2018-04-29 17:01:40.891922	1
80	4	queso (como el cheddar, mozzarella, suizo, parmesano, tiras de queso, requesón)	2018-04-29 17:02:00.97745	2018-04-29 17:02:00.97745	1
81	4	pudín	2018-04-29 17:02:12.168309	2018-04-29 17:02:12.168309	1
82	4	helado	2018-04-29 17:02:29.811119	2018-04-29 17:02:29.811119	1
83	4	leche de soja	2018-04-29 17:02:51.809098	2018-04-29 17:02:51.809098	1
84	5	Manzanas	2018-04-29 17:03:30.928589	2018-04-29 17:03:30.928589	1
85	5	compota de manzanas	2018-04-29 17:03:45.203944	2018-04-29 17:03:45.203944	1
86	5	albaricoques	2018-04-29 17:03:59.983709	2018-04-29 17:03:59.983709	1
87	5	bananas	2018-04-29 17:04:12.141034	2018-04-29 17:04:12.141034	1
88	5	bayas (fresas, arándanos, frambuesas)	2018-04-29 17:04:27.097005	2018-04-29 17:04:27.097005	1
89	5	jugos de frutas (sin azúcar)	2018-04-29 17:04:52.037925	2018-04-29 17:04:52.037925	1
90	5	toronja	2018-04-29 17:05:07.355478	2018-04-29 17:05:07.355478	1
91	5	uvas	2018-04-29 17:05:17.537972	2018-04-29 17:05:17.537972	1
92	5	kiwis	2018-04-29 17:05:26.760147	2018-04-29 17:05:26.760147	1
93	5	mangos	2018-04-29 17:05:35.26587	2018-04-29 17:05:35.26587	1
94	5	melones (cantalupo, melón tuna, sandía)	2018-04-29 17:05:43.136078	2018-04-29 17:05:43.136078	1
95	5	nectarinas	2018-04-29 17:06:18.935932	2018-04-29 17:06:18.935932	1
96	5	naranjas	2018-04-29 17:06:27.140425	2018-04-29 17:06:27.140425	1
97	5	papayas	2018-04-29 17:06:37.599725	2018-04-29 17:06:37.599725	1
98	5	duraznos	2018-04-29 17:06:48.452894	2018-04-29 17:06:48.452894	1
99	5	peras	2018-04-29 17:06:57.006538	2018-04-29 17:06:57.006538	1
100	5	ciruelas	2018-04-29 17:07:04.814222	2018-04-29 17:07:04.814222	1
101	5	piña	2018-04-29 17:07:13.325088	2018-04-29 17:07:13.325088	1
102	5	pasas	2018-04-29 17:07:21.390469	2018-04-29 17:07:21.390469	1
103	5	ciruelas	2018-04-29 17:07:33.362892	2018-04-29 17:07:33.362892	1
104	5	carambolas	2018-04-29 17:07:40.370742	2018-04-29 17:07:40.370742	1
105	5	mandarinas	2018-04-29 17:07:46.893328	2018-04-29 17:07:46.893328	1
\.


--
-- Data for Name: app_movil; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY app_movil (id_app_movil, sistema_operativo, url_descarga, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
2	Ios	https://saschanutric.com/	2018-04-29 12:17:50.397657	2018-04-29 12:17:50.397657	1
1	Android	https://saschanutric.com/Android	2018-04-29 12:16:44.458	2018-04-29 12:16:44.458	1
\.


--
-- Data for Name: bloque_horario; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
2	07:00:00	08:00:00	2018-04-29 13:29:32.441887-04	2018-04-29 13:29:32.441887	1
3	08:00:00	09:00:00	2018-04-29 13:29:44.24225-04	2018-04-29 13:29:44.24225	1
4	09:00:00	10:00:00	2018-04-29 13:29:57.010425-04	2018-04-29 13:29:57.010425	1
5	11:00:00	12:00:00	2018-04-29 13:30:05.586403-04	2018-04-29 13:30:05.586403	1
1	06:00:00	07:00:00	2018-04-29 13:27:39.964-04	2018-04-29 13:27:39.964	1
\.


--
-- Data for Name: calificacion; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY calificacion (id_criterio, id_valoracion, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus, id_calificacion) FROM stdin;
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	2	1	3	V-24160052	Jose Alberto	Guerrero Carrillo	0414-5495292	Urb. El Amanecer, Cabudare	1994-06-07	1	\N	2018-04-19 22:12:23.435	2018-04-19 22:12:23.435	1
\.


--
-- Data for Name: comentario; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY comentario (id_comentario, id_cliente, id_respuesta, contenido, respuesta, id_tipo_comentario, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	contenido	respuesta	2	2018-04-30 22:51:00.809818	2018-04-30 22:51:00.809818	1
\.


--
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Desayuno	2018-04-28 21:53:48.786998	2018-04-28 21:53:48.786998	1
2	Almuerzo	2018-04-28 21:54:10.699942	2018-04-28 21:54:10.699942	1
3	Cena	2018-04-28 21:54:23.134874	2018-04-28 21:54:23.134874	1
4	Meriendas	2018-04-28 21:54:42.891521	2018-04-28 21:54:42.891521	1
5		2018-04-29 12:15:47.85841	2018-04-29 12:15:47.85841	1
\.


--
-- Data for Name: condicion_garantia; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY condicion_garantia (id_condicion_garantia, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	condiciones de garantias	2018-04-29 19:10:20.818	2018-04-29 19:10:20.818	1
2	garantias	2018-04-29 19:11:34.003742	2018-04-29 19:11:34.003742	1
\.


--
-- Data for Name: contenido; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: criterio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY criterio (id_criterio, id_tipo_criterio, id_tipo_valoracion, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	nombre	descripcion	2018-04-30 13:49:08.234671	2018-04-30 13:49:08.234671	1
\.


--
-- Data for Name: detalle_plan_dieta; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
2	1	1	1	2018-04-29 19:41:41.888408	2018-04-29 19:41:41.888408	1
\.


--
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus, id_detalle_regimen_alimento) FROM stdin;
\.


--
-- Data for Name: detalle_visita; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_detalle_visita) FROM stdin;
\.


--
-- Data for Name: dia_laborable; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: empleado; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) FROM stdin;
\.


--
-- Data for Name: especialidad_empleado; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY especialidad_empleado (id_empleado, id_especialidad, fecha_creacion, fecha_actualizacion, estatus, id_especialidad_empleado) FROM stdin;
\.


--
-- Data for Name: especialidad_servicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY especialidad_servicio (id_servicio, id_especialidad, fecha_creacion, fecha_actualizacion, estatus, id_especialidad_servicio) FROM stdin;
\.


--
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY estado (id_estado, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Lara	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
2	Carabobo	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
3	Anzoategui	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
4	Aragua	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
5	Nueva Esparta	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
6	Distrito Capital	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
7	Zulia	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
8	Mérida	2018-04-12 23:54:14.138	2018-04-12 23:54:14.138	1
\.


--
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY estado_civil (id_estado_civil, nombre) FROM stdin;
2	Comprometido/a
1	Soltero/a
4	Divorciado/a
3	Casado/a
5	Viudo/a
\.


--
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: funcionalidad; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) FROM stdin;
\.


--
-- Data for Name: garantia_servicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus, id_garantia_servicio) FROM stdin;
1	1	2018-04-29 19:16:25.946971	2018-04-29 19:16:25.946971	1	1
\.


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY genero (id_genero, nombre) FROM stdin;
2	Femenino
1	Masculino
\.


--
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	Granos	2018-04-29 16:01:38.561615	2018-04-29 16:01:38.561615	1
2	1	Vegetales	2018-04-29 16:11:24.341823	2018-04-29 16:11:24.341823	1
3	1	Carne	2018-04-29 16:11:50.193224	2018-04-29 16:11:50.193224	1
4	1	Lácteos	2018-04-29 16:12:13.445518	2018-04-29 16:12:13.445518	1
5	1	Fruta	2018-04-29 16:12:54.655452	2018-04-29 16:12:54.655452	1
\.


--
-- Data for Name: horario_empleado; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus, id_horario_empleado) FROM stdin;
\.


--
-- Name: id_agenda_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_agenda_seq', 1, false);


--
-- Name: id_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_alimento_seq', 105, true);


--
-- Name: id_app_movil_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_app_movil_seq', 2, true);


--
-- Name: id_bloque_horario_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_bloque_horario_seq', 5, true);


--
-- Name: id_calificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_calificacion_seq', 1, false);


--
-- Name: id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_cita_seq', 1, false);


--
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_cliente_seq', 1, true);


--
-- Name: id_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_comentario_seq', 1, true);


--
-- Name: id_comida_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_comida_seq', 5, true);


--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_condicion_garantia_seq', 2, true);


--
-- Name: id_contenido_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_contenido_seq', 1, false);


--
-- Name: id_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_criterio_seq', 1, true);


--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_detalle_plan_dieta_seq', 4, true);


--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_detalle_plan_ejercicio_seq', 1, false);


--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_detalle_plan_suplemento_seq', 1, false);


--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_detalle_regimen_alimento_seq', 1, false);


--
-- Name: id_detalle_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_detalle_visita_seq', 1, false);


--
-- Name: id_dia_laborable_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_dia_laborable_seq', 1, false);


--
-- Name: id_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_ejercicio_seq', 1, false);


--
-- Name: id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_empleado_seq', 1, false);


--
-- Name: id_especialidad_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_especialidad_empleado_seq', 1, false);


--
-- Name: id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_especialidad_seq', 1, false);


--
-- Name: id_especialidad_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_especialidad_servicio_seq', 1, false);


--
-- Name: id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_estado_civil_seq', 1, false);


--
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_estado_seq', 8, true);


--
-- Name: id_frecuencia_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_frecuencia_seq', 1, false);


--
-- Name: id_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_funcionalidad_seq', 1, false);


--
-- Name: id_garantia_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_garantia_servicio_seq', 1, true);


--
-- Name: id_genero_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_genero_seq', 1, true);


--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_grupo_alimenticio_seq', 5, true);


--
-- Name: id_horario_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_horario_empleado_seq', 1, false);


--
-- Name: id_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_incidencia_seq', 1, true);


--
-- Name: id_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_motivo_seq', 1, true);


--
-- Name: id_negocio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_negocio_seq', 1, true);


--
-- Name: id_orden_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_orden_servicio_seq', 1, false);


--
-- Name: id_parametro_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_parametro_cliente_seq', 2, true);


--
-- Name: id_parametro_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_parametro_promocion_seq', 1, false);


--
-- Name: id_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_parametro_seq', 1, true);


--
-- Name: id_parametro_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_parametro_servicio_seq', 1, false);


--
-- Name: id_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_plan_dieta_seq', 2, true);


--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_plan_ejercicio_seq', 2, true);


--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_plan_suplemento_seq', 1, true);


--
-- Name: id_precio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_precio_seq', 2, true);


--
-- Name: id_preferencia_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_preferencia_cliente_seq', 1, false);


--
-- Name: id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_promocion_seq', 1, true);


--
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_rango_edad_seq', 5, true);


--
-- Name: id_reclamo_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_reclamo_seq', 1, false);


--
-- Name: id_red_social_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_red_social_seq', 1, false);


--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_regimen_dieta_seq', 1, false);


--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_regimen_ejercicio_seq', 1, false);


--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_regimen_suplemento_seq', 1, false);


--
-- Name: id_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_respuesta_seq', 1, true);


--
-- Name: id_rol_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_rol_funcionalidad_seq', 1, false);


--
-- Name: id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_rol_seq', 1, false);


--
-- Name: id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_servicio_seq', 1, true);


--
-- Name: id_slide_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_slide_seq', 1, false);


--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_solicitud_servicio_seq', 1, false);


--
-- Name: id_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_suplemento_seq', 1, false);


--
-- Name: id_tiempo_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tiempo_seq', 1, false);


--
-- Name: id_tipo_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_tipo_cita_seq', 1, true);


--
-- Name: id_tipo_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_tipo_comentario_seq', 2, true);


--
-- Name: id_tipo_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_tipo_criterio_seq', 1, true);


--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_dieta_seq', 1, true);


--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_incidencia_seq', 1, true);


--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_motivo_seq', 1, true);


--
-- Name: id_tipo_orden_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_tipo_orden_seq', 1, true);


--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_parametro_seq', 1, true);


--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_respuesta_seq', 1, true);


--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_unidad_seq', 3, true);


--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_tipo_valoracion_seq', 1, true);


--
-- Name: id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_unidad_seq', 10, true);


--
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_usuario_seq', 1, true);


--
-- Name: id_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_valoracion_seq', 1, false);


--
-- Name: id_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: byqkxhkjgnspco
--

SELECT pg_catalog.setval('id_visita_seq', 1, false);


--
-- Data for Name: incidencia; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) FROM stdin;
\.


--
-- Data for Name: motivo; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	descripcion	2018-04-30 14:00:54.022162	2018-04-30 14:00:54.022162	1
\.


--
-- Data for Name: negocio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY negocio (id_negocio, razon_social, rif, url_logo, mision, vision, objetivo, telefono, correo, latitud, longitud, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Sascha	1-3211111112111	https://res.cloudinary.com/saschanutric/image/upload/v1524779283/logosascha.png	mision2	vision2	objetivo2	555-5555555	saschanutric@gmail.com	10.0768150	-69.3545490	2018-04-27 19:36:48.598	2018-04-27 19:36:48.598	1
\.


--
-- Data for Name: orden_servicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: parametro; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	1	nombre parametro	2018-04-30 16:55:35.418238	2018-04-30 16:55:35.418238	1
\.


--
-- Data for Name: parametro_cliente; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus, id_parametro_cliente) FROM stdin;
1	1	12.0000	2018-04-30 17:16:59.287469	2018-04-30 17:16:59.287469	1	1
\.


--
-- Data for Name: parametro_promocion; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY parametro_promocion (id_parametro, id_promocion, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_promocion) FROM stdin;
\.


--
-- Data for Name: parametro_servicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus, id_parametro_servicio) FROM stdin;
\.


--
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	Nutricional Deportiva	mas informacion	2018-04-26 22:28:08.231389	2018-04-26 22:28:08.231389	1
\.


--
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
2	Caminar	todo los dias	2018-04-28 13:22:03.5738	2018-04-28 13:22:03.5738	1
\.


--
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	suplemento	suplemento	2018-04-28 13:24:19.168145	2018-04-28 13:24:19.168145	1
\.


--
-- Data for Name: precio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY precio (id_precio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus, valor) FROM stdin;
2	3	ochenta	2018-04-28 16:05:40.523271	2018-04-28 16:05:40.523271	1	80
\.


--
-- Data for Name: preferencia_cliente; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY preferencia_cliente (id_cliente, id_especialidad, fecha_creacion, fecha_actualizacion, estatus, id_preferencia_cliente) FROM stdin;
\.


--
-- Data for Name: promocion; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, id_estado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	nombre	descripcion	2018-04-30	2018-05-30	1	1	4	1	2018-04-30 14:41:55.828093	2018-04-30 14:41:55.828093	1
\.


--
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Bebe	0	1	2018-04-19 21:11:06.606	2018-04-19 21:11:06.606	1
2	Niño/a	1	12	2018-04-19 21:11:19.305	2018-04-19 21:11:19.305	1
3	Joven 	12	30	2018-04-19 21:11:32.739	2018-04-19 21:11:32.739	1
4	Adulto	30	60	2018-04-19 21:11:41.765	2018-04-19 21:11:41.765	1
5	Adulto mayor	60	120	2018-04-19 21:12:03.981	2018-04-19 21:12:03.981	1
\.


--
-- Data for Name: reclamo; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: red_social; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_ejercicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY regimen_ejercicio (id_regimen_ejercicio, id_plan_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_suplemento; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY regimen_suplemento (id_regimen_suplemento, id_plan_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: respuesta; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	descripcion	2018-04-30 20:22:21.134494	2018-04-30 20:22:21.134494	1
\.


--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: rol_funcionalidad; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus, id_rol_funcionalidad) FROM stdin;
\.


--
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, id_precio, numero_visitas, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	2	1	Plan para Adultos Mayores	Un nutricionista calificado realiza una evaluación de tu estado nutricional	https://res.cloudinary.com/saschanutric/image/upload/v1524936642/nutricionadultos.jpg	2	5	2018-04-28 13:38:46.242099	2018-04-28 13:38:46.242099	1
\.


--
-- Data for Name: slide; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: solicitud_servicio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: suplemento; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tiempo; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_cita; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_cita (id_tipo_cita, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Criterio	2018-04-26 15:17:34.87	2018-04-26 15:17:58.572	1
\.


--
-- Data for Name: tipo_comentario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tipo_comentario (id_tipo_comentario, nombre, estatus, fecha_actualizacion, fecha_creacion) FROM stdin;
2	nuevo comentario	1	2018-04-30 21:20:17.782	2018-04-30 21:20:17.782
\.


--
-- Data for Name: tipo_criterio; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_criterio (id_tipo_criterio, nombre, estatus, fecha_actualizacion, fecha_creacion) FROM stdin;
1	Criterio	1	2018-04-26 16:23:34.800573	2018-04-26 16:23:34.800573
\.


--
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Nutricional deportiva	2018-04-26 14:41:11.711	2018-04-26 14:41:11.711	1
\.


--
-- Data for Name: tipo_incidencia; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_incidencia (id_tipo_incidencia, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	nuevo motivo	2018-04-26 17:33:09.924	2018-04-26 17:33:09.924	1
\.


--
-- Data for Name: tipo_motivo; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	motivo                                            	2018-04-26 18:08:25.981343	2018-04-26 18:08:25.981343	1
\.


--
-- Data for Name: tipo_orden; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_orden (id_tipo_orden, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	nueva orden	2018-04-26 18:42:16.06	2018-04-26 18:42:16.06	1
\.


--
-- Data for Name: tipo_parametro; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	nueva parametro	2018-04-26 18:56:58.785	2018-04-26 18:56:58.785	1
\.


--
-- Data for Name: tipo_respuesta; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_respuesta (id_tipo_respuesta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	nueva respuesta	2018-04-26 20:00:24.576	2018-04-26 20:00:24.576	1
\.


--
-- Data for Name: tipo_unidad; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
2	moneda	2018-04-28 16:01:38.443991	2018-04-28 16:01:38.443991	1
1	Masa	2018-04-26 20:11:18.444	2018-04-26 20:11:18.444	1
3	Tiempo	2018-04-29 15:46:00.58441	2018-04-29 15:46:00.58441	1
\.


--
-- Data for Name: tipo_valoracion; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY tipo_valoracion (id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Buena	2018-04-26 20:12:24.532	2018-04-26 20:12:24.532	1
\.


--
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus, simbolo) FROM stdin;
1	1	gramos	gm	2018-04-26 20:56:51.086	2018-04-26 20:56:51.086	1	g
5	1	kilogramo	K	2018-04-29 15:29:55.229859	2018-04-29 15:29:55.229859	1	k
7	3	Hora	h	2018-04-29 15:30:26.023738	2018-04-29 15:30:26.023738	1	h
8	3	Minuto	min	2018-04-29 15:30:41.183499	2018-04-29 15:30:41.183499	1	m
9	3	Segundo	seg	2018-04-29 15:31:00.859754	2018-04-29 15:31:00.859754	1	s
10	2	Dólar estadounidense	USD	2018-04-29 15:37:05.908467	2018-04-29 15:37:05.908467	1	$
6	1	milligramo	mg	2018-04-29 15:30:10.690033	2018-04-29 15:30:10.690033	1	mg
3	2	Bolivares Fuertes	VEF	2018-04-28 16:04:41.417766	2018-04-28 16:04:41.417766	1	BsF
4	1	tonelada	ton	2018-04-29 15:29:26.717019	2018-04-29 15:29:26.717019	1	ton
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol) FROM stdin;
1	jguerrero	guerrero.c.jose.a@gmail.com	$2a$12$Zsfm7hKFFwzszEOGSuOS7ePL179wk2RfxNBObxu.Un/gZtVjHunj6	$2a$12$Zsfm7hKFFwzszEOGSuOS7e	2018-04-19 22:12:23.435	2018-04-19 22:12:23.435	\N	1	\N
\.


--
-- Data for Name: valoracion; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: visita; Type: TABLE DATA; Schema: public; Owner: byqkxhkjgnspco
--

COPY visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Name: agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (id_agenda);


--
-- Name: alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_pkey PRIMARY KEY (id_alimento);


--
-- Name: app_movil_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY app_movil
    ADD CONSTRAINT app_movil_pkey PRIMARY KEY (id_app_movil);


--
-- Name: bloque_horario_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY bloque_horario
    ADD CONSTRAINT bloque_horario_pkey PRIMARY KEY (id_bloque_horario);


--
-- Name: calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_pkey PRIMARY KEY (id_criterio, id_valoracion, id_visita, id_orden_servicio);


--
-- Name: cita_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_pkey PRIMARY KEY (id_comentario);


--
-- Name: comida_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY comida
    ADD CONSTRAINT comida_pkey PRIMARY KEY (id_comida);


--
-- Name: condicion_garantia_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY condicion_garantia
    ADD CONSTRAINT condicion_garantia_pkey PRIMARY KEY (id_condicion_garantia);


--
-- Name: contenido_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY contenido
    ADD CONSTRAINT contenido_pkey PRIMARY KEY (id_contenido);


--
-- Name: criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_pkey PRIMARY KEY (id_criterio);


--
-- Name: detalle_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_pkey PRIMARY KEY (id_detalle_plan_dieta);


--
-- Name: detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- Name: detalle_regimen_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_pkey PRIMARY KEY (id_regimen_dieta, id_alimento);


--
-- Name: detalle_visita_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_pkey PRIMARY KEY (id_visita, id_parametro);


--
-- Name: dia_laborable_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY dia_laborable
    ADD CONSTRAINT dia_laborable_pkey PRIMARY KEY (id_dia_laborable);


--
-- Name: ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY ejercicio
    ADD CONSTRAINT ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);


--
-- Name: especialidad_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_pkey PRIMARY KEY (id_empleado, id_especialidad);


--
-- Name: especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: especialidad_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_pkey PRIMARY KEY (id_servicio, id_especialidad);


--
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- Name: frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- Name: funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_pkey PRIMARY KEY (id_funcionalidad);


--
-- Name: garantia_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_pkey PRIMARY KEY (id_condicion_garantia, id_servicio);


--
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- Name: grupo_alimenticio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_pkey PRIMARY KEY (id_grupo_alimenticio);


--
-- Name: horario_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_pkey PRIMARY KEY (id_empleado, id_bloque_horario, id_dia_laborable);


--
-- Name: id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_pkey PRIMARY KEY (id_incidencia);


--
-- Name: motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY motivo
    ADD CONSTRAINT motivo_pkey PRIMARY KEY (id_motivo);


--
-- Name: negocio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY negocio
    ADD CONSTRAINT negocio_pkey PRIMARY KEY (id_negocio);


--
-- Name: orden_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_pkey PRIMARY KEY (id_orden_servicio);


--
-- Name: parametro_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_pkey PRIMARY KEY (id_cliente, id_parametro);


--
-- Name: parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_pkey PRIMARY KEY (id_parametro);


--
-- Name: parametro_promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_promocion
    ADD CONSTRAINT parametro_promocion_pkey PRIMARY KEY (id_parametro, id_promocion);


--
-- Name: parametro_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_pkey PRIMARY KEY (id_servicio, id_parametro);


--
-- Name: plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- Name: plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- Name: plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- Name: precio_id_precio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY precio
    ADD CONSTRAINT precio_id_precio_pkey PRIMARY KEY (id_precio);


--
-- Name: preferencia_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_pkey PRIMARY KEY (id_cliente, id_especialidad);


--
-- Name: promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);


--
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- Name: reclamo_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_pkey PRIMARY KEY (id_reclamo);


--
-- Name: red_social_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY red_social
    ADD CONSTRAINT red_social_pkey PRIMARY KEY (id_red_social);


--
-- Name: regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- Name: regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- Name: regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- Name: respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (id_respuesta);


--
-- Name: rol_funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_pkey PRIMARY KEY (id_rol, id_funcionalidad);


--
-- Name: rol_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);


--
-- Name: slide_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY slide
    ADD CONSTRAINT slide_pkey PRIMARY KEY (id_slide);


--
-- Name: solicitud_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_pkey PRIMARY KEY (id_solicitud_servicio);


--
-- Name: suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- Name: tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tiempo
    ADD CONSTRAINT tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- Name: tipo_cita_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_cita
    ADD CONSTRAINT tipo_cita_pkey PRIMARY KEY (id_tipo_cita);


--
-- Name: tipo_comentario_id_tipo_comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_comentario
    ADD CONSTRAINT tipo_comentario_id_tipo_comentario_pkey PRIMARY KEY (id_tipo_comentario);


--
-- Name: tipo_criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_criterio
    ADD CONSTRAINT tipo_criterio_pkey PRIMARY KEY (id_tipo_criterio);


--
-- Name: tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_dieta
    ADD CONSTRAINT tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- Name: tipo_incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_incidencia
    ADD CONSTRAINT tipo_incidencia_pkey PRIMARY KEY (id_tipo_incidencia);


--
-- Name: tipo_motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_motivo
    ADD CONSTRAINT tipo_motivo_pkey PRIMARY KEY (id_tipo_motivo);


--
-- Name: tipo_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_orden
    ADD CONSTRAINT tipo_orden_pkey PRIMARY KEY (id_tipo_orden);


--
-- Name: tipo_parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_parametro
    ADD CONSTRAINT tipo_parametro_pkey PRIMARY KEY (id_tipo_parametro);


--
-- Name: tipo_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_respuesta
    ADD CONSTRAINT tipo_respuesta_pkey PRIMARY KEY (id_tipo_respuesta);


--
-- Name: tipo_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_unidad
    ADD CONSTRAINT tipo_unidad_pkey PRIMARY KEY (id_tipo_unidad);


--
-- Name: tipo_valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY tipo_valoracion
    ADD CONSTRAINT tipo_valoracion_pkey PRIMARY KEY (id_tipo_valoracion);


--
-- Name: unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (id_unidad);


--
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY valoracion
    ADD CONSTRAINT valoracion_pkey PRIMARY KEY (id_valoracion);


--
-- Name: visita_pkey; Type: CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY visita
    ADD CONSTRAINT visita_pkey PRIMARY KEY (id_visita);


--
-- Name: fki_comentario_id_tipo_comentario_fkey; Type: INDEX; Schema: public; Owner: byqkxhkjgnspco
--

CREATE INDEX fki_comentario_id_tipo_comentario_fkey ON comentario USING btree (id_tipo_comentario);


--
-- Name: fki_incidencia_id_agenda_fkey; Type: INDEX; Schema: public; Owner: byqkxhkjgnspco
--

CREATE INDEX fki_incidencia_id_agenda_fkey ON incidencia USING btree (id_agenda);


--
-- Name: fki_servicio_id_precio_fkey; Type: INDEX; Schema: public; Owner: byqkxhkjgnspco
--

CREATE INDEX fki_servicio_id_precio_fkey ON servicio USING btree (id_precio);


--
-- Name: dis_asignar_rango_edad; Type: TRIGGER; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TRIGGER dis_asignar_rango_edad AFTER INSERT ON cliente FOR EACH ROW EXECUTE PROCEDURE fun_asignar_rango_edad();


--
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: byqkxhkjgnspco
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- Name: agenda_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES cita(id_cita);


--
-- Name: agenda_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: agenda_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: agenda_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: agenda_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: alimento_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: calificacion_id_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_criterio_fkey FOREIGN KEY (id_criterio) REFERENCES criterio(id_criterio);


--
-- Name: calificacion_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: calificacion_id_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_valoracion_fkey FOREIGN KEY (id_valoracion) REFERENCES valoracion(id_valoracion);


--
-- Name: calificacion_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: cita_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES bloque_horario(id_bloque_horario);


--
-- Name: cita_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: cita_id_tipo_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_tipo_cita_fkey FOREIGN KEY (id_tipo_cita) REFERENCES tipo_cita(id_tipo_cita);


--
-- Name: cliente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil);


--
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- Name: cliente_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- Name: comentario_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: comentario_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: comentario_id_tipo_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_tipo_comentario_fkey FOREIGN KEY (id_tipo_comentario) REFERENCES tipo_comentario(id_tipo_comentario);


--
-- Name: criterio_id_tipo_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_id_tipo_criterio_fkey FOREIGN KEY (id_tipo_criterio) REFERENCES tipo_criterio(id_tipo_criterio);


--
-- Name: criterio_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES tipo_valoracion(id_tipo_valoracion);


--
-- Name: detalle_plan_dieta_id_comida_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_comida_fkey FOREIGN KEY (id_comida) REFERENCES comida(id_comida);


--
-- Name: detalle_plan_dieta_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: detalle_plan_dieta_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- Name: detalle_plan_ejercicio_id_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES ejercicio(id_ejercicio);


--
-- Name: detalle_plan_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: detalle_plan_suplemento_id_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES suplemento(id_suplemento);


--
-- Name: detalle_regimen_alimento_id_alimento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_alimento_fkey FOREIGN KEY (id_alimento) REFERENCES alimento(id_alimento);


--
-- Name: detalle_regimen_alimento_id_regimen_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_regimen_dieta_fkey FOREIGN KEY (id_regimen_dieta) REFERENCES regimen_dieta(id_regimen_dieta);


--
-- Name: detalle_visita_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: detalle_visita_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: empleado_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- Name: empleado_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- Name: especialidad_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: especialidad_empleado_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: especialidad_servicio_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: especialidad_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: frecuencia_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- Name: funcionalidad_id_funcionalidad_padre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_id_funcionalidad_padre_fkey FOREIGN KEY (id_funcionalidad_padre) REFERENCES funcionalidad(id_funcionalidad);


--
-- Name: garantia_servicio_id_condicion_garantia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_condicion_garantia_fkey FOREIGN KEY (id_condicion_garantia) REFERENCES condicion_garantia(id_condicion_garantia);


--
-- Name: garantia_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: grupo_alimenticio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: horario_empleado_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES bloque_horario(id_bloque_horario);


--
-- Name: horario_empleado_id_dia_laborable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_dia_laborable_fkey FOREIGN KEY (id_dia_laborable) REFERENCES dia_laborable(id_dia_laborable);


--
-- Name: horario_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: incidencia_id_agenda_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_agenda_fkey FOREIGN KEY (id_agenda) REFERENCES agenda(id_agenda);


--
-- Name: incidencia_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: incidencia_id_tipo_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_tipo_incidencia_fkey FOREIGN KEY (id_tipo_incidencia) REFERENCES tipo_incidencia(id_tipo_incidencia);


--
-- Name: motivo_id_tipo_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY motivo
    ADD CONSTRAINT motivo_id_tipo_motivo_fkey FOREIGN KEY (id_tipo_motivo) REFERENCES tipo_motivo(id_tipo_motivo);


--
-- Name: orden_servicio_id_reclamo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_reclamo_fkey FOREIGN KEY (id_reclamo) REFERENCES reclamo(id_reclamo);


--
-- Name: orden_servicio_id_solicitud_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_solicitud_servicio_fkey FOREIGN KEY (id_solicitud_servicio) REFERENCES solicitud_servicio(id_solicitud_servicio);


--
-- Name: orden_servicio_id_tipo_orden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_tipo_orden_fkey FOREIGN KEY (id_tipo_orden) REFERENCES tipo_orden(id_tipo_orden);


--
-- Name: parametro_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: parametro_cliente_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: parametro_servicio_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: parametro_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: parametro_tipo_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_tipo_parametro_fkey FOREIGN KEY (id_tipo_parametro) REFERENCES tipo_parametro(id_tipo_parametro);


--
-- Name: parametro_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: plan_dieta_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES tipo_dieta(id_tipo_dieta);


--
-- Name: precio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY precio
    ADD CONSTRAINT precio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: preferencia_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: preferencia_cliente_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: promocion_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: reclamo_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: reclamo_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: reclamo_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_dieta_id_detalle_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_detalle_plan_dieta_fkey FOREIGN KEY (id_detalle_plan_dieta) REFERENCES detalle_plan_dieta(id_detalle_plan_dieta);


--
-- Name: regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_ejercicio_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- Name: regimen_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: regimen_ejercicio_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- Name: regimen_suplemento_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_suplemento_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- Name: regimen_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: respuesta_id_tipo_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_id_tipo_respuesta_fkey FOREIGN KEY (id_tipo_respuesta) REFERENCES tipo_respuesta(id_tipo_respuesta);


--
-- Name: rol_funcionalidad_id_funcionalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_funcionalidad_fkey FOREIGN KEY (id_funcionalidad) REFERENCES funcionalidad(id_funcionalidad);


--
-- Name: rol_funcionalidad_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES rol(id_rol);


--
-- Name: servicio_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- Name: servicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: servicio_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: servicio_id_precio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_precio_fkey FOREIGN KEY (id_precio) REFERENCES precio(id_precio);


--
-- Name: solicitud_servicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: solicitud_servicio_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: solicitud_servicio_id_promocion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_promocion_fkey FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion);


--
-- Name: solicitud_servicio_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: solicitud_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: unidad_tipo_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_tipo_unidad_fkey FOREIGN KEY (id_tipo_unidad) REFERENCES tipo_unidad(id_tipo_unidad);


--
-- Name: usuario_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES rol(id_rol);


--
-- Name: valoracion_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: byqkxhkjgnspco
--

ALTER TABLE ONLY valoracion
    ADD CONSTRAINT valoracion_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES tipo_valoracion(id_tipo_valoracion);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

