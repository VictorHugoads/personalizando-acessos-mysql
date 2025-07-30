# -Personalizando-Acessos-e-Automatizando-a-es-no-MySQL

Personalizando acessos com views
Vamos criar as views conforme os cenários que você mencionou e, em seguida, definir as permissões de acesso.

Script de Criação das Views

-- 1. Número de empregados por departamento e localidade
CREATE VIEW emp_por_depto_localidade AS
SELECT departamento, localidade, COUNT(*) AS num_empregados
FROM empregados
GROUP BY departamento, localidade;

-- 2. Lista de departamentos e seus gerentes
CREATE VIEW depto_e_gerente AS
SELECT d.departamento, g.nome AS gerente
FROM departamentos d
JOIN empregados e ON e.departamento_id = d.id
JOIN gerentes g ON g.id = e.id_gerente;

-- 3. Projetos com maior número de empregados (ordenado decrescente)
CREATE VIEW projetos_maiores_empregados AS
SELECT p.projeto, COUNT(*) AS num_empregados
FROM projetos p
JOIN empregados e ON e.projeto_id = p.id
GROUP BY p.projeto
ORDER BY num_empregados DESC;

-- 4. Lista de projetos, departamentos e gerentes
CREATE VIEW projetos_deptos_gerentes AS
SELECT p.projeto, d.departamento, g.nome AS gerente
FROM projetos p
JOIN departamentos d ON p.departamento_id = d.id
JOIN empregados e ON e.departamento_id = d.id
JOIN gerentes g ON g.id = e.id_gerente;

-- 5. Empregados que possuem dependentes e se são gerentes
CREATE VIEW empregados_com_dependentes_e_gerentes AS
SELECT e.nome AS empregado, 
       e.dependentes, 
       CASE WHEN e.id_gerente IS NOT NULL THEN 'Sim' ELSE 'Não' END AS gerente
FROM empregados e
WHERE e.dependentes > 0;
Definindo Permissões de Acesso
Abaixo, o código para criação de usuários e definição de permissões.


-- Criar usuário gerente
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha123';
GRANT SELECT ON database_name.emp_por_depto_localidade TO 'gerente'@'localhost';
GRANT SELECT ON database_name.depto_e_gerente TO 'gerente'@'localhost';

-- Criar usuário empregado
CREATE USER 'empregado'@'localhost' IDENTIFIED BY 'senha456';
GRANT SELECT ON database_name.empregados TO 'empregado'@'localhost';
-- Não damos permissão para os departamentos ou gerentes
Parte 2 - Criando Gatilhos para o Cenário de E-commerce
Script de Criação de Triggers
Trigger de remoção de usuários:


-- Gatilho antes da remoção de usuários
CREATE TRIGGER before_user_delete
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO historico_exclusao_usuarios (usuario_id, data_exclusao)
    VALUES (OLD.id, NOW());
END;
Trigger de atualização de salário base de colaboradores:



-- Gatilho antes de atualizar o salário de um colaborador
CREATE TRIGGER before_salary_update
BEFORE UPDATE ON colaboradores
FOR EACH ROW
BEGIN
    IF NEW.salario_base != OLD.salario_base THEN
        INSERT INTO historico_salarios (colaborador_id, salario_antigo, salario_novo, data_atualizacao)
        VALUES (OLD.id, OLD.salario_base, NEW.salario_base, NOW());
    END IF;
END;

Trigger de inserção de novos colaboradores:


-- Gatilho de inserção de novos colaboradores
CREATE TRIGGER after_employee_insert
AFTER INSERT ON colaboradores
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_colaboradores (colaborador_id, acao, data_acao)
    VALUES (NEW.id, 'Inserção', NOW());
END;
