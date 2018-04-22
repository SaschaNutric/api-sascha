--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.11
-- Dumped by pg_dump version 9.5.11

-- Started on 2018-04-22 18:18:01 VET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12395)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2574 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 234 (class 1255 OID 17445)
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
-- TOC entry 197 (class 1259 OID 17528)
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
-- TOC entry 233 (class 1259 OID 18146)
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
-- TOC entry 182 (class 1259 OID 17451)
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
-- TOC entry 183 (class 1259 OID 17453)
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
-- TOC entry 2575 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- TOC entry 196 (class 1259 OID 17526)
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
-- TOC entry 228 (class 1259 OID 17824)
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
-- TOC entry 195 (class 1259 OID 17524)
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
-- TOC entry 229 (class 1259 OID 17832)
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
-- TOC entry 194 (class 1259 OID 17522)
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
-- TOC entry 230 (class 1259 OID 17839)
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
-- TOC entry 193 (class 1259 OID 17520)
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
-- TOC entry 231 (class 1259 OID 17846)
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
-- TOC entry 192 (class 1259 OID 17518)
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
-- TOC entry 232 (class 1259 OID 17853)
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
-- TOC entry 191 (class 1259 OID 17516)
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
-- TOC entry 227 (class 1259 OID 17815)
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
-- TOC entry 181 (class 1259 OID 17446)
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
-- TOC entry 184 (class 1259 OID 17484)
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
-- TOC entry 190 (class 1259 OID 17514)
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
-- TOC entry 226 (class 1259 OID 17810)
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado_civil (
    id_estado_civil integer DEFAULT nextval('id_estado_civil_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 17512)
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
-- TOC entry 225 (class 1259 OID 17803)
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
-- TOC entry 188 (class 1259 OID 17510)
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
-- TOC entry 224 (class 1259 OID 17798)
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE genero (
    id_genero integer DEFAULT nextval('id_genero_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 17530)
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
-- TOC entry 223 (class 1259 OID 17790)
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
-- TOC entry 199 (class 1259 OID 17532)
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
-- TOC entry 200 (class 1259 OID 17534)
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
-- TOC entry 201 (class 1259 OID 17536)
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
-- TOC entry 185 (class 1259 OID 17504)
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
-- TOC entry 202 (class 1259 OID 17538)
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
-- TOC entry 203 (class 1259 OID 17540)
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
-- TOC entry 204 (class 1259 OID 17542)
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
-- TOC entry 205 (class 1259 OID 17544)
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
-- TOC entry 206 (class 1259 OID 17546)
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
-- TOC entry 207 (class 1259 OID 17548)
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
-- TOC entry 208 (class 1259 OID 17550)
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
-- TOC entry 187 (class 1259 OID 17508)
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
-- TOC entry 186 (class 1259 OID 17506)
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
-- TOC entry 209 (class 1259 OID 17552)
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
-- TOC entry 210 (class 1259 OID 17561)
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
-- TOC entry 211 (class 1259 OID 17570)
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
-- TOC entry 212 (class 1259 OID 17579)
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
-- TOC entry 213 (class 1259 OID 17587)
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
-- TOC entry 214 (class 1259 OID 17594)
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
-- TOC entry 215 (class 1259 OID 17601)
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
-- TOC entry 216 (class 1259 OID 17608)
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
    numero_visita integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE servicio OWNER TO leo;

--
-- TOC entry 217 (class 1259 OID 17618)
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
-- TOC entry 218 (class 1259 OID 17624)
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
-- TOC entry 219 (class 1259 OID 17632)
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
-- TOC entry 220 (class 1259 OID 17641)
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
-- TOC entry 221 (class 1259 OID 17649)
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
-- TOC entry 222 (class 1259 OID 17658)
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
-- TOC entry 2576 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo
0: Eliminado';


--
-- TOC entry 2566 (class 0 OID 18146)
-- Dependencies: 233
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2516 (class 0 OID 17453)
-- Dependencies: 183
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2561 (class 0 OID 17824)
-- Dependencies: 228
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2562 (class 0 OID 17832)
-- Dependencies: 229
-- Data for Name: detalle_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_dieta (id_detalle_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2563 (class 0 OID 17839)
-- Dependencies: 230
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2564 (class 0 OID 17846)
-- Dependencies: 231
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2565 (class 0 OID 17853)
-- Dependencies: 232
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2560 (class 0 OID 17815)
-- Dependencies: 227
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2517 (class 0 OID 17484)
-- Dependencies: 184
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY estado (id_estado, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Lara	2018-04-20 00:00:00-04	2018-04-20 00:00:00-04	1
\.


--
-- TOC entry 2559 (class 0 OID 17810)
-- Dependencies: 226
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estado_civil (id_estado_civil, nombre) FROM stdin;
\.


--
-- TOC entry 2558 (class 0 OID 17803)
-- Dependencies: 225
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2557 (class 0 OID 17798)
-- Dependencies: 224
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY genero (id_genero, nombre) FROM stdin;
\.


--
-- TOC entry 2556 (class 0 OID 17790)
-- Dependencies: 223
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2577 (class 0 OID 0)
-- Dependencies: 197
-- Name: id_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_alimento_seq', 1, true);


--
-- TOC entry 2578 (class 0 OID 0)
-- Dependencies: 182
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_cliente_seq', 1, true);


--
-- TOC entry 2579 (class 0 OID 0)
-- Dependencies: 196
-- Name: id_comida_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_comida_seq', 1, true);


--
-- TOC entry 2580 (class 0 OID 0)
-- Dependencies: 195
-- Name: id_detalle_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_dieta_seq', 1, true);


--
-- TOC entry 2581 (class 0 OID 0)
-- Dependencies: 194
-- Name: id_detalle_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_ejercicio_seq', 1, true);


--
-- TOC entry 2582 (class 0 OID 0)
-- Dependencies: 193
-- Name: id_detalle_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_plan_suplemento_seq', 1, true);


--
-- TOC entry 2583 (class 0 OID 0)
-- Dependencies: 192
-- Name: id_detalle_regimen_alimento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_detalle_regimen_alimento_seq', 1, true);


--
-- TOC entry 2584 (class 0 OID 0)
-- Dependencies: 191
-- Name: id_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_ejercicio_seq', 1, true);


--
-- TOC entry 2585 (class 0 OID 0)
-- Dependencies: 190
-- Name: id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_civil_seq', 1, true);


--
-- TOC entry 2586 (class 0 OID 0)
-- Dependencies: 181
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_seq', 7, true);


--
-- TOC entry 2587 (class 0 OID 0)
-- Dependencies: 189
-- Name: id_frecuencia_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_frecuencia_seq', 1, true);


--
-- TOC entry 2588 (class 0 OID 0)
-- Dependencies: 188
-- Name: id_genero_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_genero_seq', 1, true);


--
-- TOC entry 2589 (class 0 OID 0)
-- Dependencies: 198
-- Name: id_grupo_alimenticio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_grupo_alimenticio_seq', 1, true);


--
-- TOC entry 2590 (class 0 OID 0)
-- Dependencies: 199
-- Name: id_plan_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_dieta_seq', 2, true);


--
-- TOC entry 2591 (class 0 OID 0)
-- Dependencies: 200
-- Name: id_plan_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_ejercicio_seq', 1, true);


--
-- TOC entry 2592 (class 0 OID 0)
-- Dependencies: 201
-- Name: id_plan_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_plan_suplemento_seq', 2, true);


--
-- TOC entry 2593 (class 0 OID 0)
-- Dependencies: 185
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_rango_edad_seq', 1, false);


--
-- TOC entry 2594 (class 0 OID 0)
-- Dependencies: 202
-- Name: id_regimen_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_dieta_seq', 1, true);


--
-- TOC entry 2595 (class 0 OID 0)
-- Dependencies: 203
-- Name: id_regimen_ejercicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_ejercicio_seq', 1, true);


--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 204
-- Name: id_regimen_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_regimen_suplemento_seq', 1, true);


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 205
-- Name: id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_servicio_seq', 1, true);


--
-- TOC entry 2598 (class 0 OID 0)
-- Dependencies: 206
-- Name: id_suplemento_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_suplemento_seq', 1, true);


--
-- TOC entry 2599 (class 0 OID 0)
-- Dependencies: 207
-- Name: id_tiempo_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tiempo_seq', 1, true);


--
-- TOC entry 2600 (class 0 OID 0)
-- Dependencies: 208
-- Name: id_tipo_dieta_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_tipo_dieta_seq', 4, true);


--
-- TOC entry 2601 (class 0 OID 0)
-- Dependencies: 187
-- Name: id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_unidad_seq', 1, true);


--
-- TOC entry 2602 (class 0 OID 0)
-- Dependencies: 186
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_usuario_seq', 1, true);


--
-- TOC entry 2542 (class 0 OID 17552)
-- Dependencies: 209
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	plan dieta	descripcion	2018-02-05 00:00:00-04	2018-04-05 00:00:00-04	1
2	1	PlanDieta	Detalle	2018-04-21 23:59:09.189075-04	2018-04-21 23:59:09.189075-04	1
\.


--
-- TOC entry 2543 (class 0 OID 17561)
-- Dependencies: 210
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	ejercicio	descripcion	2018-05-04 00:00:00-04	2018-06-08 00:00:00-04	1
\.


--
-- TOC entry 2544 (class 0 OID 17570)
-- Dependencies: 211
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	suplemento actualizado	descripcion	2018-07-04 00:00:00-04	2018-07-09 00:00:00-04	1
2	suplemento nuevo		2018-04-22 18:10:44.152783-04	2018-04-22 18:10:44.152783-04	1
\.


--
-- TOC entry 2545 (class 0 OID 17579)
-- Dependencies: 212
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2546 (class 0 OID 17587)
-- Dependencies: 213
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_dieta (id_regimen_dieta, id_detalle_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2547 (class 0 OID 17594)
-- Dependencies: 214
-- Data for Name: regimen_ejercicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_ejercicio (id_regimen_ejercicio, id_plan_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2548 (class 0 OID 17601)
-- Dependencies: 215
-- Data for Name: regimen_suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY regimen_suplemento (id_regimen_suplemento, id_plan_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2549 (class 0 OID 17608)
-- Dependencies: 216
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, precio, numero_visita, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	1	nombre del servicio	descripcion del servicio	url de la imagen	34	5	2018-04-06 00:00:00-04	2018-05-06 00:00:00-04	1
2	1	1	1	bbn	req.body.descripcion	req.body.url_imagen	788390	6	2018-04-21 20:53:05.962768-04	2018-04-21 20:53:05.962768-04	1
\.


--
-- TOC entry 2550 (class 0 OID 17618)
-- Dependencies: 217
-- Data for Name: servicio_parametro; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY servicio_parametro (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2551 (class 0 OID 17624)
-- Dependencies: 218
-- Data for Name: suplemento; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2552 (class 0 OID 17632)
-- Dependencies: 219
-- Data for Name: tiempo; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2553 (class 0 OID 17641)
-- Dependencies: 220
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Nueva Dieta	2018-04-02 00:00:00-04	2018-05-02 00:00:00-04	1
2	dieta1	2018-04-21 23:56:32.238-04	2018-04-21 23:56:32.238-04	0
4	Nueva	2018-04-22 17:14:36.36457-04	2018-04-22 17:14:36.36457-04	1
\.


--
-- TOC entry 2554 (class 0 OID 17649)
-- Dependencies: 221
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY unidad (id_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2555 (class 0 OID 17658)
-- Dependencies: 222
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus) FROM stdin;
\.


--
-- TOC entry 2370 (class 2606 OID 18131)
-- Name: PK_id_comida; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comida
    ADD CONSTRAINT "PK_id_comida" PRIMARY KEY (id_comida);


--
-- TOC entry 2373 (class 2606 OID 18133)
-- Name: PK_id_detalle_dieta; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_dieta
    ADD CONSTRAINT "PK_id_detalle_dieta" PRIMARY KEY (id_detalle_dieta);


--
-- TOC entry 2361 (class 2606 OID 18135)
-- Name: PK_id_grupo_alimento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT "PK_id_grupo_alimento" PRIMARY KEY (id_grupo_alimenticio);


--
-- TOC entry 2383 (class 2606 OID 18155)
-- Name: alimento_id_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_alimento_pkey PRIMARY KEY (id_alimento);


--
-- TOC entry 2311 (class 2606 OID 17673)
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 2375 (class 2606 OID 18137)
-- Name: detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- TOC entry 2379 (class 2606 OID 18139)
-- Name: detalle_plan_suplemento_id_detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- TOC entry 2368 (class 2606 OID 18141)
-- Name: ejercicio_id_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ejercicio
    ADD CONSTRAINT ejercicio_id_ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- TOC entry 2366 (class 2606 OID 18143)
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- TOC entry 2313 (class 2606 OID 17675)
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- TOC entry 2364 (class 2606 OID 18145)
-- Name: frecuencia_id_frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_id_frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- TOC entry 2317 (class 2606 OID 17677)
-- Name: plan_dieta_id_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- TOC entry 2319 (class 2606 OID 17679)
-- Name: plan_ejercicio_id_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_id_plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- TOC entry 2321 (class 2606 OID 17681)
-- Name: plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- TOC entry 2323 (class 2606 OID 17683)
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- TOC entry 2327 (class 2606 OID 17685)
-- Name: regimen_dieta_id_regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- TOC entry 2333 (class 2606 OID 17687)
-- Name: regimen_ejercicio_id_regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- TOC entry 2338 (class 2606 OID 17689)
-- Name: regimen_suplemento_id_regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- TOC entry 2345 (class 2606 OID 17691)
-- Name: servicio_id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- TOC entry 2347 (class 2606 OID 17693)
-- Name: servicio_parametro_id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio_parametro
    ADD CONSTRAINT servicio_parametro_id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- TOC entry 2350 (class 2606 OID 17695)
-- Name: suplemento_id_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- TOC entry 2352 (class 2606 OID 17697)
-- Name: tiempo_id_tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tiempo
    ADD CONSTRAINT tiempo_id_tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- TOC entry 2354 (class 2606 OID 17699)
-- Name: tipo_dieta_id_tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY tipo_dieta
    ADD CONSTRAINT tipo_dieta_id_tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- TOC entry 2357 (class 2606 OID 17701)
-- Name: unidad_id_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_id_unidad_pkey PRIMARY KEY (id_unidad);


--
-- TOC entry 2359 (class 2606 OID 17703)
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 2324 (class 1259 OID 17704)
-- Name: FKI_id_detalle_dieta; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX "FKI_id_detalle_dieta" ON regimen_dieta USING btree (id_detalle_dieta);


--
-- TOC entry 2384 (class 1259 OID 18307)
-- Name: fki_alimento_id_grupo_alimento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_alimento_id_grupo_alimento_fkey ON alimento USING btree (id_grupo_alimenticio);


--
-- TOC entry 2371 (class 1259 OID 18304)
-- Name: fki_comida_id_comida; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_comida_id_comida ON comida USING btree (id_comida);


--
-- TOC entry 2376 (class 1259 OID 18308)
-- Name: fki_detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey ON detalle_plan_ejercicio USING btree (id_plan_ejercicio);


--
-- TOC entry 2377 (class 1259 OID 18309)
-- Name: fki_detalle_plan_ejercicio_id_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_ejercicio_id_ejercicio_fkey ON detalle_plan_ejercicio USING btree (id_ejercicio);


--
-- TOC entry 2380 (class 1259 OID 18310)
-- Name: fki_detalle_plan_suplemento_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_suplemento_id_plan_suplemento_fkey ON detalle_plan_suplemento USING btree (id_plan_suplemento);


--
-- TOC entry 2381 (class 1259 OID 18311)
-- Name: fki_detalle_plan_suplemento_id_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_suplemento_id_suplemento_fkey ON detalle_plan_suplemento USING btree (id_suplemento);


--
-- TOC entry 2362 (class 1259 OID 18312)
-- Name: fki_frecuencia_id_tiempo_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_frecuencia_id_tiempo_fkey ON frecuencia USING btree (id_tiempo);


--
-- TOC entry 2314 (class 1259 OID 18305)
-- Name: fki_plan_dieta_id_plan_dieta; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_plan_dieta_id_plan_dieta ON plan_dieta USING btree (id_plan_dieta);


--
-- TOC entry 2315 (class 1259 OID 17705)
-- Name: fki_plan_dieta_idtipo_dieta_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_plan_dieta_idtipo_dieta_fkey ON plan_dieta USING btree (id_tipo_dieta);


--
-- TOC entry 2325 (class 1259 OID 17706)
-- Name: fki_regimen_dieta_id_cliente_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_dieta_id_cliente_fkey ON regimen_dieta USING btree (id_cliente);


--
-- TOC entry 2328 (class 1259 OID 17707)
-- Name: fki_regimen_ejercicio_id_cliente_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_cliente_fkey ON regimen_ejercicio USING btree (id_cliente);


--
-- TOC entry 2329 (class 1259 OID 17708)
-- Name: fki_regimen_ejercicio_id_frecuencia_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_frecuencia_fkey ON regimen_ejercicio USING btree (id_frecuencia);


--
-- TOC entry 2330 (class 1259 OID 17709)
-- Name: fki_regimen_ejercicio_id_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_plan_ejercicio_fkey ON regimen_ejercicio USING btree (id_plan_ejercicio);


--
-- TOC entry 2331 (class 1259 OID 17710)
-- Name: fki_regimen_ejercicio_id_tiempo_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_ejercicio_id_tiempo_fkey ON regimen_ejercicio USING btree (id_tiempo);


--
-- TOC entry 2334 (class 1259 OID 17711)
-- Name: fki_regimen_suplemento_id_cliente_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_suplemento_id_cliente_fkey ON regimen_suplemento USING btree (id_cliente);


--
-- TOC entry 2335 (class 1259 OID 17712)
-- Name: fki_regimen_suplemento_id_frecuencia_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_suplemento_id_frecuencia_fkey ON regimen_suplemento USING btree (id_frecuencia);


--
-- TOC entry 2336 (class 1259 OID 17713)
-- Name: fki_regimen_suplemento_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_regimen_suplemento_id_plan_suplemento_fkey ON regimen_suplemento USING btree (id_plan_suplemento);


--
-- TOC entry 2339 (class 1259 OID 17714)
-- Name: fki_servicio_id_plan_dieta; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_dieta ON servicio USING btree (id_plan_dieta);


--
-- TOC entry 2340 (class 1259 OID 18313)
-- Name: fki_servicio_id_plan_dieta_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_dieta_fkey ON servicio USING btree (id_plan_dieta);


--
-- TOC entry 2341 (class 1259 OID 17715)
-- Name: fki_servicio_id_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_ejercicio_fkey ON servicio USING btree (id_plan_ejercicio);


--
-- TOC entry 2342 (class 1259 OID 18314)
-- Name: fki_servicio_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_suplemento_fkey ON servicio USING btree (id_plan_suplemento);


--
-- TOC entry 2343 (class 1259 OID 17716)
-- Name: fki_servicio_id_plan_suplemento_pkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_servicio_id_plan_suplemento_pkey ON servicio USING btree (id_plan_suplemento);


--
-- TOC entry 2348 (class 1259 OID 17717)
-- Name: fki_suplemento_id_unidad_fkey; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_suplemento_id_unidad_fkey ON suplemento USING btree (id_unidad);


--
-- TOC entry 2355 (class 1259 OID 18306)
-- Name: fki_unidad_id_unidad; Type: INDEX; Schema: public; Owner: leo
--

CREATE INDEX fki_unidad_id_unidad ON unidad USING btree (id_unidad);


--
-- TOC entry 2399 (class 2620 OID 17718)
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: leo
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- TOC entry 2385 (class 2606 OID 17719)
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- TOC entry 2386 (class 2606 OID 17724)
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- TOC entry 2387 (class 2606 OID 17729)
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- TOC entry 2388 (class 2606 OID 17734)
-- Name: plan_dieta_id_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES tipo_dieta(id_tipo_dieta);


--
-- TOC entry 2389 (class 2606 OID 17739)
-- Name: regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- TOC entry 2390 (class 2606 OID 17744)
-- Name: regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- TOC entry 2391 (class 2606 OID 17749)
-- Name: regimen_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- TOC entry 2392 (class 2606 OID 17754)
-- Name: regimen_ejercicio_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- TOC entry 2393 (class 2606 OID 17759)
-- Name: regimen_suplemento_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- TOC entry 2394 (class 2606 OID 17764)
-- Name: regimen_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- TOC entry 2395 (class 2606 OID 17769)
-- Name: servicio_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- TOC entry 2396 (class 2606 OID 17774)
-- Name: servicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- TOC entry 2397 (class 2606 OID 17779)
-- Name: servicio_id_plan_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_servicio_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- TOC entry 2398 (class 2606 OID 17784)
-- Name: suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- TOC entry 2573 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2018-04-22 18:18:01 VET

--
-- PostgreSQL database dump complete
--

