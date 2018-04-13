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
	UPDATE cliente SET estatus = 0 WHERE cliente.id_usuario = OLD.id_usuario;
	RETURN NULL;
END
$$;


ALTER FUNCTION public.fun_eliminar_cliente() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE genero (
    id_genero integer NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.genero OWNER TO postgres;


CREATE TABLE estado_civil (
    id_estado_civil integer NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.estado_civil OWNER TO postgres;


CREATE SEQUENCE id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.id_estado_seq OWNER TO postgres;


CREATE TABLE estado (
    id_estado integer DEFAULT nextval('id_estado_seq'::regclass) NOT NULL,
    nombre character varying(50) DEFAULT ''::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.estado OWNER TO postgres;


CREATE SEQUENCE id_rango_edad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.id_rango_edad_seq OWNER TO postgres;


CREATE TABLE rango_edad (
    id_rango_edad integer DEFAULT nextval('id_rango_edad_seq'::regclass) NOT NULL,
    nombre character varying(20) DEFAULT ''::character varying NOT NULL,
    minimo integer NOT NULL,
    maximo integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL,
    estatus integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.estado_civil OWNER TO postgres;


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

--
-- TOC entry 173 (class 1259 OID 23240)
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


COMMENT ON COLUMN cliente.estatus IS '1: Potencial 2: Consolidado';

--
-- TOC entry 170 (class 1259 OID 23213)
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
-- TOC entry 172 (class 1259 OID 23217)
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
-- TOC entry 1971 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN usuario.estatus; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN usuario.estatus IS '1: Activo
0: Eliminado';

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


ALTER TABLE ONLY estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


ALTER TABLE ONLY rango_edad
    ADD CONSTRAINT rango_edad_pkey PRIMARY KEY (id_rango_edad);


--
-- TOC entry 1849 (class 2606 OID 23253)
-- Name: cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--


ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 1847 (class 2606 OID 23230)
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 1851 (class 2620 OID 23265)
-- Name: dis_usuario_eliminada; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dis_usuario_eliminada AFTER UPDATE OF estatus ON usuario FOR EACH ROW WHEN ((new.estatus = 0)) EXECUTE PROCEDURE fun_eliminar_cliente();


--
-- TOC entry 1850 (class 2606 OID 23254)
-- Name: cliente_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario);


ALTER TABLE ONLY cliente 
    ADD CONSTRAINT cliente_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES genero(id_genero);

ALTER TABLE ONLY cliente 
    ADD CONSTRAINT cliente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil);

ALTER TABLE ONLY cliente 
    ADD CONSTRAINT cliente_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado);

ALTER TABLE ONLY cliente
    ADD CONSTRAINT cliente_id_rango_edad_fkey FOREIGN KEY (id_rango_edad) REFERENCES rango_edad(id_rango_edad);     



CREATE VIEW v_cliente AS
SELECT a.id_cliente, 
    a.id_usuario,
    a.cedula, 
    a.nombres, 
    a.apellidos, 
    b.id_genero,
    b.nombre as genero,
    c.id_estado_civil,
    c.nombre as estado_civil, 
    a.fecha_nacimiento,
    a.telefono,
    a.direccion, 
    d.id_estado,
    d.nombre as estado, 
    a.tipo_cliente
   FROM (((cliente a
   JOIN genero b ON (a.id_genero = b.id_genero))
   JOIN estado_civil c ON (a.id_estado_civil = c.id_estado_civil))
   JOIN estado d ON (a.id_estado = d.id_estado))
  WHERE (a.estatus = 1);


ALTER TABLE public.v_cliente OWNER TO postgres;


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

