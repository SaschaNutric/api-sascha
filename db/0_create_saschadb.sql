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
-- Name: fun_asignar_rango_edad(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.fun_asignar_rango_edad() OWNER TO postgres;

--
-- Name: fun_eliminar_cliente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_eliminar_cliente() RETURNS trigger
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

CREATE SEQUENCE id_agenda_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_agenda_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agenda; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE agenda OWNER TO postgres;

--
-- Name: id_alimento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_alimento_seq OWNER TO postgres;

--
-- Name: alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE alimento (
    id_alimento integer DEFAULT nextval('id_alimento_seq'::regclass) NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE alimento OWNER TO postgres;

--
-- Name: id_app_movil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_app_movil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_app_movil_seq OWNER TO postgres;

--
-- Name: app_movil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE app_movil (
    id_app_movil integer DEFAULT nextval('id_app_movil_seq'::regclass) NOT NULL,
    sistema_operativo character varying(50) DEFAULT ''::character varying NOT NULL,
    url_descarga character varying(500) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE app_movil OWNER TO postgres;

--
-- Name: id_bloque_horario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_bloque_horario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_bloque_horario_seq OWNER TO postgres;

--
-- Name: bloque_horario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE bloque_horario (
    id_bloque_horario integer DEFAULT nextval('id_bloque_horario_seq'::regclass) NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE bloque_horario OWNER TO postgres;

--
-- Name: id_calificacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_calificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_calificacion_seq OWNER TO postgres;

--
-- Name: calificacion; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE calificacion OWNER TO postgres;

--
-- Name: id_cita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_cita_seq OWNER TO postgres;

--
-- Name: cita; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE cita OWNER TO postgres;

--
-- Name: id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_cliente_seq OWNER TO postgres;

--
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE cliente OWNER TO postgres;

--
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- Name: id_comentario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_comentario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_comentario_seq OWNER TO postgres;

--
-- Name: comentario; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE comentario OWNER TO postgres;

--
-- Name: id_comida_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_comida_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_comida_seq OWNER TO postgres;

--
-- Name: comida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comida (
    id_comida integer DEFAULT nextval('id_comida_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE comida OWNER TO postgres;

--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_condicion_garantia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_condicion_garantia_seq OWNER TO postgres;

--
-- Name: condicion_garantia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE condicion_garantia (
    id_condicion_garantia integer DEFAULT nextval('id_condicion_garantia_seq'::regclass) NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE condicion_garantia OWNER TO postgres;

--
-- Name: id_contenido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_contenido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_contenido_seq OWNER TO postgres;

--
-- Name: contenido; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE contenido OWNER TO postgres;

--
-- Name: id_criterio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_criterio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_criterio_seq OWNER TO postgres;

--
-- Name: criterio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE criterio OWNER TO postgres;

--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_detalle_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_dieta_seq OWNER TO postgres;

--
-- Name: detalle_plan_dieta; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE detalle_plan_dieta OWNER TO postgres;

--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_detalle_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_ejercicio_seq OWNER TO postgres;

--
-- Name: detalle_plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_plan_ejercicio (
    id_detalle_plan_ejercicio integer DEFAULT nextval('id_detalle_plan_ejercicio_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_ejercicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_ejercicio OWNER TO postgres;

--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_detalle_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_suplemento_seq OWNER TO postgres;

--
-- Name: detalle_plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_plan_suplemento (
    id_detalle_plan_suplemento integer DEFAULT nextval('id_detalle_plan_suplemento_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_suplemento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_suplemento OWNER TO postgres;

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
-- Name: detalle_regimen_alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_regimen_alimento (
    id_regimen_dieta integer NOT NULL,
    id_alimento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_detalle_regimen_alimento integer DEFAULT nextval('id_detalle_regimen_alimento_seq'::regclass) NOT NULL
);


ALTER TABLE detalle_regimen_alimento OWNER TO postgres;

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
-- Name: detalle_visita; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE detalle_visita OWNER TO postgres;

--
-- Name: id_dia_laborable_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_dia_laborable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_dia_laborable_seq OWNER TO postgres;

--
-- Name: dia_laborable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dia_laborable (
    id_dia_laborable integer DEFAULT nextval('id_dia_laborable_seq'::regclass) NOT NULL,
    dia character varying(20) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE dia_laborable OWNER TO postgres;

--
-- Name: id_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_ejercicio_seq OWNER TO postgres;

--
-- Name: ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE ejercicio (
    id_ejercicio integer DEFAULT nextval('id_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE ejercicio OWNER TO postgres;

--
-- Name: id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_empleado_seq OWNER TO postgres;

--
-- Name: empleado; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE empleado OWNER TO postgres;

--
-- Name: id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_especialidad_seq OWNER TO postgres;

--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE especialidad (
    id_especialidad integer DEFAULT nextval('id_especialidad_seq'::regclass) NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE especialidad OWNER TO postgres;

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
-- Name: especialidad_empleado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE especialidad_empleado (
    id_empleado integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_especialidad_empleado integer DEFAULT nextval('id_especialidad_empleado_seq'::regclass) NOT NULL
);


ALTER TABLE especialidad_empleado OWNER TO postgres;

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
-- Name: especialidad_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE especialidad_servicio (
    id_servicio integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_especialidad_servicio integer DEFAULT nextval('id_especialidad_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE especialidad_servicio OWNER TO postgres;

--
-- Name: id_estado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_estado_seq OWNER TO postgres;

--
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado (
    id_estado integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE estado OWNER TO postgres;

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
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado_civil (
    id_estado_civil integer DEFAULT nextval('id_estado_civil_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO postgres;

--
-- Name: id_frecuencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_frecuencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_frecuencia_seq OWNER TO postgres;

--
-- Name: frecuencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE frecuencia (
    id_frecuencia integer DEFAULT nextval('id_frecuencia_seq'::regclass) NOT NULL,
    id_tiempo integer NOT NULL,
    repeticiones integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE frecuencia OWNER TO postgres;

--
-- Name: id_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_funcionalidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_funcionalidad_seq OWNER TO postgres;

--
-- Name: funcionalidad; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE funcionalidad OWNER TO postgres;

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
-- Name: garantia_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE garantia_servicio (
    id_condicion_garantia integer NOT NULL,
    id_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_garantia_servicio integer DEFAULT nextval('id_garantia_servicio_seq'::regclass) NOT NULL
);


ALTER TABLE garantia_servicio OWNER TO postgres;

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
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE genero (
    id_genero integer DEFAULT nextval('id_genero_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO postgres;

--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_grupo_alimenticio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_grupo_alimenticio_seq OWNER TO postgres;

--
-- Name: grupo_alimenticio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE grupo_alimenticio (
    id_grupo_alimenticio integer DEFAULT nextval('id_grupo_alimenticio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE grupo_alimenticio OWNER TO postgres;

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
-- Name: horario_empleado; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE horario_empleado OWNER TO postgres;

--
-- Name: id_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_incidencia_seq OWNER TO postgres;

--
-- Name: id_motivo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_motivo_seq OWNER TO postgres;

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
-- Name: id_orden_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_orden_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_orden_servicio_seq OWNER TO postgres;

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
-- Name: id_parametro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_parametro_seq OWNER TO postgres;

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
-- Name: id_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_dieta_seq OWNER TO postgres;

--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_ejercicio_seq OWNER TO postgres;

--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_suplemento_seq OWNER TO postgres;

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
-- Name: id_promocion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_promocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_promocion_seq OWNER TO postgres;

--
-- Name: id_rango_edad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_rango_edad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rango_edad_seq OWNER TO postgres;

--
-- Name: id_reclamo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_reclamo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_reclamo_seq OWNER TO postgres;

--
-- Name: id_red_social_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_red_social_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_red_social_seq OWNER TO postgres;

--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_regimen_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_dieta_seq OWNER TO postgres;

--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_regimen_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_ejercicio_seq OWNER TO postgres;

--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_regimen_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_suplemento_seq OWNER TO postgres;

--
-- Name: id_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_respuesta_seq OWNER TO postgres;

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
-- Name: id_rol_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rol_seq OWNER TO postgres;

--
-- Name: id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_servicio_seq OWNER TO postgres;

--
-- Name: id_slide_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_slide_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_slide_seq OWNER TO postgres;

--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_solicitud_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_solicitud_servicio_seq OWNER TO postgres;

--
-- Name: id_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_suplemento_seq OWNER TO postgres;

--
-- Name: id_tiempo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tiempo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tiempo_seq OWNER TO postgres;

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
-- Name: id_tipo_dieta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_dieta_seq OWNER TO postgres;

--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_incidencia_seq OWNER TO postgres;

--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_motivo_seq OWNER TO postgres;

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
-- Name: id_tipo_parametro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_parametro_seq OWNER TO postgres;

--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_respuesta_seq OWNER TO postgres;

--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_unidad_seq OWNER TO postgres;

--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_tipo_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_valoracion_seq OWNER TO postgres;

--
-- Name: id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_unidad_seq OWNER TO postgres;

--
-- Name: id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_usuario_seq OWNER TO postgres;

--
-- Name: id_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_valoracion_seq OWNER TO postgres;

--
-- Name: id_visita_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_visita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_visita_seq OWNER TO postgres;

--
-- Name: incidencia; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE incidencia OWNER TO postgres;

--
-- Name: motivo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE motivo (
    id_motivo integer DEFAULT nextval('id_motivo_seq'::regclass) NOT NULL,
    id_tipo_motivo integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE motivo OWNER TO postgres;

--
-- Name: negocio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE negocio OWNER TO postgres;

--
-- Name: orden_servicio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE orden_servicio OWNER TO postgres;

--
-- Name: parametro; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE parametro OWNER TO postgres;

--
-- Name: COLUMN parametro.tipo_valor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN parametro.tipo_valor IS '1: Nominal  2: Numerico';


--
-- Name: parametro_cliente; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE parametro_cliente OWNER TO postgres;

--
-- Name: parametro_promocion; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE parametro_promocion OWNER TO postgres;

--
-- Name: parametro_servicio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE parametro_servicio OWNER TO postgres;

--
-- Name: plan_dieta; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE plan_dieta OWNER TO postgres;

--
-- Name: plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE plan_ejercicio (
    id_plan_ejercicio integer DEFAULT nextval('id_plan_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_ejercicio OWNER TO postgres;

--
-- Name: plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE plan_suplemento (
    id_plan_suplemento integer DEFAULT nextval('id_plan_suplemento_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_suplemento OWNER TO postgres;

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
-- Name: preferencia_cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE preferencia_cliente (
    id_cliente integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_preferencia_cliente integer DEFAULT nextval('id_preferencia_cliente_seq'::regclass) NOT NULL
);


ALTER TABLE preferencia_cliente OWNER TO postgres;

--
-- Name: promocion; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE promocion OWNER TO postgres;

--
-- Name: COLUMN promocion.id_estado_civil; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN promocion.id_estado_civil IS '
';


--
-- Name: rango_edad; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE rango_edad OWNER TO postgres;

--
-- Name: reclamo; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE reclamo OWNER TO postgres;

--
-- Name: red_social; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE red_social OWNER TO postgres;

--
-- Name: regimen_dieta; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE regimen_dieta OWNER TO postgres;

--
-- Name: regimen_ejercicio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE regimen_ejercicio OWNER TO postgres;

--
-- Name: regimen_suplemento; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE regimen_suplemento OWNER TO postgres;

--
-- Name: respuesta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE respuesta (
    id_respuesta integer DEFAULT nextval('id_respuesta_seq'::regclass) NOT NULL,
    id_tipo_respuesta integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE respuesta OWNER TO postgres;



--
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rol (
    id_rol integer DEFAULT nextval('id_rol_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE rol OWNER TO postgres;

--
-- Name: rol_funcionalidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rol_funcionalidad (
    id_rol integer NOT NULL,
    id_funcionalidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    id_rol_funcionalidad integer DEFAULT nextval('id_rol_funcionalidad_seq'::regclass) NOT NULL
);


ALTER TABLE rol_funcionalidad OWNER TO postgres;

--
-- Name: servicio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE servicio OWNER TO postgres;

--
-- Name: slide; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE slide OWNER TO postgres;

--
-- Name: solicitud_servicio; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE solicitud_servicio OWNER TO postgres;

--
-- Name: suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE suplemento (
    id_suplemento integer DEFAULT nextval('id_suplemento_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE suplemento OWNER TO postgres;

--
-- Name: tiempo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tiempo (
    id_tiempo integer DEFAULT nextval('id_tiempo_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tiempo OWNER TO postgres;

--
-- Name: tipo_cita; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_cita (
    id_tipo_cita integer DEFAULT nextval('id_tipo_cita_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_cita OWNER TO postgres;

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
-- Name: tipo_criterio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_criterio (
    id_tipo_criterio integer DEFAULT nextval('id_tipo_criterio_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    estatus integer DEFAULT 1 NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE tipo_criterio OWNER TO postgres;

--
-- Name: tipo_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_dieta (
    id_tipo_dieta integer DEFAULT nextval('id_tipo_dieta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_dieta OWNER TO postgres;

--
-- Name: tipo_incidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_incidencia (
    id_tipo_incidencia integer DEFAULT nextval('id_tipo_incidencia_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_incidencia OWNER TO postgres;

--
-- Name: tipo_motivo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_motivo (
    id_tipo_motivo integer DEFAULT nextval('id_tipo_motivo_seq'::regclass) NOT NULL,
    nombre character(50) DEFAULT ''::bpchar NOT NULL,
    canal_escucha boolean DEFAULT TRUE NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_motivo OWNER TO postgres;

--
-- Name: tipo_orden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_orden (
    id_tipo_orden integer DEFAULT nextval('id_tipo_orden_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_orden OWNER TO postgres;

--
-- Name: tipo_parametro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_parametro (
    id_tipo_parametro integer DEFAULT nextval('id_tipo_parametro_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_parametro OWNER TO postgres;

--
-- Name: tipo_respuesta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_respuesta (
    id_tipo_respuesta integer DEFAULT nextval('id_tipo_respuesta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_respuesta OWNER TO postgres;

--
-- Name: tipo_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_unidad (
    id_tipo_unidad integer DEFAULT nextval('id_tipo_unidad_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_unidad OWNER TO postgres;

--
-- Name: tipo_valoracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_valoracion (
    id_tipo_valoracion integer DEFAULT nextval('id_tipo_valoracion_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_valoracion OWNER TO postgres;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE unidad OWNER TO postgres;

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE usuario OWNER TO postgres;

--
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo 0: Eliminado';


--
-- Name: valoracion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE valoracion (
    id_valoracion integer DEFAULT nextval('id_valoracion_seq'::regclass) NOT NULL,
    id_tipo_valoracion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE valoracion OWNER TO postgres;

--
-- Name: visita; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE visita (
    id_visita integer DEFAULT nextval('id_visita_seq'::regclass) NOT NULL,
    numero integer NOT NULL,
    fecha_atencion date NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE visita OWNER TO postgres;

--
-- Name: vista_cliente; Type: VIEW; Schema: public; Owner: postgres
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
    a.tipo_cliente,
    e.nombre AS rango_edad,
    e.id_rango_edad
   FROM (((cliente a
     JOIN genero b ON ((a.id_genero = b.id_genero)))
     JOIN estado_civil c ON ((a.id_estado_civil = c.id_estado_civil)))
     LEFT JOIN rango_edad e ON ((a.id_rango_edad = e.id_rango_edad)))
  WHERE (a.estatus = 1);


ALTER TABLE vista_cliente OWNER TO postgres;


CREATE VIEW vista_cliente_ordenes AS
    SELECT a.id_cliente,
    a.id_usuario,
    ARRAY(SELECT id_orden_servicio 
          FROM orden_servicio b 
          JOIN solicitud_servicio c 
          ON b.id_solicitud_servicio = c.id_solicitud_servicio
          WHERE c.id_cliente = a.id_cliente
          AND b.estado = 1) AS ordenes
    FROM cliente a
    WHERE a.estatus = 1;

ALTER TABLE vista_cliente_ordenes OWNER TO postgres;


CREATE VIEW vista_cliente_servicio_activo AS
    SELECT a.id_orden_servicio, 
        b.id_solicitud_servicio, 
        d.id_cliente, 
        (d.nombres || ' ' || d.apellidos) AS nombre_cliente, 
        c.id_servicio, 
        c.nombre as nombre_servicio
    FROM orden_servicio a 
    JOIN solicitud_servicio b ON a.id_solicitud_servicio = b.id_solicitud_servicio
    JOIN servicio c ON b.id_servicio = c.id_servicio
    JOIN cliente d ON b.id_cliente = d.id_cliente
    WHERE a.estatus = 1 AND b.estatus = 1 AND c.estatus = 1 AND d.estatus = 1;

ALTER TABLE vista_cliente_servicio_activo OWNER TO byqkxhkjgnspco;


CREATE VIEW vista_agenda AS
SELECT a.id_agenda, 
    i.id_empleado,
    (i.nombres || ' ' || i.apellidos) AS nombre_empleado,
    b.id_cliente, 
    (b.nombres || ' ' || b.apellidos) AS nombre_cliente, 
    c.id_servicio, 
    c.nombre AS nombre_servicio,
    d.id_tipo_cita, 
    e.nombre AS tipo_cita, 
    d.fecha, 
    f.hora_inicio, 
    f.hora_fin
FROM agenda a
    JOIN cliente b ON a.id_cliente = b.id_cliente
    JOIN orden_servicio g ON a.id_orden_servicio = g.id_orden_servicio
    JOIN solicitud_servicio h ON g.id_solicitud_servicio = h.id_solicitud_servicio
    JOIN servicio c ON c.id_servicio = h.id_servicio
    JOIN cita d ON a.id_cita = d.id_cita
    JOIN tipo_cita e ON d.id_tipo_cita = e.id_tipo_cita
    JOIN bloque_horario f ON d.id_bloque_horario = f.id_bloque_horario
    JOIN empleado i ON a.id_empleado = i.id_empleado
WHERE a.estatus = 1 
    AND b.estatus = 1 
    AND c.estatus = 1 
    AND d.estatus = 1
    AND g.estatus = 1 
    AND g.estado = 1
    AND i.estatus = 1;
    
ALTER TABLE vista_cliente_servicio_activo OWNER TO byqkxhkjgnspco;

--
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO alimento (id_alimento, id_grupo_alimenticio, nombre) 
VALUES (1, 1, 'arroz blanco'),
(2, 1, 'arroz integral'),
(3, 1, 'trigo sarraceno'),
(4, 1, 'trigo integral (trigo partido)'),
(5, 1, 'harina de avena') ,
(6, 1, 'palomitas de maíz'),
(7, 1, 'cebada de grano entero'),
(8, 1, 'harina de maíz integral'),
(9, 1, 'centeno integral'),
(10, 1, 'pan integral'),
(11, 1, 'galletas de trigo integral'),
(12, 1, 'pasta de trigo integral'),
(13, 1, 'copos de cereales integrales de trigo'),
(14, 1, 'tortillas de trigo integral'),
(15, 1, 'arroz salvaje'),
(16, 1, 'pan de maíz'),
(17, 1, 'tortillas de maíz'),
(18, 1, 'cuscús'),
(19, 1, 'galletas'),
(20, 2, 'col china'),
(21, 2, 'brócoli'),
(22, 2, 'berza'),
(23, 2, 'col rizada'),
(24, 2, 'espinaca'),
(25, 2, 'calabaza bellota'),
(26, 2, 'calabaza moscada'),
(27, 2, 'zanahorias'),
(28, 2, 'calabaza'),
(29, 2, 'pimientos rojos'),
(30, 2, 'batatas'),
(31, 2, 'tomates'),
(32, 2, 'jugo de tomate'),
(33, 2, 'maíz'),
(34, 2, 'guisantes'),
(35, 2, 'patatas'),
(36, 2, 'alcachofas'),
(37, 2, 'espárragos'),
(38, 2, 'aguacate'),
(39, 2, 'brotes de soja'),
(40, 2, 'remolacha'),
(41, 2, 'coles de bruselas'),
(43, 2, 'coliflor'),
(44, 2, 'apio'),
(42, 2, 'repollo'),
(45, 2, 'pepinos'),
(46, 2, 'berenjenas')	,
(47, 2, 'pimientos verdes y rojos'),
(48, 2, 'pimientosjícama'),
(49, 2, 'hongos'),
(50, 2, 'quimbombó'),
(51, 2, 'cebollas'),
(52, 2, 'arveja china'),
(53, 2, 'judías verdes'),
(54, 2, 'tomates'),
(55, 2, 'jugos de verduras'),
(56, 2, 'calabacín'),
(57, 3, 'cortes magros de carne de res'),
(58, 3, 'ternera'),
(59, 3, 'cerdo'),
(60, 3, 'jamón y cordero'),
(61, 3, 'embutidos reducidos en grasa'),
(62, 3, 'embutidospollo sin piel y pavo'),
(63, 3, 'carne picada de pollo y pavo'),
(65, 3, 'trucha'),
(66, 3, 'almejas'),
(64, 3, 'salmón'),
(67, 3, 'arenque'),
(68, 3, 'cangrejo'),
(69, 3, 'langosta'),
(70, 3, 'mejillones'),
(71, 3, 'pulpo'),
(72, 3, 'ostras')	,
(73, 3, 'vieiras'),
(74, 3, 'calamares'),
(75, 3, 'atún enlatado'),
(76, 3, 'huevos de pollo'),
(77, 3, 'huevos de pato'),
(78, 4, 'Leche baja en grasa'),
(79, 4, 'yogur'),
(80, 4, 'queso (como el cheddar, mozzarella, suizo, parmesano, tiras de queso, requesón)'),
(81, 4, 'pudín'),
(82, 4, 'helado'),
(83, 4, 'leche de soja'),
(84, 5, 'Manzanas'),
(85, 5, 'compota de manzanas'),
(86, 5, 'albaricoques'),
(87, 5, 'bananas'),
(88, 5, 'bayas (fresas, arándanos, frambuesas)'),
(89, 5, 'jugos de frutas (sin azúcar)'),
(90, 5, 'toronja'),
(91, 5, 'uvas'),
(92, 5, 'kiwis'),
(93, 5, 'mangos'),
(94, 5, 'melones (cantalupo, melón tuna, sandía)'),
(95, 5, 'nectarinas'),
(96, 5, 'naranjas'),
(97, 5, 'papayas'),
(98, 5, 'duraznos'),
(99, 5, 'peras'),
(100, 5, 'ciruelas'),   
(101, 5, 'piña'),
(102, 5, 'pasas'),
(103, 5, 'ciruelas'),
(104, 5, 'carambolas'),
(105, 5, 'mandarinas');


SELECT pg_catalog.setval('id_alimento_seq', 105, true);


--
-- Data for Name: app_movil; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO app_movil (id_app_movil, sistema_operativo, url_descarga) 
VALUES (1, 'Android', 'https://saschanutric.com/Android'),
(2, 'IOS', 'https://saschanutric.com/');


SELECT pg_catalog.setval('id_app_movil_seq', 2, true);


--
-- Data for Name: bloque_horario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO bloque_horario (id_bloque_horario, hora_inicio, hora_fin) 
VALUES (1, '07:00:00', '08:00:00'),
(2, '08:00:00', '09:00:00'),
(3, '09:00:00', '10:00:00'),
(4, '10:00:00', '11:00:00'),
(5, '11:00:00', '12:00:00'),
(6, '12:00:00', '13:00:00'),
(7, '13:00:00', '14:00:00'),
(8, '14:00:00', '15:00:00'),
(9, '15:00:00', '16:00:00'),
(10, '16:00:00', '17:00:00'),
(11, '17:00:00', '18:00:00');


SELECT pg_catalog.setval('id_bloque_horario_seq', 11, true);


--
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado)
VALUES (1, 1, 1, 2, 1, 3, 'V-24160052', 'Jose Alberto', 'Guerrero Carrillo', '0414-5495292', 'Urb. El Amanecer, Cabudare', '1994-06-07', 1, null);


SELECT pg_catalog.setval('id_cliente_seq', 1, true);


--
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO comida (id_comida, nombre) 
VALUES (1, 'Desayuno'),
(2, 'Merienda de la mañana'),
(3, 'Almuerzo'),
(4, 'Merienda de la tarde'),
(5, 'Cena'),
(6, 'Merienda de la noche');


SELECT pg_catalog.setval('id_comida_seq', 6, true);

INSERT INTO dia_laborable(id_dia_laborable, dia)
VALUES (0, 'Domingo'),
(1, 'Lunes'),
(2, 'Martes'),
(3, 'Miercoles'),
(4, 'Jueves'),
(5, 'Viernes'),
(6, 'Sábado');

--
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO estado VALUES (1, 'Lara', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (2, 'Carabobo', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (3, 'Anzoategui', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (4, 'Aragua', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (5, 'Nueva Esparta', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (6, 'Distrito Capital', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (7, 'Zulia', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);
INSERT INTO estado VALUES (8, 'Mérida', '2018-04-12 23:54:14.138-04:30', '2018-04-12 23:54:14.138-04:30', 1);


SELECT pg_catalog.setval('id_estado_seq', 8, true);

INSERT INTO especialidad (id_especialidad, nombre)
VALUES (1, 'Adelgazar'),
(2, 'Aumentar Peso'),
(3, 'Ganar Masa Muscular'),
(4, 'Definición de Musculo'),
(5, 'Control de Patología'),
(6, 'Atención Deportiva');

SELECT pg_catalog.setval('id_especialidad_seq', 6, true);

--
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO estado_civil VALUES (2, 'Comprometido/a');
INSERT INTO estado_civil VALUES (1, 'Soltero/a');
INSERT INTO estado_civil VALUES (4, 'Divorciado/a');
INSERT INTO estado_civil VALUES (3, 'Casado/a');
INSERT INTO estado_civil VALUES (5, 'Viudo/a');


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO genero VALUES (2, 'Femenino');
INSERT INTO genero VALUES (1, 'Masculino');


SELECT pg_catalog.setval('id_genero_seq', 1, true);


--
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre)
VALUES (1, 1, 'Granos'),
(2, 1, 'Vegetales'), 
(3, 1, 'Carne'),
(4, 1, 'Lácteos'),
(5, 1, 'Fruta');


SELECT pg_catalog.setval('id_grupo_alimenticio_seq', 5, true);

--
-- Name: id_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
INSERT INTO funcionalidad VALUES (1, NULL, 'Dashboard', 'fa fa-leaf', 1, 1, 1, 'dashboard.html');
INSERT INTO funcionalidad VALUES (2, NULL, 'Registros Básicos', 'fa fa-edit', 2, 1, 1, '');
INSERT INTO funcionalidad VALUES (3, NULL, 'Configuración', 'fa fa-cogs', 3, 1, 1, '');
INSERT INTO funcionalidad VALUES (4, NULL, 'Visitas', 'fa fa-calendar', 4, 1, 1, '');
INSERT INTO funcionalidad VALUES (5, NULL, 'Ofertas y promociones', 'fa fa-tags', 5, 1, 1, '');
INSERT INTO funcionalidad VALUES (6, NULL, 'Reportes', 'fa fa-bar-chart-o', 6, 1, 1, '');
INSERT INTO funcionalidad VALUES (7, NULL, 'Administración del Sistema', 'fa fa-wrench', 7, 1, 1, '');
INSERT INTO funcionalidad VALUES (8, 2, 'Unidades', 'fa fa-chevron-right', 1, 2, 1, 'regi_unidad.html');
INSERT INTO funcionalidad VALUES (9, 2, 'Tipos de Parámetros', 'fa fa-chevron-right', 2, 2, 1, 'regi_tipo_parametro.html');

SELECT pg_catalog.setval('id_funcionalidad_seq', 7, true);


INSERT INTO negocio (id_negocio, razon_social, rif, url_logo, mision, vision, objetivo, telefono, correo, latitud, longitud)
VALUES(1, 'Sascha', '1-3211111112111', 'https://res.cloudinary.com/saschanutric/image/upload/v1524779283/logosascha.png', 'mision', 'vision', 'objetivo', '555-5555555', 'saschanutric@gmail.com', 10.0768150, -69.3545490);


SELECT pg_catalog.setval('id_negocio_seq', 1, true);


INSERT INTO rango_edad VALUES (1, 'Bebe', 0, 1, '2018-04-19 21:11:06.606-04:30', '2018-04-19 21:11:06.606-04:30', 1);
INSERT INTO rango_edad VALUES (2, 'Niño/a', 1, 12, '2018-04-19 21:11:19.305-04:30', '2018-04-19 21:11:19.305-04:30', 1);
INSERT INTO rango_edad VALUES (3, 'Joven ', 12, 30, '2018-04-19 21:11:32.739-04:30', '2018-04-19 21:11:32.739-04:30', 1);
INSERT INTO rango_edad VALUES (4, 'Adulto', 30, 60, '2018-04-19 21:11:41.765-04:30', '2018-04-19 21:11:41.765-04:30', 1);
INSERT INTO rango_edad VALUES (5, 'Adulto mayor', 60, 120, '2018-04-19 21:12:03.981-04:30', '2018-04-19 21:12:03.981-04:30', 1);


SELECT pg_catalog.setval('id_rango_edad_seq', 5, true);


INSERT INTO tipo_motivo(id_tipo_motivo, nombre)
VALUES (1, 'Solicitud'),
(2, 'Reclamo'),
(3, 'Incidencia'),
(4, 'Queja'),
(5, 'Sugerencia'),
(6, 'Pregunta');


SELECT pg_catalog.setval('id_tipo_motivo_seq', 6, true);


INSERT INTO tipo_cita (id_tipo_cita, nombre)
VALUES (1, 'Diagnostico'),
(2, 'Control'),
(3, 'Reprogramada');


SELECT pg_catalog.setval('id_tipo_cita_seq', 3, true);


INSERT INTO tipo_orden (id_tipo_orden, nombre)
VALUES (1, 'Normal'),
(2, 'Garantía'),
(3, 'Promoción');


SELECT pg_catalog.setval('id_tipo_orden_seq', 3, true);


INSERT INTO motivo(id_motivo, id_tipo_motivo, descripcion)
VALUES (1, 1, 'Alcanzar peso ideal'),
(2, 1, 'Control de patología'),
(3, 1, 'Entrenamiento para atletas');


SELECT pg_catalog.setval('id_motivo_seq', 3, true);


INSERT INTO tipo_unidad (id_tipo_unidad, nombre)
VALUES (1, 'Masa'),
(2, 'Moneda'),
(3,	'Tiempo');


SELECT pg_catalog.setval('id_tipo_unidad_seq', 3, true);


INSERT INTO unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, simbolo) 
VALUES (1, 1, 'Gramo', 'gr', 'gr'),
(3, 2, 'Bolivares Fuertes', 'VEF', 'BsF'),
(4,	1, 'Tonelada', 'ton', 'ton'),
(5, 1, 'Kilogramo', 'Kg', 'Kg'),
(6, 1,  'Miligramo', 'mg',  'mg'),
(7, 3,  'Hora', 'h', 'h'),
(8, 3,  'Minuto', 'min', 'm'),
(9, 3,  'Segundo', 'seg', 's'),
(10, 2, 'Dólar estadounidense', 'USD', '$');


SELECT pg_catalog.setval('id_unidad_seq', 10, true);


INSERT INTO usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, ultimo_acceso, id_rol)
VALUES (1, 'jguerrero', 'guerrero.c.jose.a@gmail.com', '$2a$12$Zsfm7hKFFwzszEOGSuOS7ePL179wk2RfxNBObxu.Un/gZtVjHunj6', '$2a$12$Zsfm7hKFFwzszEOGSuOS7e', null, null);


SELECT pg_catalog.setval('id_usuario_seq', 1, true);


--
-- Name: agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (id_agenda);


--
-- Name: alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_pkey PRIMARY KEY (id_alimento);


--
-- Name: app_movil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY app_movil
    ADD CONSTRAINT app_movil_pkey PRIMARY KEY (id_app_movil);


--
-- Name: bloque_horario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bloque_horario
    ADD CONSTRAINT bloque_horario_pkey PRIMARY KEY (id_bloque_horario);


--
-- Name: calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_pkey PRIMARY KEY (id_criterio, id_valoracion, id_visita, id_orden_servicio);


--
-- Name: cita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_pkey PRIMARY KEY (id_comentario);


--
-- Name: comida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comida
    ADD CONSTRAINT comida_pkey PRIMARY KEY (id_comida);


--
-- Name: condicion_garantia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY condicion_garantia
    ADD CONSTRAINT condicion_garantia_pkey PRIMARY KEY (id_condicion_garantia);


--
-- Name: contenido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contenido
    ADD CONSTRAINT contenido_pkey PRIMARY KEY (id_contenido);


--
-- Name: criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_pkey PRIMARY KEY (id_criterio);


--
-- Name: detalle_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_pkey PRIMARY KEY (id_detalle_plan_dieta);


--
-- Name: detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- Name: detalle_regimen_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_pkey PRIMARY KEY (id_regimen_dieta, id_alimento);


--
-- Name: detalle_visita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_pkey PRIMARY KEY (id_visita, id_parametro);


--
-- Name: dia_laborable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dia_laborable
    ADD CONSTRAINT dia_laborable_pkey PRIMARY KEY (id_dia_laborable);


--
-- Name: ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ejercicio
    ADD CONSTRAINT ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);


--
-- Name: especialidad_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_pkey PRIMARY KEY (id_empleado, id_especialidad);


--
-- Name: especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: especialidad_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_pkey PRIMARY KEY (id_servicio, id_especialidad);


--
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- Name: frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- Name: funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_pkey PRIMARY KEY (id_funcionalidad);


--
-- Name: garantia_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_pkey PRIMARY KEY (id_condicion_garantia, id_servicio);


--
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- Name: grupo_alimenticio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_pkey PRIMARY KEY (id_grupo_alimenticio);


--
-- Name: horario_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_pkey PRIMARY KEY (id_empleado, id_bloque_horario, id_dia_laborable);


--
-- Name: id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_pkey PRIMARY KEY (id_incidencia);


--
-- Name: motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY motivo
    ADD CONSTRAINT motivo_pkey PRIMARY KEY (id_motivo);


--
-- Name: negocio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY negocio
    ADD CONSTRAINT negocio_pkey PRIMARY KEY (id_negocio);


--
-- Name: orden_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_pkey PRIMARY KEY (id_orden_servicio);


--
-- Name: parametro_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_pkey PRIMARY KEY (id_cliente, id_parametro);


--
-- Name: parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_pkey PRIMARY KEY (id_parametro);


--
-- Name: parametro_promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_promocion
    ADD CONSTRAINT parametro_promocion_pkey PRIMARY KEY (id_parametro, id_promocion);


--
-- Name: parametro_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_pkey PRIMARY KEY (id_servicio, id_parametro);


--
-- Name: plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- Name: plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- Name: plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- Name: precio_id_precio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY precio
    ADD CONSTRAINT precio_id_precio_pkey PRIMARY KEY (id_precio);


--
-- Name: preferencia_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_pkey PRIMARY KEY (id_cliente, id_especialidad);


--
-- Name: promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);


--
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- Name: reclamo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_pkey PRIMARY KEY (id_reclamo);


--
-- Name: red_social_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY red_social
    ADD CONSTRAINT red_social_pkey PRIMARY KEY (id_red_social);


--
-- Name: regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- Name: regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- Name: regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- Name: respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (id_respuesta);


--
-- Name: rol_funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_pkey PRIMARY KEY (id_rol, id_funcionalidad);


--
-- Name: rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);


--
-- Name: slide_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY slide
    ADD CONSTRAINT slide_pkey PRIMARY KEY (id_slide);


--
-- Name: solicitud_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_pkey PRIMARY KEY (id_solicitud_servicio);


--
-- Name: suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- Name: tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tiempo
    ADD CONSTRAINT tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- Name: tipo_cita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_cita
    ADD CONSTRAINT tipo_cita_pkey PRIMARY KEY (id_tipo_cita);


--
-- Name: tipo_comentario_id_tipo_comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_comentario
    ADD CONSTRAINT tipo_comentario_id_tipo_comentario_pkey PRIMARY KEY (id_tipo_comentario);


--
-- Name: tipo_criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_criterio
    ADD CONSTRAINT tipo_criterio_pkey PRIMARY KEY (id_tipo_criterio);


--
-- Name: tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_dieta
    ADD CONSTRAINT tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- Name: tipo_incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_incidencia
    ADD CONSTRAINT tipo_incidencia_pkey PRIMARY KEY (id_tipo_incidencia);


--
-- Name: tipo_motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_motivo
    ADD CONSTRAINT tipo_motivo_pkey PRIMARY KEY (id_tipo_motivo);


--
-- Name: tipo_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_orden
    ADD CONSTRAINT tipo_orden_pkey PRIMARY KEY (id_tipo_orden);


--
-- Name: tipo_parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_parametro
    ADD CONSTRAINT tipo_parametro_pkey PRIMARY KEY (id_tipo_parametro);


--
-- Name: tipo_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_respuesta
    ADD CONSTRAINT tipo_respuesta_pkey PRIMARY KEY (id_tipo_respuesta);


--
-- Name: tipo_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_unidad
    ADD CONSTRAINT tipo_unidad_pkey PRIMARY KEY (id_tipo_unidad);


--
-- Name: tipo_valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_valoracion
    ADD CONSTRAINT tipo_valoracion_pkey PRIMARY KEY (id_tipo_valoracion);


--
-- Name: unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (id_unidad);


--
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY valoracion
    ADD CONSTRAINT valoracion_pkey PRIMARY KEY (id_valoracion);


--
-- Name: visita_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY visita
    ADD CONSTRAINT visita_pkey PRIMARY KEY (id_visita);


--
-- Name: fki_comentario_id_tipo_comentario_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_comentario_id_tipo_comentario_fkey ON comentario USING btree (id_tipo_comentario);


--
-- Name: fki_incidencia_id_agenda_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_incidencia_id_agenda_fkey ON incidencia USING btree (id_agenda);


--
-- Name: fki_servicio_id_precio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_servicio_id_precio_fkey ON servicio USING btree (id_precio);


--
-- Name: dis_asignar_rango_edad; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_asignar_rango_edad AFTER INSERT ON cliente FOR EACH ROW EXECUTE PROCEDURE fun_asignar_rango_edad();


--
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- Name: agenda_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES cita(id_cita);


--
-- Name: agenda_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: agenda_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: agenda_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: agenda_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: alimento_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: calificacion_id_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_criterio_fkey FOREIGN KEY (id_criterio) REFERENCES criterio(id_criterio);


--
-- Name: calificacion_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: calificacion_id_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_valoracion_fkey FOREIGN KEY (id_valoracion) REFERENCES valoracion(id_valoracion);


--
-- Name: calificacion_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: cita_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES bloque_horario(id_bloque_horario);


--
-- Name: cita_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: cita_id_tipo_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_tipo_cita_fkey FOREIGN KEY (id_tipo_cita) REFERENCES tipo_cita(id_tipo_cita);


--
-- Name: cliente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil);


--
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- Name: cliente_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- Name: comentario_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: comentario_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: comentario_id_tipo_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_tipo_comentario_fkey FOREIGN KEY (id_tipo_comentario) REFERENCES tipo_comentario(id_tipo_comentario);


--
-- Name: criterio_id_tipo_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_id_tipo_criterio_fkey FOREIGN KEY (id_tipo_criterio) REFERENCES tipo_criterio(id_tipo_criterio);


--
-- Name: criterio_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES tipo_valoracion(id_tipo_valoracion);


--
-- Name: detalle_plan_dieta_id_comida_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_comida_fkey FOREIGN KEY (id_comida) REFERENCES comida(id_comida);


--
-- Name: detalle_plan_dieta_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: detalle_plan_dieta_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- Name: detalle_plan_ejercicio_id_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES ejercicio(id_ejercicio);


--
-- Name: detalle_plan_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: detalle_plan_suplemento_id_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES suplemento(id_suplemento);


--
-- Name: detalle_regimen_alimento_id_alimento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_alimento_fkey FOREIGN KEY (id_alimento) REFERENCES alimento(id_alimento);


--
-- Name: detalle_regimen_alimento_id_regimen_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_regimen_dieta_fkey FOREIGN KEY (id_regimen_dieta) REFERENCES regimen_dieta(id_regimen_dieta);


--
-- Name: detalle_visita_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: detalle_visita_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: empleado_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- Name: empleado_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- Name: especialidad_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: especialidad_empleado_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: especialidad_servicio_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: especialidad_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: frecuencia_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- Name: funcionalidad_id_funcionalidad_padre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_id_funcionalidad_padre_fkey FOREIGN KEY (id_funcionalidad_padre) REFERENCES funcionalidad(id_funcionalidad);


--
-- Name: garantia_servicio_id_condicion_garantia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_condicion_garantia_fkey FOREIGN KEY (id_condicion_garantia) REFERENCES condicion_garantia(id_condicion_garantia);


--
-- Name: garantia_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: grupo_alimenticio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: horario_empleado_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES bloque_horario(id_bloque_horario);


--
-- Name: horario_empleado_id_dia_laborable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_dia_laborable_fkey FOREIGN KEY (id_dia_laborable) REFERENCES dia_laborable(id_dia_laborable);


--
-- Name: horario_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: incidencia_id_agenda_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_agenda_fkey FOREIGN KEY (id_agenda) REFERENCES agenda(id_agenda);


--
-- Name: incidencia_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: incidencia_id_tipo_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_tipo_incidencia_fkey FOREIGN KEY (id_tipo_incidencia) REFERENCES tipo_incidencia(id_tipo_incidencia);


--
-- Name: motivo_id_tipo_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY motivo
    ADD CONSTRAINT motivo_id_tipo_motivo_fkey FOREIGN KEY (id_tipo_motivo) REFERENCES tipo_motivo(id_tipo_motivo);


--
-- Name: orden_servicio_id_reclamo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_reclamo_fkey FOREIGN KEY (id_reclamo) REFERENCES reclamo(id_reclamo);


--
-- Name: orden_servicio_id_solicitud_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_solicitud_servicio_fkey FOREIGN KEY (id_solicitud_servicio) REFERENCES solicitud_servicio(id_solicitud_servicio);


--
-- Name: orden_servicio_id_tipo_orden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_tipo_orden_fkey FOREIGN KEY (id_tipo_orden) REFERENCES tipo_orden(id_tipo_orden);


--
-- Name: parametro_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: parametro_cliente_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: parametro_servicio_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: parametro_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: parametro_tipo_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_tipo_parametro_fkey FOREIGN KEY (id_tipo_parametro) REFERENCES tipo_parametro(id_tipo_parametro);


--
-- Name: parametro_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: plan_dieta_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES tipo_dieta(id_tipo_dieta);


--
-- Name: precio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY precio
    ADD CONSTRAINT precio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: preferencia_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: preferencia_cliente_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: promocion_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: reclamo_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: reclamo_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: reclamo_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_dieta_id_detalle_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_detalle_plan_dieta_fkey FOREIGN KEY (id_detalle_plan_dieta) REFERENCES detalle_plan_dieta(id_detalle_plan_dieta);


--
-- Name: regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_ejercicio_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- Name: regimen_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: regimen_ejercicio_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- Name: regimen_suplemento_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_suplemento_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- Name: regimen_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: respuesta_id_tipo_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_id_tipo_respuesta_fkey FOREIGN KEY (id_tipo_respuesta) REFERENCES tipo_respuesta(id_tipo_respuesta);


--
-- Name: rol_funcionalidad_id_funcionalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_funcionalidad_fkey FOREIGN KEY (id_funcionalidad) REFERENCES funcionalidad(id_funcionalidad);


--
-- Name: rol_funcionalidad_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES rol(id_rol);


--
-- Name: servicio_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- Name: servicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: servicio_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: servicio_id_precio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_precio_fkey FOREIGN KEY (id_precio) REFERENCES precio(id_precio);


--
-- Name: solicitud_servicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: solicitud_servicio_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: solicitud_servicio_id_promocion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_promocion_fkey FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion);


--
-- Name: solicitud_servicio_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: solicitud_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: unidad_tipo_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_tipo_unidad_fkey FOREIGN KEY (id_tipo_unidad) REFERENCES tipo_unidad(id_tipo_unidad);


--
-- Name: usuario_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES rol(id_rol);


--
-- Name: valoracion_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
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

