-- ==========================================================================
-- Tipo de Equipamento
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_tipo_equipamento
CALL sp_create_tipo_equipamento('New Equipment Type');

-- Teste: fn_get_tipo_equipamentos
SELECT * FROM fn_get_tipo_equipamentos();

-- Teste: fn_get_tipo_equipamento
SELECT * FROM fn_get_tipo_equipamento(25);

-- Teste: sp_edit_tipo_equipamento
CALL sp_edit_tipo_equipamento(25, 'Edited Equipment Type');

-- Demonstração da alteração
SELECT * FROM fn_get_tipo_equipamento(25);

-- Teste: fn_delete_tipo_equipamento_by_id
SELECT * FROM fn_delete_tipo_equipamento_by_id(25);

ROLLBACK;


-- ==========================================================================
-- Tipo De Mão de Obra
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_tipo_mao_obra
CALL sp_create_tipo_mao_obra('New Mao de Obra', 100);

-- Teste: fn_get_tipo_mao_obra
SELECT * FROM fn_get_tipo_mao_obra();

-- Teste: fn_get_tipo_mao_obra
SELECT * FROM fn_get_tipo_mao_obra_by_id(19);

-- Teste: sp_edit_tipo_mao_obra
CALL sp_edit_tipo_mao_de_obra(19, 'Edited Tipo de Mao de Obra', 100);

-- Demonstração da alteração
SELECT * FROM fn_get_tipo_mao_obra_by_id(19);

ROLLBACK;


-- ==========================================================================
-- Armazém
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_armazem
CALL sp_create_armazem('New Warehouse', 'Location A', '12345', 'City A');

-- Teste: fn_get_armazens
SELECT * FROM fn_get_armazens(NULL, NULL);

-- Teste: fn_get_armazem_by_id
SELECT * FROM fn_get_armazem_by_id(16);

-- Teste: sp_edit_armazem
CALL sp_edit_armazem(16, 'Edited Warehouse', 'Location B', '54321', 'City B');

-- Demonstração da alteração
SELECT * FROM fn_get_armazem_by_id(16);

-- Teste: fn_delete_armazem_by_id
SELECT * FROM fn_delete_armazem_by_id(16);

ROLLBACK;


-- ==========================================================================
-- Fornecedor
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_fornecedor
CALL sp_create_fornecedor('New Supplier', 'address', '1233-1213', 'Rua A', 'email@email.com');

-- Teste: fn_get_fornecedores
SELECT * FROM fn_get_fornecedores(NULL, NULL);

-- Teste: fn_get_fornecedor_by_id
SELECT * FROM fn_get_fornecedor_by_id(26);

-- Teste: sp_edit_fornecedor
CALL sp_edit_fornecedor(26, 'Edited Supplier', 'address', '1233-1213', 'Rua A', 'email@email.com');

-- Demonstração da alteração
SELECT * FROM fn_get_fornecedor_by_id(26);

-- Teste: fn_get_fornecedores
SELECT * FROM fn_get_fornecedores(NULL, NULL);

-- Teste: fn_delete_fornecedor_by_id
SELECT * FROM fn_delete_fornecedor_by_id(26);

ROLLBACK;


-- ==========================================================================
-- Utilizador
-- ==========================================================================

START TRANSACTION;

INSERT INTO ipv_bd2_projeto_utilizador (first_name, last_name, email, type, is_superuser, last_login, password, is_staff, date_joined, is_active)
VALUES ('John', 'Doe', 'john.doe@example.com', 'AD', true, '2024-01-03 12:00:00', 'hashed_password', true, '2024-01-03 12:00:00', true);

-- Teste: fn_get_utilizadores
SELECT * FROM fn_get_utilizadores(NULL, NULL);

-- Teste: fn_get_user
SELECT * FROM fn_get_user(17);

-- Teste: sp_edit_user
CALL sp_edit_user(17, 'Johnny', 'Depp', 'FU');

-- Demonstração da alteração
SELECT * FROM fn_get_user(17);

ROLLBACK;


-- ==========================================================================
-- Equipamento
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_equipment
SELECT * FROM fn_create_equipment('New Equipamento', 12);

-- Teste: fn_get_equipamentos
SELECT * FROM fn_get_equipamentos(NULL, NULL);

-- Teste: sp_edit_equipamento
CALL sp_edit_equipamento(16, 'Edited Equipamento', 12);

-- Demonstração da alteração
SELECT * FROM fn_get_equipamento_by_id(16);

-- Teste: fn_delete_armazem_by_id
SELECT * FROM fn_delete_equipment_by_id(16);

ROLLBACK;


-- ==========================================================================
-- Componente
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_component
CALL sp_create_component('Intel Core i9', 249.99, 25);

-- Teste: fn_get_components
SELECT * FROM fn_get_components(NULL, NULL);

-- Teste: fn_get_component
SELECT * FROM fn_get_component(29);

-- Teste: sp_edit_component
CALL sp_edit_component(29, 'Updated Test Component', 150.00, 25);

-- Demonstração da alteração
SELECT * FROM fn_get_component(29);

-- Teste: fn_delete_component_by_id
SELECT * FROM fn_delete_component_by_id(29);

ROLLBACK;
