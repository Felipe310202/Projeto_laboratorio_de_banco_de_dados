-- ============================================================
-- B6 - Gatilhos (triggers) e auditoria
-- Tema: Oficina Mecanica
-- MySQL 8.0+ - rodar depois de 01_ddl.sql e 02_carga.sql
--
-- auditoria                -> tabela que guarda quem mudou o que, quando,
--                             valor anterior e valor posterior
-- trg_peca_audit_preco     -> audita mudanca de preco da peca (B6)
-- trg_os_audit_status      -> audita mudanca de status da OS e grava o
--                             historico automaticamente (B6, RN16)
-- trg_mecanico_rn08_ins    -> impede mecanico supervisor de si mesmo (RN08)
-- trg_mecanico_rn08_upd       no cadastro e na alteracao
--
-- Por que auditar preco e status:
--   * preco_atual define quanto o cliente paga nas proximas OS; um
--     reajuste errado ou indevido precisa ter autor e data registrados.
--   * status_atual mostra onde o carro esta e se o prazo foi cumprido;
--     numa reclamacao do cliente a oficina precisa saber quem mudou o
--     status e quando.
--
-- Autor da alteracao: a aplicacao conecta sempre com o mesmo usuario do
-- banco, entao ela informa quem esta logado com
--     SET @usuario_app = 'login_da_pessoa';
-- antes de alterar. Sem essa variavel (ex.: alguem no Workbench), o
-- gatilho grava o usuario da conexao, USER().
-- ============================================================

USE oficina_mecanica;

-- ------------------------------------------------------------
-- Tabela de auditoria
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS auditoria (
  id_auditoria  INT AUTO_INCREMENT,
  tabela        VARCHAR(40)  NOT NULL,
  id_registro   INT          NOT NULL,
  campo         VARCHAR(40)  NOT NULL,
  valor_antigo  VARCHAR(200),
  valor_novo    VARCHAR(200),
  usuario       VARCHAR(100) NOT NULL,
  data_hora     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria),
  -- consulta tipica: "todo o historico de alteracoes da peca 2"
  INDEX idx_auditoria_registro (tabela, id_registro)
) ENGINE=InnoDB;

-- Permite rodar o script mais de uma vez sem erro
DROP TRIGGER IF EXISTS trg_peca_audit_preco;
DROP TRIGGER IF EXISTS trg_os_audit_status;
DROP TRIGGER IF EXISTS trg_mecanico_rn08_ins;
DROP TRIGGER IF EXISTS trg_mecanico_rn08_upd;

-- O corpo dos gatilhos tem varios ';'. O DELIMITER troca o fim de
-- comando para '$$' enquanto eles sao criados.
DELIMITER $$

-- ------------------------------------------------------------
-- Gatilho 1 (B6): auditoria de preco da peca
-- AFTER: a alteracao ja aconteceu; o gatilho so registra.
-- So grava quando o preco de fato mudou (um UPDATE no estoque
-- da mesma peca nao gera registro).
-- ------------------------------------------------------------
CREATE TRIGGER trg_peca_audit_preco
AFTER UPDATE ON peca
FOR EACH ROW
BEGIN
  IF NOT (OLD.preco_atual <=> NEW.preco_atual) THEN
    INSERT INTO auditoria (tabela, id_registro, campo, valor_antigo, valor_novo, usuario)
    VALUES ('peca', NEW.id_peca, 'preco_atual',
            OLD.preco_atual, NEW.preco_atual,
            COALESCE(@usuario_app, USER()));
  END IF;
END$$

-- ------------------------------------------------------------
-- Gatilho 2 (B6 + RN16): mudanca de status da OS
-- Faz duas coisas quando o status muda:
--   1. registra a mudanca na auditoria (autor, data, antes, depois);
--   2. acrescenta o proximo evento no status_historico da OS,
--      calculando o num_sequencia (chave parcial da entidade fraca).
-- A observacao do historico vem de @obs_status, se a aplicacao
-- informar (ex.: justificativa ao voltar um status, RN05).
-- ------------------------------------------------------------
CREATE TRIGGER trg_os_audit_status
AFTER UPDATE ON ordem_servico
FOR EACH ROW
BEGIN
  DECLARE v_proxima_seq INT;

  IF NOT (OLD.status_atual <=> NEW.status_atual) THEN
    INSERT INTO auditoria (tabela, id_registro, campo, valor_antigo, valor_novo, usuario)
    VALUES ('ordem_servico', NEW.id_os, 'status_atual',
            OLD.status_atual, NEW.status_atual,
            COALESCE(@usuario_app, USER()));

    SELECT COALESCE(MAX(num_sequencia), 0) + 1
      INTO v_proxima_seq
      FROM status_historico
     WHERE id_os = NEW.id_os;

    INSERT INTO status_historico (id_os, num_sequencia, status, data_hora_mudanca, observacao)
    VALUES (NEW.id_os, v_proxima_seq, NEW.status_atual, NOW(), @obs_status);
  END IF;
END$$

-- ------------------------------------------------------------
-- Gatilhos 3 e 4 (RN08): mecanico nao pode supervisionar a si mesmo
-- BEFORE: verifica antes de gravar e, se a regra for violada, cancela
-- a operacao com SIGNAL (erro 45000 com mensagem propria).
-- Na Etapa 1 essa regra nao pode virar CHECK (coluna com acao de FK
-- e referencia a coluna AUTO_INCREMENT), por isso ficou para gatilho.
-- ------------------------------------------------------------
CREATE TRIGGER trg_mecanico_rn08_ins
BEFORE INSERT ON mecanico
FOR EACH ROW
BEGIN
  IF NEW.id_supervisor IS NOT NULL AND NEW.id_supervisor = NEW.id_mecanico THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'RN08: um mecanico nao pode ser supervisor de si mesmo';
  END IF;
END$$

CREATE TRIGGER trg_mecanico_rn08_upd
BEFORE UPDATE ON mecanico
FOR EACH ROW
BEGIN
  IF NEW.id_supervisor IS NOT NULL AND NEW.id_supervisor = NEW.id_mecanico THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'RN08: um mecanico nao pode ser supervisor de si mesmo';
  END IF;
END$$

DELIMITER ;
