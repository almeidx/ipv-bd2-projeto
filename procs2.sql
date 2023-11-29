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


-- Procedure to create component
CREATE OR REPLACE PROCEDURE sp_create_component(
    p_ComponentName NVARCHAR(50),
    p_ComponentCost FLOAT,
    p_FornecedorId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Componente (name, cost, fornecedor_id)
    VALUES (p_ComponentName, p_ComponentCost, p_FornecedorId);

    RAISE NOTICE 'Componente criado com sucesso.';
END;
$$;


-- Procedure to create tipo de equipamento
CREATE OR REPLACE PROCEDURE sp_create_tipo_equipamento(
    p_name NVARCHAR(50)
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


-- Function to get tipo de equipamento
CREATE OR REPLACE FUNCTION fn_get_tipo_equipamentos()
RETURNS TABLE (
    id INT,
    tipo VARCHAR(50)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT id, tipo FROM ipv_bd2_projeto_tipodeequipamento;
END;
$$ LANGUAGE plpgsql;

