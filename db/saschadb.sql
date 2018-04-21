--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.11
-- Dumped by pg_dump version 9.5.11

-- Started on 2018-04-20 22:12:20 VET

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
-- TOC entry 2434 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 212 (class 1255 OID 16870)
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
-- TOC entry 183 (class 1259 OID 16886)
-- Name: id_estado_seq; Type: SEQUENCE; Schema: public; Owner: leo
--

CREATE SEQUENCE id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_estado_seq OWNER TO leo;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 208 (class 1259 OID 17216)
-- Name: alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE alimento (
    id_alimento integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE alimento OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 16871)
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
-- TOC entry 182 (class 1259 OID 16873)
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
-- TOC entry 2435 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- TOC entry 189 (class 1259 OID 16973)
-- Name: comida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comida (
    id_comida integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE comida OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 17209)
-- Name: detalle_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_dieta (
    id_detalle_dieta integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_plan_dieta integer NOT NULL,
    id_comida integer NOT NULL,
    id_grupo_alimenticio integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_dieta OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 17202)
-- Name: detalle_plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_plan_ejercicio (
    id_detalle_plan_ejercicio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
    id_ejercicio integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_ejercicio OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 17127)
-- Name: detalle_plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_plan_suplemento (
    id_detalle_plan_suplemento integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_suplemento integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_plan_suplemento OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 17195)
-- Name: detalle_regimen_alimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE detalle_regimen_alimento (
    id_regimen_dieta integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_alimento integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE detalle_regimen_alimento OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 17072)
-- Name: ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE ejercicio (
    id_ejercicio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE ejercicio OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 16888)
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
-- TOC entry 204 (class 1259 OID 17188)
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado_civil (
    id_estado_civil integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 17181)
-- Name: frecuencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE frecuencia (
    id_frecuencia integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_tiempo integer NOT NULL,
    repeticiones integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE frecuencia OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 17174)
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE genero (
    id_genero integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 17166)
-- Name: grupo_alimenticio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE grupo_alimenticio (
    id_grupo_alimenticio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE grupo_alimenticio OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 16904)
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
-- TOC entry 186 (class 1259 OID 16906)
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
-- TOC entry 198 (class 1259 OID 17141)
-- Name: plan_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE plan_dieta (
    id_plan_dieta integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_tipo_dieta integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_dieta OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 17081)
-- Name: plan_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE plan_ejercicio (
    id_plan_ejercicio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_ejercicio OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 17109)
-- Name: plan_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE plan_suplemento (
    id_plan_suplemento integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    descripcion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE plan_suplemento OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 16908)
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
-- TOC entry 197 (class 1259 OID 17134)
-- Name: regimen_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE regimen_dieta (
    id_regimen_dieta integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_detalle_dieta integer NOT NULL,
    id_cliente integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_dieta OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 17159)
-- Name: regimen_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE regimen_ejercicio (
    id_plan_ejercicio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_cliente integer NOT NULL,
    id_frecuencia integer NOT NULL,
    id_tiempo integer NOT NULL,
    duracion integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_ejercicio OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 17225)
-- Name: regimen_suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE regimen_suplemento (
    id_regimen_suplemento integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_plan_suplemento integer NOT NULL,
    id_cliente integer NOT NULL,
    id_frecuencia integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE regimen_suplemento OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 17232)
-- Name: servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE servicio (
    id_servicio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
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


ALTER TABLE servicio OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 17242)
-- Name: servicio_parametro; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE servicio_parametro OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 17151)
-- Name: suplemento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE suplemento (
    id_suplemento integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE suplemento OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 17055)
-- Name: tiempo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tiempo (
    id_tiempo integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tiempo OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 16999)
-- Name: tipo_dieta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_dieta (
    id_tipo_dieta integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE tipo_dieta OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 16981)
-- Name: unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE unidad (
    id_unidad integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    abreviatura character varying(5) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE unidad OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 16916)
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
-- TOC entry 2436 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo
0: Eliminado';


--
-- TOC entry 2423 (class 0 OID 17216)
-- Dependencies: 208
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2397 (class 0 OID 16873)
-- Dependencies: 182
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2404 (class 0 OID 16973)
-- Dependencies: 189
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2422 (class 0 OID 17209)
-- Dependencies: 207
-- Data for Name: detalle_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_dieta (id_detalle_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2421 (class 0 OID 17202)
-- Dependencies: 206
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2411 (class 0 OID 17127)
-- Dependencies: 196
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2420 (class 0 OID 17195)
-- Dependencies: 205
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2408 (class 0 OID 17072)
-- Dependencies: 193
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2399 (class 0 OID 16888)
-- Dependencies: 184
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY estado (id_estado, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2419 (class 0 OID 17188)
-- Dependencies: 204
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estado_civil (id_estado_civil, nombre) FROM stdin;
\.


--
-- TOC entry 2418 (class 0 OID 17181)
-- Dependencies: 203
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2417 (class 0 OID 17174)
-- Dependencies: 202
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY genero (id_genero, nombre) FROM stdin;
\.


--
-- TOC entry 2416 (class 0 OID 17166)
-- Dependencies: 201
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2437 (class 0 OID 0)
-- Dependencies: 181
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_cliente_seq', 1, false);


--
-- TOC entry 2438 (class 0 OID 0)
-- Dependencies: 183
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_seq', 1, false);


--
-- TOC entry 2439 (class 0 OID 0)
-- Dependencies: 185
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_rango_edad_seq', 1, false);


--
-- TOC entry 2440 (class 0 OID 0)
-- Dependencies: 186
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_usuario_seq', 1, false);


--
-- TOC entry 2413 (class 0 OID 17141)
-- Dependencies: 198
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2409 (class 0 OID 17081)
-- Dependencies: 194
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2410 (class 0 OID 17109)
-- Dependencies: 195
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2402 (class 0 OID 16908)
-- Dependencies: 187
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2412 (class 0 OID 17134)
-- Dependencies: 197
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY regimen_dieta (id_regimen_dieta, id_detalle_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2415 (class 0 OID 17159)
-- Dependencies: 200
-- Data for Name: regimen_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY regimen_ejercicio (id_plan_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2424 (class 0 OID 17225)
-- Dependencies: 209
-- Data for Name: regimen_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY regimen_suplemento (id_regimen_suplemento, id_plan_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2425 (class 0 OID 17232)
-- Dependencies: 210
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, precio, numero_visita, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2426 (class 0 OID 17242)
-- Dependencies: 211
-- Data for Name: servicio_parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY servicio_parametro (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2414 (class 0 OID 17151)
-- Dependencies: 199
-- Data for Name: suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2407 (class 0 OID 17055)
-- Dependencies: 192
-- Data for Name: tiempo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2406 (class 0 OID 16999)
-- Dependencies: 191
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2405 (class 0 OID 16981)
-- Dependencies: 190
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY unidad (id_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2403 (class 0 OID 16916)
-- Dependencies: 188
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus) FROM stdin;
\.


--
-- TOC entry 2267 (class 2606 OID 16936)
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 2277 (class 2606 OID 17194)
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- TOC entry 2269 (class 2606 OID 16940)
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- TOC entry 2275 (class 2606 OID 17180)
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- TOC entry 2271 (class 2606 OID 16944)
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- TOC entry 2273 (class 2606 OID 16946)
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 2281 (class 2620 OID 16947)
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: leo
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- TOC entry 2278 (class 2606 OID 16953)
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- TOC entry 2279 (class 2606 OID 16963)
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- TOC entry 2280 (class 2606 OID 16968)
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- TOC entry 2433 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2018-04-20 22:12:21 VET

--
-- PostgreSQL database dump complete
--

