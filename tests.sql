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
SELECT * FROM fn_get_tipo_mao_obra_by_id(22);

-- Teste: sp_edit_tipo_mao_obra
CALL sp_edit_tipo_mao_de_obra(22, 'Edited Tipo de Mao de Obra', 100);

-- Demonstração da alteração
SELECT * FROM fn_get_tipo_mao_obra_by_id(22);


SELECT * FROM fn_delete_labor_by_id(22);

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

-- Teste: fn_check_if_there_are_users
select * from fn_check_if_there_are_users()

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

START TRANSACTION;

SELECT * FROM fn_import_components('[{"name":"RAM","cost":25.99,"supplier":{"name":"Newegg","email":"contact@newegg.com","address":"123 Tech Street","postal_code":"98765","locality":"Electron City"}},{"name":"CPU","cost":199.99,"supplier":{"name":"Newegg","email":"contact@newegg.com","address":"123 Tech Street","postal_code":"98765","locality":"Electron City"}},{"name":"Graphics Card","cost":349.99,"supplier":{"name":"NVIDIA","email":"contact@nvidia.com","address":"456 GPU Avenue","postal_code":"54321","locality":"Graphics Town"}},{"name":"Storage (SSD)","cost":129.99,"supplier":{"name":"Samsung","email":"info@samsung.com","address":"789 Data Drive","postal_code":"12345","locality":"Storage City"}},{"name":"Motherboard","cost":179.95,"supplier":{"name":"ASUS","email":"support@asus.com","address":"101 Motherboard Lane","postal_code":"67890","locality":"Boardville"}},{"name":"Power Supply Unit (PSU)","cost":89.99,"supplier":{"name":"Corsair","email":"sales@corsair.com","address":"202 Power Street","postal_code":"34567","locality":"Power City"}},{"name":"Cooling System (CPU Cooler)","cost":79.99,"supplier":{"name":"NZXT","email":"info@nzxt.com","address":"303 Coolers Avenue","postal_code":"87654","locality":"Cooling Town"}},{"name":"Storage (HDD)","cost":69.99,"supplier":{"name":"Western Digital","email":"sales@wd.com","address":"404 Hard Drive Lane","postal_code":"23456","locality":"Data City"}},{"name":"Case","cost":109.95,"supplier":{"name":"Cooler Master","email":"info@coolermaster.com","address":"505 Case Street","postal_code":"78901","locality":"Caseville"}},{"name":"Monitor","cost":299.99,"supplier":{"name":"Dell","email":"sales@dell.com","address":"606 Display Drive","postal_code":"01234","locality":"Screen City"}}]');

SELECT * FROM fn_get_components(NULL, NULL);

ROLLBACK;


-- ==========================================================================
-- Encomenda Componente
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_component
SELECT * FROM fn_create_encomenda_componentes(NOW()::timestamp without time zone, 12, 17);

-- Teste: fn_get_components
SELECT * FROM fn_get_component_orders()

CALL sp_create_quantidades_encomenda_componentes(20, 14, 207);

-- Teste: fn_get_components
SELECT * FROM fn_get_component_order_amounts()

-- Teste: sp_edit_component
CALL sp_edit_encomenda_componentes(20, 14, 17);

-- Demonstração da alteração
SELECT * FROM fn_get_encomenda_componentes_by_id(20);

-- Teste: sp_edit_quantidades_encomenda_componentes
CALL sp_edit_quantidades_encomenda_componentes(30, 14, 7);

-- Teste: fn_get_components
SELECT * FROM fn_get_component_order_amounts()

-- Teste: sp_delete_quantidades_encomenda_componentes
CALL sp_delete_quantidade_encomenda_componente(30);

-- Teste: fn_delete_component_by_id
SELECT * FROM fn_delete_encomenda_componente(20);

ROLLBACK;


-- ==========================================================================
-- Cliente
-- ==========================================================================

-- Teste: fn_get_clients
SELECT * FROM fn_get_clients();


-- ==========================================================================
-- Encomenda Componente
-- ==========================================================================

START TRANSACTION;

-- Teste: fn_create_encomenda_equipamento
SELECT * FROM fn_create_encomenda_equipamento(NOW()::timestamp without time zone, 'Morada', '3000-000', 'Viseu', 13, 15);

-- Teste: fn_get_equipment_orders
SELECT * FROM fn_get_equipment_orders(NULL, NULL);

-- Teste: sp_create_quantidades_encomenda_equipamentos
CALL sp_create_quantidades_encomenda_equipamentos(10, 11, 1);

-- Teste: fn_get_equipment_order_amounts
SELECT * FROM fn_get_equipment_order_amounts(NULL, NULL);

-- Teste: fn_delete_encomenda_by_id
SELECT * FROM fn_delete_encomenda_by_id(10);

-- Teste: sp_mark_component_orders_as_exported
CALL sp_mark_component_orders_as_exported()

ROLLBACK;


-- ==========================================================================
-- Registo de Produção
-- ==========================================================================

START TRANSACTION;

-- Teste: fn_create_production_registry
SELECT * FROM fn_create_production_registry(NOW()::date, NOW()::date, 10, 11, 13, 6);

-- Teste: fn_get_production_registries
SELECT * FROM fn_get_production_registries();

-- Teste: sp_create_quantidades_componente_registo_producao
CALL sp_create_quantidades_componente_registo_producao(11, 16, 3);

-- Teste: fn_get_production_registry_component_amouts
SELECT * FROM fn_get_production_registry_component_amouts();

-- Teste: fn_get_unassigned_production_registries
SELECT * FROM fn_get_unassigned_production_registries();

-- Teste: sp_edit_registo_producao
CALL sp_edit_registo_producao(11, NOW()::date, NOW()::date, 10, 6);

-- Teste: fn_get_production_registry_by_id
SELECT * FROM fn_get_production_registry_by_id(11);

-- Teste: fn_delete_registo_producao_by_id
SELECT * FROM fn_delete_registo_producao_by_id(11);

ROLLBACK;


-- ==========================================================================
-- Guia Entrega Componetes
-- ==========================================================================

START TRANSACTION;

-- Teste: fn_create_guia_entrega_componentes
SELECT * FROM fn_create_guia_entrega_componentes(NOW()::date, 7);

-- Teste: fn_get_guia_entrega_componentes
SELECT * FROM fn_get_guia_entrega_componentes();

-- Teste: sp_create_quantidades_guia_entrega_componentes
CALL sp_create_quantidades_guia_entrega_componentes(5, 16, 30);

-- Teste: fn_get_guia_entrega_componentes_amounts
SELECT * FROM fn_get_guia_entrega_componentes_amounts();

ROLLBACK;


-- ==========================================================================
-- Expedição
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_expedicao
CALL sp_create_expedicao(NOW()::date, '10-AB-90', NOW()::date, 11, ARRAY[10]);

-- Teste: fn_get_expedicao
SELECT * FROM fn_get_expedicao();

-- Teste: fn_get_expedicao_by_id
SELECT * FROM fn_get_expedicao_by_id(11);

ROLLBACK;


-- ==========================================================================
-- Fatura
-- ==========================================================================

START TRANSACTION;

-- Teste: sp_create_fatura
CALL sp_create_fatura(NOW()::date, '987654321', 11);

-- Teste: fn_get_equipment_order_invoices
SELECT * FROM fn_get_equipment_order_invoices();

-- Teste: fn_get_equipment_order_invoice_by_id
SELECT * FROM fn_get_equipment_order_invoice_by_id(11);

ROLLBACK;


-- ==========================================================================
-- Stock de Equipamentos
-- ==========================================================================

SELECT * FROM fn_get_stock_equipamentos()

-- ==========================================================================
-- Stock de Componentes
-- ==========================================================================

SELECT * FROM fn_get_stock_componentes()
