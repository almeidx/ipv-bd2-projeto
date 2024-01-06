--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Ubuntu 14.5-2.pgdg20.04+2)
-- Dumped by pg_dump version 15.0 (Ubuntu 15.0-1.pgdg20.04+1)

-- Started on 2024-01-06 17:29:27 UTC

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

--
-- TOC entry 3651 (class 1262 OID 30284)
-- Name: aluno5; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE aluno5 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


\connect aluno5

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

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- TOC entry 345 (class 1255 OID 37479)
-- Name: fn_check_if_there_are_users(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_check_if_there_are_users() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM ipv_bd2_projeto_utilizador;

    IF user_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;


--
-- TOC entry 299 (class 1255 OID 37056)
-- Name: fn_create_encomenda_componentes(timestamp without time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_create_encomenda_componentes(p_created_at timestamp without time zone, p_funcionario_id integer, p_fornecedor_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    encomenda_id INT;
BEGIN
    INSERT INTO ipv_bd2_projeto_encomendacomponente(created_at, funcionario_responsavel_id_id, fornecedor_id_id, exported)
    VALUES (p_created_at, p_funcionario_id, p_fornecedor_id, FALSE)
    RETURNING id INTO encomenda_id;

    RETURN encomenda_id;
END;
$$;


--
-- TOC entry 304 (class 1255 OID 37342)
-- Name: fn_create_encomenda_equipamento(timestamp without time zone, character varying, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_create_encomenda_equipamento(p_created_at timestamp without time zone, address character varying, postal_code character varying, locality character varying, p_funcionario_id integer, p_client_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    encomenda_id INT;
BEGIN
    INSERT INTO ipv_bd2_projeto_encomendaequipamento(created_at, address, postal_code, locality, client_id_id, funcionario_id_id )
    VALUES (p_created_at, address, postal_code, locality, p_client_id, p_funcionario_id)
    RETURNING id INTO encomenda_id;

    RETURN encomenda_id;
END;
$$;


--
-- TOC entry 310 (class 1255 OID 37336)
-- Name: fn_create_equipment(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_create_equipment(p_equipmentname character varying, p_tipoequipamentoid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_equipment_id INTEGER;
BEGIN
    INSERT INTO ipv_bd2_projeto_equipamento (name, tipo_equipamento_id_id, created_at)
    VALUES (p_equipmentname, p_tipoequipamentoid, CURRENT_DATE)
    RETURNING id INTO new_equipment_id;

    RAISE NOTICE 'Equipamento criado com sucesso. ID: %', new_equipment_id;

    RETURN new_equipment_id;
END;
$$;


--
-- TOC entry 332 (class 1255 OID 37459)
-- Name: fn_create_guia_entrega_componentes(date, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_create_guia_entrega_componentes(p_created_at date, p_armazem_id_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_guia_id INTEGER;
BEGIN
    INSERT INTO ipv_bd2_projeto_guiaentregacomponente (created_at, armazem_id_id )
    VALUES (p_created_at, p_armazem_id_id)
	RETURNING id INTO new_guia_id;

	RAISE NOTICE 'Guia criado com sucesso. ID: %', new_guia_id;

    RETURN new_guia_id;
END;
$$;


--
-- TOC entry 312 (class 1255 OID 37388)
-- Name: fn_create_production_registry(date, date, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_create_production_registry(p_started_at date, p_ended_at date, p_armazem_id_id integer, p_equipamento_id_id integer, p_funcionario_id_id integer, p_tipo_mao_de_obra_id_id integer, OUT p_inserted_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_registoproducao (
        started_at,
        ended_at,
        armazem_id_id,
        equipamento_id_id,
        funcionario_id_id,
        tipo_mao_de_obra_id_id
    )
    VALUES (
        p_started_at,
        p_ended_at,
        p_armazem_id_id,
        p_equipamento_id_id,
        p_funcionario_id_id,
        p_tipo_mao_de_obra_id_id
    )
	 RETURNING ipv_bd2_projeto_registoproducao.id INTO p_inserted_id;
END;
$$;


--
-- TOC entry 301 (class 1255 OID 37222)
-- Name: fn_delete_armazem_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_armazem_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o armazém está sendo usado em algum lugar
    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.id = p_id) INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o armazém, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = p_id) THEN
            DELETE FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = p_id;
            RAISE NOTICE 'Armazem apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Armazem não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 314 (class 1255 OID 37287)
-- Name: fn_delete_component_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_component_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o componente está sendo usado em algum lugar
	SELECT
        EXISTS (
            SELECT 1 FROM ipv_bd2_projeto_quantidadeencomendacomponente
            WHERE ipv_bd2_projeto_quantidadeencomendacomponente.componente_id = p_id
        ) OR
        EXISTS (
            SELECT 1 FROM ipv_bd2_projeto_quantidadeguiaentregacomponente
            WHERE ipv_bd2_projeto_quantidadeguiaentregacomponente.componente_id = p_id
        ) OR
        EXISTS (
            SELECT 1 FROM ipv_bd2_projeto_quantidadecomponenteregistoproducao
            WHERE ipv_bd2_projeto_quantidadecomponenteregistoproducao.componente_id = p_id
        )
        INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o componente, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_componente WHERE ipv_bd2_projeto_componente.id = p_id) THEN
            DELETE FROM ipv_bd2_projeto_componente WHERE ipv_bd2_projeto_componente.id = p_id;
            RAISE NOTICE 'Componente apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Componente não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 328 (class 1255 OID 37433)
-- Name: fn_delete_encomenda_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_encomenda_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se a encomenda está sendo usada em algum lugar
    SELECT
        EXISTS (
            SELECT 1 FROM ipv_bd2_projeto_expedicao
            WHERE ipv_bd2_projeto_expedicao.encomenda_id_id = p_id
        ) OR
        INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar a encomenda, pois está sendo usada em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usada, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_encomendaequipamento WHERE ipv_bd2_projeto_encomendaequipamento.id = p_id) THEN
			DELETE FROM ipv_bd2_projeto_quantidadeencomendaequipamento WHERE ipv_bd2_projeto_quantidadeencomendaequipamento.encomenda_id = p_id;
            DELETE FROM ipv_bd2_projeto_encomendaequipamento WHERE ipv_bd2_projeto_encomendaequipamento.id = p_id;
            RAISE NOTICE 'Encomenda apagada com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Encomenda não encontrada.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 316 (class 1255 OID 37377)
-- Name: fn_delete_encomenda_componente(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_encomenda_componente(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ipv_bd2_projeto_encomendacomponente
        WHERE ipv_bd2_projeto_encomendacomponente.id = p_id AND ipv_bd2_projeto_encomendacomponente.exported = TRUE
    ) THEN
        RAISE NOTICE 'Não é possível apagar a encomenda, pois já foi exportada.';
        RETURN FALSE;
    ELSE
		DELETE FROM ipv_bd2_projeto_quantidadeencomendacomponente WHERE ipv_bd2_projeto_quantidadeencomendacomponente.encomenda_id = p_id;
        DELETE FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.id = p_id;
        RAISE NOTICE 'Encomenda apagada com sucesso.';
        RETURN TRUE;
    END IF;
END;
$$;


--
-- TOC entry 309 (class 1255 OID 37282)
-- Name: fn_delete_equipment_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_equipment_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o equipamento está sendo usado em algum lugar
    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_quantidadeencomendaequipamento WHERE ipv_bd2_projeto_quantidadeencomendaequipamento.equipamento_id = p_id) INTO item_in_use;

    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.equipamento_id_id = p_id) INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o equipamento, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_equipamento WHERE ipv_bd2_projeto_equipamento.id = p_id) THEN
            DELETE FROM ipv_bd2_projeto_equipamento WHERE ipv_bd2_projeto_equipamento.id = p_id;
            RAISE NOTICE 'Equipamento apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Equipamento não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 308 (class 1255 OID 37228)
-- Name: fn_delete_fornecedor_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_fornecedor_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o fornecedor está sendo usado em algum lugar
    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_componente WHERE ipv_bd2_projeto_componente.fornecedor_id_id = p_id) INTO item_in_use;

	SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.fornecedor_id_id = p_id) INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o fornecedor, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.id = p_id) THEN
            DELETE FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.id = p_id;
            RAISE NOTICE 'Fornecedor apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Fornecedor não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 300 (class 1255 OID 37224)
-- Name: fn_delete_labor_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_labor_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o labor está sendo usado em algum lugar
    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.id = p_id) INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o labor, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = p_id) THEN
            DELETE FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = p_id;
            RAISE NOTICE 'Labor apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Labor não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 319 (class 1255 OID 37394)
-- Name: fn_delete_registo_producao_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_registo_producao_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
	SELECT
        EXISTS (
            SELECT 1 FROM ipv_bd2_projeto_registoproducao
            WHERE ipv_bd2_projeto_registoproducao.id = p_id AND ipv_bd2_projeto_registoproducao.expedicao_id_id IS NOT NULL
        )
        INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o registo de produção, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.id = p_id) THEN
			DELETE FROM ipv_bd2_projeto_quantidadecomponenteregistoproducao WHERE ipv_bd2_projeto_quantidadecomponenteregistoproducao.registo_producao_id = p_id;
            DELETE FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.id = p_id;
            RAISE NOTICE 'Registo de produção apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Registo de produção não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 303 (class 1255 OID 37227)
-- Name: fn_delete_tipo_equipamento_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_delete_tipo_equipamento_by_id(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o tipo de equipamento está sendo usado em algum lugar
    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_equipamento WHERE ipv_bd2_projeto_equipamento.id = p_id) INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o tipo de equipamento, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipodeequipamento WHERE ipv_bd2_projeto_tipodeequipamento.id = p_id) THEN
            DELETE FROM ipv_bd2_projeto_tipodeequipamento WHERE ipv_bd2_projeto_tipodeequipamento.id = p_id;
            RAISE NOTICE 'Tipo de equipamento apagado com sucesso.';
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Tipo de equipamento não encontrado.';
            RETURN FALSE;
        END IF;
    END IF;
END;
$$;


--
-- TOC entry 285 (class 1255 OID 36999)
-- Name: fn_get_armazem_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_armazem_by_id(p_armazem_id integer) RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = p_armazem_id;
END;
$$;


--
-- TOC entry 321 (class 1255 OID 37407)
-- Name: fn_get_armazens(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_armazens(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.name,
        a.address,
        a.postal_code,
        a.locality
    FROM
        ipv_bd2_projeto_armazem a
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        a.name ILIKE p_filtered OR
        a.address ILIKE p_filtered OR
        a.postal_code ILIKE p_filtered OR
        a.locality ILIKE p_filtered OR
        (p_filtered ~ E'^\\d+$' AND a.id = p_filtered::int))
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN a.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN a.id END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(a.name) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(a.name) END DESC,
        CASE WHEN p_order = 'address-asc' THEN LOWER(a.address) END ASC,
        CASE WHEN p_order = 'address-desc' THEN LOWER(a.address) END DESC,
        CASE WHEN p_order = 'postal_code-asc' THEN LOWER(a.postal_code) END ASC,
        CASE WHEN p_order = 'postal_code-desc' THEN LOWER(a.postal_code) END DESC,
        CASE WHEN p_order = 'locality-asc' THEN LOWER(a.locality) END ASC,
        CASE WHEN p_order = 'locality-desc' THEN LOWER(a.locality) END DESC;
END;
$_$;


--
-- TOC entry 267 (class 1255 OID 37341)
-- Name: fn_get_clients(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_clients() RETURNS TABLE(user_id integer, full_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name
    FROM
        ipv_bd2_projeto_utilizador u
	WHERE
        u.type = 'CL';
END;
$$;


--
-- TOC entry 296 (class 1255 OID 37024)
-- Name: fn_get_component(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_component(p_componentid integer) RETURNS TABLE(id integer, name character varying, created_at date, cost double precision, fornecedor_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_componente.id,
        ipv_bd2_projeto_componente.name,
        ipv_bd2_projeto_componente.created_at,
        ipv_bd2_projeto_componente.cost,
        fornecedor_id_id
    FROM
        ipv_bd2_projeto_componente
    WHERE
        ipv_bd2_projeto_componente.id = p_ComponentId;
END;
$$;


--
-- TOC entry 307 (class 1255 OID 37473)
-- Name: fn_get_component_order_amounts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_component_order_amounts() RETURNS TABLE(encomenda_id integer, componente character varying, amount integer, componente_id integer, id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
	SELECT
	    q.encomenda_id,
        c.name,
        q.amount,
		c.id,
		q.id
	FROM ipv_bd2_projeto_quantidadeencomendacomponente q
	INNER JOIN ipv_bd2_projeto_componente c on q.componente_id = c.id;
END;
$$;


--
-- TOC entry 336 (class 1255 OID 37440)
-- Name: fn_get_component_orders(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_component_orders(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT 'asc'::character varying) RETURNS TABLE(id integer, created_at date, fornecedor_name character varying, funcionario_responsavel_name text, exported boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.created_at,
        f.name AS fornecedor_name,
        CONCAT(u.first_name, ' ', u.last_name) AS funcionario_responsavel_name,
        e.exported
    FROM
        ipv_bd2_projeto_encomendacomponente e
    INNER JOIN
        ipv_bd2_projeto_fornecedor f ON e.fornecedor_id_id = f.id
    INNER JOIN
        ipv_bd2_projeto_utilizador u ON e.funcionario_responsavel_id_id = u.id
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        f.name ILIKE p_filtered)
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN e.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN e.id END DESC,
        CASE WHEN p_order = 'date-asc' THEN e.created_at END ASC,
        CASE WHEN p_order = 'date-desc' THEN e.created_at END DESC,
        CASE WHEN p_order = 'supplier-asc' THEN f.name END ASC,
        CASE WHEN p_order = 'supplier-desc' THEN f.name END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(CONCAT(u.first_name, ' ', u.last_name)) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(CONCAT(u.first_name, ' ', u.last_name)) END DESC;
END;
$$;


--
-- TOC entry 322 (class 1255 OID 37405)
-- Name: fn_get_components(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_components(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(id integer, name character varying, created_at date, cost double precision, fornecedor_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.name,
        c.created_at,
        c.cost,
        f.name AS fornecedor_name
    FROM
        ipv_bd2_projeto_componente c
    JOIN
        ipv_bd2_projeto_fornecedor f ON c.fornecedor_id_id = f.id
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        c.name ILIKE p_filtered)
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN c.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN c.id END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(c.name) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(c.name) END DESC,
        CASE WHEN p_order = 'created_at-asc' THEN c.created_at END ASC,
        CASE WHEN p_order = 'created_at-desc' THEN c.created_at END DESC,
        CASE WHEN p_order = 'cost-asc' THEN c.cost END ASC,
        CASE WHEN p_order = 'cost-desc' THEN c.cost END DESC,
        CASE WHEN p_order = 'fornecedor-asc' THEN LOWER(f.name) END ASC,
        CASE WHEN p_order = 'fornecedor-desc' THEN LOWER(f.name) END DESC;
END;
$$;


--
-- TOC entry 341 (class 1255 OID 37469)
-- Name: fn_get_encomenda_componentes_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_encomenda_componentes_by_id(p_encomenda_id integer) RETURNS TABLE(id integer, created_at date, fornecedor integer, funcionario_responsavel integer, exported boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.created_at,
		e.fornecedor_id_id,
		e.funcionario_responsavel_id_id,
        e.exported
    FROM
        ipv_bd2_projeto_encomendacomponente e
    WHERE
        e.id = p_encomenda_id;
END;
$$;


--
-- TOC entry 295 (class 1255 OID 37022)
-- Name: fn_get_equipamento_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipamento_by_id(p_equipamentoid integer) RETURNS TABLE(id integer, name character varying, created_at date, tipo_equipamento_id_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT e.id, e.name, e.created_at, e.tipo_equipamento_id_id
    FROM ipv_bd2_projeto_equipamento e
    WHERE e.id = p_EquipamentoId;
END;
$$;


--
-- TOC entry 293 (class 1255 OID 37017)
-- Name: fn_get_equipamentos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipamentos() RETURNS TABLE(id integer, name character varying, created_at date, tipo_equipamento_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT e.id, e.name, e.created_at, t.name AS tipo_equipamento_name
    FROM ipv_bd2_projeto_equipamento e
    JOIN ipv_bd2_projeto_tipodeequipamento t ON e.tipo_equipamento_id_id = t.id;
END;
$$;


--
-- TOC entry 320 (class 1255 OID 37397)
-- Name: fn_get_equipamentos(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipamentos(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(id integer, name character varying, created_at date, tipo_equipamento_name character varying)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY
    SELECT e.id, e.name, e.created_at, t.name AS tipo_equipamento_name
    FROM ipv_bd2_projeto_equipamento e
    JOIN ipv_bd2_projeto_tipodeequipamento t ON e.tipo_equipamento_id_id = t.id
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        e.name ILIKE p_filtered OR
        (p_filtered ~ E'^\\d+$' AND e.id = p_filtered::int))
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN e.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN e.id END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(e.name) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(e.name) END DESC,
        CASE WHEN p_order = 'created_at-asc' THEN e.created_at END ASC,
        CASE WHEN p_order = 'created_at-desc' THEN e.created_at END DESC;
END;
$_$;


--
-- TOC entry 305 (class 1255 OID 37348)
-- Name: fn_get_equipment_order_amounts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipment_order_amounts() RETURNS TABLE(equipamento_id integer, equipment character varying, amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
	SELECT
	    q.encomenda_id,
        e.name,
        q.amount
	FROM ipv_bd2_projeto_quantidadeencomendaequipamento q
	INNER JOIN ipv_bd2_projeto_equipamento e on q.equipamento_id = e.id;
END;
$$;


--
-- TOC entry 325 (class 1255 OID 37425)
-- Name: fn_get_equipment_order_amounts(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipment_order_amounts(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(equipamento_id integer, equipment character varying, amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        q.encomenda_id,
        e.name AS equipment,
        q.amount
    FROM
        ipv_bd2_projeto_quantidadeencomendaequipamento q
    INNER JOIN
        ipv_bd2_projeto_equipamento e ON q.equipamento_id = e.id
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        e.name ILIKE p_filtered)
    ORDER BY
        CASE WHEN p_order = 'encomenda_id-asc' OR p_order IS NULL THEN q.encomenda_id END ASC,
        CASE WHEN p_order = 'encomenda_id-desc' THEN q.encomenda_id END DESC,
        CASE WHEN p_order = 'equipment-asc' THEN LOWER(e.name) END ASC,
        CASE WHEN p_order = 'equipment-desc' THEN LOWER(e.name) END DESC;
END;
$$;


--
-- TOC entry 338 (class 1255 OID 37437)
-- Name: fn_get_equipment_order_invoice_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipment_order_invoice_by_id(p_encomenda_id integer) RETURNS TABLE(result json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT
    json_build_object(
        'created_at', f.created_at,
        'contribuinte', f.contribuinte,
        'cliente', (
            SELECT
                json_build_object(
                    'id', u_client.id,
                    'name', u_client.first_name || ' ' || u_client.last_name,
                    'email', u_client.email
                )
            FROM
                ipv_bd2_projeto_encomendaequipamento f_client
            INNER JOIN ipv_bd2_projeto_utilizador u_client ON u_client.id = f_client.client_id_id
            WHERE
                f_client.id = p_encomenda_id
            LIMIT 1
        ),
		'encomenda', (
			SELECT
				json_build_object(
					'created_at', encomenda.created_at,
					'address', encomenda.address,
					'postal_code', encomenda.postal_code,
					'locality', encomenda.locality
				)
            FROM
                ipv_bd2_projeto_encomendaequipamento encomenda
            WHERE
                encomenda.id = f.encomenda_id_id
		),
        'expedicao', (
            SELECT
                json_build_object(
                    'truck_license', e.truck_license,
                    'delivery_date_expected', e.delivery_date_expected,
                    'registos_producao', (
                        SELECT
                            json_agg(
                                json_build_object(
                                    'ended_at', rp.ended_at,
									'equipamento_id', rp.equipamento_id_id,
                                    'equipamento_name', eq.name,
                                    'tipo_mao_de_obra_cost', mo.cost,
                                    'componentes_usados', (
                                        SELECT
                                            json_agg(
                                                json_build_object(
                                                    'component_name', comp.name,
                                                    'component_cost', comp.cost,
                                                    'amount', qnt.amount
                                                )
                                            )
                                        FROM
                                            ipv_bd2_projeto_quantidadecomponenteregistoproducao qnt
                                        INNER JOIN ipv_bd2_projeto_componente comp ON comp.id = qnt.componente_id
                                        WHERE qnt.registo_producao_id = rp.id
                                    )
                                )
                            )
                        FROM
                            ipv_bd2_projeto_registoproducao rp
                        INNER JOIN ipv_bd2_projeto_equipamento eq ON eq.id = rp.equipamento_id_id
                        INNER JOIN ipv_bd2_projeto_tipomaodeobra mo ON mo.id = rp.tipo_mao_de_obra_id_id
                        WHERE expedicao_id_id = e.encomenda_id_id
                    )
                )
            FROM
                ipv_bd2_projeto_expedicao e
            WHERE
                e.encomenda_id_id = f.encomenda_id_id
        ),
        'total_cost', (
            SELECT
                COALESCE(
                    SUM(tmo.tipo_mao_de_obra_cost + tcomp.total_component_cost),
                    0
                )
            FROM (
                SELECT
                    rp.id,
                    mo.cost AS tipo_mao_de_obra_cost
                FROM
                    ipv_bd2_projeto_registoproducao rp
                INNER JOIN ipv_bd2_projeto_tipomaodeobra mo ON mo.id = rp.tipo_mao_de_obra_id_id
                WHERE rp.expedicao_id_id = f.encomenda_id_id
            ) tmo
            LEFT JOIN (
                SELECT
                    qnt.registo_producao_id,
                    SUM(comp.cost * qnt.amount) AS total_component_cost
                FROM
                    ipv_bd2_projeto_quantidadecomponenteregistoproducao qnt
                INNER JOIN ipv_bd2_projeto_componente comp ON comp.id = qnt.componente_id
                GROUP BY qnt.registo_producao_id
            ) tcomp ON tcomp.registo_producao_id = tmo.id
        )
    ) AS result
FROM
    ipv_bd2_projeto_fatura f
WHERE
    f.encomenda_id_id = p_encomenda_id;
	END;
$$;


--
-- TOC entry 330 (class 1255 OID 37436)
-- Name: fn_get_equipment_order_invoices(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipment_order_invoices() RETURNS TABLE(invoice_id integer, created_at date, contribuinte character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.encomenda_id_id AS invoice_id,
        f.created_at,
        f.contribuinte
    FROM
        ipv_bd2_projeto_fatura f;

    IF NOT FOUND THEN
        RAISE NOTICE 'No invoices found for the specified equipment order.';
    END IF;
END;
$$;


--
-- TOC entry 346 (class 1255 OID 37483)
-- Name: fn_get_equipment_orders(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_equipment_orders(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(id integer, created_at date, cliente text, funcionario_name text, has_expedicao boolean, has_fatura boolean, locality character varying, postal_code character varying, address character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.created_at,
		cliente.first_name || ' ' || cliente.last_name AS client_name,
        u.first_name || ' ' || u.last_name AS funcionario_name,
		EXISTS (SELECT 1 FROM ipv_bd2_projeto_expedicao ex WHERE ex.encomenda_id_id = e.id) AS has_expedicao,
        EXISTS (SELECT 1 FROM ipv_bd2_projeto_fatura fa WHERE fa.encomenda_id_id = e.id) AS has_fatura,
		e.locality,
		e.postal_code,
		e.address
    FROM
        ipv_bd2_projeto_encomendaequipamento e
    JOIN
        ipv_bd2_projeto_utilizador u ON e.funcionario_id_id = u.id
    JOIN
        ipv_bd2_projeto_utilizador cliente ON e.client_id_id = cliente.id
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        CONCAT(u.first_name, ' ', u.last_name) ILIKE p_filtered)
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN e.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN e.id END DESC,
        CASE WHEN p_order = 'date-asc' THEN e.created_at END ASC,
        CASE WHEN p_order = 'date-desc' THEN e.created_at END DESC,
        CASE WHEN p_order = 'func-asc' THEN LOWER(CONCAT(u.first_name, ' ', u.last_name)) END ASC,
        CASE WHEN p_order = 'func-desc' THEN LOWER(CONCAT(u.first_name, ' ', u.last_name)) END DESC;
END;
$$;


--
-- TOC entry 306 (class 1255 OID 37351)
-- Name: fn_get_expedicao(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_expedicao() RETURNS TABLE(id integer, sent_at date, truck_license character varying, delivery_date_expected date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT e.encomenda_id_id, e.sent_at, e.truck_license , e.delivery_date_expected
    FROM ipv_bd2_projeto_expedicao e
    LEFT JOIN ipv_bd2_projeto_registoproducao t ON e.encomenda_id_id = t.expedicao_id_id;
END;
$$;


--
-- TOC entry 329 (class 1255 OID 37422)
-- Name: fn_get_expedicao_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_expedicao_by_id(p_encomenda_id integer) RETURNS TABLE(result json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
    json_build_object(
        'encomenda_id', e.encomenda_id_id,
        'sent_at', e.sent_at,
        'truck_license', e.truck_license,
        'delivery_date_expected', e.delivery_date_expected,
		'address', enceq.address,
		'postal_code', enceq.postal_code,
		'locality', enceq.locality,
        'registos_producao', (
            SELECT
                json_agg(
                    json_build_object(
                        'started_at', rp.started_at,
                        'ended_at', rp.ended_at,
                        'armazem_name', ar.name,
                        'equipamento_name', eq.name,
                        'funcionario_name', u.first_name || ' ' || u.last_name,
                        'tipo_mao_de_obra_name', mo.name,
                        'tipo_mao_de_obra_cost', mo.cost,
                        'componentes_usados', (
                            SELECT
                                json_agg(
                                    json_build_object(
                                        'component_name', comp.name,
                                        'component_cost', comp.cost,
                                        'amount', qnt.amount
                                    )
                                )
                            FROM
                                ipv_bd2_projeto_quantidadecomponenteregistoproducao qnt
                            INNER JOIN ipv_bd2_projeto_componente comp ON comp.id = qnt.componente_id
                            WHERE qnt.registo_producao_id = rp.id
                        )
                    )
                )
            FROM
                ipv_bd2_projeto_registoproducao rp
            INNER JOIN ipv_bd2_projeto_armazem ar ON ar.id = rp.armazem_id_id
            INNER JOIN ipv_bd2_projeto_equipamento eq ON eq.id = rp.equipamento_id_id
            INNER JOIN ipv_bd2_projeto_utilizador u ON u.id = rp.funcionario_id_id
            INNER JOIN ipv_bd2_projeto_tipomaodeobra mo ON mo.id = rp.tipo_mao_de_obra_id_id
            WHERE expedicao_id_id = e.encomenda_id_id
        )
    ) AS result
FROM
    ipv_bd2_projeto_expedicao e
INNER JOIN ipv_bd2_projeto_encomendaequipamento enceq ON enceq.id = e.encomenda_id_id
WHERE
    e.encomenda_id_id = p_encomenda_id;

END;
$$;


--
-- TOC entry 291 (class 1255 OID 37010)
-- Name: fn_get_fornecedor_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_fornecedor_by_id(p_fornecedor_id integer) RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.id = p_fornecedor_id;
END;
$$;


--
-- TOC entry 331 (class 1255 OID 37438)
-- Name: fn_get_fornecedores(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_fornecedores(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.name,
        e.address,
        e.postal_code,
		e.locality,
		e.email
    FROM
        ipv_bd2_projeto_fornecedor e
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        e.name ILIKE p_filtered )
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN e.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN e.id END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(e.name) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(e.name) END DESC,
        CASE WHEN p_order = 'morada-asc' THEN e.address END ASC,
        CASE WHEN p_order = 'morada-desc' THEN e.address END DESC,
        CASE WHEN p_order = 'postal_code-asc' THEN e.postal_code END ASC,
        CASE WHEN p_order = 'postal_code-desc' THEN e.postal_code END DESC,
		CASE WHEN p_order = 'locality-asc' THEN e.locality END ASC,
        CASE WHEN p_order = 'locality-desc' THEN e.locality END DESC,
		CASE WHEN p_order = 'email-asc' THEN e.email END ASC,
        CASE WHEN p_order = 'email-desc' THEN e.email END DESC;
END;
$$;


--
-- TOC entry 334 (class 1255 OID 37461)
-- Name: fn_get_guia_entrega_componentes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_guia_entrega_componentes() RETURNS TABLE(id integer, created_at date, armazem character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT g.id, g.created_at, a.name AS armazem
    FROM ipv_bd2_projeto_guiaentregacomponente g
    JOIN ipv_bd2_projeto_armazem a ON g.armazem_id_id = a.id;
END;
$$;


--
-- TOC entry 335 (class 1255 OID 37463)
-- Name: fn_get_guia_entrega_componentes_amounts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_guia_entrega_componentes_amounts() RETURNS TABLE(guia_entrega_id integer, componente character varying, amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT q.guia_entrega_id, c.name, q.amount
    FROM ipv_bd2_projeto_quantidadeguiaentregacomponente q
    JOIN ipv_bd2_projeto_componente c ON q.componente_id = c.id;
END;
$$;


--
-- TOC entry 326 (class 1255 OID 37432)
-- Name: fn_get_production_registries(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_production_registries() RETURNS TABLE(production_registrie_id integer, equipamento_name character varying, tipo_mao_obra character varying, started_at date, ended_at date, funcionario_name text, armazem character varying, custo double precision, is_in_expedition boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
		rp.id,
		e.name as equipamento_name,
		tmo.name as tipo_mao_obra,
		rp.started_at,
		rp.ended_at,
		CONCAT(u.first_name, ' ', u.last_name) as funcionario_name,
		arm.name as armazem,
		tmo.cost as custo,
		CASE WHEN rp.expedicao_id_id IS NOT NULL THEN true ELSE false END AS is_in_expedition
    FROM
        ipv_bd2_projeto_registoproducao rp
    JOIN
        ipv_bd2_projeto_equipamento e ON rp.equipamento_id_id = e.id
	JOIN
		ipv_bd2_projeto_tipomaodeobra tmo ON rp.tipo_mao_de_obra_id_id = tmo.id
	JOIN
		ipv_bd2_projeto_utilizador u ON rp.funcionario_id_id = u.id
	JOIN
		ipv_bd2_projeto_armazem arm ON rp.armazem_id_id = arm.id;
END;
$$;


--
-- TOC entry 337 (class 1255 OID 37443)
-- Name: fn_get_production_registry_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_production_registry_by_id(p_registry_id integer) RETURNS TABLE(started_at date, ended_at date, armazem_id_id integer, tipo_mao_de_obra_id_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        pr.started_at,
        pr.ended_at,
        pr.armazem_id_id,
		pr.tipo_mao_de_obra_id_id
    FROM
        ipv_bd2_projeto_registoproducao pr;
END;
$$;


--
-- TOC entry 327 (class 1255 OID 37434)
-- Name: fn_get_production_registry_component_amouts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_production_registry_component_amouts() RETURNS TABLE(production_id integer, componente_name character varying, amount integer, cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
		q.registo_producao_id,
        c.name AS componente_name,
        q.amount,
		c.cost
    FROM
        ipv_bd2_projeto_quantidadecomponenteregistoproducao q
    JOIN
        ipv_bd2_projeto_componente c ON q.componente_id = c.id;
END;
$$;


--
-- TOC entry 339 (class 1255 OID 37465)
-- Name: fn_get_stock_componentes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_stock_componentes() RETURNS TABLE(componente_id integer, componente_name character varying, armazem_id_id integer, armazem_name character varying, remaining_amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        qgc.componente_id,
        c.name AS componente_name,
        gc.armazem_id_id,
        a.name AS armazem_name,
        SUM(qgc.amount - COALESCE(rp.amount_used, 0))::INT AS remaining_amount
    FROM
        ipv_bd2_projeto_guiaentregacomponente gc
    JOIN
        ipv_bd2_projeto_quantidadeguiaentregacomponente qgc ON gc.id = qgc.guia_entrega_id
    JOIN
        ipv_bd2_projeto_componente c ON qgc.componente_id = c.id
    JOIN
        ipv_bd2_projeto_armazem a ON gc.armazem_id_id = a.id
    LEFT JOIN (
        SELECT
            qc.componente_id,
            SUM(qc.amount) AS amount_used
        FROM
            ipv_bd2_projeto_registoproducao rp
        JOIN
            ipv_bd2_projeto_quantidadecomponenteregistoproducao qc ON rp.id = qc.registo_producao_id
        GROUP BY
            qc.componente_id
    ) rp ON qgc.componente_id = rp.componente_id
    GROUP BY
        qgc.componente_id, c.name, gc.armazem_id_id, a.name;

    RETURN;
END;
$$;


--
-- TOC entry 340 (class 1255 OID 37453)
-- Name: fn_get_stock_equipamentos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_stock_equipamentos() RETURNS TABLE(equipamento_id_id integer, equipamento_name character varying, armazem_id_id integer, armazem_name character varying, equipamento_count integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.equipamento_id_id,
        e.name AS equipamento_name,
        r.armazem_id_id,
        a.name AS armazem_name,
        COUNT(*)::INT AS equipamento_count
    FROM
        ipv_bd2_projeto_registoproducao r
    JOIN
        ipv_bd2_projeto_equipamento e ON r.equipamento_id_id = e.id
    JOIN
        ipv_bd2_projeto_armazem a ON r.armazem_id_id = a.id
    GROUP BY
        r.equipamento_id_id, e.name, r.armazem_id_id, a.name;

    RETURN;
END;
$$;


--
-- TOC entry 265 (class 1255 OID 36995)
-- Name: fn_get_tipo_equipamento(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_tipo_equipamento(p_tipo_id integer) RETURNS TABLE(id integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_tipodeequipamento.id,
        ipv_bd2_projeto_tipodeequipamento.name
    FROM
        ipv_bd2_projeto_tipodeequipamento
    WHERE
        ipv_bd2_projeto_tipodeequipamento.id = p_tipo_id;
END;
$$;


--
-- TOC entry 282 (class 1255 OID 33783)
-- Name: fn_get_tipo_equipamentos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_tipo_equipamentos() RETURNS TABLE(id integer, tipo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT ipv_bd2_projeto_tipodeequipamento.id, ipv_bd2_projeto_tipodeequipamento.name FROM ipv_bd2_projeto_tipodeequipamento;
END;
$$;


--
-- TOC entry 288 (class 1255 OID 37002)
-- Name: fn_get_tipo_mao_obra(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_tipo_mao_obra() RETURNS TABLE(id integer, name character varying, cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_tipomaodeobra ORDER BY id;
END;
$$;


--
-- TOC entry 264 (class 1255 OID 37003)
-- Name: fn_get_tipo_mao_obra_by_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_tipo_mao_obra_by_id(p_tipo_mao_obra_id integer) RETURNS TABLE(id integer, name character varying, cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = p_tipo_mao_obra_id;
END;
$$;


--
-- TOC entry 315 (class 1255 OID 37399)
-- Name: fn_get_unassigned_production_registries(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_unassigned_production_registries() RETURNS TABLE(production_id integer, equipamento_name character varying, started_at date, ended_at date, quantidade_componentes integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        rp.id,
        e.name AS equipamento_name,
        rp.started_at,
        rp.ended_at,
		COUNT(qc.*)::integer AS quantidade_componentes
    FROM
        ipv_bd2_projeto_registoproducao rp
    JOIN
        ipv_bd2_projeto_equipamento e ON rp.equipamento_id_id = e.id
	LEFT JOIN
        ipv_bd2_projeto_quantidadecomponenteregistoproducao qc ON rp.id = qc.registo_producao_id
    WHERE
        rp.expedicao_id_id IS NULL
	GROUP BY
        rp.id, e.name, rp.started_at, rp.ended_at;
END;
$$;


--
-- TOC entry 266 (class 1255 OID 33653)
-- Name: fn_get_user(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_user(p_user_id integer) RETURNS TABLE(id integer, first_name character varying, last_name character varying, email character varying, type character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_utilizador.id,
        ipv_bd2_projeto_utilizador.first_name,
        ipv_bd2_projeto_utilizador.last_name,
        ipv_bd2_projeto_utilizador.email,
        ipv_bd2_projeto_utilizador.type
    FROM
        ipv_bd2_projeto_utilizador
    WHERE
        ipv_bd2_projeto_utilizador.id = p_user_id;
END;
$$;


--
-- TOC entry 324 (class 1255 OID 37419)
-- Name: fn_get_utilizadores(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_utilizadores(p_filtered character varying DEFAULT NULL::character varying, p_order character varying DEFAULT NULL::character varying) RETURNS TABLE(id integer, full_name text, email character varying, type character varying)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        u.email,
        u.type
    FROM
        ipv_bd2_projeto_utilizador u
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR
        CONCAT(u.first_name, ' ', u.last_name) ILIKE p_filtered OR
        u.email ILIKE p_filtered OR  u.type ILIKE p_filtered OR
        (p_filtered ~ E'^\\d+$' AND u.id = p_filtered::int))
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN u.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN u.id END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(CONCAT(u.first_name, ' ', u.last_name)) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(CONCAT(u.first_name, ' ', u.last_name)) END DESC,
        CASE WHEN p_order = 'email-asc' THEN LOWER(u.email) END ASC,
        CASE WHEN p_order = 'email-desc' THEN LOWER(u.email) END DESC,
		CASE WHEN p_order = 'type-asc' THEN LOWER(u.type) END ASC,
        CASE WHEN p_order = 'type-desc' THEN LOWER(u.type) END DESC;
END;
$_$;


--
-- TOC entry 347 (class 1255 OID 37468)
-- Name: fn_import_components(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_import_components(json_data jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    component_data jsonb;
    component_record jsonb;
    supplier_id INTEGER;
BEGIN
    FOR component_data IN SELECT * FROM jsonb_array_elements(json_data)
    LOOP
        component_record = component_data;

        SELECT id INTO supplier_id
        FROM ipv_bd2_projeto_fornecedor
        WHERE name = component_record->'supplier'->>'name';

        IF supplier_id IS NULL THEN
            INSERT INTO ipv_bd2_projeto_fornecedor (name, address, postal_code, locality, email)
            VALUES (
                component_record->'supplier'->>'name',
                COALESCE(component_record->'supplier'->>'address', ''),
                COALESCE(component_record->'supplier'->>'postal_code', ''),
                COALESCE(component_record->'supplier'->>'locality', ''),
                COALESCE(component_record->'supplier'->>'email', '')
            )
            RETURNING id INTO supplier_id;
        END IF;

        INSERT INTO ipv_bd2_projeto_componente (name, created_at, cost, fornecedor_id_id)
        VALUES (
            component_record->>'name',
            NOW(),
            (component_record->>'cost')::double precision,
            supplier_id
        );
    END LOOP;
END;
$$;


--
-- TOC entry 283 (class 1255 OID 36996)
-- Name: sp_create_armazem(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_armazem(IN p_name character varying, IN p_address character varying, IN p_postal_code character varying, IN p_locality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.name = p_name) THEN
        INSERT INTO ipv_bd2_projeto_armazem (name, address, postal_code, locality)
        VALUES (p_name, p_address, p_postal_code, p_locality);
        RAISE NOTICE 'Armazem criado com sucesso.';
    ELSE
        RAISE NOTICE 'Armazem já existe.';
    END IF;
END;
$$;


--
-- TOC entry 297 (class 1255 OID 37023)
-- Name: sp_create_component(character varying, double precision, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_component(IN p_componentname character varying, IN p_componentcost double precision, IN p_fornecedorid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_componente (name, cost, fornecedor_id_id, created_at)
    VALUES (p_ComponentName, p_ComponentCost, p_FornecedorId, CURRENT_DATE);

    RAISE NOTICE 'Componente criado com sucesso.';
END;
$$;


--
-- TOC entry 323 (class 1255 OID 37416)
-- Name: sp_create_expedicao(date, character varying, date, integer, integer[]); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_expedicao(IN p_sent_at date, IN p_truck_license character varying, IN p_delivery_date_expected date, IN p_encomenda_id_id integer, IN p_registo_producao_ids integer[])
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_expedicao_id_id integer;
BEGIN
    -- Inserir na tabela de expedicao e recuperar o ID inserido
    INSERT INTO ipv_bd2_projeto_expedicao(sent_at, truck_license, delivery_date_expected, encomenda_id_id)
    VALUES (p_sent_at, p_truck_license, p_delivery_date_expected, p_encomenda_id_id)
    RETURNING ipv_bd2_projeto_expedicao.encomenda_id_id INTO v_expedicao_id_id;

    -- Atualizar os registos de producao com o ID da expedicao
    UPDATE ipv_bd2_projeto_registoproducao
    SET expedicao_id_id = v_expedicao_id_id
    WHERE ipv_bd2_projeto_registoproducao.id = ANY(p_registo_producao_ids);

    RAISE NOTICE 'Expedicao criada com sucesso. ID da Expedicao: %', v_expedicao_id_id;
END;
$$;


--
-- TOC entry 318 (class 1255 OID 37403)
-- Name: sp_create_fatura(date, character varying, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_fatura(IN p_created_at date, IN p_contribuinte character varying, IN p_encomenda_id_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_fatura(created_at, contribuinte, encomenda_id_id)
    VALUES (p_created_at, p_contribuinte, p_encomenda_id_id );

    RAISE NOTICE 'Expedicao criada com sucesso.';
END;
$$;


--
-- TOC entry 290 (class 1255 OID 37007)
-- Name: sp_create_fornecedor(character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_fornecedor(IN p_name character varying, IN p_address character varying, IN p_postal_code character varying, IN p_locality character varying, IN p_email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.name = p_name) THEN
        INSERT INTO ipv_bd2_projeto_fornecedor (name, address, postal_code, locality, email)
        VALUES (p_name, p_address, p_postal_code, p_locality, p_email);
        RAISE NOTICE 'Fornecedor criado com sucesso.';
    ELSE
        RAISE NOTICE 'Fornecedor já existe.';
    END IF;
END;
$$;


--
-- TOC entry 313 (class 1255 OID 37389)
-- Name: sp_create_quantidades_componente_registo_producao(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_quantidades_componente_registo_producao(IN registo_producao_id integer, IN p_componente_id integer, IN p_amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_quantidadecomponenteregistoproducao(registo_producao_id, componente_id, amount)
    VALUES (registo_producao_id, p_componente_id, p_amount);

END;
$$;


--
-- TOC entry 302 (class 1255 OID 37053)
-- Name: sp_create_quantidades_encomenda_componentes(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_quantidades_encomenda_componentes(IN p_encomenda_id integer, IN p_componente_id integer, IN p_amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Your logic to create quantities for the order components
    -- Replace the following line with your actual logic
    INSERT INTO ipv_bd2_projeto_quantidadeencomendacomponente(encomenda_id, componente_id, amount)
    VALUES (p_encomenda_id, p_componente_id, p_amount);

END;
$$;


--
-- TOC entry 311 (class 1255 OID 37343)
-- Name: sp_create_quantidades_encomenda_equipamentos(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_quantidades_encomenda_equipamentos(IN p_encomenda_id integer, IN p_equipamento_id integer, IN p_amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Your logic to create quantities for the order components
    -- Replace the following line with your actual logic
    INSERT INTO ipv_bd2_projeto_quantidadeencomendaequipamento(encomenda_id, equipamento_id, amount)
    VALUES (p_encomenda_id, p_equipamento_id, p_amount);

END;
$$;


--
-- TOC entry 333 (class 1255 OID 37460)
-- Name: sp_create_quantidades_guia_entrega_componentes(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_quantidades_guia_entrega_componentes(IN p_guia_entrega_id integer, IN p_componente_id integer, IN p_amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_quantidadeguiaentregacomponente(guia_entrega_id, componente_id, amount)
    VALUES (p_guia_entrega_id, p_componente_id, p_amount);

END;
$$;


--
-- TOC entry 281 (class 1255 OID 33655)
-- Name: sp_create_tipo_equipamento(character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_tipo_equipamento(IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipodeequipamento WHERE name = p_name) THEN
        INSERT INTO ipv_bd2_projeto_tipodeequipamento (name)
        VALUES (p_name);
        RAISE NOTICE 'Tipo de equipamento criado com sucesso.';
    ELSE
        RAISE NOTICE 'Tipo de equipamento já existe.';
    END IF;
END;
$$;


--
-- TOC entry 286 (class 1255 OID 37001)
-- Name: sp_create_tipo_mao_obra(character varying, double precision); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_create_tipo_mao_obra(IN p_name character varying, IN p_cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipomaodeobra WHERE name = p_name) THEN
        INSERT INTO ipv_bd2_projeto_tipomaodeobra (name, cost)
        VALUES (p_name, p_cost);
        RAISE NOTICE 'Tipo de mão de obra criado com sucesso.';
    ELSE
        RAISE NOTICE 'Tipo de mão de obra já existe.';
    END IF;
END;
$$;


--
-- TOC entry 292 (class 1255 OID 37011)
-- Name: sp_delete_fornecedor(integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_delete_fornecedor(IN p_fornecedorid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_fornecedor WHERE id = p_FornecedorId) THEN
        RAISE NOTICE 'Fornecedor não encontrado. Falha na exclusão do fornecedor.';
        RETURN;
    END IF;

    DELETE FROM ipv_bd2_projeto_fornecedor
    WHERE id = p_FornecedorId;

    RAISE NOTICE 'Fornecedor excluído com sucesso.';
END;
$$;


--
-- TOC entry 344 (class 1255 OID 37472)
-- Name: sp_delete_quantidade_encomenda_componente(integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_delete_quantidade_encomenda_componente(IN p_encomendacomponente_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
        DELETE FROM ipv_bd2_projeto_quantidadeencomendacomponente
        WHERE ipv_bd2_projeto_quantidadeencomendacomponente.id = p_encomendacomponente_id;
        RAISE NOTICE 'Encomenda de Componente excluída com sucesso.';
END;
$$;


--
-- TOC entry 284 (class 1255 OID 36998)
-- Name: sp_edit_armazem(integer, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_armazem(IN p_armazemid integer, IN p_newarmazemname character varying, IN p_newarmazemaddress character varying, IN p_newarmazempostalcode character varying, IN p_newarmazemlocality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = p_ArmazemId) THEN
        RAISE NOTICE 'Armazém não encontrado. Falha na edição do armazém.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_armazem
    SET
        name = p_NewArmazemName,
        address = p_NewArmazemAddress,
        postal_code = p_NewArmazemPostalCode,
        locality = p_NewArmazemLocality
    WHERE
        id = p_ArmazemId;

    RAISE NOTICE 'Armazém editado com sucesso.';
END;
$$;


--
-- TOC entry 298 (class 1255 OID 37027)
-- Name: sp_edit_component(integer, character varying, double precision, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_component(IN p_component_id integer, IN p_new_name character varying, IN p_new_cost double precision, IN p_new_fornecedor_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ipv_bd2_projeto_componente
    SET
        name = p_new_name,
        cost = p_new_cost,
        fornecedor_id_id = p_new_fornecedor_id
    WHERE
        ipv_bd2_projeto_componente.id = p_component_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Componente não encontrado. Falha na edição do componente.';
        RETURN;
    END IF;

    RAISE NOTICE 'Componente editado com sucesso.';
END;
$$;


--
-- TOC entry 317 (class 1255 OID 37396)
-- Name: sp_edit_encomenda_componentes(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_encomenda_componentes(IN p_encomendacomponenteid integer, IN p_newfornecedorid integer, IN p_newfuncionarioresponsavelid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ipv_bd2_projeto_encomendacomponente
        WHERE ipv_bd2_projeto_encomendacomponente.id = p_encomendacomponenteid AND ipv_bd2_projeto_encomendacomponente.exported = TRUE
    ) THEN
        RAISE NOTICE 'Não é possível editar a encomenda, pois já foi exportada.';
        RETURN;
    ELSE
        UPDATE ipv_bd2_projeto_encomendacomponente
        SET
            fornecedor_id_id = p_newfornecedorid,
            funcionario_responsavel_id_id = p_newfuncionarioresponsavelid
        WHERE
            ipv_bd2_projeto_encomendacomponente.id = p_encomendacomponenteid;
        RAISE NOTICE 'Encomenda de Componentes editada com sucesso.';
    END IF;
END;
$$;


--
-- TOC entry 294 (class 1255 OID 37013)
-- Name: sp_edit_equipamento(integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_equipamento(IN p_equipamentoid integer, IN p_newequipamentoname character varying, IN p_newtipoequipamentoid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_equipamento WHERE id = p_EquipamentoId) THEN
        RAISE NOTICE 'Equipamento não encontrado. Falha na edição do equipamento.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_equipamento
    SET
        name = p_NewEquipamentoName,
        tipo_equipamento_id_id = p_NewTipoEquipamentoId
    WHERE
        id = p_EquipamentoId;

    RAISE NOTICE 'Equipamento editado com sucesso.';
END;
$$;


--
-- TOC entry 289 (class 1255 OID 37009)
-- Name: sp_edit_fornecedor(integer, character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_fornecedor(IN p_fornecedorid integer, IN p_newfornecedorname character varying, IN p_newfornecedoraddress character varying, IN p_newfornecedorpostalcode character varying, IN p_newfornecedorlocality character varying, IN p_newfornecedoremail character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_fornecedor WHERE id = p_FornecedorId) THEN
        RAISE NOTICE 'Fornecedor não encontrado. Falha na edição do fornecedor.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_fornecedor
    SET
        name = p_NewFornecedorName,
        address = p_NewFornecedorAddress,
        postal_code = p_NewFornecedorPostalCode,
        locality = p_NewFornecedorLocality,
        email = p_NewFornecedorEmail
    WHERE
        id = p_FornecedorId;

    RAISE NOTICE 'Fornecedor editado com sucesso.';
END;
$$;


--
-- TOC entry 342 (class 1255 OID 37471)
-- Name: sp_edit_quantidades_encomenda_componentes(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_quantidades_encomenda_componentes(IN p_id integer, IN p_componente_id integer, IN p_new_quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
     IF EXISTS (
        SELECT 1
        FROM ipv_bd2_projeto_quantidadeencomendacomponente
        WHERE encomenda_id = p_id AND componente_id = p_componente_id
    ) THEN
        UPDATE ipv_bd2_projeto_quantidadeencomendacomponente
        SET
            amount = p_new_quantity
        WHERE
            encomenda_id = p_id AND componente_id = p_componente_id;
        RAISE NOTICE 'Quantidade de Componente na Encomenda editada com sucesso.';
    ELSE
        INSERT INTO ipv_bd2_projeto_quantidadeencomendacomponente (encomenda_id, componente_id, amount)
        VALUES (p_id, p_componente_id, p_new_quantity);
        RAISE NOTICE 'Nova Quantidade de Componente adicionada à Encomenda com sucesso.';
    END IF;
END;
$$;


--
-- TOC entry 348 (class 1255 OID 37482)
-- Name: sp_edit_registo_producao(integer, date, date, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_registo_producao(IN registo_prod_id integer, IN p_started_at date, IN p_ended_at date, IN p_armazem_id_id integer, IN p_tipo_mao_de_obra_id_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.id = registo_prod_id) THEN
        RAISE NOTICE 'Tipo de Registo não encontrado. Falha na edição do tipo de Registo.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_registoproducao
    SET
        started_at = p_started_at,
		ended_at = p_ended_at,
		armazem_id_id = p_armazem_id_id,
		tipo_mao_de_obra_id_id = p_tipo_mao_de_obra_id_id

    WHERE
        id = registo_prod_id;

    RAISE NOTICE 'Tipo de Equipamento editado com sucesso.';
END;
$$;


--
-- TOC entry 272 (class 1255 OID 36994)
-- Name: sp_edit_tipo_equipamento(integer, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_tipo_equipamento(IN p_tipoequipamentoid integer, IN p_newtipoequipamentoname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipodeequipamento WHERE id = p_TipoEquipamentoId) THEN
        RAISE NOTICE 'Tipo de Equipamento não encontrado. Falha na edição do tipo de equipamento.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_tipodeequipamento
    SET
        name = p_NewTipoEquipamentoName
    WHERE
        id = p_TipoEquipamentoId;

    RAISE NOTICE 'Tipo de Equipamento editado com sucesso.';
END;
$$;


--
-- TOC entry 287 (class 1255 OID 37006)
-- Name: sp_edit_tipo_mao_de_obra(integer, character varying, double precision); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_tipo_mao_de_obra(IN p_tipomaodeobraid integer, IN p_newtipomaodeobraname character varying, IN p_newtipomaodeobracost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipomaodeobra WHERE id = p_TipoMaoDeObraId) THEN
        RAISE NOTICE 'Tipo de Mão de Obra não encontrado. Falha na edição do tipo de mão de obra.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_tipomaodeobra
    SET
        name = p_NewTipoMaoDeObraName,
        cost = p_NewTipoMaoDeObraCost
    WHERE
        id = p_TipoMaoDeObraId;

    RAISE NOTICE 'Tipo de Mão de Obra editado com sucesso.';
END;
$$;


--
-- TOC entry 271 (class 1255 OID 33654)
-- Name: sp_edit_user(integer, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_edit_user(IN p_id integer, IN p_first_name character varying, IN p_last_name character varying, IN p_user_type character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_utilizador WHERE ipv_bd2_projeto_utilizador.id = p_id) THEN
        UPDATE ipv_bd2_projeto_utilizador SET first_name = p_first_name, last_name = p_last_name, type = p_user_type WHERE ipv_bd2_projeto_utilizador.id = p_id;
        RAISE NOTICE 'Utilizador atualizado com sucesso.';
    ELSE
        RAISE NOTICE 'Utilizador com id % não existe.', p_id;
    END IF;
END;
$$;


--
-- TOC entry 343 (class 1255 OID 37476)
-- Name: sp_mark_component_orders_as_exported(); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_mark_component_orders_as_exported()
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ipv_bd2_projeto_encomendacomponente
    SET exported = TRUE
    WHERE exported = FALSE;

    COMMIT;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 30733)
-- Name: auth_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


--
-- TOC entry 215 (class 1259 OID 30732)
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 30741)
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 30740)
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 214 (class 1259 OID 30727)
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 30726)
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 30747)
-- Name: auth_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 30755)
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 30754)
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 30746)
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 30761)
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 30760)
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 30819)
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


--
-- TOC entry 225 (class 1259 OID 30818)
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 212 (class 1259 OID 30719)
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 30718)
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 210 (class 1259 OID 30711)
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


--
-- TOC entry 209 (class 1259 OID 30710)
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 244 (class 1259 OID 31070)
-- Name: django_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 30847)
-- Name: ipv_bd2_projeto_armazem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_armazem (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    address character varying(100) NOT NULL,
    postal_code character varying(10) NOT NULL,
    locality character varying(50) NOT NULL
);


--
-- TOC entry 250 (class 1259 OID 33668)
-- Name: ipv_bd2_projeto_armazem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_armazem ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_armazem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 30852)
-- Name: ipv_bd2_projeto_componente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_componente (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at date NOT NULL,
    cost double precision NOT NULL,
    fornecedor_id_id integer NOT NULL
);


--
-- TOC entry 251 (class 1259 OID 33686)
-- Name: ipv_bd2_projeto_componente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_componente ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_componente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 30857)
-- Name: ipv_bd2_projeto_encomendacomponente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_encomendacomponente (
    id integer NOT NULL,
    created_at date NOT NULL,
    exported boolean NOT NULL,
    fornecedor_id_id integer NOT NULL,
    funcionario_responsavel_id_id integer NOT NULL
);


--
-- TOC entry 252 (class 1259 OID 33694)
-- Name: ipv_bd2_projeto_encomendacomponente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_encomendacomponente ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_encomendacomponente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 30862)
-- Name: ipv_bd2_projeto_encomendaequipamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_encomendaequipamento (
    id integer NOT NULL,
    created_at date NOT NULL,
    address character varying(50) NOT NULL,
    postal_code character varying(50) NOT NULL,
    locality character varying(50) NOT NULL,
    client_id_id integer NOT NULL,
    funcionario_id_id integer NOT NULL
);


--
-- TOC entry 253 (class 1259 OID 33712)
-- Name: ipv_bd2_projeto_encomendaequipamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_encomendaequipamento ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_encomendaequipamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 30867)
-- Name: ipv_bd2_projeto_equipamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_equipamento (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at date NOT NULL,
    tipo_equipamento_id_id integer NOT NULL
);


--
-- TOC entry 254 (class 1259 OID 33725)
-- Name: ipv_bd2_projeto_equipamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_equipamento ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_equipamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 30897)
-- Name: ipv_bd2_projeto_expedicao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_expedicao (
    sent_at date NOT NULL,
    truck_license character varying(50),
    delivery_date_expected date NOT NULL,
    encomenda_id_id integer NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 30902)
-- Name: ipv_bd2_projeto_fatura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_fatura (
    created_at date NOT NULL,
    contribuinte character varying(50) NOT NULL,
    encomenda_id_id integer NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 30872)
-- Name: ipv_bd2_projeto_fornecedor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_fornecedor (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    address character varying(50) NOT NULL,
    postal_code character varying(50) NOT NULL,
    locality character varying(50) NOT NULL,
    email character varying(254) NOT NULL
);


--
-- TOC entry 255 (class 1259 OID 33738)
-- Name: ipv_bd2_projeto_fornecedor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_fornecedor ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_fornecedor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 30877)
-- Name: ipv_bd2_projeto_guiaentregacomponente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_guiaentregacomponente (
    id integer NOT NULL,
    created_at date NOT NULL,
    armazem_id_id integer NOT NULL
);


--
-- TOC entry 256 (class 1259 OID 33746)
-- Name: ipv_bd2_projeto_guiaentregacomponente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_guiaentregacomponente ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_guiaentregacomponente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 243 (class 1259 OID 30927)
-- Name: ipv_bd2_projeto_quantidadecomponenteregistoproducao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_quantidadecomponenteregistoproducao (
    id integer NOT NULL,
    amount integer NOT NULL,
    componente_id integer NOT NULL,
    registo_producao_id integer NOT NULL
);


--
-- TOC entry 257 (class 1259 OID 33749)
-- Name: ipv_bd2_projeto_quantidadecomponenteregistoproducao_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_quantidadecomponenteregistoproducao ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_quantidadecomponenteregistoproducao_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 242 (class 1259 OID 30922)
-- Name: ipv_bd2_projeto_quantidadeencomendacomponente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_quantidadeencomendacomponente (
    id integer NOT NULL,
    amount integer NOT NULL,
    componente_id integer NOT NULL,
    encomenda_id integer NOT NULL
);


--
-- TOC entry 258 (class 1259 OID 33752)
-- Name: ipv_bd2_projeto_quantidadeencomendacomponente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_quantidadeencomendacomponente ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_quantidadeencomendacomponente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 30917)
-- Name: ipv_bd2_projeto_quantidadeencomendaequipamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_quantidadeencomendaequipamento (
    id integer NOT NULL,
    amount integer NOT NULL,
    encomenda_id integer NOT NULL,
    equipamento_id integer NOT NULL
);


--
-- TOC entry 259 (class 1259 OID 33755)
-- Name: ipv_bd2_projeto_quantidadeencomendaequipamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_quantidadeencomendaequipamento ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_quantidadeencomendaequipamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 240 (class 1259 OID 30912)
-- Name: ipv_bd2_projeto_quantidadeguiaentregacomponente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_quantidadeguiaentregacomponente (
    id integer NOT NULL,
    amount integer NOT NULL,
    componente_id integer NOT NULL,
    guia_entrega_id integer NOT NULL
);


--
-- TOC entry 260 (class 1259 OID 33758)
-- Name: ipv_bd2_projeto_quantidadeguiaentregacomponente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_quantidadeguiaentregacomponente ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_quantidadeguiaentregacomponente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 30907)
-- Name: ipv_bd2_projeto_registoproducao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_registoproducao (
    id integer NOT NULL,
    started_at date NOT NULL,
    ended_at date NOT NULL,
    armazem_id_id integer NOT NULL,
    equipamento_id_id integer NOT NULL,
    funcionario_id_id integer NOT NULL,
    tipo_mao_de_obra_id_id integer NOT NULL,
    expedicao_id_id integer
);


--
-- TOC entry 261 (class 1259 OID 33766)
-- Name: ipv_bd2_projeto_registoproducao_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_registoproducao ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_registoproducao_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 30882)
-- Name: ipv_bd2_projeto_tipodeequipamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_tipodeequipamento (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


--
-- TOC entry 262 (class 1259 OID 33774)
-- Name: ipv_bd2_projeto_tipodeequipamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_tipodeequipamento ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_tipodeequipamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 30887)
-- Name: ipv_bd2_projeto_tipomaodeobra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_tipomaodeobra (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    cost double precision NOT NULL
);


--
-- TOC entry 263 (class 1259 OID 33782)
-- Name: ipv_bd2_projeto_tipomaodeobra_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_tipomaodeobra ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_tipomaodeobra_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 236 (class 1259 OID 30892)
-- Name: ipv_bd2_projeto_utilizador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_utilizador (
    id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(254) NOT NULL,
    type character varying(2) NOT NULL,
    is_superuser boolean NOT NULL,
    last_login timestamp with time zone,
    password character varying(256) NOT NULL,
    is_staff boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    is_active boolean NOT NULL
);


--
-- TOC entry 246 (class 1259 OID 33574)
-- Name: ipv_bd2_projeto_utilizador_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_utilizador_groups (
    id bigint NOT NULL,
    utilizador_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- TOC entry 245 (class 1259 OID 33573)
-- Name: ipv_bd2_projeto_utilizador_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_utilizador_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_utilizador_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 249 (class 1259 OID 33620)
-- Name: ipv_bd2_projeto_utilizador_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_utilizador ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_utilizador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 248 (class 1259 OID 33584)
-- Name: ipv_bd2_projeto_utilizador_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipv_bd2_projeto_utilizador_user_permissions (
    id bigint NOT NULL,
    utilizador_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- TOC entry 247 (class 1259 OID 33583)
-- Name: ipv_bd2_projeto_utilizador_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ipv_bd2_projeto_utilizador_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipv_bd2_projeto_utilizador_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3361 (class 2606 OID 30845)
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- TOC entry 3366 (class 2606 OID 30776)
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- TOC entry 3369 (class 2606 OID 30745)
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3363 (class 2606 OID 30737)
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- TOC entry 3356 (class 2606 OID 30767)
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- TOC entry 3358 (class 2606 OID 30731)
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 3377 (class 2606 OID 30759)
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3380 (class 2606 OID 30791)
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- TOC entry 3371 (class 2606 OID 30751)
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3383 (class 2606 OID 30765)
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3386 (class 2606 OID 30805)
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- TOC entry 3374 (class 2606 OID 30840)
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- TOC entry 3389 (class 2606 OID 30826)
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3351 (class 2606 OID 30725)
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- TOC entry 3353 (class 2606 OID 30723)
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3349 (class 2606 OID 30717)
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3458 (class 2606 OID 31076)
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- TOC entry 3392 (class 2606 OID 33657)
-- Name: ipv_bd2_projeto_armazem ipv_bd2_projeto_armazem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_armazem
    ADD CONSTRAINT ipv_bd2_projeto_armazem_pkey PRIMARY KEY (id);


--
-- TOC entry 3395 (class 2606 OID 33670)
-- Name: ipv_bd2_projeto_componente ipv_bd2_projeto_componente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_componente
    ADD CONSTRAINT ipv_bd2_projeto_componente_pkey PRIMARY KEY (id);


--
-- TOC entry 3399 (class 2606 OID 33688)
-- Name: ipv_bd2_projeto_encomendacomponente ipv_bd2_projeto_encomendacomponente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_encomendacomponente
    ADD CONSTRAINT ipv_bd2_projeto_encomendacomponente_pkey PRIMARY KEY (id);


--
-- TOC entry 3403 (class 2606 OID 33696)
-- Name: ipv_bd2_projeto_encomendaequipamento ipv_bd2_projeto_encomendaequipamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_encomendaequipamento
    ADD CONSTRAINT ipv_bd2_projeto_encomendaequipamento_pkey PRIMARY KEY (id);


--
-- TOC entry 3405 (class 2606 OID 33714)
-- Name: ipv_bd2_projeto_equipamento ipv_bd2_projeto_equipamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_equipamento
    ADD CONSTRAINT ipv_bd2_projeto_equipamento_pkey PRIMARY KEY (id);


--
-- TOC entry 3422 (class 2606 OID 30901)
-- Name: ipv_bd2_projeto_expedicao ipv_bd2_projeto_expedicao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_expedicao
    ADD CONSTRAINT ipv_bd2_projeto_expedicao_pkey PRIMARY KEY (encomenda_id_id);


--
-- TOC entry 3424 (class 2606 OID 30906)
-- Name: ipv_bd2_projeto_fatura ipv_bd2_projeto_fatura_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_fatura
    ADD CONSTRAINT ipv_bd2_projeto_fatura_pkey PRIMARY KEY (encomenda_id_id);


--
-- TOC entry 3408 (class 2606 OID 33727)
-- Name: ipv_bd2_projeto_fornecedor ipv_bd2_projeto_fornecedor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_fornecedor
    ADD CONSTRAINT ipv_bd2_projeto_fornecedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3411 (class 2606 OID 33740)
-- Name: ipv_bd2_projeto_guiaentregacomponente ipv_bd2_projeto_guiaentregacomponente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_guiaentregacomponente
    ADD CONSTRAINT ipv_bd2_projeto_guiaentregacomponente_pkey PRIMARY KEY (id);


--
-- TOC entry 3453 (class 2606 OID 33748)
-- Name: ipv_bd2_projeto_quantidadecomponenteregistoproducao ipv_bd2_projeto_quantidadecomponenteregistoproducao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadecomponenteregistoproducao
    ADD CONSTRAINT ipv_bd2_projeto_quantidadecomponenteregistoproducao_pkey PRIMARY KEY (id);


--
-- TOC entry 3447 (class 2606 OID 33751)
-- Name: ipv_bd2_projeto_quantidadeencomendacomponente ipv_bd2_projeto_quantidadeencomendacomponente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendacomponente
    ADD CONSTRAINT ipv_bd2_projeto_quantidadeencomendacomponente_pkey PRIMARY KEY (id);


--
-- TOC entry 3441 (class 2606 OID 33754)
-- Name: ipv_bd2_projeto_quantidadeencomendaequipamento ipv_bd2_projeto_quantidadeencomendaequipamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendaequipamento
    ADD CONSTRAINT ipv_bd2_projeto_quantidadeencomendaequipamento_pkey PRIMARY KEY (id);


--
-- TOC entry 3435 (class 2606 OID 33757)
-- Name: ipv_bd2_projeto_quantidadeguiaentregacomponente ipv_bd2_projeto_quantidadeguiaentregacomponente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeguiaentregacomponente
    ADD CONSTRAINT ipv_bd2_projeto_quantidadeguiaentregacomponente_pkey PRIMARY KEY (id);


--
-- TOC entry 3430 (class 2606 OID 33760)
-- Name: ipv_bd2_projeto_registoproducao ipv_bd2_projeto_registoproducao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_registoproducao
    ADD CONSTRAINT ipv_bd2_projeto_registoproducao_pkey PRIMARY KEY (id);


--
-- TOC entry 3413 (class 2606 OID 33768)
-- Name: ipv_bd2_projeto_tipodeequipamento ipv_bd2_projeto_tipodeequipamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_tipodeequipamento
    ADD CONSTRAINT ipv_bd2_projeto_tipodeequipamento_pkey PRIMARY KEY (id);


--
-- TOC entry 3415 (class 2606 OID 33776)
-- Name: ipv_bd2_projeto_tipomaodeobra ipv_bd2_projeto_tipomaodeobra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_tipomaodeobra
    ADD CONSTRAINT ipv_bd2_projeto_tipomaodeobra_pkey PRIMARY KEY (id);


--
-- TOC entry 3461 (class 2606 OID 33622)
-- Name: ipv_bd2_projeto_utilizador_groups ipv_bd2_projeto_utilizad_utilizador_id_group_id_33c28c17_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_groups
    ADD CONSTRAINT ipv_bd2_projeto_utilizad_utilizador_id_group_id_33c28c17_uniq UNIQUE (utilizador_id, group_id);


--
-- TOC entry 3467 (class 2606 OID 33636)
-- Name: ipv_bd2_projeto_utilizador_user_permissions ipv_bd2_projeto_utilizad_utilizador_id_permission_3bfa85d3_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_user_permissions
    ADD CONSTRAINT ipv_bd2_projeto_utilizad_utilizador_id_permission_3bfa85d3_uniq UNIQUE (utilizador_id, permission_id);


--
-- TOC entry 3418 (class 2606 OID 33596)
-- Name: ipv_bd2_projeto_utilizador ipv_bd2_projeto_utilizador_email_82f46450_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador
    ADD CONSTRAINT ipv_bd2_projeto_utilizador_email_82f46450_uniq UNIQUE (email);


--
-- TOC entry 3464 (class 2606 OID 33578)
-- Name: ipv_bd2_projeto_utilizador_groups ipv_bd2_projeto_utilizador_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_groups
    ADD CONSTRAINT ipv_bd2_projeto_utilizador_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3420 (class 2606 OID 33599)
-- Name: ipv_bd2_projeto_utilizador ipv_bd2_projeto_utilizador_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador
    ADD CONSTRAINT ipv_bd2_projeto_utilizador_pkey PRIMARY KEY (id);


--
-- TOC entry 3470 (class 2606 OID 33588)
-- Name: ipv_bd2_projeto_utilizador_user_permissions ipv_bd2_projeto_utilizador_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_user_permissions
    ADD CONSTRAINT ipv_bd2_projeto_utilizador_user_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3449 (class 2606 OID 30967)
-- Name: ipv_bd2_projeto_quantidadeencomendacomponente unique_componente_encomenda; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendacomponente
    ADD CONSTRAINT unique_componente_encomenda UNIQUE (componente_id, encomenda_id);


--
-- TOC entry 3437 (class 2606 OID 30963)
-- Name: ipv_bd2_projeto_quantidadeguiaentregacomponente unique_componente_guia_entrega; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeguiaentregacomponente
    ADD CONSTRAINT unique_componente_guia_entrega UNIQUE (componente_id, guia_entrega_id);


--
-- TOC entry 3455 (class 2606 OID 30969)
-- Name: ipv_bd2_projeto_quantidadecomponenteregistoproducao unique_componente_registo_producao; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadecomponenteregistoproducao
    ADD CONSTRAINT unique_componente_registo_producao UNIQUE (componente_id, registo_producao_id);


--
-- TOC entry 3443 (class 2606 OID 30965)
-- Name: ipv_bd2_projeto_quantidadeencomendaequipamento unique_equipamento_encomenda; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendaequipamento
    ADD CONSTRAINT unique_equipamento_encomenda UNIQUE (equipamento_id, encomenda_id);


--
-- TOC entry 3359 (class 1259 OID 30846)
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- TOC entry 3364 (class 1259 OID 30787)
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- TOC entry 3367 (class 1259 OID 30788)
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- TOC entry 3354 (class 1259 OID 30773)
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- TOC entry 3375 (class 1259 OID 30803)
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- TOC entry 3378 (class 1259 OID 30802)
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- TOC entry 3381 (class 1259 OID 30817)
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- TOC entry 3384 (class 1259 OID 30816)
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- TOC entry 3372 (class 1259 OID 30841)
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- TOC entry 3387 (class 1259 OID 30837)
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- TOC entry 3390 (class 1259 OID 30838)
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- TOC entry 3456 (class 1259 OID 31078)
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- TOC entry 3459 (class 1259 OID 31077)
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- TOC entry 3393 (class 1259 OID 31069)
-- Name: ipv_bd2_projeto_componente_fornecedor_id_id_df64b80e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_componente_fornecedor_id_id_df64b80e ON public.ipv_bd2_projeto_componente USING btree (fornecedor_id_id);


--
-- TOC entry 3396 (class 1259 OID 31068)
-- Name: ipv_bd2_projeto_encomendac_funcionario_responsavel_id_3f63ec99; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_encomendac_funcionario_responsavel_id_3f63ec99 ON public.ipv_bd2_projeto_encomendacomponente USING btree (funcionario_responsavel_id_id);


--
-- TOC entry 3397 (class 1259 OID 31067)
-- Name: ipv_bd2_projeto_encomendacomponente_fornecedor_id_id_0fd80159; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_encomendacomponente_fornecedor_id_id_0fd80159 ON public.ipv_bd2_projeto_encomendacomponente USING btree (fornecedor_id_id);


--
-- TOC entry 3400 (class 1259 OID 31065)
-- Name: ipv_bd2_projeto_encomendaequipamento_client_id_id_f8333eab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_encomendaequipamento_client_id_id_f8333eab ON public.ipv_bd2_projeto_encomendaequipamento USING btree (client_id_id);


--
-- TOC entry 3401 (class 1259 OID 31066)
-- Name: ipv_bd2_projeto_encomendaequipamento_funcionario_id_id_ae493915; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_encomendaequipamento_funcionario_id_id_ae493915 ON public.ipv_bd2_projeto_encomendaequipamento USING btree (funcionario_id_id);


--
-- TOC entry 3406 (class 1259 OID 31064)
-- Name: ipv_bd2_projeto_equipamento_tipo_equipamento_id_id_2d6452e1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_equipamento_tipo_equipamento_id_id_2d6452e1 ON public.ipv_bd2_projeto_equipamento USING btree (tipo_equipamento_id_id);


--
-- TOC entry 3409 (class 1259 OID 30975)
-- Name: ipv_bd2_projeto_guiaentregacomponente_armazem_id_id_6fec9e87; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_guiaentregacomponente_armazem_id_id_6fec9e87 ON public.ipv_bd2_projeto_guiaentregacomponente USING btree (armazem_id_id);


--
-- TOC entry 3450 (class 1259 OID 31062)
-- Name: ipv_bd2_projeto_quantidade_componente_id_5c1bd6eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_componente_id_5c1bd6eb ON public.ipv_bd2_projeto_quantidadecomponenteregistoproducao USING btree (componente_id);


--
-- TOC entry 3432 (class 1259 OID 31026)
-- Name: ipv_bd2_projeto_quantidade_componente_id_bf73b2fb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_componente_id_bf73b2fb ON public.ipv_bd2_projeto_quantidadeguiaentregacomponente USING btree (componente_id);


--
-- TOC entry 3444 (class 1259 OID 31050)
-- Name: ipv_bd2_projeto_quantidade_componente_id_d308854e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_componente_id_d308854e ON public.ipv_bd2_projeto_quantidadeencomendacomponente USING btree (componente_id);


--
-- TOC entry 3438 (class 1259 OID 31038)
-- Name: ipv_bd2_projeto_quantidade_encomenda_id_9eadfdd0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_encomenda_id_9eadfdd0 ON public.ipv_bd2_projeto_quantidadeencomendaequipamento USING btree (encomenda_id);


--
-- TOC entry 3445 (class 1259 OID 31051)
-- Name: ipv_bd2_projeto_quantidade_encomenda_id_e366189d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_encomenda_id_e366189d ON public.ipv_bd2_projeto_quantidadeencomendacomponente USING btree (encomenda_id);


--
-- TOC entry 3439 (class 1259 OID 31039)
-- Name: ipv_bd2_projeto_quantidade_equipamento_id_bc6a2a0b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_equipamento_id_bc6a2a0b ON public.ipv_bd2_projeto_quantidadeencomendaequipamento USING btree (equipamento_id);


--
-- TOC entry 3433 (class 1259 OID 31027)
-- Name: ipv_bd2_projeto_quantidade_guia_entrega_id_c8202fb3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_guia_entrega_id_c8202fb3 ON public.ipv_bd2_projeto_quantidadeguiaentregacomponente USING btree (guia_entrega_id);


--
-- TOC entry 3451 (class 1259 OID 31063)
-- Name: ipv_bd2_projeto_quantidade_registo_producao_id_ebc87815; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_quantidade_registo_producao_id_ebc87815 ON public.ipv_bd2_projeto_quantidadecomponenteregistoproducao USING btree (registo_producao_id);


--
-- TOC entry 3425 (class 1259 OID 31011)
-- Name: ipv_bd2_projeto_registoproducao_armazem_id_id_3ea7abec; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_registoproducao_armazem_id_id_3ea7abec ON public.ipv_bd2_projeto_registoproducao USING btree (armazem_id_id);


--
-- TOC entry 3426 (class 1259 OID 31012)
-- Name: ipv_bd2_projeto_registoproducao_equipamento_id_id_76f1b7be; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_registoproducao_equipamento_id_id_76f1b7be ON public.ipv_bd2_projeto_registoproducao USING btree (equipamento_id_id);


--
-- TOC entry 3427 (class 1259 OID 37413)
-- Name: ipv_bd2_projeto_registoproducao_expedicao_id_id_85c4025b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_registoproducao_expedicao_id_id_85c4025b ON public.ipv_bd2_projeto_registoproducao USING btree (expedicao_id_id);


--
-- TOC entry 3428 (class 1259 OID 31013)
-- Name: ipv_bd2_projeto_registoproducao_funcionario_id_id_76156b7b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_registoproducao_funcionario_id_id_76156b7b ON public.ipv_bd2_projeto_registoproducao USING btree (funcionario_id_id);


--
-- TOC entry 3431 (class 1259 OID 31014)
-- Name: ipv_bd2_projeto_registoproducao_tipo_mao_de_obra_id_id_966089c6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_registoproducao_tipo_mao_de_obra_id_id_966089c6 ON public.ipv_bd2_projeto_registoproducao USING btree (tipo_mao_de_obra_id_id);


--
-- TOC entry 3416 (class 1259 OID 33597)
-- Name: ipv_bd2_projeto_utilizador_email_82f46450_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_utilizador_email_82f46450_like ON public.ipv_bd2_projeto_utilizador USING btree (email varchar_pattern_ops);


--
-- TOC entry 3462 (class 1259 OID 33634)
-- Name: ipv_bd2_projeto_utilizador_groups_group_id_45e4a6ad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_utilizador_groups_group_id_45e4a6ad ON public.ipv_bd2_projeto_utilizador_groups USING btree (group_id);


--
-- TOC entry 3465 (class 1259 OID 33633)
-- Name: ipv_bd2_projeto_utilizador_groups_utilizador_id_a98d0b2a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_utilizador_groups_utilizador_id_a98d0b2a ON public.ipv_bd2_projeto_utilizador_groups USING btree (utilizador_id);


--
-- TOC entry 3468 (class 1259 OID 33648)
-- Name: ipv_bd2_projeto_utilizador_permission_id_a05a2c5e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_utilizador_permission_id_a05a2c5e ON public.ipv_bd2_projeto_utilizador_user_permissions USING btree (permission_id);


--
-- TOC entry 3471 (class 1259 OID 33647)
-- Name: ipv_bd2_projeto_utilizador_utilizador_id_0f32fd19; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ipv_bd2_projeto_utilizador_utilizador_id_0f32fd19 ON public.ipv_bd2_projeto_utilizador_user_permissions USING btree (utilizador_id);


--
-- TOC entry 3473 (class 2606 OID 30782)
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3474 (class 2606 OID 30777)
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3472 (class 2606 OID 30768)
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3475 (class 2606 OID 30797)
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3476 (class 2606 OID 30792)
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3477 (class 2606 OID 30811)
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3478 (class 2606 OID 30806)
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3479 (class 2606 OID 30827)
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3480 (class 2606 OID 30832)
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3481 (class 2606 OID 33733)
-- Name: ipv_bd2_projeto_componente ipv_bd2_projeto_comp_fornecedor_id_id_df64b80e_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_componente
    ADD CONSTRAINT ipv_bd2_projeto_comp_fornecedor_id_id_df64b80e_fk_ipv_bd2_p FOREIGN KEY (fornecedor_id_id) REFERENCES public.ipv_bd2_projeto_fornecedor(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3484 (class 2606 OID 33600)
-- Name: ipv_bd2_projeto_encomendaequipamento ipv_bd2_projeto_enco_client_id_id_f8333eab_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_encomendaequipamento
    ADD CONSTRAINT ipv_bd2_projeto_enco_client_id_id_f8333eab_fk_ipv_bd2_p FOREIGN KEY (client_id_id) REFERENCES public.ipv_bd2_projeto_utilizador(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3482 (class 2606 OID 33728)
-- Name: ipv_bd2_projeto_encomendacomponente ipv_bd2_projeto_enco_fornecedor_id_id_0fd80159_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_encomendacomponente
    ADD CONSTRAINT ipv_bd2_projeto_enco_fornecedor_id_id_0fd80159_fk_ipv_bd2_p FOREIGN KEY (fornecedor_id_id) REFERENCES public.ipv_bd2_projeto_fornecedor(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3485 (class 2606 OID 33605)
-- Name: ipv_bd2_projeto_encomendaequipamento ipv_bd2_projeto_enco_funcionario_id_id_ae493915_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_encomendaequipamento
    ADD CONSTRAINT ipv_bd2_projeto_enco_funcionario_id_id_ae493915_fk_ipv_bd2_p FOREIGN KEY (funcionario_id_id) REFERENCES public.ipv_bd2_projeto_utilizador(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3483 (class 2606 OID 33610)
-- Name: ipv_bd2_projeto_encomendacomponente ipv_bd2_projeto_enco_funcionario_responsa_3f63ec99_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_encomendacomponente
    ADD CONSTRAINT ipv_bd2_projeto_enco_funcionario_responsa_3f63ec99_fk_ipv_bd2_p FOREIGN KEY (funcionario_responsavel_id_id) REFERENCES public.ipv_bd2_projeto_utilizador(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3486 (class 2606 OID 33769)
-- Name: ipv_bd2_projeto_equipamento ipv_bd2_projeto_equi_tipo_equipamento_id__2d6452e1_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_equipamento
    ADD CONSTRAINT ipv_bd2_projeto_equi_tipo_equipamento_id__2d6452e1_fk_ipv_bd2_p FOREIGN KEY (tipo_equipamento_id_id) REFERENCES public.ipv_bd2_projeto_tipodeequipamento(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3488 (class 2606 OID 33697)
-- Name: ipv_bd2_projeto_expedicao ipv_bd2_projeto_expe_encomenda_id_id_387d2844_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_expedicao
    ADD CONSTRAINT ipv_bd2_projeto_expe_encomenda_id_id_387d2844_fk_ipv_bd2_p FOREIGN KEY (encomenda_id_id) REFERENCES public.ipv_bd2_projeto_encomendaequipamento(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3489 (class 2606 OID 33702)
-- Name: ipv_bd2_projeto_fatura ipv_bd2_projeto_fatu_encomenda_id_id_37f7678b_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_fatura
    ADD CONSTRAINT ipv_bd2_projeto_fatu_encomenda_id_id_37f7678b_fk_ipv_bd2_p FOREIGN KEY (encomenda_id_id) REFERENCES public.ipv_bd2_projeto_encomendaequipamento(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3487 (class 2606 OID 33658)
-- Name: ipv_bd2_projeto_guiaentregacomponente ipv_bd2_projeto_guia_armazem_id_id_6fec9e87_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_guiaentregacomponente
    ADD CONSTRAINT ipv_bd2_projeto_guia_armazem_id_id_6fec9e87_fk_ipv_bd2_p FOREIGN KEY (armazem_id_id) REFERENCES public.ipv_bd2_projeto_armazem(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3501 (class 2606 OID 33681)
-- Name: ipv_bd2_projeto_quantidadecomponenteregistoproducao ipv_bd2_projeto_quan_componente_id_5c1bd6eb_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadecomponenteregistoproducao
    ADD CONSTRAINT ipv_bd2_projeto_quan_componente_id_5c1bd6eb_fk_ipv_bd2_p FOREIGN KEY (componente_id) REFERENCES public.ipv_bd2_projeto_componente(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3495 (class 2606 OID 33671)
-- Name: ipv_bd2_projeto_quantidadeguiaentregacomponente ipv_bd2_projeto_quan_componente_id_bf73b2fb_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeguiaentregacomponente
    ADD CONSTRAINT ipv_bd2_projeto_quan_componente_id_bf73b2fb_fk_ipv_bd2_p FOREIGN KEY (componente_id) REFERENCES public.ipv_bd2_projeto_componente(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3499 (class 2606 OID 33676)
-- Name: ipv_bd2_projeto_quantidadeencomendacomponente ipv_bd2_projeto_quan_componente_id_d308854e_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendacomponente
    ADD CONSTRAINT ipv_bd2_projeto_quan_componente_id_d308854e_fk_ipv_bd2_p FOREIGN KEY (componente_id) REFERENCES public.ipv_bd2_projeto_componente(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3497 (class 2606 OID 33707)
-- Name: ipv_bd2_projeto_quantidadeencomendaequipamento ipv_bd2_projeto_quan_encomenda_id_9eadfdd0_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendaequipamento
    ADD CONSTRAINT ipv_bd2_projeto_quan_encomenda_id_9eadfdd0_fk_ipv_bd2_p FOREIGN KEY (encomenda_id) REFERENCES public.ipv_bd2_projeto_encomendaequipamento(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3500 (class 2606 OID 33689)
-- Name: ipv_bd2_projeto_quantidadeencomendacomponente ipv_bd2_projeto_quan_encomenda_id_e366189d_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendacomponente
    ADD CONSTRAINT ipv_bd2_projeto_quan_encomenda_id_e366189d_fk_ipv_bd2_p FOREIGN KEY (encomenda_id) REFERENCES public.ipv_bd2_projeto_encomendacomponente(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3498 (class 2606 OID 33720)
-- Name: ipv_bd2_projeto_quantidadeencomendaequipamento ipv_bd2_projeto_quan_equipamento_id_bc6a2a0b_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeencomendaequipamento
    ADD CONSTRAINT ipv_bd2_projeto_quan_equipamento_id_bc6a2a0b_fk_ipv_bd2_p FOREIGN KEY (equipamento_id) REFERENCES public.ipv_bd2_projeto_equipamento(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3496 (class 2606 OID 33741)
-- Name: ipv_bd2_projeto_quantidadeguiaentregacomponente ipv_bd2_projeto_quan_guia_entrega_id_c8202fb3_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadeguiaentregacomponente
    ADD CONSTRAINT ipv_bd2_projeto_quan_guia_entrega_id_c8202fb3_fk_ipv_bd2_p FOREIGN KEY (guia_entrega_id) REFERENCES public.ipv_bd2_projeto_guiaentregacomponente(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3502 (class 2606 OID 33761)
-- Name: ipv_bd2_projeto_quantidadecomponenteregistoproducao ipv_bd2_projeto_quan_registo_producao_id_ebc87815_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_quantidadecomponenteregistoproducao
    ADD CONSTRAINT ipv_bd2_projeto_quan_registo_producao_id_ebc87815_fk_ipv_bd2_p FOREIGN KEY (registo_producao_id) REFERENCES public.ipv_bd2_projeto_registoproducao(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3490 (class 2606 OID 33663)
-- Name: ipv_bd2_projeto_registoproducao ipv_bd2_projeto_regi_armazem_id_id_3ea7abec_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_registoproducao
    ADD CONSTRAINT ipv_bd2_projeto_regi_armazem_id_id_3ea7abec_fk_ipv_bd2_p FOREIGN KEY (armazem_id_id) REFERENCES public.ipv_bd2_projeto_armazem(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3491 (class 2606 OID 33715)
-- Name: ipv_bd2_projeto_registoproducao ipv_bd2_projeto_regi_equipamento_id_id_76f1b7be_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_registoproducao
    ADD CONSTRAINT ipv_bd2_projeto_regi_equipamento_id_id_76f1b7be_fk_ipv_bd2_p FOREIGN KEY (equipamento_id_id) REFERENCES public.ipv_bd2_projeto_equipamento(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3492 (class 2606 OID 37408)
-- Name: ipv_bd2_projeto_registoproducao ipv_bd2_projeto_regi_expedicao_id_id_85c4025b_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_registoproducao
    ADD CONSTRAINT ipv_bd2_projeto_regi_expedicao_id_id_85c4025b_fk_ipv_bd2_p FOREIGN KEY (expedicao_id_id) REFERENCES public.ipv_bd2_projeto_expedicao(encomenda_id_id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3493 (class 2606 OID 33615)
-- Name: ipv_bd2_projeto_registoproducao ipv_bd2_projeto_regi_funcionario_id_id_76156b7b_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_registoproducao
    ADD CONSTRAINT ipv_bd2_projeto_regi_funcionario_id_id_76156b7b_fk_ipv_bd2_p FOREIGN KEY (funcionario_id_id) REFERENCES public.ipv_bd2_projeto_utilizador(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3494 (class 2606 OID 33777)
-- Name: ipv_bd2_projeto_registoproducao ipv_bd2_projeto_regi_tipo_mao_de_obra_id__966089c6_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_registoproducao
    ADD CONSTRAINT ipv_bd2_projeto_regi_tipo_mao_de_obra_id__966089c6_fk_ipv_bd2_p FOREIGN KEY (tipo_mao_de_obra_id_id) REFERENCES public.ipv_bd2_projeto_tipomaodeobra(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3503 (class 2606 OID 33628)
-- Name: ipv_bd2_projeto_utilizador_groups ipv_bd2_projeto_util_group_id_45e4a6ad_fk_auth_grou; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_groups
    ADD CONSTRAINT ipv_bd2_projeto_util_group_id_45e4a6ad_fk_auth_grou FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3505 (class 2606 OID 33642)
-- Name: ipv_bd2_projeto_utilizador_user_permissions ipv_bd2_projeto_util_permission_id_a05a2c5e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_user_permissions
    ADD CONSTRAINT ipv_bd2_projeto_util_permission_id_a05a2c5e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3506 (class 2606 OID 33637)
-- Name: ipv_bd2_projeto_utilizador_user_permissions ipv_bd2_projeto_util_utilizador_id_0f32fd19_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_user_permissions
    ADD CONSTRAINT ipv_bd2_projeto_util_utilizador_id_0f32fd19_fk_ipv_bd2_p FOREIGN KEY (utilizador_id) REFERENCES public.ipv_bd2_projeto_utilizador(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 3504 (class 2606 OID 33623)
-- Name: ipv_bd2_projeto_utilizador_groups ipv_bd2_projeto_util_utilizador_id_a98d0b2a_fk_ipv_bd2_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipv_bd2_projeto_utilizador_groups
    ADD CONSTRAINT ipv_bd2_projeto_util_utilizador_id_a98d0b2a_fk_ipv_bd2_p FOREIGN KEY (utilizador_id) REFERENCES public.ipv_bd2_projeto_utilizador(id) DEFERRABLE INITIALLY DEFERRED;


-- Completed on 2024-01-06 17:29:40 UTC

--
-- PostgreSQL database dump complete
--

