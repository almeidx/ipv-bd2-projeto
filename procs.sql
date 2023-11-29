
--procedure to sp_create_component
CREATE PROCEDURE sp_create_component
    @ComponentName NVARCHAR(50),
    @ComponentCost FLOAT,
    @FornecedorId INT,
AS
BEGIN

    INSERT INTO Componente (name, cost, fornecedor_id)
    VALUES (@ComponentName, @ComponentCost, @FornecedorId);

    PRINT 'Componente criado com sucesso.';
END

--procedure to sp_edit_component
CREATE PROCEDURE sp_edit_component
    @component_id INT,
    @new_name NVARCHAR(50),
    @new_cost FLOAT,
    @new_fornecedor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Componente WHERE id = @component_id)
    BEGIN

        UPDATE Componente
        SET
            name = @new_name,
            cost = @new_cost,
            fornecedor_id = @new_fornecedor_id
        WHERE
            id = @component_id;

        PRINT 'Component edited successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Component not found.';
    END
END;


-- Function to sp_get_component
CREATE FUNCTION dbo.fn_get_component
(
    @ComponentId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        id,
        name,
        create_at,
        cost,
        fornecedor_id
    FROM
        Componente
    WHERE
        id = @ComponentId
);


--Function sp_get_components
CREATE FUNCTION sp_get_components
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Componente
);


-- sp_delete_component
CREATE PROCEDURE sp_delete_component
    @component_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Componente WHERE id = @component_id)
    BEGIN

        DELETE FROM Componente WHERE id = @component_id;

        PRINT 'Component deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Component not found.';
    END
END;


--procedure to sp_create_equipment
CREATE PROCEDURE sp_create_equipment
    @equipmentName NVARCHAR(50),
    @tipoEquipamentoId INT
AS
BEGIN

    INSERT INTO Equipamento (name, tipo_equipamento_id)
    VALUES (@equipmentName, @tipoEquipamentoId);

    PRINT 'Equipamento criado com sucesso.';
END

-- sp_edit_equipamento
CREATE PROCEDURE sp_edit_equipamento
    @EquipamentoId INT,
    @NewEquipamentoName NVARCHAR(50),
    @NewTipoEquipamentoId INT
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Equipamento WHERE id = @EquipamentoId)
    BEGIN
        PRINT 'Equipamento não encontrado. Falha na edição do equipamento.';
        RETURN;
    END


    UPDATE Equipamento
    SET
        name = @NewEquipamentoName,
        tipo_equipamento_id = @NewTipoEquipamentoId
    WHERE
        id = @EquipamentoId;

    PRINT 'Equipamento editado com sucesso.';
END


-- sp_get_equipamentos
CREATE FUNCTION sp_get_equipamentos()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Equipamento
);

-- sp_create_fornecedor
CREATE PROCEDURE sp_create_fornecedor
    @name NVARCHAR(50),
    @address NVARCHAR(50),
    @postal_code NVARCHAR(50),
    @locality NVARCHAR(50),
    @email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Fornecedor WHERE name = @name)
    BEGIN

        INSERT INTO Fornecedor (name, address, postal_code, locality, email)
        VALUES (@name, @address, @postal_code, @locality, @email);

        PRINT 'Fornecedor created successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Fornecedor already exists.';
    END
END;


-- sp_edit_fornecedor

CREATE PROCEDURE sp_edit_fornecedor
    @FornecedorId INT,
    @NewFornecedorName NVARCHAR(50),
    @NewFornecedorAddress NVARCHAR(50),
    @NewFornecedorPostalCode NVARCHAR(50),
    @NewFornecedorLocality NVARCHAR(50),
    @NewFornecedorEmail NVARCHAR(256)
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Fornecedor WHERE id = @FornecedorId)
    BEGIN
        PRINT 'Fornecedor não encontrado. Falha na edição do fornecedor.';
        RETURN;
    END

    UPDATE Fornecedor
    SET
        name = @NewFornecedorName,
        address = @NewFornecedorAddress,
        postal_code = @NewFornecedorPostalCode,
        locality = @NewFornecedorLocality,
        email = @NewFornecedorEmail
    WHERE
        id = @FornecedorId;

    PRINT 'Fornecedor editado com sucesso.';
END


-- sp_get_fornecedor_by_id
CREATE FUNCTION sp_get_fornecedor_by_id
(
    @fornecedor_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Fornecedor WHERE id = @fornecedor_id
);


-- get_fornecedores
CREATE FUNCTION get_fornecedores()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Fornecedor
);


-- sp_create_armazem
CREATE PROCEDURE sp_create_armazem
    @name NVARCHAR(50),
    @address NVARCHAR(100),
    @postal_code NVARCHAR(10),
    @locality NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Armazem WHERE name = @name)
    BEGIN

        INSERT INTO Armazem (name, address, postal_code, locality)
        VALUES (@name, @address, @postal_code, @locality);

        PRINT 'Armazem created successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Armazem already exists.';
    END
END;

--sp_edit_armazem

CREATE PROCEDURE sp_edit_armazem
    @ArmazemId INT,
    @NewArmazemName NVARCHAR(50),
    @NewArmazemAddress NVARCHAR(100),
    @NewArmazemPostalCode NVARCHAR(10),
    @NewArmazemLocality NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Armazem WHERE id = @ArmazemId)
    BEGIN
        PRINT 'Armazém não encontrado. Falha na edição do armazém.';
        RETURN;
    END



    UPDATE Armazem
    SET
        name = @NewArmazemName,
        address = @NewArmazemAddress,
        postal_code = @NewArmazemPostalCode,
        locality = @NewArmazemLocality
    WHERE
        id = @ArmazemId;

    PRINT 'Armazém editado com sucesso.';
END




-- sp_get_armazem_by_id
CREATE FUNCTION sp_get_armazem_by_id
(
    @armazem_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Armazem WHERE id = @armazem_id
);


-- sp_get_armazens
CREATE FUNCTION sp_get_armazens()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Armazem
);


-- sp_delete_armazem
CREATE PROCEDURE sp_delete_armazem
    @armazem_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Armazem WHERE id = @armazem_id)
    BEGIN

        DELETE FROM Armazem WHERE id = @armazem_id;

        PRINT 'Armazem deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Armazem not found.';
    END
END;



--Procedure to sp_create_tipo_equipamento
CREATE PROCEDURE sp_create_tipo_equipamento
    @name NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TipoDeEquipamento WHERE name = @name)
    BEGIN

        INSERT INTO TipoDeEquipamento (name)
        VALUES (@name);

        PRINT 'Tipo de equipamento criado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de equipamento já existe.';
    END
END;

-- sp_edit_tipo_equipamento
    CREATE PROCEDURE sp_edit_tipo_equipamento
    @TipoEquipamentoId INT,
    @NewTipoEquipamentoName NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM TipoDeEquipamento WHERE id = @TipoEquipamentoId)
    BEGIN
        PRINT 'Tipo de Equipamento não encontrado. Falha na edição do tipo de equipamento.';
        RETURN;
    END
    UPDATE TipoDeEquipamento
    SET
        name = @NewTipoEquipamentoName
    WHERE
        id = @TipoEquipamentoId;

    PRINT 'Tipo de Equipamento editado com sucesso.';
END






-- Function sp_get_tipo_equipamento
CREATE FUNCTION sp_get_tipo_equipamento()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM TipoDeEquipamento
);

-- sp_get_tipo_equipamento_by_id
CREATE FUNCTION sp_get_tipo_equipamento_by_id
(
    @tipo_equipamento_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM TipoDeEquipamento WHERE id = @tipo_equipamento_id
);

-- sp_delete_tipo_equipamento
CREATE PROCEDURE sp_delete_tipo_equipamento
    @tipo_equipamento_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM TipoDeEquipamento WHERE id = @tipo_equipamento_id)
    BEGIN

        DELETE FROM TipoDeEquipamento WHERE id = @tipo_equipamento_id;

        PRINT 'Tipo de Equipamento deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de Equipamento not found.';
    END
END;


-- Procedure sp_create_tipo_mao_obra
CREATE PROCEDURE sp_create_tipo_mao_obra
    @name NVARCHAR(50)
    @cost FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TipoDeMaoDeObra WHERE name = @name)
    BEGIN

        INSERT INTO TipoDeMaoDeObra (name, cost)
        VALUES (@name, @cost);

        PRINT 'Tipo de mão de obra criado com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de mão de obra já existe.';
    END
END;

--sp_edit_tipo_mao_obra
CREATE PROCEDURE sp_edit_tipo_mao_de_obra
    @TipoMaoDeObraId INT,
    @NewTipoMaoDeObraName NVARCHAR(50),
    @NewTipoMaoDeObraCost FLOAT
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM TipoMaoDeObra WHERE id = @TipoMaoDeObraId)
    BEGIN
        PRINT 'Tipo de Mão de Obra não encontrado. Falha na edição do tipo de mão de obra.';
        RETURN;
    END


    UPDATE TipoMaoDeObra
    SET
        name = @NewTipoMaoDeObraName,
        cost = @NewTipoMaoDeObraCost
    WHERE
        id = @TipoMaoDeObraId;

    PRINT 'Tipo de Mão de Obra editado com sucesso.';
END

-- sp_get_tipo_mao_obra_by_id
CREATE FUNCTION sp_get_tipo_mao_obra_by_id
(
    @tipo_mao_obra_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM TipoDeMaoObra WHERE id = @tipo_mao_obra_id
);

-- sp_delete_tipo_mao_obra
CREATE PROCEDURE sp_delete_tipo_mao_obra
    @tipo_mao_obra_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM TipoDeMaoObra WHERE id = @tipo_mao_obra_id)
    BEGIN

        DELETE FROM TipoDeMaoObra WHERE id = @tipo_mao_obra_id;

        PRINT 'Tipo de Mão de Obra deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de Mão de Obra not found.';
    END
END;


--sp_create_registo_producao
CREATE PROCEDURE sp_create_registo_producao
    @DeliveryId INT,
    @TipoMaoDeObraId INT,
    @ArmazemId INT,
    @FuncionarioId INT,
    @EquipamentoId INT
AS
BEGIN
    -- Insere um novo registro de produção na tabela RegistoProducao
    INSERT INTO RegistoProducao (started_at, ended_at, delivery_id, tipo_mao_de_obra_id, armazem_id, funcionario_id, equipamento_id)
    VALUES (GETDATE(), GETDATE(), @DeliveryId, @TipoMaoDeObraId, @ArmazemId, @FuncionarioId, @EquipamentoId);

    PRINT 'Registro de Produção criado com sucesso.';
END

-- sp_get_registro_producao_by_id
CREATE FUNCTION sp_get_registro_producao_by_id
(
    @registro_producao_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM RegistroProducao WHERE id = @registro_producao_id
);

-- sp_create_encomenda_componentes
CREATE PROCEDURE sp_create_encomenda_componentes
    @fornecedor_id INT,
    @funcionario_responsavel_id INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EncomendaComponente (created_at, fornecedor_id, funcionario_responsavel_id, exported)
    VALUES (GETDATE(), @fornecedor_id, @funcionario_responsavel_id, 0);

    PRINT 'Encomenda de Componentes criada com sucesso.';
END;


--Procedure sp_edit_encomenda_componente

CREATE PROCEDURE sp_edit_encomenda_componentes
    @EncomendaComponenteCreatedAt DATE,
    @NewFornecedorId INT,
    @NewFuncionarioResponsavelId INT,
    @NewExportedStatus BIT
AS
BEGIN

    UPDATE EncomendaComponente
    SET
        fornecedor_id = @NewFornecedorId,
        funcionario_responsavel_id = @NewFuncionarioResponsavelId,
        exported = @NewExportedStatus
    WHERE
        created_at = @EncomendaComponenteCreatedAt;

    PRINT 'Encomenda de Componentes editada com sucesso.';
END

-- sp_get_encomenda_componentes
CREATE FUNCTION sp_get_encomenda_componentes_by_id
(
    @encomenda_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM EncomendaComponente WHERE id = @encomenda_id
);


-- sp_delete_encomenda_componentes
CREATE PROCEDURE sp_delete_encomenda_componentes
    @encomenda_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM EncomendaComponente WHERE id = @encomenda_id)
    BEGIN

        DELETE FROM EncomendaComponente WHERE id = @encomenda_id;

        PRINT 'Encomenda de Componentes excluída com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Encomenda de Componentes não encontrada.';
    END
END;


-- Procedure sp_create_encomenda_equipamentos
CREATE PROCEDURE sp_create_encomenda_equipamentos
    @address NVARCHAR(100),
    @postal_code NVARCHAR(10),
    @locality NVARCHAR(50),
    @client_id INT,
    @funcionario_id INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EncomendaEquipamento (address, postal_code, locality, client_id, funcionario_id)
    VALUES (@address, @postal_code, @locality, @client_id, @funcionario_id);

    PRINT 'Encomenda de Equipamentos criada com sucesso.';
END;



--sp_get_encomenda_equipamentos
CREATE FUNCTION sp_get_encomenda_equipamentos()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM EncomendaEquipamento
);


-- sp_get_encomenda_equipamentos_by_id
CREATE FUNCTION sp_get_encomenda_equipamentos_by_id
(
    @encomenda_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM EncomendaEquipamento WHERE id = @encomenda_id
);


-- sp_delete_encomenda_equipamentos
CREATE PROCEDURE sp_delete_encomenda_equipamentos
    @encomenda_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM EncomendaEquipamento WHERE id = @encomenda_id)
    BEGIN

        DELETE FROM EncomendaEquipamento WHERE id = @encomenda_id;

        PRINT 'Encomenda de Equipamentos excluída com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Encomenda de Equipamentos não encontrada.';
    END
END;

-- sp_edit_encomenda_equipamentos

CREATE PROCEDURE sp_edit_encomenda_equipamentos
    @EncomendaEquipamentoId INT,
    @NewAddress NVARCHAR(50),
    @NewPostalCode NVARCHAR(50),
    @NewLocality NVARCHAR(50),
    @NewClientId INT,
    @NewFuncionarioId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EncomendaEquipamento WHERE id = @EncomendaEquipamentoId)
    BEGIN
        PRINT 'Encomenda de Equipamentos não encontrada. Falha na edição da encomenda.';
        RETURN;
    END

    UPDATE EncomendaEquipamento
    SET
        address = @NewAddress,
        postal_code = @NewPostalCode,
        locality = @NewLocality,
        client_id = @NewClientId,
        funcionario_id = @NewFuncionarioId
    WHERE
        id = @EncomendaEquipamentoId;

    PRINT 'Encomenda de Equipamentos editada com sucesso.';
END


-- Procedure sp_create_expedicao
CREATE PROCEDURE sp_create_expedicao
    @send_at DATE,
    @truck_license_plate NVARCHAR(10),
    @delivery_at DATE,
    @encomenda_id INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Expedicao (send_at, truck_license_plate, delivery_at, encomenda_id)
    VALUES (@send_at, @truck_license_plate, @delivery_at, @encomenda_id);

    PRINT 'Expedição criada com sucesso.';
END;


-- Function sp_get_expedicao
CREATE FUNCTION sp_get_expedicao()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Expedicao
);


-- Procedure sp_create_fatura
CREATE PROCEDURE sp_create_fatura
    @encomenda_id INT,
    @contribuinte INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Fatura (encomenda_id, contribuinte)
    VALUES (@encomenda_id, @contribuinte);

    PRINT 'Fatura criada com sucesso.';
END;


-- Function sp_get_fatura
CREATE FUNCTION sp_get_fatura()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Fatura
);
