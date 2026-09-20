-- ============================================================
-- A6 - Script de criacao do banco (DDL)
-- Tema: Oficina Mecanica
-- MySQL 8.0+, testado do zero em base limpa
-- ============================================================

-- RN01, RN02: cliente e a base de tudo, cpf_cnpj nao pode repetir
CREATE TABLE cliente (
  id_cliente     INT AUTO_INCREMENT PRIMARY KEY,
  nome           VARCHAR(120) NOT NULL,
  cpf_cnpj       VARCHAR(14)  NOT NULL,
  telefone       VARCHAR(20),
  email          VARCHAR(120),
  endereco       VARCHAR(200),
  CONSTRAINT uq_cliente_cpf_cnpj UNIQUE (cpf_cnpj)
) ENGINE=InnoDB;

-- RN01, RN03: todo veiculo pertence a um cliente, placa e unica
CREATE TABLE veiculo (
  id_veiculo      INT AUTO_INCREMENT PRIMARY KEY,
  placa           VARCHAR(8) NOT NULL,
  modelo          VARCHAR(60) NOT NULL,
  marca           VARCHAR(40) NOT NULL,
  ano_fabricacao  INT NOT NULL,
  id_cliente      INT NOT NULL,
  CONSTRAINT uq_veiculo_placa UNIQUE (placa),
  CONSTRAINT fk_veiculo_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- RN08: mecanico nao pode se autosupervisionar
CREATE TABLE mecanico (
  id_mecanico    INT AUTO_INCREMENT PRIMARY KEY,
  nome           VARCHAR(120) NOT NULL,
  especialidade  VARCHAR(60),
  id_supervisor  INT,
  CONSTRAINT fk_mecanico_supervisor FOREIGN KEY (id_supervisor)
    REFERENCES mecanico(id_mecanico) ON DELETE SET NULL ON UPDATE CASCADE
  -- RN08 (mecanico nao pode se autosupervisionar) nao pode virar CHECK aqui:
  -- o MySQL nao permite CHECK numa coluna que ja tem acao de FK (ON DELETE SET NULL).
  -- Essa regra fica garantida por um trigger BEFORE INSERT/UPDATE (ver Etapa 2)
  -- e, por enquanto, pela aplicacao/validacao manual na carga de dados.
) ENGINE=InnoDB;

-- RN18: mecanico interno tem salario fixo
CREATE TABLE mecanico_interno (
  id_mecanico       INT PRIMARY KEY,
  matricula         VARCHAR(20) NOT NULL,
  salario           DECIMAL(10,2) NOT NULL,
  data_contratacao  DATE NOT NULL,
  CONSTRAINT fk_mecint_mecanico FOREIGN KEY (id_mecanico)
    REFERENCES mecanico(id_mecanico) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- RN07: mecanico terceirizado precisa de empresa parceira
CREATE TABLE mecanico_terceirizado (
  id_mecanico        INT PRIMARY KEY,
  empresa_parceira   VARCHAR(120) NOT NULL,
  cnpj_empresa       VARCHAR(14) NOT NULL,
  valor_hora_padrao  DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_mecterc_mecanico FOREIGN KEY (id_mecanico)
    REFERENCES mecanico(id_mecanico) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE fornecedor (
  id_fornecedor  INT AUTO_INCREMENT PRIMARY KEY,
  nome           VARCHAR(120) NOT NULL,
  cnpj           VARCHAR(14) NOT NULL,
  telefone       VARCHAR(20),
  endereco       VARCHAR(200),
  CONSTRAINT uq_fornecedor_cnpj UNIQUE (cnpj)
) ENGINE=InnoDB;

-- RN11: toda peca precisa de fornecedor
CREATE TABLE peca (
  id_peca        INT AUTO_INCREMENT PRIMARY KEY,
  nome           VARCHAR(120) NOT NULL,
  descricao      VARCHAR(200),
  id_fornecedor  INT NOT NULL,
  preco_atual    DECIMAL(10,2) NOT NULL,
  estoque_atual  INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_peca_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES fornecedor(id_fornecedor) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- RN04, RN13: OS pertence a um veiculo, data de entrega nao pode ser antes da abertura
CREATE TABLE ordem_servico (
  id_os                 INT AUTO_INCREMENT PRIMARY KEY,
  id_veiculo            INT NOT NULL,
  data_abertura         DATE NOT NULL,
  data_previsao_entrega DATE,
  data_entrega_real     DATE,
  status_atual          VARCHAR(20) NOT NULL DEFAULT 'aberta',
  CONSTRAINT fk_os_veiculo FOREIGN KEY (id_veiculo)
    REFERENCES veiculo(id_veiculo) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_os_datas CHECK (data_entrega_real IS NULL OR data_entrega_real >= data_abertura),
  CONSTRAINT ck_os_status CHECK (status_atual IN ('aberta','em execucao','aguardando peca','concluida','entregue'))
) ENGINE=InnoDB;

-- RN16: toda mudanca de status fica registrada aqui, com data e hora
CREATE TABLE status_historico (
  id_status_hist    INT AUTO_INCREMENT PRIMARY KEY,
  id_os             INT NOT NULL,
  status            VARCHAR(20) NOT NULL,
  data_hora_mudanca DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacao        VARCHAR(200),
  CONSTRAINT fk_statushist_os FOREIGN KEY (id_os)
    REFERENCES ordem_servico(id_os) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- RN09, RN10: entidade fraca, preco praticado nao muda depois
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
  CONSTRAINT ck_ospeca_quantidade CHECK (quantidade > 0)
) ENGINE=InnoDB;

-- RN17: horas trabalhadas nao podem ser zero ou negativas
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
  CONSTRAINT ck_osmec_horas CHECK (horas_trabalhadas > 0)
) ENGINE=InnoDB;

CREATE INDEX idx_veiculo_cliente ON veiculo(id_cliente);
CREATE INDEX idx_os_veiculo ON ordem_servico(id_veiculo);
CREATE INDEX idx_peca_fornecedor ON peca(id_fornecedor);
CREATE INDEX idx_statushist_os ON status_historico(id_os);
CREATE INDEX idx_ospeca_peca ON os_peca(id_peca);
CREATE INDEX idx_osmec_mecanico ON os_mecanico(id_mecanico);
