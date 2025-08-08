--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP SCHEMA IF EXISTS techdocs;
DROP SCHEMA IF EXISTS search;
DROP SCHEMA IF EXISTS scaffolder;
DROP SCHEMA IF EXISTS catalog;
DROP SCHEMA IF EXISTS auth;
--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- Name: catalog; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA catalog;


ALTER SCHEMA catalog OWNER TO postgres;

--
-- Name: scaffolder; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA scaffolder;


ALTER SCHEMA scaffolder OWNER TO postgres;

--
-- Name: search; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA search;


ALTER SCHEMA search OWNER TO postgres;

--
-- Name: techdocs; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA techdocs;


ALTER SCHEMA techdocs OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA auth TO backstage_user;


--
-- Name: SCHEMA catalog; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA catalog TO backstage_user;


--
-- Name: SCHEMA scaffolder; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA scaffolder TO backstage_user;


--
-- Name: SCHEMA search; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA search TO backstage_user;


--
-- Name: SCHEMA techdocs; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA techdocs TO backstage_user;


--
-- PostgreSQL database dump complete
--

