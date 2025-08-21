Estrutura para GitHub:
# Personalizando Acessos e Automatizando Ações no MySQL

Este repositório contém scripts SQL para personalização de acessos e automação em bancos de dados MySQL. O projeto inclui a criação de views, gatilhos e permissões de acesso para diferentes tipos de usuários.

## Funcionalidades

- **Criação de views** para contagem de empregados por departamento e localidade.
- **Gatilhos** para registro de ações como remoção de usuários e atualizações de salários.
- **Concessão de permissões de acesso** específicas para diferentes usuários (como gerentes e empregados).

## Scripts SQL

### 1. Criação de Views para Contagem de Empregados por Departamento e Localidade

```sql
-- Criação de view para contar o número de empregados por departamento e localidade
CREATE VIEW emp_por_depto_localidade AS
SELECT departamento, localidade, COUNT(*) AS num_empregados
FROM empregados
GROUP BY departamento, localidade;

2. Gatilhos para Registro de Ações
2.1 Gatilho de Remoção de Usuários
-- Gatilho para registrar a remoção de um usuário no histórico antes da exclusão
CREATE TRIGGER before_user_delete
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
    -- Registra a exclusão do usuário no histórico
    INSERT INTO historico_exclusao_usuarios (usuario_id, data_exclusao)
    VALUES (OLD.id, NOW());
END;

2.2 Gatilho de Atualização de Salário Base de Colaboradores
-- Gatilho para registrar mudanças no salário base de colaboradores
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

2.3 Gatilho de Inserção de Novos Colaboradores
-- Gatilho para registrar a inserção de novos colaboradores na auditoria
CREATE TRIGGER after_employee_insert
AFTER INSERT ON colaboradores
FOR EACH ROW
BEGIN
    -- Registra a inserção do novo colaborador na auditoria
    INSERT INTO auditoria_colaboradores (colaborador_id, acao, data_acao)
    VALUES (NEW.id, 'Inserção', NOW());
END;

3. Concessão de Permissões de Acesso a Diferentes Usuários
3.1 Criando Usuário Gerente e Concedendo Permissões
-- Criando usuário gerente e concedendo permissões
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha123';
-- O gerente terá permissão de leitura nas views específicas
GRANT SELECT ON database_name.emp_por_depto_localidade TO 'gerente'@'localhost';
GRANT SELECT ON database_name.depto_e_gerente TO 'gerente'@'localhost';

3.2 Criando Usuário Empregado e Concedendo Permissões Limitadas
-- Criando usuário empregado e concedendo permissões limitadas
CREATE USER 'empregado'@'localhost' IDENTIFIED BY 'senha456';
-- O empregado só tem acesso à tabela de empregados
GRANT SELECT ON database_name.empregados TO 'empregado'@'localhost';
-- Não damos permissão para os departamentos ou gerentes


