# -Personalizando-Acessos-e-Automatizando-a-es-no-MySQL

Personalizando acessos com views
Vamos criar as views conforme os cenários que você mencionou e, em seguida, definir as permissões de acesso.

Script de Criação das Views

-- ========================================
-- PARTE 1: PERSONALIZANDO ACESSOS COM VIEWS
-- ========================================

-- 1. Número de empregados por departamento e localidade
CREATE VIEW emp_por_depto_localidade AS
-- Contagem de empregados agrupados por departamento e localidade
SELECT 
    departamento, 
    localidade, 
    COUNT(*) AS num_empregados
FROM empregados
GROUP BY departamento, localidade;

-- 2. Lista de departamentos e seus gerentes
CREATE VIEW depto_e_gerente AS
-- Exibe os departamentos com seus respectivos gerentes
SELECT 
    d.departamento, 
    g.nome AS gerente
FROM departamentos d
JOIN empregados e ON e.departamento_id = d.id
JOIN gerentes g ON g.id = e.id_gerente;

-- 3. Projetos com maior número de empregados (ordenado de forma decrescente)
CREATE VIEW projetos_maiores_empregados AS
-- Lista os projetos com o número de empregados ordenado em ordem decrescente
SELECT 
    p.projeto, 
    COUNT(*) AS num_empregados
FROM projetos p
JOIN empregados e ON e.projeto_id = p.id
GROUP BY p.projeto
ORDER BY num_empregados DESC;

-- 4. Lista de projetos, departamentos e gerentes
CREATE VIEW projetos_deptos_gerentes AS
-- Exibe projetos com departamentos e seus gerentes
SELECT 
    p.projeto, 
    d.departamento, 
    g.nome AS gerente
FROM projetos p
JOIN departamentos d ON p.departamento_id = d.id
JOIN empregados e ON e.departamento_id = d.id
JOIN gerentes g ON g.id = e.id_gerente;

-- 5. Empregados que possuem dependentes e se são gerentes
CREATE VIEW empregados_com_dependentes_e_gerentes AS
-- Lista os empregados com dependentes, e se são gerentes ou não
SELECT 
    e.nome AS empregado, 
    e.dependentes, 
    CASE WHEN e.id_gerente IS NOT NULL THEN 'Sim' ELSE 'Não' END AS gerente
FROM empregados e
WHERE e.dependentes > 0;

-- ========================================
-- PARTE 2: CRIANDO GATILHOS PARA E-COMMERCE
-- ========================================

-- Gatilho de remoção de usuários
-- Este gatilho registra a remoção de um usuário no histórico antes da exclusão
CREATE TRIGGER before_user_delete
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
    -- Registra a exclusão do usuário no histórico
    INSERT INTO historico_exclusao_usuarios (usuario_id, data_exclusao)
    VALUES (OLD.id, NOW());
END;

-- Gatilho de atualização de salário base de colaboradores
-- Este gatilho registra mudanças no salário base de colaboradores
CREATE TRIGGER before_salary_update
BEFORE UPDATE ON colaboradores
FOR EACH ROW
BEGIN
    IF NEW.salario_base != OLD.salario_base THEN
        -- Registra a alteração no histórico de salários
        INSERT INTO historico_salarios (colaborador_id, salario_antigo, salario_novo, data_atualizacao)
        VALUES (OLD.id, OLD.salario_base, NEW.salario_base, NOW());
    END IF;
END;

-- Gatilho de inserção de novos colaboradores
-- Este gatilho registra a inserção de novos colaboradores na auditoria
CREATE TRIGGER after_employee_insert
AFTER INSERT ON colaboradores
FOR EACH ROW
BEGIN
    -- Registra a inserção do novo colaborador na auditoria
    INSERT INTO auditoria_colaboradores (colaborador_id, acao, data_acao)
    VALUES (NEW.id, 'Inserção', NOW());
END;

-- ========================================
-- PARTE 3: PERMISSÕES DE ACESSO AOS USUÁRIOS
-- ========================================

-- Criando usuário gerente e concedendo permissões
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha123';
-- O gerente terá permissão de leitura nas views específicas
GRANT SELECT ON database_name.emp_por_depto_localidade TO 'gerente'@'localhost';
GRANT SELECT ON database_name.depto_e_gerente TO 'gerente'@'localhost';

-- Criando usuário empregado e concedendo permissões limitadas
CREATE USER 'empregado'@'localhost' IDENTIFIED BY 'senha456';
-- O empregado só tem acesso à tabela de empregados
GRANT SELECT ON database_name.empregados TO 'empregado'@'localhost';
-- Não damos permissão para os departamentos ou gerentes

-- ========================================
-- FIM DO SCRIPT
-- ========================================
