--
-- TOC entry 307 (class 1255 OID 37056)
-- Name: fn_create_encomenda_componentes(timestamp without time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_create_encomenda_componentes(p_created_at timestamp without time zone, p_funcionario_id integer, p_fornecedor_id integer) RETURNS integer
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
-- TOC entry 308 (class 1255 OID 37220)
-- Name: fn_delete_armazem(character varying); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_armazem(p_name character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    item_in_use boolean;
BEGIN
    -- Verificar se o armazém está sendo usado em algum lugar
    SELECT EXISTS (SELECT 1 FROM ipv_bd2_projeto_resgistoproducao WHERE ipv_bd2_projeto_armazem.name = p_name) INTO item_in_use;

    IF item_in_use THEN
        RAISE NOTICE 'Não é possível apagar o armazém, pois está sendo usado em algum lugar.';
        RETURN FALSE;
    ELSE
        -- Se não estiver sendo usado, realizar a exclusão
        IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.name = p_name) THEN
            DELETE FROM ipv_bd2_projeto_armazem WHERE name = p_name;
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
-- TOC entry 310 (class 1255 OID 37222)
-- Name: fn_delete_armazem_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_armazem_by_id(p_id integer) RETURNS boolean
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
-- TOC entry 318 (class 1255 OID 37287)
-- Name: fn_delete_component_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_component_by_id(p_id integer) RETURNS boolean
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
-- TOC entry 316 (class 1255 OID 37282)
-- Name: fn_delete_equipment_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_equipment_by_id(p_id integer) RETURNS boolean
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
-- TOC entry 315 (class 1255 OID 37228)
-- Name: fn_delete_fornecedor_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_fornecedor_by_id(p_id integer) RETURNS boolean
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
-- TOC entry 309 (class 1255 OID 37224)
-- Name: fn_delete_labor_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_labor_by_id(p_id integer) RETURNS boolean
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
-- TOC entry 314 (class 1255 OID 37227)
-- Name: fn_delete_tipo_equipamento_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_delete_tipo_equipamento_by_id(p_id integer) RETURNS boolean
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
-- TOC entry 287 (class 1255 OID 36999)
-- Name: fn_get_armazem_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_armazem_by_id(p_armazem_id integer) RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = p_armazem_id;
END;
$$;

--
-- TOC entry 283 (class 1255 OID 37000)
-- Name: fn_get_armazens(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_armazens() RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_armazem ORDER BY id;
END;
$$;

--
-- TOC entry 301 (class 1255 OID 37024)
-- Name: fn_get_component(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_component(p_componentid integer) RETURNS TABLE(id integer, name character varying, created_at date, cost double precision, fornecedor_id integer)
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
-- TOC entry 313 (class 1255 OID 37286)
-- Name: fn_get_component_order_amounts(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_component_order_amounts() RETURNS TABLE(componente_id integer, component character varying, amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
	SELECT
	    q.encomenda_id,
        c.name,
        q.amount
	FROM ipv_bd2_projeto_quantidadeencomendacomponente q
	INNER JOIN ipv_bd2_projeto_componente c on q.componente_id = c.id;
END;
$$;

--
-- TOC entry 317 (class 1255 OID 37283)
-- Name: fn_get_component_orders(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_component_orders() RETURNS TABLE(id integer, created_at date, fornecedor_name character varying, funcionario_responsavel_name text, exported boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.created_at,
        f.name AS fornecedor_name,
        u.first_name || ' ' || u.last_name AS funcionario_responsavel_name,
        e.exported
    FROM
        ipv_bd2_projeto_encomendacomponente e
    INNER JOIN
        ipv_bd2_projeto_fornecedor f ON e.fornecedor_id_id = f.id
    INNER JOIN
        ipv_bd2_projeto_utilizador u ON e.funcionario_responsavel_id_id = u.id;
END;
$$;

--
-- TOC entry 299 (class 1255 OID 37026)
-- Name: fn_get_components(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_components() RETURNS TABLE(component_id integer, component_name character varying, component_created_at date, component_cost double precision, fornecedor_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.name ,
        c.created_at,
        c.cost ,
        f.name
    FROM
        ipv_bd2_projeto_componente c
    JOIN
        ipv_bd2_projeto_fornecedor f ON c.fornecedor_id_id = f.id;
END;
$$;

--
-- TOC entry 305 (class 1255 OID 37030)
-- Name: fn_get_encomenda_componentes_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_encomenda_componentes_by_id(p_encomenda_id integer)
RETURNS TABLE(
    id integer,
    created_at date,
    fornecedor_id integer,
    funcionario_responsavel_id integer,
    exported boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_encomendacomponente.id,
        ipv_bd2_projeto_encomendacomponente.created_at,
        ipv_bd2_projeto_encomendacomponente.fornecedor_id_id,
        ipv_bd2_projeto_encomendacomponente.funcionario_responsavel_id_id,
        ipv_bd2_projeto_encomendacomponente.exported
    FROM
        ipv_bd2_projeto_encomendacomponente
    WHERE
        ipv_bd2_projeto_encomendacomponente.id = p_encomenda_id;
END;
$$;

--
-- TOC entry 300 (class 1255 OID 37022)
-- Name: fn_get_equipamento_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_equipamento_by_id(p_equipamentoid integer) RETURNS TABLE(id integer, name character varying, created_at date, tipo_equipamento_id_id integer)
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
-- TOC entry 296 (class 1255 OID 37017)
-- Name: fn_get_equipamentos(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_equipamentos() RETURNS TABLE(id integer, name character varying, created_at date, tipo_equipamento_name character varying)
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
-- TOC entry 264 (class 1255 OID 37005)
-- Name: fn_get_fatura(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_fatura() RETURNS TABLE(created_at date, contribuinte integer, encomenda_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_fatura;
END;
$$;

--
-- TOC entry 294 (class 1255 OID 37010)
-- Name: fn_get_fornecedor_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_fornecedor_by_id(p_fornecedor_id integer) RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.id = p_fornecedor_id;
END;
$$;

--
-- TOC entry 291 (class 1255 OID 37008)
-- Name: fn_get_fornecedores(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_fornecedores() RETURNS TABLE(id integer, name character varying, address character varying, postal_code character varying, locality character varying, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_fornecedor;
END;
$$;

--
-- TOC entry 306 (class 1255 OID 37050)
-- Name: fn_get_quantity_orders(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_quantity_orders(p_id integer, p_encomenda_id integer, p_componente_id integer, p_amount integer) RETURNS TABLE(id integer, encomenda_id integer, componente_id integer, amount integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM ipv_bd2_projeto_quantidadeencomendacomponente
    WHERE
        (p_id IS NULL OR ipv_bd2_projeto_quantidadeencomendacomponente.id = p_id)
        AND (p_encomenda_id IS NULL OR ipv_bd2_projeto_quantidadeencomendacomponente.encomenda_id = p_encomenda_id)
        AND (p_componente_id IS NULL OR ipv_bd2_projeto_quantidadeencomendacomponente.componente_id = p_componente_id)
        AND (p_amount IS NULL OR ipv_bd2_projeto_quantidadeencomendacomponente.amount = p_amount);
END;
$$;

--
-- TOC entry 267 (class 1255 OID 36995)
-- Name: fn_get_tipo_equipamento(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_tipo_equipamento(p_tipo_id integer) RETURNS TABLE(id integer, name character varying)
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
-- TOC entry 284 (class 1255 OID 33783)
-- Name: fn_get_tipo_equipamentos(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_tipo_equipamentos() RETURNS TABLE(id integer, tipo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT ipv_bd2_projeto_tipodeequipamento.id, ipv_bd2_projeto_tipodeequipamento.name FROM ipv_bd2_projeto_tipodeequipamento;
END;
$$;

--
-- TOC entry 290 (class 1255 OID 37002)
-- Name: fn_get_tipo_mao_obra(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_tipo_mao_obra() RETURNS TABLE(id integer, name character varying, cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_tipomaodeobra ORDER BY id;
END;
$$;

--
-- TOC entry 265 (class 1255 OID 37003)
-- Name: fn_get_tipo_mao_obra_by_id(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_tipo_mao_obra_by_id(p_tipo_mao_obra_id integer) RETURNS TABLE(id integer, name character varying, cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = p_tipo_mao_obra_id;
END;
$$;

--
-- TOC entry 268 (class 1255 OID 33653)
-- Name: fn_get_user(integer); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_user(p_user_id integer) RETURNS TABLE(id integer, first_name character varying, last_name character varying, email character varying, type character varying)
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
-- TOC entry 312 (class 1255 OID 37226)
-- Name: fn_get_user_name(character varying, character varying); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_user_name(p_first_name character varying, p_last_name character varying) RETURNS TABLE(id integer, first_name character varying, last_name character varying, email character varying, user_type character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_utilizador.id,
        ipv_bd2_projeto_utilizador.first_name,
        ipv_bd2_projeto_utilizador.last_name,
        ipv_bd2_projeto_utilizador.email,
        type AS user_type
    FROM
        ipv_bd2_projeto_utilizador
    WHERE
        (
            LOWER(ipv_bd2_projeto_utilizador.first_name) ILIKE LOWER('%' || p_first_name || '%')
            AND LOWER(ipv_bd2_projeto_utilizador.last_name) ILIKE LOWER('%' || p_last_name || '%')
        )
        OR
        (
            LOWER(ipv_bd2_projeto_utilizador.first_name) ILIKE LOWER('%' || p_first_name || '%')
            AND p_last_name IS NULL
        )
        OR
        (
            LOWER(ipv_bd2_projeto_utilizador.last_name) ILIKE LOWER('%' || p_last_name || '%')
            AND p_first_name IS NULL
        );
END;
$$;

--
-- TOC entry 266 (class 1255 OID 33652)
-- Name: fn_get_users(); Type: FUNCTION; Schema: public; Owner: aluno5
--

CREATE FUNCTION fn_get_users() RETURNS TABLE(id integer, first_name character varying, last_name character varying, email character varying, type character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT ipv_bd2_projeto_utilizador.id, ipv_bd2_projeto_utilizador.first_name, ipv_bd2_projeto_utilizador.last_name, ipv_bd2_projeto_utilizador.email, ipv_bd2_projeto_utilizador.type FROM ipv_bd2_projeto_utilizador;
END;
$$;

--
-- TOC entry 285 (class 1255 OID 36996)
-- Name: sp_create_armazem(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_armazem(IN p_name character varying, IN p_address character varying, IN p_postal_code character varying, IN p_locality character varying)
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
-- TOC entry 302 (class 1255 OID 37023)
-- Name: sp_create_component(character varying, double precision, integer); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_component(IN p_componentname character varying, IN p_componentcost double precision, IN p_fornecedorid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_componente (name, cost, fornecedor_id_id, created_at)
    VALUES (p_ComponentName, p_ComponentCost, p_FornecedorId, CURRENT_DATE);

    RAISE NOTICE 'Componente criado com sucesso.';
END;
$$;

--
-- TOC entry 298 (class 1255 OID 37012)
-- Name: sp_create_equipment(character varying, integer); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_equipment(IN p_equipmentname character varying, IN p_tipoequipamentoid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_equipamento (name, tipo_equipamento_id_id, created_at)
    VALUES (p_equipmentName, p_tipoEquipamentoId, CURRENT_DATE);

    RAISE NOTICE 'Equipamento criado com sucesso.';
END;
$$;

--
-- TOC entry 293 (class 1255 OID 37007)
-- Name: sp_create_fornecedor(character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_fornecedor(IN p_name character varying, IN p_address character varying, IN p_postal_code character varying, IN p_locality character varying, IN p_email character varying)
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
-- TOC entry 311 (class 1255 OID 37053)
-- Name: sp_create_quantidades_encomenda_componentes(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_quantidades_encomenda_componentes(IN p_encomenda_id integer, IN p_componente_id integer, IN p_amount integer)
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
-- TOC entry 282 (class 1255 OID 33655)
-- Name: sp_create_tipo_equipamento(character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_tipo_equipamento(IN p_name character varying)
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
-- TOC entry 288 (class 1255 OID 37001)
-- Name: sp_create_tipo_mao_obra(character varying, double precision); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_create_tipo_mao_obra(IN p_name character varying, IN p_cost double precision)
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
-- TOC entry 295 (class 1255 OID 37011)
-- Name: sp_delete_fornecedor(integer); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_delete_fornecedor(IN p_fornecedorid integer)
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
-- TOC entry 286 (class 1255 OID 36998)
-- Name: sp_edit_armazem(integer, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_armazem(IN p_armazemid integer, IN p_newarmazemname character varying, IN p_newarmazemaddress character varying, IN p_newarmazempostalcode character varying, IN p_newarmazemlocality character varying)
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
-- TOC entry 303 (class 1255 OID 37027)
-- Name: sp_edit_component(integer, character varying, double precision, integer); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_component(IN p_component_id integer, IN p_new_name character varying, IN p_new_cost double precision, IN p_new_fornecedor_id integer)
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
-- TOC entry 304 (class 1255 OID 37029)
-- Name: sp_edit_encomenda_componentes(date, integer, integer, boolean); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_encomenda_componentes(IN p_encomendacomponenteid integer, IN p_newfornecedorid integer, IN p_newfuncionarioresponsavelid integer)
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
            ipv_bd2_projeto_encomendacomponente.fornecedor_id = p_newfornecedorid,
            ipv_bd2_projeto_encomendacomponente.funcionario_responsavel_id = p_newfuncionarioresponsavelid,
        WHERE
            ipv_bd2_projeto_encomendacomponente.id = p_encomendacomponenteid;
        RAISE NOTICE 'Encomenda de Componentes editada com sucesso.';
    END IF;
END;
$$;


--
-- TOC entry 297 (class 1255 OID 37013)
-- Name: sp_edit_equipamento(integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_equipamento(IN p_equipamentoid integer, IN p_newequipamentoname character varying, IN p_newtipoequipamentoid integer)
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
-- TOC entry 292 (class 1255 OID 37009)
-- Name: sp_edit_fornecedor(integer, character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_fornecedor(IN p_fornecedorid integer, IN p_newfornecedorname character varying, IN p_newfornecedoraddress character varying, IN p_newfornecedorpostalcode character varying, IN p_newfornecedorlocality character varying, IN p_newfornecedoremail character varying)
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
-- TOC entry 273 (class 1255 OID 36994)
-- Name: sp_edit_tipo_equipamento(integer, character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_tipo_equipamento(IN p_tipoequipamentoid integer, IN p_newtipoequipamentoname character varying)
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
-- TOC entry 289 (class 1255 OID 37006)
-- Name: sp_edit_tipo_mao_de_obra(integer, character varying, double precision); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_tipo_mao_de_obra(IN p_tipomaodeobraid integer, IN p_newtipomaodeobraname character varying, IN p_newtipomaodeobracost double precision)
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
-- TOC entry 272 (class 1255 OID 33654)
-- Name: sp_edit_user(integer, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: aluno5
--

CREATE PROCEDURE sp_edit_user(IN p_id integer, IN p_first_name character varying, IN p_last_name character varying, IN p_user_type character varying)
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

-- fuction delete encomenda de componentes
CREATE FUNCTION fn_delete_encomenda_componente(p_id integer) RETURNS boolean
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
        DELETE FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.id = p_id;
        RAISE NOTICE 'Encomenda apagada com sucesso.';
        RETURN TRUE;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_get_equipamentos(
    IN p_filtered character varying DEFAULT NULL,
    IN p_order character varying DEFAULT NULL
)
RETURNS TABLE(id integer, name character varying, created_at date, tipo_equipamento_name character varying)
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT e.id, e.name, e.created_at, t.name AS tipo_equipamento_name
    FROM ipv_bd2_projeto_equipamento e
    JOIN ipv_bd2_projeto_tipodeequipamento t ON e.tipo_equipamento_id_id = t.id
    WHERE
        (p_filtered IS NULL OR p_filtered = '' OR e.name ILIKE p_filtered)
    ORDER BY
        CASE WHEN p_order = 'id-asc' OR p_order IS NULL THEN e.id END ASC,
        CASE WHEN p_order = 'id-desc' THEN e.id END DESC,
        CASE WHEN p_order = 'name-asc' THEN LOWER(e.name) END ASC,
        CASE WHEN p_order = 'name-desc' THEN LOWER(e.name) END DESC,
        CASE WHEN p_order = 'created_at-asc' THEN e.created_at END ASC,
        CASE WHEN p_order = 'created_at-desc' THEN e.created_at END DESC;
END;
$BODY$;



CREATE OR REPLACE FUNCTION public.fn_get_unassigned_production_registries()
RETURNS TABLE(
    production_id integer,
    equipamento_name character varying,
    started_at date,
    ended_at date,
	componentes integer,
	quantidade_componentes integer
)
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT
        rp.id,
        e.name AS equipamento_name,
        rp.started_at,
        rp.ended_at,
		COUNT(qc.*) AS quantidade_componentes
    FROM
        ipv_bd2_projeto_registoproducao rp
    JOIN
        ipv_bd2_projeto_equipamento e ON rp.equipamento_id_id = e.id
	LEFT JOIN
        ipv_bd2_projeto_quantidadecomponenteregistoproducao qc ON rp.id = qc.registo_producao_id
    WHERE
        ipv_bd2_projeto_expedicao.registo_producao_id_id IS NULL;
END;
$BODY$;

-- FUNCTION: public.fn_get_expedicao_by_id(integer)

-- DROP FUNCTION IF EXISTS public.fn_get_expedicao_by_id(integer);

CREATE OR REPLACE FUNCTION public.fn_get_expedicao_by_id(
	p_encomenda_id integer)
    RETURNS TABLE(id integer, sent_at date, truck_license character varying, delivery_date_expected date)
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT e.encomenda_id_id, e.sent_at, e.truck_license, e.delivery_date_expected,
    FROM ipv_bd2_projeto_expedicao e
    LEFT JOIN ipv_bd2_projeto_registoproducao t ON e.encomenda_id_id = t.expedicao_id_id
    WHERE e.encomenda_id_id = p_encomenda_id;
END;
$BODY$;

ALTER FUNCTION public.fn_get_expedicao_by_id(integer)
    OWNER TO aluno5;



---
SELECT
    json_build_object(
        'encomenda_id', e.encomenda_id_id,
        'sent_at', e.sent_at,
        'truck_license', e.truck_license,
        'delivery_date_expected', e.delivery_date_expected,
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
                                        'component_cost', comp.cost
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
            WHERE expedicao_id_id = 1
        )
    ) AS result
FROM
    ipv_bd2_projeto_expedicao e
WHERE
    e.encomenda_id_id = 1;
