--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.1
-- Dumped by pg_dump version 9.3.1
-- Started on 2018-04-01 16:43:30

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 174 (class 3079 OID 11750)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1970 (class 0 OID 0)
-- Dependencies: 174
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 187 (class 1255 OID 23261)
-- Name: fun_eliminar_cliente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fun_eliminar_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE BEGIN
	UPDATE cliente SET estatus = 0 WHERE cliente.id_suscripcion = OLD.id_suscripcion;
	RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_eliminar_cliente() OWNER TO postgres;

--
-- TOC entry 171 (class 1259 OID 23215)
-- Name: id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_cliente_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 173 (class 1259 OID 23240)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cliente (
    id_cliente integer DEFAULT nextval('id_cliente_seq'::regclass) NOT NULL,
    id_suscripcion integer NOT NULL,
    cedula character varying(10) DEFAULT ''::character varying NOT NULL,
    nombres character varying(50) DEFAULT ''::character varying NOT NULL,
    apellidos character varying(50) DEFAULT ''::character varying NOT NULL,
    telefono character varying(12) DEFAULT ''::character varying NOT NULL,
    direccion character varying(100) DEFAULT ''::character varying NOT NULL,
    fecha_nacimiento date NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 170 (class 1259 OID 23213)
-- Name: id_suscripcion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_suscripcion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_suscripcion_seq OWNER TO postgres;

--
-- TOC entry 172 (class 1259 OID 23217)
-- Name: suscripcion; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE suscripcion (
    id_suscripcion integer DEFAULT nextval('id_suscripcion_seq'::regclass) NOT NULL,
    correo character varying(100) DEFAULT ''::character varying NOT NULL,
    contrasenia character varying DEFAULT ''::character varying NOT NULL,
    salt character varying DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp without time zone,
    ultimo_acceso timestamp with time zone,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.suscripcion OWNER TO postgres;

--
-- TOC entry 1971 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN suscripcion.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN suscripcion.estatus IS '1: Activo
0: Eliminado';


--
-- TOC entry 1962 (class 0 OID 23240)
-- Dependencies: 173
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cliente (id_cliente, id_suscripcion, cedula, nombres, apellidos, telefono, direccion, fecha_nacimiento, fecha_creacion, fecha_actualizacion, estatus) FROM stdin;
10	10	V-24160052	Jose Alberto	Guerrero Carrillo	0414-5495292	Urb. El Amanecer, Cabudare	1994-06-07	2018-03-30 22:26:30.918-04:30	2018-03-30 22:26:30.918-04:30	1
2	2	V-24160052	Jose Alberto	Guerrero Carrillo	0414-5495292	Urb. El Amanecer, Cabudare	1994-06-07	2018-03-30 14:33:03.569-04:30	2018-03-30 14:33:03.569-04:30	0
4	4	V-24160052	Jose Alberto	Guerrero Carrillo	0414-5495292	Urb. El Amanecer, Cabudare	1994-06-07	2018-03-30 14:42:20.196-04:30	2018-03-30 14:42:20.196-04:30	0
3	3	V-24160052	Jose Alberto	Guerrero Carrillo	0414-5495292	Urb. El Amanecer, Cabudare	1994-06-07	2018-03-30 14:41:15.702-04:30	2018-03-30 14:41:15.702-04:30	0
\.


--
-- TOC entry 1972 (class 0 OID 0)
-- Dependencies: 171
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_cliente_seq', 10, true);


--
-- TOC entry 1973 (class 0 OID 0)
-- Dependencies: 170
-- Name: id_suscripcion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_suscripcion_seq', 10, true);


--
-- TOC entry 1961 (class 0 OID 23217)
-- Dependencies: 172
-- Data for Name: suscripcion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY suscripcion (id_suscripcion, correo, contrasenia, salt, fecha_creacion, fecha_actualizacion, ultimo_acceso, estatus) FROM stdin;
10	guerrero.c.jose.a@gmail.com	$2a$12$BqDiJzwvGZyPEYETCbjpeeflYu2/Zkrt7wMf.u8hPKGfjbQJVXBlW	$2a$12$BqDiJzwvGZyPEYETCbjpee	2018-03-30 22:26:30.918	\N	\N	1
2	guerrero.c.jose.a@gmail.com	$2a$12$iMNtPZoHYjt33IXrkConNegy5mEzCeCHbYK.YADHwL.lIpvdGQNOO	$2a$12$iMNtPZoHYjt33IXrkConNe	2018-03-30 14:33:03.555	\N	\N	0
3	guerrero.c.jose.a@gmail.com	$2a$12$zMd3.bRYfT.Zv9l7H9LbTu/JqsPO36RySJtETWmieNoHr/okOjgTm	$2a$12$zMd3.bRYfT.Zv9l7H9LbTu	2018-03-30 14:41:15.684	\N	\N	1
4	guerrero.c.jose.a@gmail.com	$2a$12$KVQFoCvP4VaC3NVxS01lBeh7ljWJufTO3iJffdnXOEkTAGfJNl03G	$2a$12$KVQFoCvP4VaC3NVxS01lBe	2018-03-30 14:42:20.148	\N	\N	1
\.


--
-- TOC entry 1849 (class 2606 OID 23253)
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 1847 (class 2606 OID 23230)
-- Name: suscripcion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY suscripcion
    ADD CONSTRAINT suscripcion_pkey PRIMARY KEY (id_suscripcion);


--
-- TOC entry 1851 (class 2620 OID 23265)
-- Name: dis_suscripcion_eliminada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_suscripcion_eliminada AFTER UPDATE OF estatus ON suscripcion FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- TOC entry 1850 (class 2606 OID 23254)
-- Name: cliente_id_suscripcion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES suscripcion(id_suscripcion);


--
-- TOC entry 1969 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2018-04-01 16:43:31

--
-- PostgreSQL database dump complete
--

