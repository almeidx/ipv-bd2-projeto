-- ✅ sp_edit_user
CREATE PROCEDURE sp_edit_user(
    IN p_id INT,
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_user_type VARCHAR(50)
)
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


-- ✅ fn_get_users
CREATE FUNCTION fn_get_users()
RETURNS TABLE (
    id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(256),
    type VARCHAR(2)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT ipv_bd2_projeto_utilizador.id, ipv_bd2_projeto_utilizador.first_name, ipv_bd2_projeto_utilizador.last_name, ipv_bd2_projeto_utilizador.email, ipv_bd2_projeto_utilizador.type FROM ipv_bd2_projeto_utilizador;
END;
$$ LANGUAGE plpgsql;


-- ✅ Function to get user
CREATE FUNCTION fn_get_user(
    p_user_id INT
)
RETURNS TABLE (
    id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(255),
    user_type VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_utilizador.id,
        ipv_bd2_projeto_utilizador.first_name,
        ipv_bd2_projeto_utilizador.last_name,
        ipv_bd2_projeto_utilizador.email,
        type AS ipv_bd2_projeto_utilizador.type
    FROM
        ipv_bd2_projeto_utilizador
    WHERE
        ipv_bd2_projeto_utilizador.id = p_user_id;
END;
$$;


-- Procedure to delete user
CREATE PROCEDURE sp_delete_user(
    IN p_user_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_utilizador WHERE ipv_bd2_projeto_utilizador.id = p_user_id) THEN
        DELETE FROM ipv_bd2_projeto_utilizador WHERE ipv_bd2_projeto_utilizador.id = p_user_id;
        RAISE NOTICE 'User eliminado com sucesso.';
    ELSE
        RAISE NOTICE 'Utilizador.';
    END IF;
END;
$$;


-- ✅ Procedure to create tipo de equipamento
CREATE PROCEDURE sp_create_tipo_equipamento(
    p_name VARCHAR(50)
)
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


-- ✅ Function to get tipo de equipamento
CREATE  FUNCTION fn_get_tipo_equipamentos()
RETURNS TABLE (
    id INT,
    tipo VARCHAR(50)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT ipv_bd2_projeto_tipodeequipamento.id, ipv_bd2_projeto_tipodeequipamento.name FROM ipv_bd2_projeto_tipodeequipamento;
END;
$$ LANGUAGE plpgsql;

-- ✅ edit tipo de equipamento
CREATE  PROCEDURE sp_edit_tipo_equipamento(
    p_TipoEquipamentoId INT,
    p_NewTipoEquipamentoName VARCHAR(50)
)
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


-- Coisas novas
-- Procedure to create component
CREATE PROCEDURE sp_create_component(
    p_ComponentName VARCHAR(50),
    p_ComponentCost FLOAT,
    p_FornecedorId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_componente (ipv_bd2_projeto_componente.name, ipv_bd2_projeto_componente.cost, ipv_bd2_projeto_componente.fornecedor_id)
    VALUES (p_ComponentName, p_ComponentCost, p_FornecedorId);

    RAISE NOTICE 'Componente criado com sucesso.';
END;
$$;

-- sp_edit_component
CREATE PROCEDURE sp_edit_component(
    p_component_id INT,
    p_new_name VARCHAR(50),
    p_new_cost FLOAT,
    p_new_fornecedor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_componente WHERE ipv_bd2_projeto_componente.id = p_component_id) THEN
        RAISE NOTICE 'Componente não encontrado. Falha na edição do componente.';
        RETURN;
    END IF;

    UPDATE ipv_bd2_projeto_componente
    SET
        ipv_bd2_projeto_componente.name = p_new_name,
        ipv_bd2_projeto_componente.cost = p_new_cost,
        ipv_bd2_projeto_componente.fornecedor_id = p_new_fornecedor_id
    WHERE
        ipv_bd2_projeto_componente.id = p_component_id;

    RAISE NOTICE 'Componente editado com sucesso.';
END;
$$;


-- Function to get component
CREATE FUNCTION fn_get_component
(
    ComponentId INT
)
RETURNS TABLE (
    id INT,
    name VARCHAR(50),
    created_at DATE,
    cost FLOAT,
    fornecedor_id INt
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_componente.id,
        ipv_bd2_projeto_componente.name,
        ipv_bd2_projeto_componente.create_at,
        ipv_bd2_projeto_componente.cost,
        ipv_bd2_projeto_componente.fornecedor_id
    FROM
        ipv_bd2_projeto_componente
    WHERE
        ipv_bd2_projeto_componente.id = ComponentId
END; $$;

-- Function to get components
CREATE FUNCTION fn_get_components
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    created_at DATE,
    cost FLOAT,
    fornecedor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_componente
END; $$;


-- Procedure to delete component
CREATE PROCEDURE sp_delete_component
    component_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_componente WHERE ipv_bd2_projeto_componente.id = component_id)
    BEGIN

        DELETE FROM ipv_bd2_projeto_componente WHERE ipv_bd2_projeto_componente.id = component_id;

        PRINT 'Componente eliminado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Componente não encontrado.';
    END;
$$;


--procedure to sp_create_equipment
CREATE PROCEDURE sp_create_equipment
    equipmentName VARCHAR(50),
    tipoEquipamentoId INT
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO ipv_bd2_projeto_equipamento (name, tipo_equipamento_id)
    VALUES (equipmentName, tipoEquipamentoId);

    PRINT 'Equipamento criado com sucesso.';
END;
$$;


-- sp_edit_equipamento
CREATE PROCEDURE sp_edit_equipamento
    EquipamentoId INT,
    NewEquipamentoName VARCHAR(50),
    NewTipoEquipamentoId INT
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_equipamento WHERE ipv_bd2_projeto_equipamento.id = EquipamentoId)
    BEGIN
        PRINT 'Equipamento não encontrado. Falha na edição do equipamento.';
        RETURN;
    END


    UPDATE ipv_bd2_projeto_equipamento
    SET
        name = NewEquipamentoName,
        ipv_bd2_projeto_equipamento.tipo_equipamento_id = NewTipoEquipamentoId
    WHERE
        ipv_bd2_projeto_equipamento.id = EquipamentoId;

    PRINT 'Equipamento editado com sucesso.';
END;
$$;


-- Function to get equipments
CREATE FUNCTION fn_get_equipamentos()
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    created_at DATE,
    tipo_equipamento_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_equipamento
END; $$;


✅ -- procedure to create fornecedor
CREATE PROCEDURE sp_create_fornecedor
    name VARCHAR(50),
    address VARCHAR(50),
    postal_code VARCHAR(50),
    locality VARCHAR(50),
    email VARCHAR(256)
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.name = name)
    BEGIN

        INSERT INTO ipv_bd2_projeto_fornecedor (name, address, postal_code, locality, email)
        VALUES (name, address, postal_code, locality, email);

        PRINT 'Fornecedor criado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Fornecedor já existe.';
    END
END;
$$;


-- sp_delete_fornecedor
CREATE OR REPLACE PROCEDURE sp_delete_fornecedor(
    p_FornecedorId INT
)
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



-- sp_edit_fornecedor
CREATE PROCEDURE sp_edit_fornecedor
    FornecedorId INT,
    NewFornecedorName VARCHAR(50),
    NewFornecedorAddress VARCHAR(50),
    NewFornecedorPostalCode VARCHAR(50),
    NewFornecedorLocality VARCHAR(50),
    NewFornecedorEmail VARCHAR(256)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.id = FornecedorId)
    BEGIN
        PRINT 'Fornecedor não encontrado. Falha na edição do fornecedor.';
        RETURN;
    END

    UPDATE ipv_bd2_projeto_fornecedor
    SET
        ipv_bd2_projeto_fornecedor.name = NewFornecedorName,
        ipv_bd2_projeto_fornecedor.address = NewFornecedorAddress,
        ipv_bd2_projeto_fornecedor.postal_code = NewFornecedorPostalCode,
        ipv_bd2_projeto_fornecedor.locality = NewFornecedorLocality,
        ipv_bd2_projeto_fornecedor.email = NewFornecedorEmail
    WHERE
        ipv_bd2_projeto_fornecedor.id = FornecedorId;

    PRINT 'Fornecedor editado com sucesso.';
END;
$$;


-- Function to get fornecedore by id
CREATE FUNCTION fn_get_fornecedor_by_id
(
    fornecedor_id INT
)
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    address VARCHAR(50),
    postal_code VARCHAR(50),
    locality VARCHAR(50),
    email VARCHAR(256)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_fornecedor WHERE ipv_bd2_projeto_fornecedor.id = fornecedor_id
END; $$;


-- Function to get fornecedores
CREATE FUNCTION fn_get_fornecedores()
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    address VARCHAR(50),
    postal_code VARCHAR(50),
    locality VARCHAR(50),
    email VARCHAR(256)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_fornecedor
END; $$;


--  ✅ procedure to create armazem
CREATE OR REPLACE PROCEDURE sp_create_armazem(
    p_name VARCHAR(50),
    p_address VARCHAR(100),
    p_postal_code VARCHAR(10),
    p_locality VARCHAR(50)
)
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



--sp_edit_armazem
CREATE OR REPLACE PROCEDURE sp_edit_armazem(
    p_ArmazemId INT,
    p_NewArmazemName VARCHAR(50),
    p_NewArmazemAddress VARCHAR(100),
    p_NewArmazemPostalCode VARCHAR(10),
    p_NewArmazemLocality VARCHAR(50)
)
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


-- sp_get_armazem_by_id
CREATE FUNCTION fn_get_armazem_by_id
(
    armazem_id INT
)
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    address VARCHAR(100),
    postal_code VARCHAR(10),
    locality VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = armazem_id
END; $$;


--  ✅ fn_get_armazens
CREATE FUNCTION fn_get_armazens()
RETURNS TABLE (
    id INT,
    name VARCHAR(50),
    address VARCHAR(100),
    postal_code VARCHAR(10),
    locality VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_armazem
END; $$;


-- sp_delete_armazem
CREATE PROCEDURE sp_delete_armazem
    armazem_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = armazem_id)
    BEGIN

        DELETE FROM ipv_bd2_projeto_armazem WHERE ipv_bd2_projeto_armazem.id = armazem_id;

        PRINT 'Armazem eliminado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Armazem não encontrado.';
    END
END;
$$;


-- ✅  Procedure sp_create_tipo_mao_obra
CREATE PROCEDURE sp_create_tipo_mao_obra
    name VARCHAR(50)
    cost FLOAT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.name = name)
    BEGIN

        INSERT INTO ipv_bd2_projeto_tipomaodeobra (name, cost)
        VALUES (name, cost);

        PRINT 'Tipo de mão de obra criado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de mão de obra já existe.';
    END
END;
$$;


-- ✅  sp_edit_tipo_mao_de_obra
CREATE PROCEDURE sp_edit_tipo_mao_de_obra
    TipoMaoDeObraId INT,
    NewTipoMaoDeObraName VARCHAR(50),
    NewTipoMaoDeObraCost FLOAT
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = TipoMaoDeObraId)
    BEGIN
        PRINT 'Tipo de Mão de Obra não encontrado. Falha na edição do tipo de mão de obra.';
        RETURN;
    END


    UPDATE ipv_bd2_projeto_tipomaodeobra
    SET
        ipv_bd2_projeto_tipomaodeobra.name = NewTipoMaoDeObraName,
        ipv_bd2_projeto_tipomaodeobra.cost = NewTipoMaoDeObraCost
    WHERE
        ipv_bd2_projeto_tipomaodeobra.id = TipoMaoDeObraId;

    PRINT 'Tipo de Mão de Obra editado com sucesso.';
END;
$$;


-- ✅   Function to get tipo de mao de obra
CREATE FUNCTION fn_get_tipo_mao_obra_by_id
(
    tipo_mao_obra_id INT
)
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    cost FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = tipo_mao_obra_id
END; $$;


-- ✅  Function to get tipo de mao de obra
CREATE FUNCTION fn_get_tipo_mao_obra()
RETURNS TABLE(
    id INT,
    name VARCHAR(50),
    cost FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_tipomaodeobra
END; $$;

-- Procedure to delete tipo de mao de obra
CREATE PROCEDURE sp_delete_tipo_mao_obra
    tipo_mao_obra_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = tipo_mao_obra_id)
    BEGIN

        DELETE FROM ipv_bd2_projeto_tipomaodeobra WHERE ipv_bd2_projeto_tipomaodeobra.id = tipo_mao_obra_id;

        PRINT 'Tipo de Mão de Obra eliminado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de Mão de Obra não encontrado.';
    END
END;
$$;


-- procedure to create registo de producao
CREATE PROCEDURE sp_create_registo_producao
    DeliveryId INT,
    TipoMaoDeObraId INT,
    ArmazemId INT,
    FuncionarioId INT,
    EquipamentoId INT
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ipv_bd2_projeto_registoproducao (started_at, ended_at, delivery_id, tipo_mao_de_obra_id, armazem_id, funcionario_id, equipamento_id)
    VALUES (GETDATE(), GETDATE(), DeliveryId, TipoMaoDeObraId, ArmazemId, FuncionarioId, EquipamentoId);

    PRINT 'Registro de Produção criado com sucesso.';
END$$
$$;


-- function to get registo de producao by id
CREATE FUNCTION fn_get_registro_producao_by_id
(
    registro_producao_id INT
)
RETURNS TABLE(
    id INT,
    started_at DATE,
    ended_at DATE,
    delivery_id INT,
    tipo_mao_de_obra_id INT,
    armazem_id INT,
    funcionario_id INT,
    equipamento_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_registoproducao WHERE ipv_bd2_projeto_registoproducao.id = registro_producao_id
END; $$;



-- sp_create_encomenda_componentes
CREATE PROCEDURE sp_create_encomenda_componentes
    fornecedor_id INT,
    funcionario_responsavel_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ipv_bd2_projeto_encomendacomponente (created_at, fornecedor_id, funcionario_responsavel_id, exported)
    VALUES (GETDATE(), fornecedor_id, funcionario_responsavel_id, 0);

    PRINT 'Encomenda de Componentes criada com sucesso.';
END;
$$;


--Procedure sp_edit_encomenda_componente
CREATE PROCEDURE sp_edit_encomenda_componentes
    EncomendaComponenteCreatedAt DATE,
    NewFornecedorId INT,
    NewFuncionarioResponsavelId INT,
    NewExportedStatus BIT
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE ipv_bd2_projeto_encomendacomponente
    SET
        ipv_bd2_projeto_encomendacomponente.fornecedor_id = NewFornecedorId,
        ipv_bd2_projeto_encomendacomponente.funcionario_responsavel_id = NewFuncionarioResponsavelId,
        ipv_bd2_projeto_encomendacomponente.exported = NewExportedStatus
    WHERE
        ipv_bd2_projeto_encomendacomponente.created_at = EncomendaComponenteCreatedAt;

    PRINT 'Encomenda de Componentes editada com sucesso.';
END;
$$;


-- fn_get_encomenda_componentes
CREATE FUNCTION fn_get_encomenda_componentes_by_id
(
    encomenda_id INT
)
RETURNS TABLE(
    id INT,
    created_at DATE,
    fornecedor_id INT,
    funcionario_responsavel_id INT,
    exported BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.id = encomenda_id
END; $$;


-- procedure to delete encomenda de componentes
CREATE PROCEDURE sp_delete_encomenda_componentes
    encomenda_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.id = encomenda_id)
    BEGIN

        DELETE FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.id = encomenda_id;

        PRINT 'Encomenda de Componentes excluída com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Encomenda de Componentes não encontrada.';
    END
END;
$$;


-- procedure to create encomenda de equipamentos
CREATE PROCEDURE sp_create_encomenda_equipamentos
    address VARCHAR(100),
    postal_code VARCHAR(10),
    locality VARCHAR(50),
    client_id INT,
    funcionario_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ipv_bd2_projeto_encomendaequipamento (address, postal_code, locality, client_id, funcionario_id)
    VALUES (address, postal_code, locality, client_id, funcionario_id);

    PRINT 'Encomenda de Equipamentos criada com sucesso.';
END;
$$;


--sp_get_encomenda_equipamentos
CREATE FUNCTION fn_get_encomenda_equipamentos()
RETURNS TABLE(
    id INT,
    created_at DATE,
    address VARCHAR(100),
    postal_code VARCHAR(10),
    locality VARCHAR(50),
    client_id INT,
    funcionario_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_encomendaequipamento
END; $$;


-- function to get encomenda de equipamentos by id
CREATE FUNCTION fn_get_encomenda_equipamentos_by_id
(
    encomenda_id INT
)
RETURNS TABLE(
    id INT,
    created_at DATE,
    address VARCHAR(100),
    postal_code VARCHAR(10),
    locality VARCHAR(50),
    client_id INT,
    funcionario_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_encomendaequipamento WHERE ipv_bd2_projeto_encomendaequipamento.id = encomenda_id
END; $$;


-- sp_delete_encomenda_equipamentos
CREATE PROCEDURE sp_delete_encomenda_equipamentos
    encomenda_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ipv_bd2_projeto_encomendaequipamento WHERE id = encomenda_id)
    BEGIN

        DELETE FROM ipv_bd2_projeto_encomendaequipamento WHERE ipv_bd2_projeto_encomendaequipamento.id = encomenda_id;

        PRINT 'Encomenda de Equipamentos excluída com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Encomenda de Equipamentos não encontrada.';
    END
END;
$$;

-- sp_edit_encomenda_equipamentos
CREATE PROCEDURE sp_edit_encomenda_equipamentos
    EncomendaEquipamentoId INT,
    NewAddress VARCHAR(50),
    NewPostalCode VARCHAR(50),
    NewLocality VARCHAR(50),
    NewClientId INT,
    NewFuncionarioId INT
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ipv_bd2_projeto_encomendaequipamento WHERE ipv_bd2_projeto_encomendaequipamento.id = EncomendaEquipamentoId)
    BEGIN
        PRINT 'Encomenda de Equipamentos não encontrada. Falha na edição da encomenda.';
        RETURN;
    END

    UPDATE ipv_bd2_projeto_encomendaequipamento
    SET
        ipv_bd2_projeto_encomendaequipamento.address = NewAddress,
        ipv_bd2_projeto_encomendaequipamento.postal_code = NewPostalCode,
        ipv_bd2_projeto_encomendaequipamento.locality = NewLocality,
        ipv_bd2_projeto_encomendaequipamento.client_id = NewClientId,
        ipv_bd2_projeto_encomendaequipamento.funcionario_id = NewFuncionarioId
    WHERE
        ipv_bd2_projeto_encomendaequipamento.id = EncomendaEquipamentoId;

    PRINT 'Encomenda de Equipamentos editada com sucesso.';
END;
$$;


-- procedure create expedicao
CREATE PROCEDURE sp_create_expedicao
    send_at DATE,
    truck_license_plate VARCHAR(10),
    delivery_at DATE,
    encomenda_id INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ipv_bd2_projeto_expedicao (send_at, truck_license_plate, delivery_at, encomenda_id)
    VALUES (send_at, truck_license_plate, delivery_at, encomenda_id);

    PRINT 'Expedição criada com sucesso.';
END;
$$;


-- fn_get_expedicao
CREATE FUNCTION fn_get_expedicao()
RETURNS TABLE(
    send_at DATE,
    truck_license_plate VARCHAR(10),
    delivery_date_expected DATE,
    encomenda_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_expedicao;
END; $$;


-- Procedure sp_create_fatura
CREATE PROCEDURE sp_create_fatura
   encomenda_id INT,
   contribuinte INT
LANGUAGE plpgsql
AS $$
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ipv_bd2_projeto_fatura (encomenda_id, contribuinte)
    VALUES (encomenda_id,contribuinte);

    PRINT 'Fatura criada com sucesso.';
END;
$$;


-- Function sp_get_fatura
CREATE FUNCTION fn_get_fatura()
RETURNS TABLE(
    created_at DATE,
    contribuinte INT,
    encomenda_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_fatura;
END;
$$;




----------------------------------------------------------------------------------------------------------------------------------------
-- Procedure to get stock of all equipment
CREATE OR REPLACE PROCEDURE sp_get_stock_equipments(
    armazem_id INT,
    equipment_id INT,
    equipment_name VARCHAR(50),
    tipo_equipamento_id INT,
    equipment_number INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_armazem.id,
        ipv_bd2_projeto_equipamento.id,
        ipv_bd2_projeto_equipamento.name,
        ipv_bd2_projeto_equipamento.tipo_equipamento_id,
        COUNT(ipv_bd2_projeto_equipamento.id) AS Quantity
    FROM
        ipv_bd2_projeto_armazem
    INNER JOIN
        ipv_bd2_projeto_equipamento  ON ipv_bd2_projeto_armazem.id = e.armazem_id
    INNER JOIN
        ipv_bd2_projeto_equipamento_componente ec ON e.id = ec.equipamento_id
    WHERE
        ipv_bd2_projeto_equipamento.armazem_id = armazem_id
        AND (equipment_id IS NULL OR ipv_bd2_projeto_equipamento.id = equipment_id)
        AND (equipment_name IS NULL OR ipv_bd2_projeto_equipamento.name = equipment_name)
        AND (tipo_equipamento_id IS NULL OR ipv_bd2_projeto_equipamento.tipo_equipamento_id = tipo_equipamento_id)
        AND (equipment_number IS NULL OR ipv_bd2_projeto_equipamento.quantity = equipment_number)
    GROUP BY
        ipv_bd2_projeto_armazem.id, e.id, e.name, e.tipo_equipamento_id
    ORDER BY
        ipv_bd2_projeto_armazem.id;
END;
$$;


-- Create procedure to get component orders
Create function fn_get_component_orders(
)
RETURNS TABLE(
    id INT,
    created_at DATE,
    fornecedor_id INT,
    funcionario_responsavel_id INT,
    exported BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ipv_bd2_projeto_encomendacomponente WHERE ipv_bd2_projeto_encomendacomponente.id = id
END; $$;

-- Create function to get user by name
-- CREATE FUNCTION fn_get_user_name(
--     a_first_name VARCHAR(50),
--     a_last_name VARCHAR(50)
-- )
-- RETURNS TABLE (
--     id INT,
--     first_name VARCHAR(50),
--     last_name VARCHAR(50),
--     email VARCHAR(255),
--     user_type VARCHAR(50)
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT
--         ipv_bd2_projeto_utilizador.id,
--         ipv_bd2_projeto_utilizador.first_name,
--     ipv_bd2_projeto_utilizador.last_name,
--         ipv_bd2_projeto_utilizador.email,
--         ipv_bd2_projeto_utilizador.type
--     FROM
--         ipv_bd2_projeto_utilizador
--     WHERE
--         LOWER(ipv_bd2_projeto_utilizador.first_name) = LOWER(a_first_name)
--         OR LOWER(ipv_bd2_projeto_utilizador.last_name) = LOWER(a_last_name);
-- END;
-- $$;

DROP FUNCTION fn_get_user_name;
-- Create function to get user by name
CREATE FUNCTION fn_get_user_name(
    p_first_name VARCHAR(50),
    p_last_name VARCHAR(50)
)
RETURNS TABLE (
    id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(255),
    user_type VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ipv_bd2_projeto_utilizador.\id,
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



