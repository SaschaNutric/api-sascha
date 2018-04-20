--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.1
-- Dumped by pg_dump version 9.3.1
-- Started on 2018-04-19 22:42:58

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

DROP DATABASE saschadb;
--
-- TOC entry 2027 (class 1262 OID 23212)
-- Name: saschadb; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE saschadb WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Bolivarian Republic of Venezuela.1252' LC_CTYPE = 'Spanish_Bolivarian Republic of Venezuela.1252';


ALTER DATABASE saschadb OWNER TO postgres;

\connect saschadb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 2028 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 181 (class 3079 OID 11750)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2030 (class 0 OID 0)
-- Dependencies: 181
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 195 (class 1255 OID 31667)
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
-- TOC entry 194 (class 1255 OID 31522)
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
-- TOC entry 176 (class 1259 OID 31551)
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
-- TOC entry 177 (class 1259 OID 31553)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 2031 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN cliente.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';


--
-- TOC entry 172 (class 1259 OID 31531)
-- Name: id_estado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_estado_seq OWNER TO postgres;

--
-- TOC entry 173 (class 1259 OID 31533)
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE estado (
    id_estado integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.estado OWNER TO postgres;

--
-- TOC entry 171 (class 1259 OID 31527)
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE estado_civil (
    id_estado_civil integer NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.estado_civil OWNER TO postgres;

--
-- TOC entry 170 (class 1259 OID 31523)
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE genero (
    id_genero integer NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.genero OWNER TO postgres;

--
-- TOC entry 174 (class 1259 OID 31541)
-- Name: id_rango_edad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_rango_edad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_rango_edad_seq OWNER TO postgres;

--
-- TOC entry 178 (class 1259 OID 31566)
-- Name: id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_usuario_seq OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 31543)
-- Name: rango_edad; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.rango_edad OWNER TO postgres;

--
-- TOC entry 179 (class 1259 OID 31568)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 2032 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo
0: Eliminado';


--
-- TOC entry 180 (class 1259 OID 31670)
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


ALTER TABLE public.vista_cliente OWNER TO postgres;

--
-- TOC entry 2020 (class 0 OID 31553)
-- Dependencies: 177
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO cliente VALUES (3, 8, 1, 2, 1, 3, 'V-24160052', 'Jose Alberto', 'Guerrero Carrillo', '0414-5495292', 'Urb. El Amanecer, Cabudare', '1994-06-07', 1, NULL, '2018-04-19 22:12:23.435-04:30', '2018-04-19 22:12:23.435-04:30', 1);


--
-- TOC entry 2016 (class 0 OID 31533)
-- Dependencies: 173
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


--
-- TOC entry 2014 (class 0 OID 31527)
-- Dependencies: 171
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO estado_civil VALUES (2, 'Comprometido/a');
INSERT INTO estado_civil VALUES (1, 'Soltero/a');
INSERT INTO estado_civil VALUES (4, 'Divorciado/a');
INSERT INTO estado_civil VALUES (3, 'Casado/a');
INSERT INTO estado_civil VALUES (5, 'Viudo/a');


--
-- TOC entry 2013 (class 0 OID 31523)
-- Dependencies: 170
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO genero VALUES (2, 'Femenino');
INSERT INTO genero VALUES (1, 'Masculino');


--
-- TOC entry 2033 (class 0 OID 0)
-- Dependencies: 176
-- Name: id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_cliente_seq', 2, true);


--
-- TOC entry 2034 (class 0 OID 0)
-- Dependencies: 172
-- Name: id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_estado_seq', 8, true);


--
-- TOC entry 2035 (class 0 OID 0)
-- Dependencies: 174
-- Name: id_rango_edad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_rango_edad_seq', 5, true);


--
-- TOC entry 2036 (class 0 OID 0)
-- Dependencies: 178
-- Name: id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_usuario_seq', 2, true);


--
-- TOC entry 2018 (class 0 OID 31543)
-- Dependencies: 175
-- Data for Name: rango_edad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO rango_edad VALUES (1, 'Bebe', 0, 1, '2018-04-19 21:11:06.606-04:30', '2018-04-19 21:11:06.606-04:30', 1);
INSERT INTO rango_edad VALUES (2, 'Niño/a', 1, 12, '2018-04-19 21:11:19.305-04:30', '2018-04-19 21:11:19.305-04:30', 1);
INSERT INTO rango_edad VALUES (3, 'Joven ', 12, 30, '2018-04-19 21:11:32.739-04:30', '2018-04-19 21:11:32.739-04:30', 1);
INSERT INTO rango_edad VALUES (4, 'Adulto', 30, 60, '2018-04-19 21:11:41.765-04:30', '2018-04-19 21:11:41.765-04:30', 1);
INSERT INTO rango_edad VALUES (5, 'Adulto mayor', 60, 120, '2018-04-19 21:12:03.981-04:30', '2018-04-19 21:12:03.981-04:30', 1);


--
-- TOC entry 2022 (class 0 OID 31568)
-- Dependencies: 179
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--


INSERT INTO usuario VALUES (1, 'jguerrero', 'guerrero.c.jose.a@gmail.com', '$2a$12$Zsfm7hKFFwzszEOGSuOS7ePL179wk2RfxNBObxu.Un/gZtVjHunj6', '$2a$12$Zsfm7hKFFwzszEOGSuOS7e', '2018-04-19 22:12:23.435', '2018-04-19 22:12:23.435', NULL, 1);


--
-- TOC entry 1895 (class 2606 OID 31591)
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 1889 (class 2606 OID 31585)
-- Name: estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- TOC entry 1891 (class 2606 OID 31587)
-- Name: estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- TOC entry 1887 (class 2606 OID 31583)
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- TOC entry 1893 (class 2606 OID 31589)
-- Name: rango_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- TOC entry 1897 (class 2606 OID 31593)
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 1903 (class 2620 OID 31668)
-- Name: dis_asignar_rango_edad; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_asignar_rango_edad AFTER INSERT ON cliente FOR EACH ROW EXECUTE PROCEDURE fun_asignar_rango_edad();


--
-- TOC entry 1904 (class 2620 OID 31594)
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- TOC entry 1900 (class 2606 OID 31605)
-- Name: cliente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil);


--
-- TOC entry 1901 (class 2606 OID 31610)
-- Name: cliente_id_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);


--
-- TOC entry 1899 (class 2606 OID 31600)
-- Name: cliente_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);


--
-- TOC entry 1902 (class 2606 OID 31615)
-- Name: cliente_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);


--
-- TOC entry 1898 (class 2606 OID 31595)
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


--
-- TOC entry 2029 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2018-04-19 22:42:59

--
-- PostgreSQL database dump complete
--

