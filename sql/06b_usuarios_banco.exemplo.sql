-- ============================================================
-- B5 - Usuarios do BANCO (modelo)
-- Tema: Oficina Mecanica
--
-- Este arquivo e so um MODELO e vai para o Git sem senhas.
-- Como usar:
--   1. Copie este arquivo para sql/06b_usuarios_banco.sql
--      (esse nome esta no .gitignore e NUNCA vai para o Git)
--   2. Na copia, troque cada <SENHA_...> por uma senha forte
--   3. Rode a copia depois do 06_seguranca.sql
--   4. Coloque as mesmas senhas no arquivo .env da aplicacao
--
-- Cada usuario do banco recebe UM papel (definido no 06_seguranca.sql).
-- SET DEFAULT ROLE faz o papel ja vir ativo quando ele conecta.
-- ============================================================

CREATE USER IF NOT EXISTS 'oficina_login'@'localhost'     IDENTIFIED BY '<SENHA_LOGIN>';
CREATE USER IF NOT EXISTS 'oficina_atendente'@'localhost' IDENTIFIED BY '<SENHA_ATENDENTE>';
CREATE USER IF NOT EXISTS 'oficina_mecanico'@'localhost'  IDENTIFIED BY '<SENHA_MECANICO>';
CREATE USER IF NOT EXISTS 'oficina_gerente'@'localhost'   IDENTIFIED BY '<SENHA_GERENTE>';

GRANT 'papel_login'     TO 'oficina_login'@'localhost';
GRANT 'papel_atendente' TO 'oficina_atendente'@'localhost';
GRANT 'papel_mecanico'  TO 'oficina_mecanico'@'localhost';
GRANT 'papel_gerente'   TO 'oficina_gerente'@'localhost';

SET DEFAULT ROLE 'papel_login'     TO 'oficina_login'@'localhost';
SET DEFAULT ROLE 'papel_atendente' TO 'oficina_atendente'@'localhost';
SET DEFAULT ROLE 'papel_mecanico'  TO 'oficina_mecanico'@'localhost';
SET DEFAULT ROLE 'papel_gerente'   TO 'oficina_gerente'@'localhost';

-- Conferir:  SHOW GRANTS FOR 'oficina_atendente'@'localhost' USING 'papel_atendente';
