--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.1
-- Dumped by pg_dump version 9.3.1
-- Started on 2018-05-03 11:40:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 241 (class 1259 OID 35582)
-- Name: funcionalidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
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


ALTER TABLE public.funcionalidad OWNER TO postgres;

--
-- TOC entry 2264 (class 0 OID 35582)
-- Dependencies: 241
-- Data for Name: funcionalidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO funcionalidad VALUES (2, NULL, 'Registros Básicos', 'fa fa-edit', 2, 1, 1, '');
INSERT INTO funcionalidad VALUES (3, NULL, 'Configuración', 'fa fa-cogs', 3, 1, 1, '');
INSERT INTO funcionalidad VALUES (4, NULL, 'Visitas', 'fa fa-calendar', 4, 1, 1, '');
INSERT INTO funcionalidad VALUES (5, NULL, 'Ofertas y promociones', 'fa fa-tags', 5, 1, 1, '');
INSERT INTO funcionalidad VALUES (6, NULL, 'Reportes', 'fa fa-bar-chart-o', 6, 1, 1, '');
INSERT INTO funcionalidad VALUES (7, NULL, 'Administración del Sistema', 'fa fa-wrench', 7, 1, 1, '');
INSERT INTO funcionalidad VALUES (1, NULL, 'Dashboard', 'fa fa-leaf', 1, 1, 1, 'dashboard.html');


--
-- TOC entry 2154 (class 2606 OID 35589)
-- Name: funcionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_pkey PRIMARY KEY (id_funcionalidad);


--
-- TOC entry 2155 (class 2606 OID 35590)
-- Name: funcionalidad_id_funcionalidad_padre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY funcionalidad
    ADD CONSTRAINT funcionalidad_id_funcionalidad_padre_fkey FOREIGN KEY (id_funcionalidad_padre) REFERENCES funcionalidad(id_funcionalidad);


-- Completed on 2018-05-03 11:40:18

--
-- PostgreSQL database dump complete
--

