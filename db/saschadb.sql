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
-- Name: fun_asignar_rango_edad(); Type: FUNCTION; Schema: public; Owner: leo
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


ALTER FUNCTION public.fun_asignar_rango_edad() OWNER TO leo;

--
-- Name: fun_eliminar_cliente(); Type: FUNCTION; Schema: public; Owner: leo
--

CREATE FUNCTION fun_eliminar_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
	UPDATE cliente SET estatus = 0 WHERE cliente.id_usuario = OLD.id_usuario;
	RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_eliminar_cliente() OWNER TO leo;

--
-- Name: id_agenda_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_agenda_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_agenda_seq OWNER TO leo;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agenda; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE agenda (
    id_agenda integer DEFAULT nextval('id_agenda_seq'::regclass) NOT NULL,
    id_empleado integer NOT NULL,
    id_cliente integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    id_visita integer,
    id_incidencia integer,
    id_cita integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE agenda OWNER TO leo;

--
-- Name: id_alimento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_alimento_seq OWNER TO leo;

--
-- Name: alimento; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE alimento (
    id_alimento integer DEFAULT nextval('id_alimento_seq'::regclass) NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE alimento OWNER TO leo;

--
-- Name: id_app_movil_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_app_movil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_app_movil_seq OWNER TO leo;

--
-- Name: app_movil; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE app_movil (
    id_app_movil integer DEFAULT nextval('id_app_movil_seq'::regclass) NOT NULL,
    sistema_operativo character varying(50) DEFAULT ''::character varying NOT NULL,
    url_descarga character varying(500) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE app_movil OWNER TO leo;

--
-- Name: id_bloque_horario_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_bloque_horario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_bloque_horario_seq OWNER TO leo;

--
-- Name: bloque_horario; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE bloque_horario (
    id_bloque_horario integer DEFAULT nextval('id_bloque_horario_seq'::regclass) NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE bloque_horario OWNER TO leo;

--
-- Name: calificacion; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE calificacion (
    id_criterio integer NOT NULL,
    id_valoracion integer NOT NULL,
    id_visita integer NOT NULL,
    id_orden_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE calificacion OWNER TO leo;

--
-- Name: id_cita_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_cita_seq OWNER TO leo;

--
-- Name: cita; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE cita OWNER TO leo;

--
-- Name: id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_cliente_seq OWNER TO leo;

--
-- Name: cliente; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE cliente OWNER TO leo;

--
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- Name: id_comentario_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_comentario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_comentario_seq OWNER TO leo;

--
-- Name: comentario; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE comentario OWNER TO leo;

--
-- Name: id_comida_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_comida_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_comida_seq OWNER TO leo;

--
-- Name: comida; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE comida (
    id_comida integer DEFAULT nextval('id_comida_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE comida OWNER TO leo;

--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_condicion_garantia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_condicion_garantia_seq OWNER TO leo;

--
-- Name: condicion_garantia; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE condicion_garantia (
    id_condicion_garantia integer DEFAULT nextval('id_condicion_garantia_seq'::regclass) NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE condicion_garantia OWNER TO leo;

--
-- Name: id_contenido_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_contenido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_contenido_seq OWNER TO leo;

--
-- Name: contenido; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE contenido OWNER TO leo;

--
-- Name: id_criterio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_criterio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_criterio_seq OWNER TO leo;

--
-- Name: criterio; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE criterio OWNER TO leo;

--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_detalle_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_dieta_seq OWNER TO leo;

--
-- Name: detalle_plan_dieta; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE detalle_plan_dieta OWNER TO leo;

--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_detalle_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_ejercicio_seq OWNER TO leo;

--
-- Name: detalle_plan_ejercicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE detalle_plan_ejercicio (
    id_detalle_plan_ejercicio integer DEFAULT nextval('id_detalle_plan_ejercicio_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_ejercicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_ejercicio OWNER TO leo;

--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_detalle_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_plan_suplemento_seq OWNER TO leo;

--
-- Name: detalle_plan_suplemento; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE detalle_plan_suplemento (
    id_detalle_plan_suplemento integer DEFAULT nextval('id_detalle_plan_suplemento_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_suplemento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_suplemento OWNER TO leo;

--
-- Name: detalle_regimen_alimento; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE detalle_regimen_alimento (
    id_regimen_dieta integer NOT NULL,
    id_alimento integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_regimen_alimento OWNER TO leo;

--
-- Name: detalle_visita; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE detalle_visita (
    id_visita integer NOT NULL,
    id_parametro integer NOT NULL,
    valor numeric(12,4),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_visita OWNER TO leo;

--
-- Name: id_dia_laborable_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_dia_laborable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_dia_laborable_seq OWNER TO leo;

--
-- Name: dia_laborable; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE dia_laborable (
    id_dia_laborable integer DEFAULT nextval('id_dia_laborable_seq'::regclass) NOT NULL,
    dia character varying(20) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE dia_laborable OWNER TO leo;

--
-- Name: id_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_ejercicio_seq OWNER TO leo;

--
-- Name: ejercicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE ejercicio (
    id_ejercicio integer DEFAULT nextval('id_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE ejercicio OWNER TO leo;

--
-- Name: id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_empleado_seq OWNER TO leo;

--
-- Name: empleado; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE empleado OWNER TO leo;

--
-- Name: id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_especialidad_seq OWNER TO leo;

--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE especialidad (
    id_especialidad integer DEFAULT nextval('id_especialidad_seq'::regclass) NOT NULL,
    nombre character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE especialidad OWNER TO leo;

--
-- Name: especialidad_empleado; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE especialidad_empleado (
    id_empleado integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE especialidad_empleado OWNER TO leo;

--
-- Name: especialidad_servicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE especialidad_servicio (
    id_servicio integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE especialidad_servicio OWNER TO leo;

--
-- Name: id_estado_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_estado_seq OWNER TO leo;

--
-- Name: estado; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE estado (
    id_estado integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE estado OWNER TO leo;

--
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE estado_civil (
    id_estado_civil integer NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO leo;

--
-- Name: id_frecuencia_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_frecuencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_frecuencia_seq OWNER TO leo;

--
-- Name: frecuencia; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE frecuencia (
    id_frecuencia integer DEFAULT nextval('id_frecuencia_seq'::regclass) NOT NULL,
    id_tiempo integer NOT NULL,
    repeticiones integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE frecuencia OWNER TO leo;

--
-- Name: id_funcionalidad_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_funcionalidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_funcionalidad_seq OWNER TO leo;

--
-- Name: funcionalidad; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE funcionalidad OWNER TO leo;

--
-- Name: garantia_servicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE garantia_servicio (
    id_condicion_garantia integer NOT NULL,
    id_servicio integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE garantia_servicio OWNER TO leo;

--
-- Name: genero; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE genero (
    id_genero integer NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO leo;

--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_grupo_alimenticio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_grupo_alimenticio_seq OWNER TO leo;

--
-- Name: grupo_alimenticio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE grupo_alimenticio (
    id_grupo_alimenticio integer DEFAULT nextval('id_grupo_alimenticio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE grupo_alimenticio OWNER TO leo;

--
-- Name: horario_empleado; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE horario_empleado (
    id_empleado integer NOT NULL,
    id_bloque_horario integer NOT NULL,
    id_dia_laborable integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE horario_empleado OWNER TO leo;

--
-- Name: id_calificacion_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_calificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_calificacion_seq OWNER TO leo;

--
-- Name: id_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_incidencia_seq OWNER TO leo;

--
-- Name: id_motivo_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_motivo_seq OWNER TO leo;

--
-- Name: id_orden_servicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_orden_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_orden_servicio_seq OWNER TO leo;

--
-- Name: id_parametro_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_parametro_seq OWNER TO leo;

--
-- Name: id_plan_dieta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_plan_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_dieta_seq OWNER TO leo;

--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_plan_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_ejercicio_seq OWNER TO leo;

--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_plan_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_plan_suplemento_seq OWNER TO leo;

--
-- Name: id_promocion_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_promocion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_promocion_seq OWNER TO leo;

--
-- Name: id_rango_edad_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_rango_edad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rango_edad_seq OWNER TO leo;

--
-- Name: id_reclamo_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_reclamo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_reclamo_seq OWNER TO leo;

--
-- Name: id_red_social_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_red_social_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_red_social_seq OWNER TO leo;

--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_regimen_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_dieta_seq OWNER TO leo;

--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_regimen_ejercicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_ejercicio_seq OWNER TO leo;

--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_regimen_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_regimen_suplemento_seq OWNER TO leo;

--
-- Name: id_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_respuesta_seq OWNER TO leo;

--
-- Name: id_rol_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rol_seq OWNER TO leo;

--
-- Name: id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_servicio_seq OWNER TO leo;

--
-- Name: id_slide_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_slide_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_slide_seq OWNER TO leo;

--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_solicitud_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_solicitud_servicio_seq OWNER TO leo;

--
-- Name: id_suplemento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_suplemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_suplemento_seq OWNER TO leo;

--
-- Name: id_tiempo_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tiempo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tiempo_seq OWNER TO leo;

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
-- Name: id_tipo_dieta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_dieta_seq OWNER TO leo;

--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_incidencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_incidencia_seq OWNER TO leo;

--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_motivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_motivo_seq OWNER TO leo;

--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_parametro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_parametro_seq OWNER TO leo;

--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_respuesta_seq OWNER TO leo;

--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_unidad_seq OWNER TO leo;

--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_tipo_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_tipo_valoracion_seq OWNER TO leo;

--
-- Name: id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_unidad_seq OWNER TO leo;

--
-- Name: id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_usuario_seq OWNER TO leo;

--
-- Name: id_valoracion_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_valoracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_valoracion_seq OWNER TO leo;

--
-- Name: id_visita_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_visita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_visita_seq OWNER TO leo;

--
-- Name: incidencia; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE incidencia OWNER TO leo;

--
-- Name: motivo; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE motivo (
    id_motivo integer DEFAULT nextval('id_motivo_seq'::regclass) NOT NULL,
    id_tipo_motivo integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE motivo OWNER TO leo;

--
-- Name: negocio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE negocio (
    id_negocio integer NOT NULL,
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


ALTER TABLE negocio OWNER TO leo;

--
-- Name: orden_servicio; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE orden_servicio OWNER TO leo;

--
-- Name: parametro; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE parametro OWNER TO leo;

--
-- Name: COLUMN parametro.tipo_valor; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN parametro.tipo_valor IS '1: Nominal  2: Numerico';


--
-- Name: parametro_cliente; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE parametro_cliente (
    id_cliente integer NOT NULL,
    id_parametro integer NOT NULL,
    valor numeric(12,4),
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE parametro_cliente OWNER TO leo;

--
-- Name: parametro_promocion; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE parametro_promocion (
    id_parametro integer NOT NULL,
    id_promocion integer NOT NULL,
    valor_minimo integer,
    valor_maximo integer,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE parametro_promocion OWNER TO leo;

--
-- Name: parametro_servicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE parametro_servicio (
    id_servicio integer NOT NULL,
    id_parametro integer NOT NULL,
    valor_minimo integer NOT NULL,
    valor_maximo integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE parametro_servicio OWNER TO leo;

--
-- Name: plan_dieta; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE plan_dieta OWNER TO leo;

--
-- Name: plan_ejercicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE plan_ejercicio (
    id_plan_ejercicio integer DEFAULT nextval('id_plan_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_ejercicio OWNER TO leo;

--
-- Name: plan_suplemento; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE plan_suplemento (
    id_plan_suplemento integer DEFAULT nextval('id_plan_suplemento_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_suplemento OWNER TO leo;

--
-- Name: preferencia_cliente; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE preferencia_cliente (
    id_cliente integer NOT NULL,
    id_especialidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE preferencia_cliente OWNER TO leo;

--
-- Name: promocion; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE promocion OWNER TO leo;

--
-- Name: COLUMN promocion.id_estado_civil; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN promocion.id_estado_civil IS '
';


--
-- Name: rango_edad; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE rango_edad OWNER TO leo;

--
-- Name: reclamo; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE reclamo OWNER TO leo;

--
-- Name: red_social; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE red_social OWNER TO leo;

--
-- Name: regimen_dieta; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE regimen_dieta OWNER TO leo;

--
-- Name: regimen_ejercicio; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE regimen_ejercicio OWNER TO leo;

--
-- Name: regimen_suplemento; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE regimen_suplemento OWNER TO leo;

--
-- Name: respuesta; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE respuesta (
    id_respuesta integer DEFAULT nextval('id_respuesta_seq'::regclass) NOT NULL,
    id_tipo_respuesta integer NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE respuesta OWNER TO leo;

--
-- Name: rol; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE rol (
    id_rol integer DEFAULT nextval('id_rol_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(150) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE rol OWNER TO leo;

--
-- Name: rol_funcionalidad; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE rol_funcionalidad (
    id_rol integer NOT NULL,
    id_funcionalidad integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE rol_funcionalidad OWNER TO leo;

--
-- Name: servicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE servicio (
    id_servicio integer DEFAULT nextval('id_servicio_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_plan_suplemento integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(50) DEFAULT ''::character varying NOT NULL,
    precio integer NOT NULL,
    numero_visitas integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE servicio OWNER TO leo;

--
-- Name: slide; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE slide OWNER TO leo;

--
-- Name: solicitud_servicio; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE solicitud_servicio OWNER TO leo;

--
-- Name: suplemento; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE suplemento (
    id_suplemento integer DEFAULT nextval('id_suplemento_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE suplemento OWNER TO leo;

--
-- Name: tiempo; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tiempo (
    id_tiempo integer DEFAULT nextval('id_tiempo_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tiempo OWNER TO leo;

--
-- Name: tipo_cita; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_cita (
    id_tipo_cita integer DEFAULT nextval('id_tipo_cita_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_cita OWNER TO leo;

--
-- Name: tipo_criterio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_criterio (
    id_tipo_criterio integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE tipo_criterio OWNER TO leo;

--
-- Name: tipo_dieta; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_dieta (
    id_tipo_dieta integer DEFAULT nextval('id_tipo_dieta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_dieta OWNER TO leo;

--
-- Name: tipo_incidencia; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_incidencia (
    id_tipo_incidencia integer DEFAULT nextval('id_tipo_incidencia_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_incidencia OWNER TO leo;

--
-- Name: tipo_motivo; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_motivo (
    id_tipo_motivo integer DEFAULT nextval('id_tipo_motivo_seq'::regclass) NOT NULL,
    nombre character(50) DEFAULT ''::bpchar NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_motivo OWNER TO leo;

--
-- Name: tipo_orden; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_orden (
    id_tipo_orden integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE tipo_orden OWNER TO leo;

--
-- Name: tipo_parametro; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_parametro (
    id_tipo_parametro integer DEFAULT nextval('id_tipo_parametro_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_parametro OWNER TO leo;

--
-- Name: tipo_respuesta; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_respuesta (
    id_tipo_respuesta integer DEFAULT nextval('id_tipo_respuesta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_respuesta OWNER TO leo;

--
-- Name: tipo_unidad; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_unidad (
    id_tipo_unidad integer DEFAULT nextval('id_tipo_unidad_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_unidad OWNER TO leo;

--
-- Name: tipo_valoracion; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_valoracion (
    id_tipo_valoracion integer DEFAULT nextval('id_valoracion_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_valoracion OWNER TO leo;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE unidad (
    id_unidad integer DEFAULT nextval('id_unidad_seq'::regclass) NOT NULL,
    id_tipo_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE unidad OWNER TO leo;

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: leo
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


ALTER TABLE usuario OWNER TO leo;

--
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo 0: Eliminado';


--
-- Name: valoracion; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE valoracion (
    id_valoracion integer DEFAULT nextval('id_valoracion_seq'::regclass) NOT NULL,
    id_tipo_valoracion integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE valoracion OWNER TO leo;

--
-- Name: visita; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE visita (
    id_visita integer DEFAULT nextval('id_visita_seq'::regclass) NOT NULL,
    numero integer NOT NULL,
    fecha_atencion date NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE visita OWNER TO leo;

--
-- Name: vista_cliente; Type: VIEW; Schema: public; Owner: leo
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


ALTER TABLE vista_cliente OWNER TO leo;

--
-- Data for Name: agenda; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY agenda (id_agenda, id_empleado, id_cliente, id_orden_servicio, id_visita, id_incidencia, id_cita, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: app_movil; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY app_movil (id_app_movil, sistema_operativo, url_descarga, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: bloque_horario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY bloque_horario (id_bloque_horario, hora_inicio, hora_fin, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: calificacion; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY calificacion (id_criterio, id_valoracion, id_visita, id_orden_servicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY cita (id_cita, id_orden_servicio, id_tipo_cita, id_bloque_horario, fecha, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	2	1	3	V-24160052	Jose Alberto	Guerrero Carrillo	0414-5495292	Urb. El Amanecer, Cabudare	1994-06-07	1	\N	2018-04-19 22:12:23.435	2018-04-19 22:12:23.435	1
\.


--
-- Data for Name: comentario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY comentario (id_comentario, id_cliente, id_respuesta, contenido, respuesta, id_tipo_comentario, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: condicion_garantia; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY condicion_garantia (id_condicion_garantia, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: contenido; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY contenido (id_contenido, titulo, texto, url_imagen, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: criterio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY criterio (id_criterio, id_tipo_criterio, id_tipo_valoracion, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_plan_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY detalle_plan_dieta (id_detalle_plan_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_visita; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY detalle_visita (id_visita, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: dia_laborable; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY dia_laborable (id_dia_laborable, dia, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: empleado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY empleado (id_empleado, id_usuario, id_genero, cedula, nombres, apellidos, telefono, correo, direccion, estatus, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY especialidad (id_especialidad, nombre, fecha_actualizacion, fecha_creacion, estatus) FROM stdin;
\.


--
-- Data for Name: especialidad_empleado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY especialidad_empleado (id_empleado, id_especialidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: especialidad_servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY especialidad_servicio (id_servicio, id_especialidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: leo
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
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY estado_civil (id_estado_civil, nombre) FROM stdin;
2	Comprometido/a
1	Soltero/a
4	Divorciado/a
3	Casado/a
5	Viudo/a
\.


--
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: funcionalidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY funcionalidad (id_funcionalidad, id_funcionalidad_padre, nombre, icono, orden, nivel, estatus, url_vista) FROM stdin;
\.


--
-- Data for Name: garantia_servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY garantia_servicio (id_condicion_garantia, id_servicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY genero (id_genero, nombre) FROM stdin;
2	Femenino
1	Masculino
\.


--
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: horario_empleado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY horario_empleado (id_empleado, id_bloque_horario, id_dia_laborable, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Name: id_agenda_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_agenda_seq', 1, false);


--
-- Name: id_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_alimento_seq', 1, false);


--
-- Name: id_app_movil_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_app_movil_seq', 1, false);


--
-- Name: id_bloque_horario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_bloque_horario_seq', 1, false);


--
-- Name: id_calificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_calificacion_seq', 1, false);


--
-- Name: id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_cita_seq', 1, false);


--
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_cliente_seq', 1, true);


--
-- Name: id_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_comentario_seq', 1, false);


--
-- Name: id_comida_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_comida_seq', 1, false);


--
-- Name: id_condicion_garantia_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_condicion_garantia_seq', 1, false);


--
-- Name: id_contenido_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_contenido_seq', 1, false);


--
-- Name: id_criterio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_criterio_seq', 1, false);


--
-- Name: id_detalle_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_dieta_seq', 1, false);


--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_ejercicio_seq', 1, false);


--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_suplemento_seq', 1, false);


--
-- Name: id_dia_laborable_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_dia_laborable_seq', 1, false);


--
-- Name: id_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_ejercicio_seq', 1, false);


--
-- Name: id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_empleado_seq', 1, false);


--
-- Name: id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_especialidad_seq', 1, false);


--
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_seq', 8, true);


--
-- Name: id_frecuencia_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_frecuencia_seq', 1, false);


--
-- Name: id_funcionalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_funcionalidad_seq', 1, false);


--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_grupo_alimenticio_seq', 1, false);


--
-- Name: id_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_incidencia_seq', 1, false);


--
-- Name: id_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_motivo_seq', 1, false);


--
-- Name: id_orden_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_orden_servicio_seq', 1, false);


--
-- Name: id_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_parametro_seq', 1, false);


--
-- Name: id_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_dieta_seq', 1, true);


--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_ejercicio_seq', 1, false);


--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_suplemento_seq', 1, false);


--
-- Name: id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_promocion_seq', 1, false);


--
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_rango_edad_seq', 5, true);


--
-- Name: id_reclamo_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_reclamo_seq', 1, false);


--
-- Name: id_red_social_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_red_social_seq', 1, false);


--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_dieta_seq', 1, false);


--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_ejercicio_seq', 1, false);


--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_suplemento_seq', 1, false);


--
-- Name: id_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_respuesta_seq', 1, false);


--
-- Name: id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_rol_seq', 1, false);


--
-- Name: id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_servicio_seq', 1, false);


--
-- Name: id_slide_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_slide_seq', 1, false);


--
-- Name: id_solicitud_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_solicitud_servicio_seq', 1, false);


--
-- Name: id_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_suplemento_seq', 1, false);


--
-- Name: id_tiempo_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tiempo_seq', 1, false);


--
-- Name: id_tipo_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_tipo_cita_seq', 1, true);


--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_dieta_seq', 1, true);


--
-- Name: id_tipo_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_incidencia_seq', 1, false);


--
-- Name: id_tipo_motivo_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_motivo_seq', 1, false);


--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_parametro_seq', 1, false);


--
-- Name: id_tipo_respuesta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_respuesta_seq', 1, false);


--
-- Name: id_tipo_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_unidad_seq', 1, false);


--
-- Name: id_tipo_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_valoracion_seq', 1, false);


--
-- Name: id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_unidad_seq', 1, false);


--
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_usuario_seq', 1, true);


--
-- Name: id_valoracion_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_valoracion_seq', 1, false);


--
-- Name: id_visita_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_visita_seq', 1, false);


--
-- Data for Name: incidencia; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY incidencia (id_incidencia, id_tipo_incidencia, id_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus, id_agenda) FROM stdin;
\.


--
-- Data for Name: motivo; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY motivo (id_motivo, id_tipo_motivo, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: negocio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY negocio (id_negocio, razon_social, rif, url_logo, mision, vision, objetivo, telefono, correo, latitud, longitud, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: orden_servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY orden_servicio (id_orden_servicio, id_solicitud_servicio, id_tipo_orden, id_meta, fecha_emision, fecha_caducidad, id_reclamo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: parametro; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY parametro (id_parametro, id_tipo_parametro, id_unidad, tipo_valor, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: parametro_cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY parametro_cliente (id_cliente, id_parametro, valor, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: parametro_promocion; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY parametro_promocion (id_parametro, id_promocion, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: parametro_servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY parametro_servicio (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: preferencia_cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY preferencia_cliente (id_cliente, id_especialidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: promocion; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY promocion (id_promocion, id_servicio, nombre, descripcion, valido_desde, valido_hasta, id_genero, id_estado_civil, id_rango_edad, id_estado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Bebe	0	1	2018-04-19 21:11:06.606	2018-04-19 21:11:06.606	1
2	Niño/a	1	12	2018-04-19 21:11:19.305	2018-04-19 21:11:19.305	1
3	Joven 	12	30	2018-04-19 21:11:32.739	2018-04-19 21:11:32.739	1
4	Adulto	30	60	2018-04-19 21:11:41.765	2018-04-19 21:11:41.765	1
5	Adulto mayor	60	120	2018-04-19 21:12:03.981	2018-04-19 21:12:03.981	1
\.


--
-- Data for Name: reclamo; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY reclamo (id_reclamo, id_motivo, id_orden_servicio, id_respuesta, respuesta, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: red_social; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY red_social (id_red_social, nombre, url_base, url_logo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_dieta (id_regimen_dieta, id_detalle_plan_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_ejercicio (id_regimen_ejercicio, id_plan_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_suplemento (id_regimen_suplemento, id_plan_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: respuesta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY respuesta (id_respuesta, id_tipo_respuesta, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rol (id_rol, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: rol_funcionalidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rol_funcionalidad (id_rol, id_funcionalidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, precio, numero_visitas, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: slide; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY slide (id_slide, titulo, descripcion, orden, url_imagen, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: solicitud_servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY solicitud_servicio (id_solicitud_servicio, id_cliente, id_motivo, id_respuesta, id_servicio, respuesta, id_promocion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tiempo; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_cita; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_cita (id_tipo_cita, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Inicial	2018-04-26 15:17:34.87	2018-04-26 15:17:58.572	1
\.


--
-- Data for Name: tipo_criterio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_criterio (id_tipo_criterio, nombre) FROM stdin;
\.


--
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Nutricional deportiva	2018-04-26 14:41:11.711	2018-04-26 14:41:11.711	1
\.


--
-- Data for Name: tipo_incidencia; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_incidencia (id_tipo_incidencia, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_motivo; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_motivo (id_tipo_motivo, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_orden; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_orden (id_tipo_orden, nombre) FROM stdin;
\.


--
-- Data for Name: tipo_parametro; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_respuesta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_respuesta (id_tipo_respuesta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_unidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_unidad (id_tipo_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: tipo_valoracion; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_valoracion (id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY unidad (id_unidad, id_tipo_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus, id_rol) FROM stdin;
1	jguerrero	guerrero.c.jose.a@gmail.com	$2a$12$Zsfm7hKFFwzszEOGSuOS7ePL179wk2RfxNBObxu.Un/gZtVjHunj6	$2a$12$Zsfm7hKFFwzszEOGSuOS7e	2018-04-19 22:12:23.435	2018-04-19 22:12:23.435	\N	1	\N
\.


--
-- Data for Name: valoracion; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY valoracion (id_valoracion, id_tipo_valoracion, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: visita; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY visita (id_visita, numero, fecha_atencion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Name: agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (id_agenda);


--
-- Name: alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_pkey PRIMARY KEY (id_alimento);


--
-- Name: app_movil_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY app_movil
    ADD CONSTRAINT app_movil_pkey PRIMARY KEY (id_app_movil);


--
-- Name: bloque_horario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY bloque_horario
    ADD CONSTRAINT bloque_horario_pkey PRIMARY KEY (id_bloque_horario);


--
-- Name: calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_pkey PRIMARY KEY (id_criterio, id_valoracion, id_visita, id_orden_servicio);


--
-- Name: cita_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_pkey PRIMARY KEY (id_comentario);


--
-- Name: comida_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY comida
    ADD CONSTRAINT comida_pkey PRIMARY KEY (id_comida);


--
-- Name: condicion_garantia_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY condicion_garantia
    ADD CONSTRAINT condicion_garantia_pkey PRIMARY KEY (id_condicion_garantia);


--
-- Name: contenido_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY contenido
    ADD CONSTRAINT contenido_pkey PRIMARY KEY (id_contenido);


--
-- Name: criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_pkey PRIMARY KEY (id_criterio);


--
-- Name: detalle_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_pkey PRIMARY KEY (id_detalle_plan_dieta);


--
-- Name: detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- Name: detalle_regimen_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_pkey PRIMARY KEY (id_regimen_dieta, id_alimento);


--
-- Name: detalle_visita_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_pkey PRIMARY KEY (id_visita, id_parametro);


--
-- Name: dia_laborable_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY dia_laborable
    ADD CONSTRAINT dia_laborable_pkey PRIMARY KEY (id_dia_laborable);


--
-- Name: ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY ejercicio
    ADD CONSTRAINT ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);


--
-- Name: especialidad_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_pkey PRIMARY KEY (id_empleado, id_especialidad);


--
-- Name: especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: especialidad_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_pkey PRIMARY KEY (id_servicio, id_especialidad);


--
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- Name: frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- Name: funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_pkey PRIMARY KEY (id_funcionalidad);


--
-- Name: garantia_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_pkey PRIMARY KEY (id_condicion_garantia, id_servicio);


--
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- Name: grupo_alimenticio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_pkey PRIMARY KEY (id_grupo_alimenticio);


--
-- Name: horario_empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_pkey PRIMARY KEY (id_empleado, id_bloque_horario, id_dia_laborable);


--
-- Name: id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_pkey PRIMARY KEY (id_incidencia);


--
-- Name: motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY motivo
    ADD CONSTRAINT motivo_pkey PRIMARY KEY (id_motivo);


--
-- Name: negocio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY negocio
    ADD CONSTRAINT negocio_pkey PRIMARY KEY (id_negocio);


--
-- Name: orden_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_pkey PRIMARY KEY (id_orden_servicio);


--
-- Name: parametro_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_pkey PRIMARY KEY (id_cliente, id_parametro);


--
-- Name: parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_pkey PRIMARY KEY (id_parametro);


--
-- Name: parametro_promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_promocion
    ADD CONSTRAINT parametro_promocion_pkey PRIMARY KEY (id_parametro, id_promocion);


--
-- Name: parametro_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_pkey PRIMARY KEY (id_servicio, id_parametro);


--
-- Name: plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- Name: plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- Name: plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- Name: preferencia_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_pkey PRIMARY KEY (id_cliente, id_especialidad);


--
-- Name: promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);


--
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- Name: reclamo_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_pkey PRIMARY KEY (id_reclamo);


--
-- Name: red_social_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY red_social
    ADD CONSTRAINT red_social_pkey PRIMARY KEY (id_red_social);


--
-- Name: regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- Name: regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- Name: regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- Name: respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (id_respuesta);


--
-- Name: rol_funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_pkey PRIMARY KEY (id_rol, id_funcionalidad);


--
-- Name: rol_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);


--
-- Name: slide_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY slide
    ADD CONSTRAINT slide_pkey PRIMARY KEY (id_slide);


--
-- Name: solicitud_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_pkey PRIMARY KEY (id_solicitud_servicio);


--
-- Name: suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- Name: tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tiempo
    ADD CONSTRAINT tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- Name: tipo_cita_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_cita
    ADD CONSTRAINT tipo_cita_pkey PRIMARY KEY (id_tipo_cita);


--
-- Name: tipo_criterio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_criterio
    ADD CONSTRAINT tipo_criterio_pkey PRIMARY KEY (id_tipo_criterio);


--
-- Name: tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_dieta
    ADD CONSTRAINT tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- Name: tipo_incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_incidencia
    ADD CONSTRAINT tipo_incidencia_pkey PRIMARY KEY (id_tipo_incidencia);


--
-- Name: tipo_motivo_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_motivo
    ADD CONSTRAINT tipo_motivo_pkey PRIMARY KEY (id_tipo_motivo);


--
-- Name: tipo_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_orden
    ADD CONSTRAINT tipo_orden_pkey PRIMARY KEY (id_tipo_orden);


--
-- Name: tipo_parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_parametro
    ADD CONSTRAINT tipo_parametro_pkey PRIMARY KEY (id_tipo_parametro);


--
-- Name: tipo_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_respuesta
    ADD CONSTRAINT tipo_respuesta_pkey PRIMARY KEY (id_tipo_respuesta);


--
-- Name: tipo_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_unidad
    ADD CONSTRAINT tipo_unidad_pkey PRIMARY KEY (id_tipo_unidad);


--
-- Name: tipo_valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_valoracion
    ADD CONSTRAINT tipo_valoracion_pkey PRIMARY KEY (id_tipo_valoracion);


--
-- Name: unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (id_unidad);


--
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: valoracion_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY valoracion
    ADD CONSTRAINT valoracion_pkey PRIMARY KEY (id_valoracion);


--
-- Name: visita_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY visita
    ADD CONSTRAINT visita_pkey PRIMARY KEY (id_visita);


--
-- Name: dis_asignar_rango_edad; Type: TRIGGER; Schema: public; Owner: leo
--

CREATE TRIGGER dis_asignar_rango_edad AFTER INSERT ON cliente FOR EACH ROW EXECUTE PROCEDURE fun_asignar_rango_edad();


--
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: leo
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- Name: agenda_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES cita(id_cita);


--
-- Name: agenda_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: agenda_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: agenda_id_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_incidencia_fkey FOREIGN KEY (id_incidencia) REFERENCES incidencia(id_incidencia);


--
-- Name: agenda_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: agenda_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: alimento_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: calificacion_id_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_criterio_fkey FOREIGN KEY (id_criterio) REFERENCES criterio(id_criterio);


--
-- Name: calificacion_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: calificacion_id_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_valoracion_fkey FOREIGN KEY (id_valoracion) REFERENCES valoracion(id_valoracion);


--
-- Name: calificacion_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY calificacion
    ADD CONSTRAINT calificacion_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: cita_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES bloque_horario(id_bloque_horario);


--
-- Name: cita_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: cita_id_tipo_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cita
    ADD CONSTRAINT cita_id_tipo_cita_fkey FOREIGN KEY (id_tipo_cita) REFERENCES tipo_cita(id_tipo_cita);


--
-- Name: cliente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil);


--
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- Name: cliente_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- Name: comentario_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: comentario_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: comentario_id_tipo_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY comentario
    ADD CONSTRAINT comentario_id_tipo_comentario_fkey FOREIGN KEY (id_tipo_comentario) REFERENCES tipo_motivo(id_tipo_motivo);


--
-- Name: criterio_id_tipo_criterio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_id_tipo_criterio_fkey FOREIGN KEY (id_tipo_criterio) REFERENCES tipo_criterio(id_tipo_criterio);


--
-- Name: criterio_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY criterio
    ADD CONSTRAINT criterio_id_tipo_valoracion_fkey FOREIGN KEY (id_tipo_valoracion) REFERENCES tipo_valoracion(id_tipo_valoracion);


--
-- Name: detalle_plan_dieta_id_comida_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_comida_fkey FOREIGN KEY (id_comida) REFERENCES comida(id_comida);


--
-- Name: detalle_plan_dieta_id_grupo_alimenticio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_grupo_alimenticio_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- Name: detalle_plan_dieta_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_dieta
    ADD CONSTRAINT detalle_plan_dieta_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- Name: detalle_plan_ejercicio_id_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES ejercicio(id_ejercicio);


--
-- Name: detalle_plan_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: detalle_plan_suplemento_id_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES suplemento(id_suplemento);


--
-- Name: detalle_regimen_alimento_id_alimento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_alimento_fkey FOREIGN KEY (id_alimento) REFERENCES alimento(id_alimento);


--
-- Name: detalle_regimen_alimento_id_regimen_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_regimen_alimento
    ADD CONSTRAINT detalle_regimen_alimento_id_regimen_dieta_fkey FOREIGN KEY (id_regimen_dieta) REFERENCES regimen_dieta(id_regimen_dieta);


--
-- Name: detalle_visita_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: detalle_visita_id_visita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY detalle_visita
    ADD CONSTRAINT detalle_visita_id_visita_fkey FOREIGN KEY (id_visita) REFERENCES visita(id_visita);


--
-- Name: empleado_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- Name: empleado_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY empleado
    ADD CONSTRAINT empleado_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- Name: especialidad_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: especialidad_empleado_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad_empleado
    ADD CONSTRAINT especialidad_empleado_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: especialidad_servicio_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: especialidad_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY especialidad_servicio
    ADD CONSTRAINT especialidad_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: frecuencia_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- Name: funcionalidad_id_funcionalidad_padre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_id_funcionalidad_padre_fkey FOREIGN KEY (id_funcionalidad_padre) REFERENCES funcionalidad(id_funcionalidad);


--
-- Name: garantia_servicio_id_condicion_garantia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_condicion_garantia_fkey FOREIGN KEY (id_condicion_garantia) REFERENCES condicion_garantia(id_condicion_garantia);


--
-- Name: garantia_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY garantia_servicio
    ADD CONSTRAINT garantia_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: grupo_alimenticio_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT grupo_alimenticio_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: horario_empleado_id_bloque_horario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_bloque_horario_fkey FOREIGN KEY (id_bloque_horario) REFERENCES bloque_horario(id_bloque_horario);


--
-- Name: horario_empleado_id_dia_laborable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_dia_laborable_fkey FOREIGN KEY (id_dia_laborable) REFERENCES dia_laborable(id_dia_laborable);


--
-- Name: horario_empleado_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY horario_empleado
    ADD CONSTRAINT horario_empleado_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);


--
-- Name: incidencia_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: incidencia_id_tipo_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY incidencia
    ADD CONSTRAINT incidencia_id_tipo_incidencia_fkey FOREIGN KEY (id_tipo_incidencia) REFERENCES tipo_incidencia(id_tipo_incidencia);


--
-- Name: motivo_id_tipo_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY motivo
    ADD CONSTRAINT motivo_id_tipo_motivo_fkey FOREIGN KEY (id_tipo_motivo) REFERENCES tipo_motivo(id_tipo_motivo);


--
-- Name: orden_servicio_id_reclamo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_reclamo_fkey FOREIGN KEY (id_reclamo) REFERENCES reclamo(id_reclamo);


--
-- Name: orden_servicio_id_solicitud_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_solicitud_servicio_fkey FOREIGN KEY (id_solicitud_servicio) REFERENCES solicitud_servicio(id_solicitud_servicio);


--
-- Name: orden_servicio_id_tipo_orden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY orden_servicio
    ADD CONSTRAINT orden_servicio_id_tipo_orden_fkey FOREIGN KEY (id_tipo_orden) REFERENCES tipo_orden(id_tipo_orden);


--
-- Name: parametro_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: parametro_cliente_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_cliente
    ADD CONSTRAINT parametro_cliente_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: parametro_servicio_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: parametro_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro_servicio
    ADD CONSTRAINT parametro_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: parametro_tipo_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_tipo_parametro_fkey FOREIGN KEY (id_tipo_parametro) REFERENCES tipo_parametro(id_tipo_parametro);


--
-- Name: parametro_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: plan_dieta_id_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES tipo_dieta(id_tipo_dieta);


--
-- Name: preferencia_cliente_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: preferencia_cliente_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY preferencia_cliente
    ADD CONSTRAINT preferencia_cliente_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad);


--
-- Name: promocion_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: reclamo_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: reclamo_id_orden_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_orden_servicio_fkey FOREIGN KEY (id_orden_servicio) REFERENCES orden_servicio(id_orden_servicio);


--
-- Name: reclamo_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY reclamo
    ADD CONSTRAINT reclamo_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_dieta_id_detalle_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_detalle_plan_dieta_fkey FOREIGN KEY (id_detalle_plan_dieta) REFERENCES detalle_plan_dieta(id_detalle_plan_dieta);


--
-- Name: regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_ejercicio_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- Name: regimen_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: regimen_ejercicio_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- Name: regimen_suplemento_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_suplemento_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- Name: regimen_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: respuesta_id_tipo_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY respuesta
    ADD CONSTRAINT respuesta_id_tipo_respuesta_fkey FOREIGN KEY (id_tipo_respuesta) REFERENCES tipo_respuesta(id_tipo_respuesta);


--
-- Name: rol_funcionalidad_id_funcionalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_funcionalidad_fkey FOREIGN KEY (id_funcionalidad) REFERENCES funcionalidad(id_funcionalidad);


--
-- Name: rol_funcionalidad_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rol_funcionalidad
    ADD CONSTRAINT rol_funcionalidad_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES rol(id_rol);


--
-- Name: servicio_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- Name: servicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- Name: servicio_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- Name: solicitud_servicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: solicitud_servicio_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES motivo(id_motivo);


--
-- Name: solicitud_servicio_id_promocion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_promocion_fkey FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion);


--
-- Name: solicitud_servicio_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta);


--
-- Name: solicitud_servicio_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY solicitud_servicio
    ADD CONSTRAINT solicitud_servicio_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio);


--
-- Name: suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- Name: unidad_tipo_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_tipo_unidad_fkey FOREIGN KEY (id_tipo_unidad) REFERENCES tipo_unidad(id_tipo_unidad);


--
-- Name: usuario_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES rol(id_rol);


--
-- Name: valoracion_id_tipo_valoracion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
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

