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
-- Name: id_alimento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_alimento_seq OWNER TO leo;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE alimento (
    id_alimento integer DEFAULT nextval('id_alimento_seq'::regclass) NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE alimento OWNER TO postgres;

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
    fecha_consolidado timestamp with time zone,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE cliente OWNER TO leo;

--
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


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
-- Name: comida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comida (
    id_comida integer DEFAULT nextval('id_comida_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE comida OWNER TO postgres;

--
-- Name: id_detalle_dieta_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_detalle_dieta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_dieta_seq OWNER TO leo;

--
-- Name: detalle_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_dieta (
    id_detalle_dieta integer DEFAULT nextval('id_detalle_dieta_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_comida integer NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_dieta OWNER TO postgres;

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
-- Name: detalle_plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_plan_ejercicio (
    id_detalle_plan_ejercicio integer DEFAULT nextval('id_detalle_plan_ejercicio_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_ejercicio integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_ejercicio OWNER TO postgres;

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
-- Name: detalle_plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_plan_suplemento (
    id_detalle_plan_suplemento integer DEFAULT nextval('id_detalle_plan_suplemento_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_suplemento integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_suplemento OWNER TO postgres;

--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_detalle_regimen_alimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_detalle_regimen_alimento_seq OWNER TO leo;

--
-- Name: detalle_regimen_alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_regimen_alimento (
    id_regimen_dieta integer DEFAULT nextval('id_detalle_regimen_alimento_seq'::regclass) NOT NULL,
    id_alimento integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_regimen_alimento OWNER TO postgres;

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
-- Name: ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE ejercicio (
    id_ejercicio integer DEFAULT nextval('id_ejercicio_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE ejercicio OWNER TO postgres;

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
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE estado OWNER TO leo;

--
-- Name: id_estado_civil_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_estado_civil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_estado_civil_seq OWNER TO leo;

--
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado_civil (
    id_estado_civil integer DEFAULT nextval('id_estado_civil_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO postgres;

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
-- Name: frecuencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE frecuencia (
    id_frecuencia integer DEFAULT nextval('id_frecuencia_seq'::regclass) NOT NULL,
    id_tiempo integer NOT NULL,
    repeticiones integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE frecuencia OWNER TO postgres;

--
-- Name: id_genero_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_genero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_genero_seq OWNER TO leo;

--
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE genero (
    id_genero integer DEFAULT nextval('id_genero_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO postgres;

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
-- Name: grupo_alimenticio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE grupo_alimenticio (
    id_grupo_alimenticio integer DEFAULT nextval('id_grupo_alimenticio_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE grupo_alimenticio OWNER TO postgres;

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
-- Name: parametro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE parametro (
    id_parametro integer DEFAULT nextval('id_parametro_seq'::regclass) NOT NULL,
    id_tipo_parametro integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    id_tipo_valor integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE parametro OWNER TO postgres;

--
-- Name: plan_dieta; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE plan_dieta (
    id_plan_dieta integer DEFAULT nextval('id_plan_dieta_seq'::regclass) NOT NULL,
    id_tipo_dieta integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
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
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
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
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_suplemento OWNER TO leo;

--
-- Name: promocion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE promocion (
    id_promocion integer DEFAULT nextval('id_promocion_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(200) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(50) DEFAULT ''::character varying NOT NULL,
    precio integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE promocion OWNER TO postgres;

--
-- Name: promocion_parametro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE promocion_parametro (
    id_promocion integer NOT NULL,
    id_parametro integer NOT NULL,
    valor_minimo integer NOT NULL,
    valor_maximo integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE promocion_parametro OWNER TO postgres;

--
-- Name: rango_edad; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE rango_edad (
    id_rango_edad integer DEFAULT nextval('id_rango_edad_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL,
    minimo integer NOT NULL,
    maximo integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE rango_edad OWNER TO leo;

--
-- Name: regimen_dieta; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE regimen_dieta (
    id_regimen_dieta integer DEFAULT nextval('id_regimen_dieta_seq'::regclass) NOT NULL,
    id_detalle_dieta integer NOT NULL,
    id_cliente integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
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
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
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
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_suplemento OWNER TO leo;

--
-- Name: servicio; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE servicio (
    id_servicio integer DEFAULT nextval('id_servicio_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_plan_suplemento integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(200) DEFAULT ''::character varying NOT NULL,
    url_imagen character varying(50) DEFAULT ''::character varying NOT NULL,
    precio integer NOT NULL,
    numero_visita integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE servicio OWNER TO leo;

--
-- Name: servicio_parametro; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE servicio_parametro (
    id_servicio integer NOT NULL,
    id_parametro integer NOT NULL,
    valor_minimo integer NOT NULL,
    valor_maximo integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE servicio_parametro OWNER TO leo;

--
-- Name: suplemento; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE suplemento (
    id_suplemento integer DEFAULT nextval('id_suplemento_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
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
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tiempo OWNER TO leo;

--
-- Name: tipo_dieta; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE tipo_dieta (
    id_tipo_dieta integer DEFAULT nextval('id_tipo_dieta_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_dieta OWNER TO leo;

--
-- Name: tipo_parametro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_parametro (
    id_tipo_parametro integer DEFAULT nextval('id_tipo_parametro_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_parametro OWNER TO postgres;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: leo
--

CREATE TABLE unidad (
    id_unidad integer DEFAULT nextval('id_unidad_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
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
    ultimo_acceso timestamp with time zone,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE usuario OWNER TO leo;

--
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo
0: Eliminado';


--
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_dieta (id_detalle_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY estado (id_estado, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Lara	2018-04-20 00:00:00-04	2018-04-20 00:00:00-04	1
\.


--
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estado_civil (id_estado_civil, nombre) FROM stdin;
\.


--
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY genero (id_genero, nombre) FROM stdin;
\.


--
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Name: id_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_alimento_seq', 1, true);


--
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_cliente_seq', 1, true);


--
-- Name: id_comida_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_comida_seq', 1, true);


--
-- Name: id_detalle_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_dieta_seq', 1, true);


--
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_ejercicio_seq', 1, true);


--
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_suplemento_seq', 1, true);


--
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_regimen_alimento_seq', 1, true);


--
-- Name: id_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_ejercicio_seq', 1, true);


--
-- Name: id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_civil_seq', 1, true);


--
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_seq', 7, true);


--
-- Name: id_frecuencia_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_frecuencia_seq', 1, true);


--
-- Name: id_genero_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_genero_seq', 1, true);


--
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_grupo_alimenticio_seq', 1, true);


--
-- Name: id_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_parametro_seq', 1, false);


--
-- Name: id_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_dieta_seq', 2, true);


--
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_ejercicio_seq', 1, true);


--
-- Name: id_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_suplemento_seq', 2, true);


--
-- Name: id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_promocion_seq', 1, true);


--
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_rango_edad_seq', 1, false);


--
-- Name: id_regimen_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_dieta_seq', 1, true);


--
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_ejercicio_seq', 1, true);


--
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_suplemento_seq', 1, true);


--
-- Name: id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_servicio_seq', 7, true);


--
-- Name: id_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_suplemento_seq', 1, true);


--
-- Name: id_tiempo_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tiempo_seq', 1, true);


--
-- Name: id_tipo_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_dieta_seq', 4, true);


--
-- Name: id_tipo_parametro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_tipo_parametro_seq', 1, false);


--
-- Name: id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_unidad_seq', 1, true);


--
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_usuario_seq', 1, true);


--
-- Data for Name: parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY parametro (id_parametro, id_tipo_parametro, nombre, id_tipo_valor, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	plan dieta	descripcion	2018-02-05 00:00:00-04	2018-04-05 00:00:00-04	1
2	1	PlanDieta	Detalle	2018-04-21 23:59:09.189075-04	2018-04-21 23:59:09.189075-04	1
\.


--
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	ejercicio	descripcion	2018-05-04 00:00:00-04	2018-06-08 00:00:00-04	1
\.


--
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	suplemento actualizado	descripcion	2018-07-04 00:00:00-04	2018-07-09 00:00:00-04	1
2	suplemento nuevo		2018-04-22 18:10:44.152783-04	2018-04-22 18:10:44.152783-04	1
\.


--
-- Data for Name: promocion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY promocion (id_promocion, nombre, descripcion, url_imagen, precio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Promocion Mes de las Madres	En el mes de Mayo las madres recibiran un precio especial en su Plan alimentacion durante el embarazo	../../assets/imgs/promomama.jpg	70	2018-04-26 10:12:04.004578-04	2018-04-26 10:12:04.004578-04	1
\.


--
-- Data for Name: promocion_parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY promocion_parametro (id_promocion, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_dieta (id_regimen_dieta, id_detalle_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
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
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, precio, numero_visita, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
3	1	1	1	Plan Control de obesidad	Consejos alimenticios y planes nutricionales para el control de peso.	../../assets/imgs/controlobe.jpg	120	10	2018-04-23 08:42:18.987037-04	2018-04-23 08:42:18.987037-04	1
1	1	1	1	Plan para Adultos Mayores.	Un nutricionista calificado realiza una evaluación de tu estado nutricional.	../../assets/imgs/nutricionadultos.jpg	100	5	2018-04-06 00:00:00-04	2018-05-06 00:00:00-04	1
4	1	1	1	Plan Nutrición Deportiva	Planes de nutrición especializados para deportistas.	../../assets/imgs/nutydep1.jpg	90	10	2018-04-25 21:56:15.151355-04	2018-04-25 21:56:15.151355-04	1
5	1	1	1	Plan Alimentacion Infantil	Un Nutricionista hará un plan nutricional para el niño, teniendo en cuenta los hábitos de alimentacion de la familia.	../../assets/imgs/nutinf.jpeg	90	10	2018-04-25 22:01:08.84057-04	2018-04-25 22:01:08.84057-04	1
6	1	1	1	Plan Gana Peso con salud	Gana peso a un ritmo adecuado de manera saludable. Equilibra tu masa muscular y porcentaje de grasa hasta conseguir el peso deseado.	../../assets/imgs/Ganarpeso.jpg	90	10	2018-04-25 22:04:06.407166-04	2018-04-25 22:04:06.407166-04	1
7	1	1	1	Plan alimentacion durante el embarazo	Tu nutricionista te proporcionara un plan adecuado durante la gestación, siguiendo las pautas necesarias para cubrir las necesidades nutricionales del bebé.	../../assets/imgs/Nutricionembarazo.jpg	90	10	2018-04-25 22:05:15.374866-04	2018-04-25 22:05:15.374866-04	1
\.


--
-- Data for Name: servicio_parametro; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY servicio_parametro (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
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
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Nueva Dieta	2018-04-02 00:00:00-04	2018-05-02 00:00:00-04	1
2	dieta1	2018-04-21 23:56:32.238-04	2018-04-21 23:56:32.238-04	0
4	Nueva	2018-04-22 17:14:36.36457-04	2018-04-22 17:14:36.36457-04	1
\.


--
-- Data for Name: tipo_parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tipo_parametro (id_tipo_parametro, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY unidad (id_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus) FROM stdin;
\.


--
-- Name: PK_id_comida; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comida
    ADD CONSTRAINT "PK_id_comida" PRIMARY KEY (id_comida);


--
-- Name: PK_id_detalle_dieta; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_dieta
    ADD CONSTRAINT "PK_id_detalle_dieta" PRIMARY KEY (id_detalle_dieta);


--
-- Name: PK_id_grupo_alimento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT "PK_id_grupo_alimento" PRIMARY KEY (id_grupo_alimenticio);


--
-- Name: alimento_id_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_alimento_pkey PRIMARY KEY (id_alimento);


--
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- Name: detalle_plan_suplemento_id_detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- Name: ejercicio_id_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ejercicio
    ADD CONSTRAINT ejercicio_id_ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- Name: frecuencia_id_frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_id_frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- Name: parametro_id_parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_id_parametro_pkey PRIMARY KEY (id_parametro);


--
-- Name: plan_dieta_id_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- Name: plan_ejercicio_id_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_id_plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- Name: plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- Name: promocion_id_promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY promocion
    ADD CONSTRAINT promocion_id_promocion_pkey PRIMARY KEY (id_promocion);


--
-- Name: promocion_parametro_id_promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY promocion_parametro
    ADD CONSTRAINT promocion_parametro_id_promocion_pkey PRIMARY KEY (id_promocion, id_parametro);


--
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- Name: regimen_dieta_id_regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- Name: regimen_ejercicio_id_regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- Name: regimen_suplemento_id_regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- Name: servicio_id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: servicio_parametro_id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio_parametro
    ADD CONSTRAINT servicio_parametro_id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: suplemento_id_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- Name: tiempo_id_tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tiempo
    ADD CONSTRAINT tiempo_id_tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- Name: tipo_dieta_id_tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_dieta
    ADD CONSTRAINT tipo_dieta_id_tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- Name: tipo_parametro_id_tipo_parametro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_parametro
    ADD CONSTRAINT tipo_parametro_id_tipo_parametro_pkey PRIMARY KEY (id_tipo_parametro);


--
-- Name: unidad_id_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_id_unidad_pkey PRIMARY KEY (id_unidad);


--
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: FKI_id_detalle_dieta; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX "FKI_id_detalle_dieta" ON regimen_dieta USING btree (id_detalle_dieta);


--
-- Name: fki_alimento_id_grupo_alimento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_alimento_id_grupo_alimento_fkey ON alimento USING btree (id_grupo_alimenticio);


--
-- Name: fki_comida_id_comida; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_comida_id_comida ON comida USING btree (id_comida);


--
-- Name: fki_detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey ON detalle_plan_ejercicio USING btree (id_plan_ejercicio);


--
-- Name: fki_detalle_plan_ejercicio_id_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_ejercicio_id_ejercicio_fkey ON detalle_plan_ejercicio USING btree (id_ejercicio);


--
-- Name: fki_detalle_plan_suplemento_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_suplemento_id_plan_suplemento_fkey ON detalle_plan_suplemento USING btree (id_plan_suplemento);


--
-- Name: fki_detalle_plan_suplemento_id_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_suplemento_id_suplemento_fkey ON detalle_plan_suplemento USING btree (id_suplemento);


--
-- Name: fki_frecuencia_id_tiempo_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_frecuencia_id_tiempo_fkey ON frecuencia USING btree (id_tiempo);


--
-- Name: fki_parametro_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_parametro_fkey ON parametro USING btree (id_tipo_parametro);


--
-- Name: fki_plan_dieta_id_plan_dieta; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_plan_dieta_id_plan_dieta ON plan_dieta USING btree (id_plan_dieta);


--
-- Name: fki_plan_dieta_idtipo_dieta_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_plan_dieta_idtipo_dieta_fkey ON plan_dieta USING btree (id_tipo_dieta);


--
-- Name: fki_promocion_parametro_id_parametro_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_promocion_parametro_id_parametro_fkey ON promocion_parametro USING btree (id_parametro);


--
-- Name: fki_regimen_dieta_id_cliente_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_dieta_id_cliente_fkey ON regimen_dieta USING btree (id_cliente);


--
-- Name: fki_regimen_ejercicio_id_cliente_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_cliente_fkey ON regimen_ejercicio USING btree (id_cliente);


--
-- Name: fki_regimen_ejercicio_id_frecuencia_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_frecuencia_fkey ON regimen_ejercicio USING btree (id_frecuencia);


--
-- Name: fki_regimen_ejercicio_id_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_plan_ejercicio_fkey ON regimen_ejercicio USING btree (id_plan_ejercicio);


--
-- Name: fki_regimen_ejercicio_id_tiempo_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_tiempo_fkey ON regimen_ejercicio USING btree (id_tiempo);


--
-- Name: fki_regimen_suplemento_id_cliente_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_suplemento_id_cliente_fkey ON regimen_suplemento USING btree (id_cliente);


--
-- Name: fki_regimen_suplemento_id_frecuencia_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_suplemento_id_frecuencia_fkey ON regimen_suplemento USING btree (id_frecuencia);


--
-- Name: fki_regimen_suplemento_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_suplemento_id_plan_suplemento_fkey ON regimen_suplemento USING btree (id_plan_suplemento);


--
-- Name: fki_servicio_id_plan_dieta; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_dieta ON servicio USING btree (id_plan_dieta);


--
-- Name: fki_servicio_id_plan_dieta_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_dieta_fkey ON servicio USING btree (id_plan_dieta);


--
-- Name: fki_servicio_id_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_ejercicio_fkey ON servicio USING btree (id_plan_ejercicio);


--
-- Name: fki_servicio_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_suplemento_fkey ON servicio USING btree (id_plan_suplemento);


--
-- Name: fki_servicio_id_plan_suplemento_pkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_suplemento_pkey ON servicio USING btree (id_plan_suplemento);


--
-- Name: fki_suplemento_id_unidad_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_suplemento_id_unidad_fkey ON suplemento USING btree (id_unidad);


--
-- Name: fki_unidad_id_unidad; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_unidad_id_unidad ON unidad USING btree (id_unidad);


--
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: leo
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


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
-- Name: parametro_id_tipo_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parametro
    ADD CONSTRAINT parametro_id_tipo_parametro_fkey FOREIGN KEY (id_tipo_parametro) REFERENCES tipo_parametro(id_tipo_parametro);


--
-- Name: plan_dieta_id_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES tipo_dieta(id_tipo_dieta);


--
-- Name: promocion_parametro_id_parametro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY promocion_parametro
    ADD CONSTRAINT promocion_parametro_id_parametro_fkey FOREIGN KEY (id_parametro) REFERENCES parametro(id_parametro);


--
-- Name: promocion_parametro_id_promocion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY promocion_parametro
    ADD CONSTRAINT promocion_parametro_id_promocion_fkey FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion);


--
-- Name: regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- Name: regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


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
-- Name: regimen_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


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
-- Name: suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


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

