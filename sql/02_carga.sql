-- ============================================================
-- A7 - Script de carga de dados (DML)
-- Tema: Oficina Mecanica
-- MySQL 8.0+ - dados ficticios, respeitando a ordem de dependencia
-- Inclui casos de contorno propositais (marcados com comentario)
-- ============================================================

-- FORNECEDORES (5)
INSERT INTO fornecedor (nome, cnpj, telefone, endereco) VALUES
('Auto Pecas Silva Ltda', '12345678000101', '61988887777', 'SIA Trecho 3, Brasilia'),
('Distribuidora Mecanica Central', '23456789000112', '61977776666', 'Setor de Industria, Taguatinga'),
('Pecas & Cia', '34567890000123', '61966665555', 'QNM 15, Ceilandia'),
('Fornecedora Nacional de Autopecas', '45678901000134', NULL, 'SCIA Bloco B, Brasilia'), -- caso de contorno: sem telefone
('Import Pecas Brasilia', '56789012000145', '61955554444', 'Setor Industrial, Gama');

-- PECAS (12)
INSERT INTO peca (nome, descricao, id_fornecedor, preco_atual, estoque_atual) VALUES
('Pastilha de freio dianteira', 'Jogo com 4 unidades', 1, 180.00, 40),
('Filtro de oleo', 'Compativel com motores 1.0 a 2.0', 1, 35.00, 60),
('Oleo motor 5W30 sintetico', 'Galao de 4 litros', 2, 120.00, 50),
('Correia dentada', 'Kit com tensor', 2, 210.00, 25),
('Amortecedor dianteiro', 'Unidade', 3, 340.00, 15),
('Bateria 60Ah', 'Garantia de fabrica de 12 meses', 3, 480.00, 10),
('Vela de ignicao', 'Jogo com 4 unidades', 4, 90.00, 70),
('Radiador', 'Aluminio, com garantia', 4, 560.00, 8),
('Disco de freio traseiro', 'Par', 1, 220.00, 20),
('Filtro de ar', NULL, 5, 45.00, 55), -- caso de contorno: sem descricao
('Kit embreagem completo', 'Disco, plato e rolamento', 5, 890.00, 6),
('Lampada farol H4', 'Par', 5, 60.00, 100);

-- CLIENTES (15 nomeados + 30 gerados = 45)
INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco) VALUES
('Joao Pereira Souza', '11122233344', '61991112222', 'joao.souza@email.com', 'QNA 10, Taguatinga'),
('Maria Fernanda Lima', '22233344455', '61992223333', 'maria.lima@email.com', 'SQN 305, Brasilia'),
('Carlos Eduardo Alves', '33344455566', '61993334444', 'carlos.alves@email.com', 'QI 15, Guara'),
('Transportes Rapido Ltda', '44455566000177', '61994445555', 'contato@transrapido.com', 'Setor de Industria, Gama'),
('Ana Paula Ribeiro', '55566677788', NULL, 'ana.ribeiro@email.com', 'QE 24, Guara'), -- caso de contorno: sem telefone
('Pedro Henrique Costa', '66677788899', '61996667777', 'pedro.costa@email.com', 'QNL 08, Taguatinga'),
('Fernanda Oliveira Santos', '77788899900', '61997778888', 'fernanda.santos@email.com', 'SQS 208, Brasilia'),
('Log Express Transportadora', '88899900000188', '61998889999', 'contato@logexpress.com', 'Setor Industrial, Sobradinho'),
('Ricardo Gomes Barbosa', '99900011122', '61999990000', 'ricardo.barbosa@email.com', 'QN 12, Ceilandia'),
('Juliana Cristina Martins', '10101010101', '61911112222', 'juliana.martins@email.com', 'QI 05, Lago Sul'),
('Bruno Almeida Rocha', '20202020202', '61922223333', NULL, 'QNM 22, Ceilandia'), -- caso de contorno: sem email
('Camila Torres Nunes', '30303030303', '61933334444', 'camila.nunes@email.com', 'SQN 112, Brasilia'),
('Rodrigo Nascimento Lima', '40404040404', '61944445555', 'rodrigo.lima@email.com', 'QE 12, Guara'),
('Patricia Souza Diniz', '50505050505', '61955556666', 'patricia.diniz@email.com', 'QNA 22, Taguatinga'),
('Tiago Ferreira Melo', '60606060606', '61966667777', 'tiago.melo@email.com', 'SQS 415, Brasilia');

-- VEICULOS (18 nomeados + 25 gerados = 43)
INSERT INTO veiculo (placa, modelo, marca, ano_fabricacao, id_cliente) VALUES
('ABC1A23', 'Onix', 'Chevrolet', 2020, 1),
('DEF2B34', 'Gol', 'Volkswagen', 2018, 1),
('GHI3C45', 'HB20', 'Hyundai', 2021, 2),
('JKL4D56', 'Corolla', 'Toyota', 2019, 3),
('MNO5E67', 'Sprinter', 'Mercedes-Benz', 2017, 4),
('PQR6F78', 'Sprinter', 'Mercedes-Benz', 2017, 4),
('STU7G89', 'Ka', 'Ford', 2016, 5),
('VWX8H90', 'Civic', 'Honda', 2022, 6),
('YZA9I01', 'Argo', 'Fiat', 2020, 7),
('BCD1J23', 'Daily', 'Iveco', 2015, 8),
('EFG2K34', 'Daily', 'Iveco', 2016, 8),
('HIJ3L45', 'Cronos', 'Fiat', 2021, 9),
('KLM4M56', 'Polo', 'Volkswagen', 2019, 10),
('NOP5N67', 'Kwid', 'Renault', 2020, 11),
('QRS6O78', 'Compass', 'Jeep', 2021, 12),
('TUV7P89', 'Onix', 'Chevrolet', 2018, 13),
('WXY8Q90', 'Uno', 'Fiat', 2014, 14),
('ZAB9R01', 'Fox', 'Volkswagen', 2017, 15);

-- MECANICOS (8: 5 internos, 3 terceirizados)
INSERT INTO mecanico (nome, especialidade, id_supervisor) VALUES
('Sebastiao Rocha', 'Motor', NULL),
('Antonio Carlos Freitas', 'Eletrica', 1),
('Marcos Vinicius Teixeira', 'Funilaria', 1),
('Leandro Souza Pinto', 'Motor', 2),
('Rafael Andrade Costa', 'Suspensao', NULL), -- caso de contorno: sem supervisor
('Diego Martins', 'Eletrica', NULL),
('Wagner Luiz Farias', 'Motor', NULL),
('Vitor Hugo Campos', 'Funilaria', 6);

INSERT INTO mecanico_interno (id_mecanico, matricula, salario, data_contratacao) VALUES
(1, 'MEC001', 4200.00, '2015-03-10'),
(2, 'MEC002', 3200.00, '2018-07-22'),
(3, 'MEC003', 3100.00, '2019-11-05'),
(4, 'MEC004', 2800.00, '2021-02-14'),
(5, 'MEC005', 3500.00, '2017-06-01');

INSERT INTO mecanico_terceirizado (id_mecanico, empresa_parceira, cnpj_empresa, valor_hora_padrao) VALUES
(6, 'Eletrica Prime Servicos', '67890123000156', 45.00),
(7, 'Motores & Reparos ME', '78901234000167', 50.00),
(8, 'Funilaria Express', '89012345000178', 40.00);

-- ORDENS DE SERVICO (22 nomeadas + 25 geradas = 47)
INSERT INTO ordem_servico (id_veiculo, data_abertura, data_previsao_entrega, data_entrega_real, status_atual) VALUES
(1, '2026-06-01', '2026-06-03', '2026-06-03', 'entregue'),
(2, '2026-06-05', '2026-06-07', '2026-06-08', 'entregue'),
(3, '2026-06-10', '2026-06-12', '2026-06-12', 'entregue'),
(4, '2026-06-15', '2026-06-18', '2026-06-17', 'entregue'),
(5, '2026-07-01', '2026-07-04', '2026-07-04', 'entregue'),
(6, '2026-07-03', '2026-07-05', '2026-07-06', 'entregue'),
(7, '2026-07-10', '2026-07-12', NULL, 'aguardando peca'), -- caso de contorno: ainda sem entrega
(8, '2026-07-15', '2026-07-17', '2026-07-17', 'entregue'),
(9, '2026-07-20', '2026-07-22', '2026-07-22', 'entregue'),
(10, '2026-08-01', '2026-08-03', '2026-08-03', 'entregue'),
(11, '2026-08-05', '2026-08-08', NULL, 'em execucao'),
(12, '2026-08-10', '2026-08-12', '2026-08-12', 'entregue'),
(13, '2026-08-15', NULL, NULL, 'aberta'), -- caso de contorno: sem previsao ainda
(14, '2026-08-20', '2026-08-22', '2026-08-22', 'entregue'),
(15, '2026-09-01', '2026-09-04', '2026-09-03', 'entregue'),
(16, '2026-09-05', '2026-09-07', NULL, 'aguardando peca'),
(17, '2026-09-08', '2026-09-10', '2026-09-10', 'entregue'),
(18, '2026-09-10', '2026-09-13', NULL, 'em execucao'),
(1, '2026-09-12', '2026-09-14', '2026-09-14', 'entregue'), -- mesmo veiculo, segunda OS (historico)
(3, '2026-09-15', '2026-09-17', '2026-09-17', 'entregue'),
(5, '2026-09-16', NULL, NULL, 'aberta'),
(9, '2026-09-17', '2026-09-19', NULL, 'em execucao');

-- STATUS_HISTORICO (parte inicial, mais linhas geradas depois)
INSERT INTO status_historico (id_os, status, data_hora_mudanca, observacao) VALUES
(1, 'aberta', '2026-06-01 08:00', NULL),
(1, 'em execucao', '2026-06-01 09:30', NULL),
(1, 'concluida', '2026-06-03 16:00', NULL),
(1, 'entregue', '2026-06-03 17:30', NULL),
(2, 'aberta', '2026-06-05 09:00', NULL),
(2, 'em execucao', '2026-06-05 10:00', NULL),
(2, 'aguardando peca', '2026-06-06 11:00', 'Aguardando correia dentada'),
(2, 'em execucao', '2026-06-07 09:00', NULL),
(2, 'concluida', '2026-06-08 15:00', NULL),
(2, 'entregue', '2026-06-08 16:00', NULL),
(3, 'aberta', '2026-06-10 08:30', NULL),
(3, 'em execucao', '2026-06-10 10:00', NULL),
(3, 'concluida', '2026-06-12 14:00', NULL),
(3, 'entregue', '2026-06-12 15:00', NULL),
(4, 'aberta', '2026-06-15 08:00', NULL),
(4, 'em execucao', '2026-06-15 09:00', NULL),
(4, 'concluida', '2026-06-17 13:00', NULL),
(4, 'entregue', '2026-06-17 14:00', NULL),
(5, 'aberta', '2026-07-01 08:00', NULL),
(5, 'em execucao', '2026-07-01 09:00', NULL),
(5, 'concluida', '2026-07-04 12:00', NULL),
(5, 'entregue', '2026-07-04 13:00', NULL),
(6, 'aberta', '2026-07-03 08:00', NULL),
(6, 'em execucao', '2026-07-04 09:00', NULL),
(6, 'concluida', '2026-07-06 10:00', NULL),
(6, 'entregue', '2026-07-06 11:00', NULL),
(7, 'aberta', '2026-07-10 08:00', NULL),
(7, 'em execucao', '2026-07-10 09:00', NULL),
(7, 'aguardando peca', '2026-07-11 10:00', 'Aguardando radiador do fornecedor'),
(8, 'aberta', '2026-07-15 08:00', NULL),
(8, 'em execucao', '2026-07-15 09:00', NULL),
(8, 'concluida', '2026-07-17 11:00', NULL),
(8, 'entregue', '2026-07-17 12:00', NULL),
(9, 'aberta', '2026-07-20 08:00', NULL),
(9, 'em execucao', '2026-07-20 09:00', NULL),
(9, 'concluida', '2026-07-22 10:00', NULL),
(9, 'entregue', '2026-07-22 11:00', NULL),
(10, 'aberta', '2026-08-01 08:00', NULL),
(10, 'em execucao', '2026-08-01 09:00', NULL),
(10, 'concluida', '2026-08-03 10:00', NULL),
(10, 'entregue', '2026-08-03 11:00', NULL),
(11, 'aberta', '2026-08-05 08:00', NULL),
(11, 'em execucao', '2026-08-06 09:00', NULL),
(13, 'aberta', '2026-08-15 08:00', NULL);

-- OS_PECA (parte inicial, mais linhas geradas depois)
INSERT INTO os_peca (id_os, id_peca, quantidade, preco_unitario_praticado) VALUES
(1, 1, 1, 180.00),
(1, 2, 1, 35.00),
(2, 4, 1, 210.00),
(2, 3, 1, 120.00),
(3, 2, 1, 35.00),
(3, 7, 1, 90.00),
(4, 5, 2, 340.00),
(5, 6, 1, 480.00),
(6, 1, 1, 180.00),
(6, 9, 1, 220.00),
(7, 8, 1, 560.00),
(8, 3, 1, 120.00),
(8, 2, 1, 35.00),
(9, 12, 1, 60.00),
(10, 7, 1, 90.00),
(10, 10, 1, 45.00),
(11, 11, 1, 890.00),
(12, 1, 1, 180.00),
(14, 3, 1, 120.00),
(14, 2, 1, 35.00),
(15, 9, 2, 220.00),
(16, 8, 1, 560.00),
(17, 5, 1, 340.00),
(18, 4, 1, 210.00),
(19, 2, 1, 35.00),
(19, 12, 2, 60.00),
(20, 1, 1, 180.00),
(20, 9, 1, 220.00),
(21, 6, 1, 480.00),
(22, 3, 1, 120.00),
(22, 10, 1, 45.00),
(1, 12, 1, 60.00),
(2, 12, 1, 60.00),
(3, 10, 1, 45.00),
(4, 10, 1, 45.00),
(5, 2, 1, 35.00),
(6, 3, 1, 120.00),
(8, 10, 1, 45.00),
(9, 2, 1, 35.00),
(10, 12, 1, 60.00),
(12, 2, 1, 35.00),
(14, 12, 1, 60.00),
(15, 2, 1, 35.00);

-- OS_MECANICO (parte inicial, mais linhas geradas depois)
INSERT INTO os_mecanico (id_os, id_mecanico, horas_trabalhadas, valor_hora_praticado) VALUES
(1, 1, 3.0, 0.00),
(1, 2, 1.5, 0.00),
(2, 4, 4.0, 0.00),
(2, 6, 2.0, 45.00),
(3, 2, 2.0, 0.00),
(4, 3, 5.0, 0.00),
(5, 5, 3.5, 0.00),
(6, 1, 2.5, 0.00),
(7, 7, 3.0, 50.00),
(8, 4, 2.0, 0.00),
(9, 8, 1.5, 40.00),
(10, 2, 3.0, 0.00),
(11, 6, 4.0, 45.00),
(12, 1, 2.0, 0.00),
(13, 5, 1.0, 0.00),
(14, 3, 3.5, 0.00),
(15, 4, 2.5, 0.00),
(16, 7, 2.0, 50.00),
(17, 5, 3.0, 0.00),
(18, 6, 2.5, 45.00),
(19, 1, 2.0, 0.00),
(19, 8, 1.0, 40.00),
(20, 2, 3.0, 0.00),
(21, 5, 4.0, 0.00),
(22, 7, 2.0, 50.00),
(1, 6, 1.0, 45.00),
(2, 3, 2.0, 0.00),
(3, 7, 1.5, 50.00),
(4, 8, 2.0, 40.00),
(5, 1, 1.0, 0.00),
(6, 4, 2.0, 0.00),
(8, 6, 1.5, 45.00),
(9, 3, 2.0, 0.00),
(10, 8, 1.0, 40.00),
(12, 5, 2.0, 0.00),
(14, 7, 1.5, 50.00),
(15, 1, 2.0, 0.00),
(16, 2, 1.5, 0.00),
(17, 8, 2.0, 40.00),
(18, 3, 1.0, 0.00),
(20, 6, 2.0, 45.00),
(21, 4, 1.5, 0.00);

-- ============================================================
-- EXPANSAO DE VOLUME (numeros gerados via CTE recursiva, recurso do MySQL 8)
-- Minimo de 40 linhas nas tabelas principais e 100 na de maior movimento.
-- "Tabelas principais": cliente, veiculo, peca, ordem_servico.
-- "Tabela de maior movimento": os_peca.
-- Fornecedor e mecanico ficaram menores de proposito (equipe fixa,
-- poucos fornecedores, nao faz sentido inflar artificialmente).
-- ============================================================

-- numeros de 1 a 30, reaproveitados nos blocos abaixo
INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco)
WITH RECURSIVE seq30 AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq30 WHERE i < 30
)
SELECT
  CONCAT('Cliente Cadastro ', i),
  LPAD(70000000000 + i, 11, '0'),
  CONCAT('619', LPAD(90000000 + i, 8, '0')),
  CONCAT('cliente', i, '@email.com'),
  CONCAT('Endereco ', i, ', Brasilia')
FROM seq30;

INSERT INTO veiculo (placa, modelo, marca, ano_fabricacao, id_cliente)
WITH RECURSIVE seq25 AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25 WHERE i < 25
)
SELECT
  CONCAT('FIC', MOD(i, 10), CHAR(65 + MOD(i, 26)), LPAD(i, 2, '0')),
  ELT(1 + MOD(i, 10), 'Onix','Gol','HB20','Corolla','Ka','Civic','Argo','Cronos','Polo','Kwid'),
  ELT(1 + MOD(i, 8), 'Chevrolet','Volkswagen','Hyundai','Toyota','Ford','Honda','Fiat','Renault'),
  2012 + MOD(i, 12),
  1 + MOD(i * 3, 45)
FROM seq25;

INSERT INTO peca (nome, descricao, id_fornecedor, preco_atual, estoque_atual)
WITH RECURSIVE seq30b AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq30b WHERE i < 30
)
SELECT
  CONCAT('Peca de Reposicao ', i),
  'Peca variada de estoque',
  1 + MOD(i, 5),
  50.00 + (i * 3.5),
  20 + MOD(i, 30)
FROM seq30b;

INSERT INTO ordem_servico (id_veiculo, data_abertura, data_previsao_entrega, data_entrega_real, status_atual)
WITH RECURSIVE seq25b AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25b WHERE i < 25
)
SELECT
  1 + MOD(i * 5, 43),
  DATE_ADD('2026-05-01', INTERVAL (i * 3) DAY),
  DATE_ADD('2026-05-01', INTERVAL (i * 3 + 3) DAY),
  CASE WHEN MOD(i, 5) = 0 THEN NULL ELSE DATE_ADD('2026-05-01', INTERVAL (i * 3 + 3) DAY) END,
  CASE WHEN MOD(i, 5) = 0 THEN 'em execucao' ELSE 'entregue' END
FROM seq25b;

-- +75 itens de peca nas novas OS (23 a 47): total os_peca = 44 + 75 = 119, tabela de maior movimento
INSERT INTO os_peca (id_os, id_peca, quantidade, preco_unitario_praticado)
WITH RECURSIVE seq25c AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25c WHERE i < 25
),
k3 AS (SELECT 0 AS k UNION ALL SELECT 1 UNION ALL SELECT 2)
SELECT
  22 + s.i,
  1 + MOD(s.i * 7 + k3.k, 42),
  1 + MOD(k3.k, 3),
  (SELECT preco_atual FROM peca p WHERE p.id_peca = 1 + MOD(s.i * 7 + k3.k, 42))
FROM seq25c s CROSS JOIN k3;

-- +25 registros de mao de obra nas novas OS
INSERT INTO os_mecanico (id_os, id_mecanico, horas_trabalhadas, valor_hora_praticado)
WITH RECURSIVE seq25d AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25d WHERE i < 25
)
SELECT
  22 + i,
  1 + MOD(i, 8),
  1.0 + MOD(i, 5),
  CASE WHEN (1 + MOD(i, 8)) IN (6, 7, 8) THEN 45.00 ELSE 0.00 END
FROM seq25d;

-- +25 registros de historico de status nas novas OS
INSERT INTO status_historico (id_os, status, data_hora_mudanca, observacao)
WITH RECURSIVE seq25e AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25e WHERE i < 25
)
SELECT
  22 + i,
  'aberta',
  DATE_ADD('2026-05-01', INTERVAL (i * 3) DAY),
  NULL
FROM seq25e;
