--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.11
-- Dumped by pg_dump version 9.5.11

-- Started on 2018-04-21 20:56:30 VET

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
-- TOC entry 2522 (class 0 OID 0)
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
-- TOC entry 207 (class 1259 OID 17216)
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
-- TOC entry 2523 (class 0 OID 0)
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
-- TOC entry 206 (class 1259 OID 17209)
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
-- TOC entry 205 (class 1259 OID 17202)
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
-- TOC entry 204 (class 1259 OID 17195)
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
-- TOC entry 203 (class 1259 OID 17188)
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado_civil (
    id_estado_civil integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE estado_civil OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 17181)
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
-- TOC entry 201 (class 1259 OID 17174)
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE genero (
    id_genero integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE genero OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 17166)
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
-- TOC entry 211 (class 1259 OID 17364)
-- Name: regimen_ejercicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE regimen_ejercicio (
    id_regimen_ejercicio integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    id_plan_ejercicio integer NOT NULL,
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
-- TOC entry 208 (class 1259 OID 17225)
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
-- TOC entry 209 (class 1259 OID 17232)
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
-- TOC entry 210 (class 1259 OID 17242)
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
-- TOC entry 2524 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: leo
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo
0: Eliminado';


--
-- TOC entry 2510 (class 0 OID 17216)
-- Dependencies: 207
-- Data for Name: alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY alimento (id_alimento, id_grupo_alimenticio, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2485 (class 0 OID 16873)
-- Dependencies: 182
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY cliente (id_cliente, id_usuario, id_genero, id_estado, id_estado_civil, id_rango_edad, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, tipo_cliente, fecha_consolidado, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2492 (class 0 OID 16973)
-- Dependencies: 189
-- Data for Name: comida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY comida (id_comida, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2509 (class 0 OID 17209)
-- Dependencies: 206
-- Data for Name: detalle_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_dieta (id_detalle_dieta, id_plan_dieta, id_comida, id_grupo_alimenticio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2508 (class 0 OID 17202)
-- Dependencies: 205
-- Data for Name: detalle_plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_ejercicio (id_detalle_plan_ejercicio, id_plan_ejercicio, id_ejercicio, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2499 (class 0 OID 17127)
-- Dependencies: 196
-- Data for Name: detalle_plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_plan_suplemento (id_detalle_plan_suplemento, id_plan_suplemento, id_suplemento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2507 (class 0 OID 17195)
-- Dependencies: 204
-- Data for Name: detalle_regimen_alimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY detalle_regimen_alimento (id_regimen_dieta, id_alimento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2496 (class 0 OID 17072)
-- Dependencies: 193
-- Data for Name: ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ejercicio (id_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2487 (class 0 OID 16888)
-- Dependencies: 184
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY estado (id_estado, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	Lara	2018-04-20 00:00:00-04	2018-04-20 00:00:00-04	1
\.


--
-- TOC entry 2506 (class 0 OID 17188)
-- Dependencies: 203
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estado_civil (id_estado_civil, nombre) FROM stdin;
4	Viudo(a)
3	Divorciado(a)
2	Casado(a)
1	Soltero(a)
\.


--
-- TOC entry 2505 (class 0 OID 17181)
-- Dependencies: 202
-- Data for Name: frecuencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY frecuencia (id_frecuencia, id_tiempo, repeticiones, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2504 (class 0 OID 17174)
-- Dependencies: 201
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY genero (id_genero, nombre) FROM stdin;
1	Masculino
2	Femenino
\.


--
-- TOC entry 2503 (class 0 OID 17166)
-- Dependencies: 200
-- Data for Name: grupo_alimenticio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY grupo_alimenticio (id_grupo_alimenticio, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2525 (class 0 OID 0)
-- Dependencies: 181
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_cliente_seq', 1, true);


--
-- TOC entry 2526 (class 0 OID 0)
-- Dependencies: 183
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_estado_seq', 7, true);


--
-- TOC entry 2527 (class 0 OID 0)
-- Dependencies: 185
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_rango_edad_seq', 1, false);


--
-- TOC entry 2528 (class 0 OID 0)
-- Dependencies: 186
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: leo
--

SELECT pg_catalog.setval('id_usuario_seq', 1, true);


--
-- TOC entry 2501 (class 0 OID 17141)
-- Dependencies: 198
-- Data for Name: plan_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plan_dieta (id_plan_dieta, id_tipo_dieta, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	plan dieta	descripcion	2018-02-05 00:00:00-04	2018-04-05 00:00:00-04	1
\.


--
-- TOC entry 2497 (class 0 OID 17081)
-- Dependencies: 194
-- Data for Name: plan_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plan_ejercicio (id_plan_ejercicio, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	ejercicio	descripcion	2018-05-04 00:00:00-04	2018-06-08 00:00:00-04	1
\.


--
-- TOC entry 2498 (class 0 OID 17109)
-- Dependencies: 195
-- Data for Name: plan_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plan_suplemento (id_plan_suplemento, nombre, descripcion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	suplemento	descripcion	2018-07-04 00:00:00-04	2018-07-09 00:00:00-04	1
\.


--
-- TOC entry 2490 (class 0 OID 16908)
-- Dependencies: 187
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY rango_edad (id_rango_edad, nombre, minimo, maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2500 (class 0 OID 17134)
-- Dependencies: 197
-- Data for Name: regimen_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY regimen_dieta (id_regimen_dieta, id_detalle_dieta, id_cliente, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2514 (class 0 OID 17364)
-- Dependencies: 211
-- Data for Name: regimen_ejercicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY regimen_ejercicio (id_regimen_ejercicio, id_plan_ejercicio, id_cliente, id_frecuencia, id_tiempo, duracion, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2511 (class 0 OID 17225)
-- Dependencies: 208
-- Data for Name: regimen_suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY regimen_suplemento (id_regimen_suplemento, id_plan_suplemento, id_cliente, id_frecuencia, cantidad, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2512 (class 0 OID 17232)
-- Dependencies: 209
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY servicio (id_servicio, id_plan_dieta, id_plan_ejercicio, id_plan_suplemento, nombre, descripcion, url_imagen, precio, numero_visita, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	1	1	1	nombre del servicio	descripcion del servicio	url de la imagen	34	5	2018-04-06 00:00:00-04	2018-05-06 00:00:00-04	1
2	1	1	1	bbn	req.body.descripcion	req.body.url_imagen	788390	6	2018-04-21 20:53:05.962768-04	2018-04-21 20:53:05.962768-04	1
\.


--
-- TOC entry 2513 (class 0 OID 17242)
-- Dependencies: 210
-- Data for Name: servicio_parametro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY servicio_parametro (id_servicio, id_parametro, valor_minimo, valor_maximo, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2502 (class 0 OID 17151)
-- Dependencies: 199
-- Data for Name: suplemento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY suplemento (id_suplemento, id_unidad, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2495 (class 0 OID 17055)
-- Dependencies: 192
-- Data for Name: tiempo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tiempo (id_tiempo, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2494 (class 0 OID 16999)
-- Dependencies: 191
-- Data for Name: tipo_dieta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tipo_dieta (id_tipo_dieta, nombre, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
1	tipo dieta	2018-04-02 00:00:00-04	2018-05-02 00:00:00-04	1
\.


--
-- TOC entry 2493 (class 0 OID 16981)
-- Dependencies: 190
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY unidad (id_unidad, nombre, abreviatura, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
\.


--
-- TOC entry 2491 (class 0 OID 16916)
-- Dependencies: 188
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: leo
--

COPY usuario (id_usuario, nombre_usuario, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus) FROM stdin;
\.


--
-- TOC entry 2275 (class 2606 OID 17249)
-- Name: PK_id_comida; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comida
    ADD CONSTRAINT "PK_id_comida" PRIMARY KEY (id_comida);


--
-- TOC entry 2320 (class 2606 OID 17281)
-- Name: PK_id_detalle_dieta; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_dieta
    ADD CONSTRAINT "PK_id_detalle_dieta" PRIMARY KEY (id_detalle_dieta);


--
-- TOC entry 2304 (class 2606 OID 17273)
-- Name: PK_id_grupo_alimento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT "PK_id_grupo_alimento" PRIMARY KEY (id_grupo_alimenticio);


--
-- TOC entry 2322 (class 2606 OID 17426)
-- Name: alimento_id_alimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_alimento_pkey PRIMARY KEY (id_alimento);


--
-- TOC entry 2267 (class 2606 OID 16936)
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 2313 (class 2606 OID 17317)
-- Name: detalle_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_pkey PRIMARY KEY (id_detalle_plan_ejercicio);


--
-- TOC entry 2289 (class 2606 OID 17400)
-- Name: detalle_plan_suplemento_id_detalle_plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_detalle_plan_suplemento_pkey PRIMARY KEY (id_detalle_plan_suplemento);


--
-- TOC entry 2283 (class 2606 OID 17398)
-- Name: ejercicio_id_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ejercicio
    ADD CONSTRAINT ejercicio_id_ejercicio_pkey PRIMARY KEY (id_ejercicio);


--
-- TOC entry 2311 (class 2606 OID 17194)
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
-- TOC entry 2309 (class 2606 OID 17337)
-- Name: frecuencia_id_frecuencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_id_frecuencia_pkey PRIMARY KEY (id_frecuencia);


--
-- TOC entry 2306 (class 2606 OID 17180)
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- TOC entry 2298 (class 2606 OID 17257)
-- Name: plan_dieta_id_plan_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_plan_dieta_pkey PRIMARY KEY (id_plan_dieta);


--
-- TOC entry 2285 (class 2606 OID 17319)
-- Name: plan_ejercicio_id_plan_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_ejercicio
    ADD CONSTRAINT plan_ejercicio_id_plan_ejercicio_pkey PRIMARY KEY (id_plan_ejercicio);


--
-- TOC entry 2287 (class 2606 OID 17321)
-- Name: plan_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_suplemento
    ADD CONSTRAINT plan_suplemento_pkey PRIMARY KEY (id_plan_suplemento);


--
-- TOC entry 2271 (class 2606 OID 16944)
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- TOC entry 2295 (class 2606 OID 17283)
-- Name: regimen_dieta_id_regimen_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_regimen_dieta_pkey PRIMARY KEY (id_regimen_dieta);


--
-- TOC entry 2341 (class 2606 OID 17372)
-- Name: regimen_ejercicio_id_regimen_ejercicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_regimen_ejercicio_pkey PRIMARY KEY (id_regimen_ejercicio);


--
-- TOC entry 2328 (class 2606 OID 17345)
-- Name: regimen_suplemento_id_regimen_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_regimen_suplemento_pkey PRIMARY KEY (id_regimen_suplemento);


--
-- TOC entry 2333 (class 2606 OID 17309)
-- Name: servicio_id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- TOC entry 2335 (class 2606 OID 17335)
-- Name: servicio_parametro_id_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio_parametro
    ADD CONSTRAINT servicio_parametro_id_servicio_pkey PRIMARY KEY (id_servicio);


--
-- TOC entry 2301 (class 2606 OID 17301)
-- Name: suplemento_id_suplemento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_suplemento_pkey PRIMARY KEY (id_suplemento);


--
-- TOC entry 2281 (class 2606 OID 17299)
-- Name: tiempo_id_tiempo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tiempo
    ADD CONSTRAINT tiempo_id_tiempo_pkey PRIMARY KEY (id_tiempo);


--
-- TOC entry 2279 (class 2606 OID 17297)
-- Name: tipo_dieta_id_tipo_dieta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_dieta
    ADD CONSTRAINT tipo_dieta_id_tipo_dieta_pkey PRIMARY KEY (id_tipo_dieta);


--
-- TOC entry 2277 (class 2606 OID 17265)
-- Name: unidad_id_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_id_unidad_pkey PRIMARY KEY (id_unidad);


--
-- TOC entry 2273 (class 2606 OID 16946)
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 2316 (class 1259 OID 17255)
-- Name: FKI_id_comida; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_id_comida" ON detalle_dieta USING btree (id_comida);


--
-- TOC entry 2292 (class 1259 OID 17289)
-- Name: FKI_id_detalle_dieta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_id_detalle_dieta" ON regimen_dieta USING btree (id_detalle_dieta);


--
-- TOC entry 2317 (class 1259 OID 17279)
-- Name: FKI_id_grupo_alimento; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_id_grupo_alimento" ON detalle_dieta USING btree (id_grupo_alimenticio);


--
-- TOC entry 2318 (class 1259 OID 17263)
-- Name: FKI_id_plan_dieta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_id_plan_dieta" ON detalle_dieta USING btree (id_plan_dieta);


--
-- TOC entry 2302 (class 1259 OID 17271)
-- Name: FKI_id_unidad; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FKI_id_unidad" ON grupo_alimenticio USING btree (id_unidad);


--
-- TOC entry 2323 (class 1259 OID 17432)
-- Name: fki_alimento_id_grupo_alimento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_alimento_id_grupo_alimento_fkey ON alimento USING btree (id_grupo_alimenticio);


--
-- TOC entry 2314 (class 1259 OID 17418)
-- Name: fki_detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey ON detalle_plan_ejercicio USING btree (id_plan_ejercicio);


--
-- TOC entry 2315 (class 1259 OID 17424)
-- Name: fki_detalle_plan_ejercicio_id_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_ejercicio_id_ejercicio_fkey ON detalle_plan_ejercicio USING btree (id_ejercicio);


--
-- TOC entry 2290 (class 1259 OID 17406)
-- Name: fki_detalle_plan_suplemento_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_suplemento_id_plan_suplemento_fkey ON detalle_plan_suplemento USING btree (id_plan_suplemento);


--
-- TOC entry 2291 (class 1259 OID 17412)
-- Name: fki_detalle_plan_suplemento_id_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_detalle_plan_suplemento_id_suplemento_fkey ON detalle_plan_suplemento USING btree (id_suplemento);


--
-- TOC entry 2307 (class 1259 OID 17343)
-- Name: fki_frecuencia_id_tiempo_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_frecuencia_id_tiempo_fkey ON frecuencia USING btree (id_tiempo);


--
-- TOC entry 2296 (class 1259 OID 17443)
-- Name: fki_plan_dieta_idtipo_dieta_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_plan_dieta_idtipo_dieta_fkey ON plan_dieta USING btree (id_tipo_dieta);


--
-- TOC entry 2293 (class 1259 OID 17295)
-- Name: fki_regimen_dieta_id_cliente_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_dieta_id_cliente_fkey ON regimen_dieta USING btree (id_cliente);


--
-- TOC entry 2336 (class 1259 OID 17384)
-- Name: fki_regimen_ejercicio_id_cliente_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_ejercicio_id_cliente_fkey ON regimen_ejercicio USING btree (id_cliente);


--
-- TOC entry 2337 (class 1259 OID 17390)
-- Name: fki_regimen_ejercicio_id_frecuencia_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_ejercicio_id_frecuencia_fkey ON regimen_ejercicio USING btree (id_frecuencia);


--
-- TOC entry 2338 (class 1259 OID 17378)
-- Name: fki_regimen_ejercicio_id_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_ejercicio_id_plan_ejercicio_fkey ON regimen_ejercicio USING btree (id_plan_ejercicio);


--
-- TOC entry 2339 (class 1259 OID 17396)
-- Name: fki_regimen_ejercicio_id_tiempo_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_ejercicio_id_tiempo_fkey ON regimen_ejercicio USING btree (id_tiempo);


--
-- TOC entry 2324 (class 1259 OID 17357)
-- Name: fki_regimen_suplemento_id_cliente_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_suplemento_id_cliente_fkey ON regimen_suplemento USING btree (id_cliente);


--
-- TOC entry 2325 (class 1259 OID 17363)
-- Name: fki_regimen_suplemento_id_frecuencia_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_suplemento_id_frecuencia_fkey ON regimen_suplemento USING btree (id_frecuencia);


--
-- TOC entry 2326 (class 1259 OID 17351)
-- Name: fki_regimen_suplemento_id_plan_suplemento_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_regimen_suplemento_id_plan_suplemento_fkey ON regimen_suplemento USING btree (id_plan_suplemento);


--
-- TOC entry 2329 (class 1259 OID 17315)
-- Name: fki_servicio_id_plan_dieta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_servicio_id_plan_dieta ON servicio USING btree (id_plan_dieta);


--
-- TOC entry 2330 (class 1259 OID 17327)
-- Name: fki_servicio_id_plan_ejercicio_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_servicio_id_plan_ejercicio_fkey ON servicio USING btree (id_plan_ejercicio);


--
-- TOC entry 2331 (class 1259 OID 17333)
-- Name: fki_servicio_id_plan_suplemento_pkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_servicio_id_plan_suplemento_pkey ON servicio USING btree (id_plan_suplemento);


--
-- TOC entry 2299 (class 1259 OID 17307)
-- Name: fki_suplemento_id_unidad_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_suplemento_id_unidad_fkey ON suplemento USING btree (id_unidad);


--
-- TOC entry 2369 (class 2620 OID 16947)
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: leo
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- TOC entry 2355 (class 2606 OID 17250)
-- Name: FK_id_comida; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_dieta
    ADD CONSTRAINT "FK_id_comida" FOREIGN KEY (id_comida) REFERENCES comida(id_comida);


--
-- TOC entry 2357 (class 2606 OID 17274)
-- Name: FK_id_grupo_alimento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_dieta
    ADD CONSTRAINT "FK_id_grupo_alimento" FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- TOC entry 2356 (class 2606 OID 17258)
-- Name: FK_id_plan_dieta; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_dieta
    ADD CONSTRAINT "FK_id_plan_dieta" FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- TOC entry 2351 (class 2606 OID 17266)
-- Name: FK_id_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY grupo_alimenticio
    ADD CONSTRAINT "FK_id_unidad" FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- TOC entry 2358 (class 2606 OID 17427)
-- Name: alimento_id_grupo_alimento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alimento
    ADD CONSTRAINT alimento_id_grupo_alimento_fkey FOREIGN KEY (id_grupo_alimenticio) REFERENCES grupo_alimenticio(id_grupo_alimenticio);


--
-- TOC entry 2342 (class 2606 OID 16953)
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- TOC entry 2343 (class 2606 OID 16963)
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- TOC entry 2344 (class 2606 OID 16968)
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leo
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- TOC entry 2353 (class 2606 OID 17413)
-- Name: detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_detalle_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- TOC entry 2354 (class 2606 OID 17419)
-- Name: detalle_plan_ejercicio_id_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_ejercicio
    ADD CONSTRAINT detalle_plan_ejercicio_id_ejercicio_fkey FOREIGN KEY (id_ejercicio) REFERENCES ejercicio(id_ejercicio);


--
-- TOC entry 2345 (class 2606 OID 17401)
-- Name: detalle_plan_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- TOC entry 2346 (class 2606 OID 17407)
-- Name: detalle_plan_suplemento_id_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY detalle_plan_suplemento
    ADD CONSTRAINT detalle_plan_suplemento_id_suplemento_fkey FOREIGN KEY (id_suplemento) REFERENCES suplemento(id_suplemento);


--
-- TOC entry 2352 (class 2606 OID 17338)
-- Name: frecuencia_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY frecuencia
    ADD CONSTRAINT frecuencia_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- TOC entry 2349 (class 2606 OID 17438)
-- Name: plan_dieta_id_tipo_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_dieta
    ADD CONSTRAINT plan_dieta_id_tipo_dieta_fkey FOREIGN KEY (id_tipo_dieta) REFERENCES tipo_dieta(id_tipo_dieta);


--
-- TOC entry 2348 (class 2606 OID 17290)
-- Name: regimen_dieta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- TOC entry 2347 (class 2606 OID 17284)
-- Name: regimen_dieta_id_detalle_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_dieta
    ADD CONSTRAINT regimen_dieta_id_detalle_dieta_fkey FOREIGN KEY (id_detalle_dieta) REFERENCES detalle_dieta(id_detalle_dieta);


--
-- TOC entry 2366 (class 2606 OID 17379)
-- Name: regimen_ejercicio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- TOC entry 2367 (class 2606 OID 17385)
-- Name: regimen_ejercicio_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- TOC entry 2365 (class 2606 OID 17373)
-- Name: regimen_ejercicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- TOC entry 2368 (class 2606 OID 17391)
-- Name: regimen_ejercicio_id_tiempo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_ejercicio
    ADD CONSTRAINT regimen_ejercicio_id_tiempo_fkey FOREIGN KEY (id_tiempo) REFERENCES tiempo(id_tiempo);


--
-- TOC entry 2360 (class 2606 OID 17352)
-- Name: regimen_suplemento_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);


--
-- TOC entry 2361 (class 2606 OID 17358)
-- Name: regimen_suplemento_id_frecuencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_frecuencia_fkey FOREIGN KEY (id_frecuencia) REFERENCES frecuencia(id_frecuencia);


--
-- TOC entry 2359 (class 2606 OID 17346)
-- Name: regimen_suplemento_id_plan_suplemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_suplemento
    ADD CONSTRAINT regimen_suplemento_id_plan_suplemento_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- TOC entry 2363 (class 2606 OID 17310)
-- Name: servicio_id_plan_dieta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_dieta_fkey FOREIGN KEY (id_plan_dieta) REFERENCES plan_dieta(id_plan_dieta);


--
-- TOC entry 2362 (class 2606 OID 17322)
-- Name: servicio_id_plan_ejercicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_ejercicio_fkey FOREIGN KEY (id_plan_ejercicio) REFERENCES plan_ejercicio(id_plan_ejercicio);


--
-- TOC entry 2364 (class 2606 OID 17433)
-- Name: servicio_id_plan_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicio
    ADD CONSTRAINT servicio_id_plan_servicio_fkey FOREIGN KEY (id_plan_suplemento) REFERENCES plan_suplemento(id_plan_suplemento);


--
-- TOC entry 2350 (class 2606 OID 17302)
-- Name: suplemento_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suplemento
    ADD CONSTRAINT suplemento_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES unidad(id_unidad);


--
-- TOC entry 2521 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2018-04-21 20:56:30 VET

--
-- PostgreSQL database dump complete
--

