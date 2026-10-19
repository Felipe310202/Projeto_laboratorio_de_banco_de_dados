-- ============================================================
-- B5 - Seguranca e controle de acesso
-- Tema: Oficina Mecanica
-- MySQL 8.0+ - rodar depois de 01, 02, 04 e 05
--
-- Parte 1: tabela de usuarios da APLICACAO, com senha em hash + sal
-- Parte 2: papeis (roles) do BANCO com GRANT/REVOKE, um por perfil,
--          seguindo o principio do menor privilegio
--
-- Os usuarios do BANCO (com senha) NAO estao neste arquivo: ficam em
-- 06b_usuarios_banco.sql, que nao vai para o Git (ver o modelo
-- 06b_usuarios_banco.exemplo.sql). Mesma ideia do .env da aplicacao:
-- senha de banco nao se versiona.
-- ============================================================

USE oficina_mecanica;

-- ============================================================
-- PARTE 1 - Usuarios da aplicacao
-- ============================================================
-- A senha NUNCA e guardada em texto. A aplicacao gera um hash bcrypt,
-- que ja embute um sal aleatorio diferente para cada senha:
--     $2b$12$<22 caracteres de sal><31 caracteres de hash>
--      |   |
--      |   +-- custo 12 (2^12 rodadas: lento de proposito contra
--      |       ataque de forca bruta)
--      +------ algoritmo bcrypt
-- No login, a aplicacao aplica o mesmo calculo na senha digitada e
-- compara com o hash guardado. Nem quem tem acesso ao banco descobre
-- a senha original.
CREATE TABLE IF NOT EXISTS usuario (
  id_usuario   INT AUTO_INCREMENT,
  login        VARCHAR(50)  NOT NULL,
  senha_hash   VARCHAR(255) NOT NULL,
  perfil       VARCHAR(20)  NOT NULL,
  id_mecanico  INT,
  ativo        BOOLEAN      NOT NULL DEFAULT TRUE,
  criado_em    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_login UNIQUE (login),
  CONSTRAINT fk_usuario_mecanico FOREIGN KEY (id_mecanico)
    REFERENCES mecanico(id_mecanico) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('atendente', 'mecanico', 'gerente')),
  -- garante que o que esta guardado tem formato de hash bcrypt, e nao texto puro
  CONSTRAINT ck_usuario_senha_hash CHECK (senha_hash LIKE '$2_$%' AND CHAR_LENGTH(senha_hash) = 60)
) ENGINE=InnoDB;

-- Usuarios de demonstracao (um por perfil). As senhas em texto NAO
-- aparecem aqui; estao no documento da equipe, fora do repositorio.
INSERT IGNORE INTO usuario (login, senha_hash, perfil, id_mecanico) VALUES
('ana.atendente',     '$2b$12$i9UrXJ2JpcDTjlNBh6e5eeIWhVIVJUIR.i0svKPN59RrvCMQcIIk.', 'atendente', NULL),
('jose.mecanico',     '$2b$12$cfPd454qVAq4svunBvK0ie/vnyvnXeeiyPFFkbThvHv4WlhTvRADq', 'mecanico',  9),
('sebastiao.gerente', '$2b$12$oEWNa2R21xBdASqd4avcT.5pIRJDBc.1kgjOS2O7eD97g.vIONh7.', 'gerente',   1);

-- ============================================================
-- PARTE 2 - Papeis do banco (roles) e privilegios
-- ============================================================
-- Um papel e um conjunto de permissoes com nome. Os usuarios do banco
-- recebem o papel, e nao as permissoes soltas: mudar o papel muda o
-- acesso de todos que o tem.
--
-- Os gatilhos e as visoes rodam com os privilegios de quem os criou
-- (DEFINER), por isso nenhum papel precisa de permissao em auditoria
-- ou status_historico para que eles funcionem.
CREATE ROLE IF NOT EXISTS
  'papel_login', 'papel_atendente', 'papel_mecanico', 'papel_gerente';

-- ------------------------------------------------------------
-- papel_login: so consegue ler a tabela de usuarios, para conferir
-- login e senha antes de saber qual perfil a pessoa tem.
-- ------------------------------------------------------------
GRANT SELECT (id_usuario, login, senha_hash, perfil, id_mecanico, ativo)
  ON oficina_mecanica.usuario TO 'papel_login';

-- ------------------------------------------------------------
-- papel_atendente: balcao. Cadastra clientes e veiculos, abre OS,
-- muda status (ex.: entregue), consulta pecas, garantia e o resumo
-- das OS. Ve os mecanicos SO pela visao sem salario.
-- Nao apaga nada e nao ve salario, matricula nem auditoria.
-- ------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON oficina_mecanica.cliente       TO 'papel_atendente';
GRANT SELECT, INSERT, UPDATE ON oficina_mecanica.veiculo       TO 'papel_atendente';
GRANT SELECT, INSERT, UPDATE ON oficina_mecanica.ordem_servico TO 'papel_atendente';
GRANT SELECT ON oficina_mecanica.status_historico    TO 'papel_atendente';
GRANT SELECT ON oficina_mecanica.vw_mecanico_publico TO 'papel_atendente';
GRANT SELECT ON oficina_mecanica.vw_resumo_os        TO 'papel_atendente';
GRANT SELECT ON oficina_mecanica.vw_garantia_os      TO 'papel_atendente';

-- REVOKE: a primeira versao do perfil deixava o atendente alterar a
-- tabela peca (ajustar estoque no balcao). Foi revogado porque o
-- estoque so deve mudar pela transacao de lancar peca na OS (RN09) e
-- o preco so pelo gerente, com auditoria. Ficou apenas a consulta.
GRANT SELECT, UPDATE ON oficina_mecanica.peca TO 'papel_atendente';
REVOKE UPDATE ON oficina_mecanica.peca FROM 'papel_atendente';

-- ------------------------------------------------------------
-- papel_mecanico: oficina. Ve so as OS em andamento e sem dados do
-- cliente (visao vw_oficina), lanca pecas e horas, muda o status.
-- Privilegio por COLUNA: no estoque da peca e no status da OS ele so
-- altera a coluna necessaria; o preco e as datas ficam bloqueados.
-- Nao tem nenhum acesso a tabela cliente (dados pessoais).
-- ------------------------------------------------------------
GRANT SELECT ON oficina_mecanica.vw_os_oficina       TO 'papel_mecanico';
GRANT SELECT ON oficina_mecanica.vw_mecanico_publico TO 'papel_mecanico';
GRANT SELECT ON oficina_mecanica.peca                TO 'papel_mecanico';
GRANT UPDATE (estoque_atual) ON oficina_mecanica.peca TO 'papel_mecanico';
GRANT SELECT, INSERT ON oficina_mecanica.os_peca     TO 'papel_mecanico';
GRANT SELECT, INSERT ON oficina_mecanica.os_mecanico TO 'papel_mecanico';
GRANT SELECT (id_os, status_atual) ON oficina_mecanica.ordem_servico TO 'papel_mecanico';
GRANT UPDATE (status_atual)        ON oficina_mecanica.ordem_servico TO 'papel_mecanico';

-- ------------------------------------------------------------
-- papel_gerente: administracao. Le e altera todas as tabelas de
-- negocio, inclusive salarios e precos, e gerencia os usuarios da
-- aplicacao. A auditoria e SOMENTE leitura: nem o gerente apaga ou
-- altera o registro do que foi feito.
-- ------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.cliente               TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.veiculo               TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.mecanico              TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.mecanico_interno      TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.mecanico_terceirizado TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.empresa_parceira      TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.fornecedor            TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.peca                  TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.ordem_servico         TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.os_peca               TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE, DELETE ON oficina_mecanica.os_mecanico           TO 'papel_gerente';
GRANT SELECT ON oficina_mecanica.status_historico    TO 'papel_gerente';
GRANT SELECT ON oficina_mecanica.auditoria           TO 'papel_gerente';
GRANT SELECT, INSERT, UPDATE ON oficina_mecanica.usuario TO 'papel_gerente';
GRANT SELECT ON oficina_mecanica.vw_resumo_os        TO 'papel_gerente';
GRANT SELECT ON oficina_mecanica.vw_mecanico_publico TO 'papel_gerente';
GRANT SELECT ON oficina_mecanica.vw_os_oficina       TO 'papel_gerente';
GRANT SELECT ON oficina_mecanica.vw_garantia_os      TO 'papel_gerente';

-- Para conferir o que cada papel pode fazer:
--   SHOW GRANTS FOR 'papel_atendente';
