-- ============================================================
-- A6 - Script de criacao do banco (DDL)
-- Tema: Oficina Mecanica
-- MySQL 8.0+, testado do zero em base limpa
--
-- Revisao (Etapa 2), a partir da devolutiva da Etapa 1:
--   * todas as chaves primarias nomeadas com o prefixo pk_
--   * CHECKs de dominio (salario, precos, estoque, valor/hora, ano,
--     status do historico, datas de previsao)
--   * status_historico virou entidade fraca: chave parcial num_sequencia,
--     identificada pela OS dona (PK composta id_os + num_sequencia)
--   * nova entidade empresa_parceira (remove a dependencia transitiva
--     id_mecanico -> cnpj_empresa -> nome da empresa em mecanico_terceirizado)
--   * matricula do mecanico interno passou a ser UNIQUE (chave alternativa)
--   * ordem_servico ganhou problema_relatado e id_os_garantia
--     (autorrelacionamento que liga um retorno em garantia a OS original)
-- ============================================================

-- Recria o banco do zero. ATENCAO: apaga o banco oficina_mecanica se existir.
DROP DATABASE IF EXISTS oficina_mecanica;
CREATE DATABASE oficina_mecanica
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE oficina_mecanica;

-- RN01, RN02: cliente e a base de tudo, cpf_cnpj nao pode repetir
CREATE TABLE cliente (
  id_cliente     INT AUTO_INCREMENT,
  nome           VARCHAR(120) NOT NULL,
  cpf_cnpj       VARCHAR(14)  NOT NULL,
  telefone       VARCHAR(20),
  email          VARCHAR(120),
  endereco       VARCHAR(200),
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cliente_cpf_cnpj UNIQUE (cpf_cnpj),
  -- CPF tem 11 digitos, CNPJ tem 14, so numeros
  CONSTRAINT ck_cliente_cpf_cnpj CHECK (cpf_cnpj REGEXP '^([0-9]{11}|[0-9]{14})$')
) ENGINE=InnoDB;

-- RN01, RN03: todo veiculo pertence a um cliente, placa e unica
CREATE TABLE veiculo (
  id_veiculo      INT AUTO_INCREMENT,
  placa           VARCHAR(8)  NOT NULL,
  modelo          VARCHAR(60) NOT NULL,
  marca           VARCHAR(40) NOT NULL,
  ano_fabricacao  INT NOT NULL,
  id_cliente      INT NOT NULL,
  CONSTRAINT pk_veiculo PRIMARY KEY (id_veiculo),
  CONSTRAINT uq_veiculo_placa UNIQUE (placa),
  CONSTRAINT fk_veiculo_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_veiculo_ano CHECK (ano_fabricacao BETWEEN 1950 AND 2100)
) ENGINE=InnoDB;

-- Superclasse da especializacao total e disjunta (RN18, RN19)
-- RN08: mecanico nao pode se autosupervisionar
CREATE TABLE mecanico (
  id_mecanico    INT AUTO_INCREMENT,
  nome           VARCHAR(120) NOT NULL,
  especialidade  VARCHAR(60),
  id_supervisor  INT,
  CONSTRAINT pk_mecanico PRIMARY KEY (id_mecanico),
  CONSTRAINT fk_mecanico_supervisor FOREIGN KEY (id_supervisor)
    REFERENCES mecanico(id_mecanico) ON DELETE SET NULL ON UPDATE CASCADE
  -- RN08 nao pode virar CHECK aqui: o MySQL nao permite CHECK numa coluna
  -- que ja tem acao de FK (ON DELETE SET NULL), nem CHECK que referencie
  -- coluna AUTO_INCREMENT (id_mecanico). A regra e garantida pelo gatilho
  -- trg_mecanico_rn08 (script 05_triggers.sql).
) ENGINE=InnoDB;

-- RN18: mecanico interno tem salario fixo; matricula e chave alternativa
CREATE TABLE mecanico_interno (
  id_mecanico       INT NOT NULL,
  matricula         VARCHAR(20) NOT NULL,
  salario           DECIMAL(10,2) NOT NULL,
  data_contratacao  DATE NOT NULL,
  CONSTRAINT pk_mecanico_interno PRIMARY KEY (id_mecanico),
  CONSTRAINT uq_mecint_matricula UNIQUE (matricula),
  CONSTRAINT fk_mecint_mecanico FOREIGN KEY (id_mecanico)
    REFERENCES mecanico(id_mecanico) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_mecint_salario CHECK (salario > 0)
) ENGINE=InnoDB;

-- RN07: empresa parceira dos terceirizados (entidade propria para manter a 3FN)
CREATE TABLE empresa_parceira (
  id_empresa  INT AUTO_INCREMENT,
  nome        VARCHAR(120) NOT NULL,
  cnpj        VARCHAR(14)  NOT NULL,
  telefone    VARCHAR(20),
  CONSTRAINT pk_empresa_parceira PRIMARY KEY (id_empresa),
  CONSTRAINT uq_empresa_cnpj UNIQUE (cnpj),
  CONSTRAINT ck_empresa_cnpj CHECK (cnpj REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB;

-- RN07, RN19: terceirizado precisa de empresa parceira e recebe por hora
CREATE TABLE mecanico_terceirizado (
  id_mecanico        INT NOT NULL,
  id_empresa         INT NOT NULL,
  valor_hora_padrao  DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_mecanico_terceirizado PRIMARY KEY (id_mecanico),
  CONSTRAINT fk_mecterc_mecanico FOREIGN KEY (id_mecanico)
    REFERENCES mecanico(id_mecanico) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_mecterc_empresa FOREIGN KEY (id_empresa)
    REFERENCES empresa_parceira(id_empresa) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_mecterc_valor_hora CHECK (valor_hora_padrao > 0)
) ENGINE=InnoDB;

CREATE TABLE fornecedor (
  id_fornecedor  INT AUTO_INCREMENT,
  nome           VARCHAR(120) NOT NULL,
  cnpj           VARCHAR(14)  NOT NULL,
  telefone       VARCHAR(20),
  endereco       VARCHAR(200),
  CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
  CONSTRAINT uq_fornecedor_cnpj UNIQUE (cnpj),
  CONSTRAINT ck_fornecedor_cnpj CHECK (cnpj REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB;

-- RN11: toda peca precisa de fornecedor; preco e estoque nunca negativos
CREATE TABLE peca (
  id_peca        INT AUTO_INCREMENT,
  nome           VARCHAR(120) NOT NULL,
  descricao      VARCHAR(200),
  id_fornecedor  INT NOT NULL,
  preco_atual    DECIMAL(10,2) NOT NULL,
  estoque_atual  INT NOT NULL DEFAULT 0,
  CONSTRAINT pk_peca PRIMARY KEY (id_peca),
  CONSTRAINT fk_peca_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES fornecedor(id_fornecedor) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_peca_preco CHECK (preco_atual >= 0),
  -- RN09: o estoque nunca pode ficar negativo (ultima barreira da transacao)
  CONSTRAINT ck_peca_estoque CHECK (estoque_atual >= 0)
) ENGINE=InnoDB;

-- RN04, RN13: OS pertence a um veiculo, entrega nao pode ser antes da abertura
-- RN14, RN15: id_os_garantia aponta para a OS original quando este atendimento
--             e um retorno em garantia (autorrelacionamento opcional)
CREATE TABLE ordem_servico (
  id_os                 INT AUTO_INCREMENT,
  id_veiculo            INT NOT NULL,
  problema_relatado     VARCHAR(300) NOT NULL,
  data_abertura         DATE NOT NULL,
  data_previsao_entrega DATE,
  data_entrega_real     DATE,
  status_atual          VARCHAR(20) NOT NULL DEFAULT 'aberta',
  id_os_garantia        INT,
  CONSTRAINT pk_ordem_servico PRIMARY KEY (id_os),
  CONSTRAINT fk_os_veiculo FOREIGN KEY (id_veiculo)
    REFERENCES veiculo(id_veiculo) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_os_garantia FOREIGN KEY (id_os_garantia)
    REFERENCES ordem_servico(id_os) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_os_datas CHECK (data_entrega_real IS NULL OR data_entrega_real >= data_abertura),
  CONSTRAINT ck_os_previsao CHECK (data_previsao_entrega IS NULL OR data_previsao_entrega >= data_abertura),
  CONSTRAINT ck_os_status CHECK (status_atual IN ('aberta','em execucao','aguardando peca','concluida','entregue'))
  -- Mesmo veiculo e janela de 90 dias da garantia (RN14/RN15) dependem de
  -- outras linhas, entao nao cabem em CHECK: ficam para gatilho/aplicacao.
) ENGINE=InnoDB;

-- RN16: toda mudanca de status fica registrada, com data e hora.
-- Entidade FRACA: um registro de historico so existe dentro da sua OS e e
-- identificado pela OS dona + numero sequencial do evento (chave parcial).
CREATE TABLE status_historico (
  id_os             INT NOT NULL,
  num_sequencia     INT NOT NULL,
  status            VARCHAR(20) NOT NULL,
  data_hora_mudanca DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacao        VARCHAR(200),
  CONSTRAINT pk_status_historico PRIMARY KEY (id_os, num_sequencia),
  CONSTRAINT fk_statushist_os FOREIGN KEY (id_os)
    REFERENCES ordem_servico(id_os) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_statushist_seq CHECK (num_sequencia > 0),
  CONSTRAINT ck_statushist_status CHECK (status IN ('aberta','em execucao','aguardando peca','concluida','entregue'))
) ENGINE=InnoDB;

-- Associativa N:N OS x Peca. RN09, RN10: preco praticado fica travado
CREATE TABLE os_peca (
  id_os                    INT NOT NULL,
  id_peca                  INT NOT NULL,
  quantidade               INT NOT NULL,
  preco_unitario_praticado DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_os_peca PRIMARY KEY (id_os, id_peca),
  CONSTRAINT fk_ospeca_os FOREIGN KEY (id_os)
    REFERENCES ordem_servico(id_os) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ospeca_peca FOREIGN KEY (id_peca)
    REFERENCES peca(id_peca) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_ospeca_quantidade CHECK (quantidade > 0),
  CONSTRAINT ck_ospeca_preco CHECK (preco_unitario_praticado >= 0)
) ENGINE=InnoDB;

-- Associativa N:N OS x Mecanico. RN17: horas nao podem ser zero ou negativas
-- valor_hora_praticado aceita 0: interno nao e pago por OS (RN18) e retorno
-- em garantia nao cobra mao de obra (RN15)
CREATE TABLE os_mecanico (
  id_os                  INT NOT NULL,
  id_mecanico            INT NOT NULL,
  horas_trabalhadas      DECIMAL(5,2) NOT NULL,
  valor_hora_praticado   DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_os_mecanico PRIMARY KEY (id_os, id_mecanico),
  CONSTRAINT fk_osmec_os FOREIGN KEY (id_os)
    REFERENCES ordem_servico(id_os) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_osmec_mecanico FOREIGN KEY (id_mecanico)
    REFERENCES mecanico(id_mecanico) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_osmec_horas CHECK (horas_trabalhadas > 0),
  CONSTRAINT ck_osmec_valor CHECK (valor_hora_praticado >= 0)
) ENGINE=InnoDB;

-- Indices nas chaves estrangeiras (o InnoDB exige indice em FK; criamos
-- com nome padronizado). status_historico nao precisa: id_os ja e o
-- primeiro campo da PK composta.
CREATE INDEX idx_veiculo_cliente   ON veiculo(id_cliente);
CREATE INDEX idx_mecanico_superv   ON mecanico(id_supervisor);
CREATE INDEX idx_mecterc_empresa   ON mecanico_terceirizado(id_empresa);
CREATE INDEX idx_peca_fornecedor   ON peca(id_fornecedor);
CREATE INDEX idx_os_veiculo        ON ordem_servico(id_veiculo);
CREATE INDEX idx_os_garantia       ON ordem_servico(id_os_garantia);
CREATE INDEX idx_ospeca_peca       ON os_peca(id_peca);
CREATE INDEX idx_osmec_mecanico    ON os_mecanico(id_mecanico);
