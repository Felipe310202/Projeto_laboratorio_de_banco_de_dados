-- ============================================================
-- A7 - Script de carga de dados (DML)
-- Tema: Oficina Mecanica
-- MySQL 8.0+ - dados ficticios, respeitando a ordem de dependencia
-- Inclui casos de contorno propositais (marcados com comentario)
--
-- Revisao (Etapa 2): mais fornecedores (12) e mecanicos (18, com
-- hierarquia de supervisao em varios niveis), empresas parceiras como
-- entidade propria, problema relatado e retornos em garantia nas OS,
-- e historico de status completo e coerente com o status atual de
-- todas as OS (entidade fraca com num_sequencia).
-- ============================================================

USE oficina_mecanica;

-- FORNECEDORES (12)
INSERT INTO fornecedor (nome, cnpj, telefone, endereco) VALUES
('Auto Pecas Silva Ltda', '12345678000101', '61988887777', 'SIA Trecho 3, Brasilia'),
('Distribuidora Mecanica Central', '23456789000112', '61977776666', 'Setor de Industria, Taguatinga'),
('Pecas & Cia', '34567890000123', '61966665555', 'QNM 15, Ceilandia'),
('Fornecedora Nacional de Autopecas', '45678901000134', NULL, 'SCIA Bloco B, Brasilia'), -- caso de contorno: sem telefone
('Import Pecas Brasilia', '56789012000145', '61955554444', 'Setor Industrial, Gama'),
('Rolamentos Planalto Ltda', '67812345000190', '61944443333', 'SIA Trecho 17, Brasilia'),
('Freios e Suspensao Centro-Oeste', '78923456000101', '61933332222', 'Setor de Oficinas Norte, Taguatinga'),
('Eletro Auto Pecas Brasilia', '89034567000112', '61922221111', 'QI 22, Guara'),
('Lubrificantes Cerrado Ltda', '90145678000123', '61911110000', 'Setor Industrial, Ceilandia'),
('Baterias Capital Distribuidora', '01256789000134', '61900009999', 'SOF Sul Quadra 9, Brasilia'),
('Vidros e Lanternas DF', '12367890000145', '61988880000', NULL), -- caso de contorno: sem endereco
('Pneus Asa Sul Comercio', '23478901000156', '61977770000', 'SCLS 410, Brasilia');

-- PECAS (12 nomeadas + 30 geradas = 42)
INSERT INTO peca (nome, descricao, id_fornecedor, preco_atual, estoque_atual) VALUES
('Pastilha de freio dianteira', 'Jogo com 4 unidades', 7, 180.00, 40),
('Filtro de oleo', 'Compativel com motores 1.0 a 2.0', 1, 35.00, 60),
('Oleo motor 5W30 sintetico', 'Galao de 4 litros', 9, 120.00, 50),
('Correia dentada', 'Kit com tensor', 2, 210.00, 25),
('Amortecedor dianteiro', 'Unidade', 7, 340.00, 15),
('Bateria 60Ah', 'Garantia de fabrica de 12 meses', 10, 480.00, 10),
('Vela de ignicao', 'Jogo com 4 unidades', 4, 90.00, 70),
('Radiador', 'Aluminio, com garantia', 4, 560.00, 8),
('Disco de freio traseiro', 'Par', 7, 220.00, 20),
('Filtro de ar', NULL, 5, 45.00, 55), -- caso de contorno: sem descricao
('Kit embreagem completo', 'Disco, plato e rolamento', 6, 890.00, 6),
('Lampada farol H4', 'Par', 11, 60.00, 100);

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

-- MECANICOS (18: 11 internos, 7 terceirizados)
-- Hierarquia de supervisao em ate 4 niveis: 1 -> 2 -> 4 -> 11
INSERT INTO mecanico (nome, especialidade, id_supervisor) VALUES
('Sebastiao Rocha', 'Motor', NULL),               -- 1  interno, chefe da oficina
('Antonio Carlos Freitas', 'Eletrica', 1),        -- 2  interno
('Marcos Vinicius Teixeira', 'Funilaria', 1),     -- 3  interno
('Leandro Souza Pinto', 'Motor', 2),              -- 4  interno
('Rafael Andrade Costa', 'Suspensao', NULL),      -- 5  interno - caso de contorno: sem supervisor
('Diego Martins', 'Eletrica', NULL),              -- 6  terceirizado - caso de contorno: sem supervisor
('Wagner Luiz Farias', 'Motor', 1),               -- 7  terceirizado
('Vitor Hugo Campos', 'Funilaria', 3),            -- 8  terceirizado
('Jose Ricardo Moura', 'Freios', 1),              -- 9  interno
('Paulo Sergio Nunes', 'Injecao eletronica', 2),  -- 10 interno
('Henrique Lopes Batista', 'Motor', 4),           -- 11 interno (quarto nivel da hierarquia)
('Mateus Oliveira Prado', 'Suspensao', 5),        -- 12 interno
('Lucas Fernandes Rezende', 'Ar-condicionado', 2),-- 13 interno
('Gustavo Araujo Lima', 'Freios', 9),             -- 14 interno
('Renato Silva Queiroz', 'Eletrica', 2),          -- 15 terceirizado
('Fabio Mendes Correia', 'Motor', 1),             -- 16 terceirizado
('Caio Pereira Dantas', 'Motor', 4),              -- 17 terceirizado
('Igor Batista Rocha', 'Suspensao', 5);           -- 18 terceirizado

INSERT INTO mecanico_interno (id_mecanico, matricula, salario, data_contratacao) VALUES
(1,  'MEC001', 4200.00, '2015-03-10'),
(2,  'MEC002', 3200.00, '2018-07-22'),
(3,  'MEC003', 3100.00, '2019-11-05'),
(4,  'MEC004', 2800.00, '2021-02-14'),
(5,  'MEC005', 3500.00, '2017-06-01'),
(9,  'MEC006', 3300.00, '2018-01-15'),
(10, 'MEC007', 3400.00, '2020-09-01'),
(11, 'MEC008', 2400.00, '2024-03-04'),
(12, 'MEC009', 2600.00, '2023-05-20'),
(13, 'MEC010', 2900.00, '2022-08-10'),
(14, 'MEC011', 2500.00, '2025-02-03');

-- EMPRESAS PARCEIRAS (4) - a empresa 2 tem tres terceirizados
INSERT INTO empresa_parceira (nome, cnpj, telefone) VALUES
('Eletrica Prime Servicos', '67890123000156', '61931112222'),
('Motores & Reparos ME', '78901234000167', '61932223333'),
('Funilaria Express', '89012345000178', NULL), -- caso de contorno: sem telefone
('Suspensao Total Servicos Ltda', '90123456000189', '61934445555');

-- valor_hora_padrao e o valor atual negociado com cada terceirizado
INSERT INTO mecanico_terceirizado (id_mecanico, id_empresa, valor_hora_padrao) VALUES
(6,  1, 45.00),
(7,  2, 50.00),
(8,  3, 40.00),
(15, 1, 45.00),
(16, 2, 55.00),
(17, 2, 50.00),
(18, 4, 48.00);

-- ORDENS DE SERVICO (22 nomeadas + 25 geradas = 47)
-- id_os_garantia preenchido = retorno em garantia (RN14: ate 90 dias da entrega real)
INSERT INTO ordem_servico (id_veiculo, problema_relatado, data_abertura, data_previsao_entrega, data_entrega_real, status_atual, id_os_garantia) VALUES
(1,  'Barulho ao frear e revisao de 40 mil km', '2026-06-01', '2026-06-03', '2026-06-03', 'entregue', NULL),
(2,  'Troca preventiva da correia dentada', '2026-06-05', '2026-06-07', '2026-06-08', 'entregue', NULL),
(3,  'Motor falhando em marcha lenta', '2026-06-10', '2026-06-12', '2026-06-12', 'entregue', NULL),
(4,  'Barulho na suspensao dianteira', '2026-06-15', '2026-06-18', '2026-06-17', 'entregue', NULL),
(5,  'Veiculo nao da partida pela manha', '2026-07-01', '2026-07-04', '2026-07-04', 'entregue', NULL),
(6,  'Freio traseiro rangendo', '2026-07-03', '2026-07-05', '2026-07-06', 'entregue', NULL),
(7,  'Superaquecimento do motor', '2026-07-10', '2026-07-12', NULL, 'aguardando peca', NULL), -- caso de contorno: ainda sem entrega
(8,  'Revisao de 20 mil km', '2026-07-15', '2026-07-17', '2026-07-17', 'entregue', NULL),
(9,  'Farol dianteiro apagando sozinho', '2026-07-20', '2026-07-22', '2026-07-22', 'entregue', NULL),
(10, 'Perda de potencia em subida', '2026-08-01', '2026-08-03', '2026-08-03', 'entregue', NULL),
(11, 'Embreagem patinando', '2026-08-05', '2026-08-08', NULL, 'em execucao', NULL),
(12, 'Pedal de freio baixo', '2026-08-10', '2026-08-12', '2026-08-12', 'entregue', NULL),
(13, 'Luz de injecao acesa no painel', '2026-08-15', NULL, NULL, 'aberta', NULL), -- caso de contorno: sem previsao ainda
(14, 'Revisao de 10 mil km', '2026-08-20', '2026-08-22', '2026-08-22', 'entregue', NULL),
(15, 'Vibracao no volante ao frear', '2026-09-01', '2026-09-04', '2026-09-03', 'entregue', NULL),
(16, 'Vazamento de agua no radiador', '2026-09-05', '2026-09-07', NULL, 'aguardando peca', NULL),
(17, 'Amortecedor traseiro vazando', '2026-09-08', '2026-09-10', '2026-09-10', 'entregue', NULL),
(18, 'Ruido na correia do motor', '2026-09-10', '2026-09-13', NULL, 'em execucao', NULL),
(1,  'Troca de oleo e lampadas queimadas', '2026-09-12', '2026-09-14', '2026-09-14', 'entregue', NULL), -- mesmo veiculo da OS 1, outro problema (historico)
(3,  'Barulho ao frear', '2026-09-15', '2026-09-17', '2026-09-17', 'entregue', NULL), -- mesmo veiculo da OS 3, fora da garantia
(5,  'Veiculo nao da partida pela manha (retorno)', '2026-09-16', NULL, NULL, 'aberta', 5), -- caso de contorno: garantia da OS 5 (74 dias)
(9,  'Farol dianteiro apagando sozinho (retorno)', '2026-09-17', '2026-09-19', NULL, 'em execucao', 9); -- caso de contorno: garantia da OS 9 (57 dias)

-- STATUS_HISTORICO das OS nomeadas (entidade fraca: id_os + num_sequencia)
-- O historico das OS geradas e montado no fim do script.
INSERT INTO status_historico (id_os, num_sequencia, status, data_hora_mudanca, observacao) VALUES
(1, 1, 'aberta', '2026-06-01 08:00', NULL),
(1, 2, 'em execucao', '2026-06-01 09:30', NULL),
(1, 3, 'concluida', '2026-06-03 16:00', NULL),
(1, 4, 'entregue', '2026-06-03 17:30', NULL),
(2, 1, 'aberta', '2026-06-05 09:00', NULL),
(2, 2, 'em execucao', '2026-06-05 10:00', NULL),
(2, 3, 'aguardando peca', '2026-06-06 11:00', 'Aguardando correia dentada'),
(2, 4, 'em execucao', '2026-06-07 09:00', NULL),
(2, 5, 'concluida', '2026-06-08 15:00', NULL),
(2, 6, 'entregue', '2026-06-08 16:00', NULL),
(3, 1, 'aberta', '2026-06-10 08:30', NULL),
(3, 2, 'em execucao', '2026-06-10 10:00', NULL),
(3, 3, 'concluida', '2026-06-12 14:00', NULL),
(3, 4, 'entregue', '2026-06-12 15:00', NULL),
(4, 1, 'aberta', '2026-06-15 08:00', NULL),
(4, 2, 'em execucao', '2026-06-15 09:00', NULL),
(4, 3, 'concluida', '2026-06-17 13:00', NULL),
(4, 4, 'entregue', '2026-06-17 14:00', NULL),
(5, 1, 'aberta', '2026-07-01 08:00', NULL),
(5, 2, 'em execucao', '2026-07-01 09:00', NULL),
(5, 3, 'concluida', '2026-07-04 12:00', NULL),
(5, 4, 'entregue', '2026-07-04 13:00', NULL),
(6, 1, 'aberta', '2026-07-03 08:00', NULL),
(6, 2, 'em execucao', '2026-07-04 09:00', NULL),
(6, 3, 'concluida', '2026-07-06 10:00', NULL),
(6, 4, 'entregue', '2026-07-06 11:00', NULL),
(7, 1, 'aberta', '2026-07-10 08:00', NULL),
(7, 2, 'em execucao', '2026-07-10 09:00', NULL),
(7, 3, 'aguardando peca', '2026-07-11 10:00', 'Aguardando radiador do fornecedor'),
(8, 1, 'aberta', '2026-07-15 08:00', NULL),
(8, 2, 'em execucao', '2026-07-15 09:00', NULL),
(8, 3, 'concluida', '2026-07-17 11:00', NULL),
(8, 4, 'entregue', '2026-07-17 12:00', NULL),
(9, 1, 'aberta', '2026-07-20 08:00', NULL),
(9, 2, 'em execucao', '2026-07-20 09:00', NULL),
(9, 3, 'concluida', '2026-07-22 10:00', NULL),
(9, 4, 'entregue', '2026-07-22 11:00', NULL),
-- caso de contorno (RN05): status voltou para tras, com justificativa registrada
(10, 1, 'aberta', '2026-08-01 08:00', NULL),
(10, 2, 'em execucao', '2026-08-01 09:00', NULL),
(10, 3, 'concluida', '2026-08-02 17:00', NULL),
(10, 4, 'em execucao', '2026-08-03 08:00', 'Reaberta: no teste final o motor ainda perdia potencia'),
(10, 5, 'concluida', '2026-08-03 10:00', NULL),
(10, 6, 'entregue', '2026-08-03 11:00', NULL),
(11, 1, 'aberta', '2026-08-05 08:00', NULL),
(11, 2, 'em execucao', '2026-08-06 09:00', NULL),
(12, 1, 'aberta', '2026-08-10 08:00', NULL),
(12, 2, 'em execucao', '2026-08-10 10:00', NULL),
(12, 3, 'concluida', '2026-08-12 14:00', NULL),
(12, 4, 'entregue', '2026-08-12 16:30', NULL),
(13, 1, 'aberta', '2026-08-15 08:00', NULL),
(14, 1, 'aberta', '2026-08-20 08:30', NULL),
(14, 2, 'em execucao', '2026-08-20 09:30', NULL),
(14, 3, 'concluida', '2026-08-22 11:00', NULL),
(14, 4, 'entregue', '2026-08-22 15:00', NULL),
(15, 1, 'aberta', '2026-09-01 08:00', NULL),
(15, 2, 'em execucao', '2026-09-01 10:00', NULL),
(15, 3, 'aguardando peca', '2026-09-01 15:00', 'Aguardando disco de freio'),
(15, 4, 'em execucao', '2026-09-02 09:00', NULL),
(15, 5, 'concluida', '2026-09-03 12:00', NULL),
(15, 6, 'entregue', '2026-09-03 17:00', NULL),
(16, 1, 'aberta', '2026-09-05 08:00', NULL),
(16, 2, 'em execucao', '2026-09-05 09:30', NULL),
(16, 3, 'aguardando peca', '2026-09-06 10:00', 'Radiador em falta no fornecedor'),
(17, 1, 'aberta', '2026-09-08 08:00', NULL),
(17, 2, 'em execucao', '2026-09-08 11:00', NULL),
(17, 3, 'concluida', '2026-09-10 10:00', NULL),
(17, 4, 'entregue', '2026-09-10 16:00', NULL),
(18, 1, 'aberta', '2026-09-10 08:00', NULL),
(18, 2, 'em execucao', '2026-09-11 08:30', NULL),
(19, 1, 'aberta', '2026-09-12 08:00', NULL),
(19, 2, 'em execucao', '2026-09-12 09:00', NULL),
(19, 3, 'concluida', '2026-09-14 10:00', NULL),
(19, 4, 'entregue', '2026-09-14 14:00', NULL),
(20, 1, 'aberta', '2026-09-15 08:00', NULL),
(20, 2, 'em execucao', '2026-09-15 10:00', NULL),
(20, 3, 'concluida', '2026-09-17 11:00', NULL),
(20, 4, 'entregue', '2026-09-17 15:00', NULL),
(21, 1, 'aberta', '2026-09-16 09:00', 'Retorno em garantia da OS 5'),
(22, 1, 'aberta', '2026-09-17 08:00', 'Retorno em garantia da OS 9'),
(22, 2, 'em execucao', '2026-09-17 10:00', NULL);

-- OS_PECA (parte inicial, mais linhas geradas depois)
-- preco_unitario_praticado = preco da peca no momento do uso (RN10)
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
(22, 12, 1, 60.00),
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
-- Interno: valor_hora_praticado = 0, pois recebe salario fixo (RN18)
-- Terceirizado: valor/hora vigente na data da OS (RN19)
INSERT INTO os_mecanico (id_os, id_mecanico, horas_trabalhadas, valor_hora_praticado) VALUES
(1, 1, 3.0, 0.00),
(1, 2, 1.5, 0.00),
(2, 4, 4.0, 0.00),
(2, 6, 2.0, 42.00), -- caso de contorno: valor antigo do terceirizado, antes do reajuste para 45 (RN10/RN19)
(3, 10, 2.0, 0.00),
(4, 12, 5.0, 0.00),
(5, 5, 3.5, 0.00),
(6, 9, 2.5, 0.00),
(7, 7, 3.0, 50.00),
(8, 4, 2.0, 0.00),
(9, 15, 1.5, 45.00),
(10, 11, 3.0, 0.00),
(11, 16, 4.0, 55.00),
(12, 14, 2.0, 0.00),
(13, 10, 1.0, 0.00),
(14, 3, 3.5, 0.00),
(15, 9, 2.5, 0.00),
(16, 17, 2.0, 50.00),
(17, 18, 3.0, 48.00),
(18, 7, 2.5, 50.00),
(19, 1, 2.0, 0.00),
(19, 8, 1.0, 40.00),
(20, 14, 3.0, 0.00),
(21, 2, 4.0, 0.00),
(22, 15, 2.0, 0.00), -- caso de contorno: retorno em garantia, mao de obra nao cobrada (RN15)
(1, 6, 1.0, 45.00),
(2, 3, 2.0, 0.00),
(3, 7, 1.5, 50.00),
(4, 18, 2.0, 48.00),
(5, 13, 1.0, 0.00),
(6, 4, 2.0, 0.00),
(8, 6, 1.5, 45.00),
(9, 2, 2.0, 0.00),
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
-- Fornecedor, empresa parceira e mecanico nao foram inflados
-- artificialmente: sao cadastros pequenos por natureza numa oficina.
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
  1 + MOD(i, 12),
  50.00 + (i * 3.5),
  20 + MOD(i, 30)
FROM seq30b;

INSERT INTO ordem_servico (id_veiculo, problema_relatado, data_abertura, data_previsao_entrega, data_entrega_real, status_atual, id_os_garantia)
WITH RECURSIVE seq25b AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25b WHERE i < 25
)
SELECT
  1 + MOD(i * 5, 43),
  ELT(1 + MOD(i, 8), 'Revisao periodica', 'Troca de oleo e filtros', 'Barulho na suspensao',
      'Freio fazendo ruido', 'Falha na partida', 'Ar-condicionado sem gelar',
      'Luz de injecao acesa', 'Alinhamento e balanceamento'),
  DATE_ADD('2026-05-01', INTERVAL (i * 3) DAY),
  DATE_ADD('2026-05-01', INTERVAL (i * 3 + 3) DAY),
  CASE WHEN MOD(i, 5) = 0 THEN NULL ELSE DATE_ADD('2026-05-01', INTERVAL (i * 3 + 3) DAY) END,
  CASE WHEN MOD(i, 5) = 0 THEN 'em execucao' ELSE 'entregue' END,
  NULL
FROM seq25b;

-- +75 itens de peca nas novas OS (23 a 47): os_peca e a tabela de maior movimento
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

-- +25 registros de mao de obra nas novas OS, distribuidos entre os 18 mecanicos.
-- Terceirizado recebe o valor/hora padrao vigente; interno fica com 0 (RN18/RN19)
INSERT INTO os_mecanico (id_os, id_mecanico, horas_trabalhadas, valor_hora_praticado)
WITH RECURSIVE seq25d AS (
  SELECT 1 AS i
  UNION ALL
  SELECT i + 1 FROM seq25d WHERE i < 25
)
SELECT
  22 + i,
  1 + MOD(i, 18),
  1.0 + MOD(i, 5),
  COALESCE((SELECT t.valor_hora_padrao FROM mecanico_terceirizado t
            WHERE t.id_mecanico = 1 + MOD(i, 18)), 0.00)
FROM seq25d;

-- Historico das OS geradas (23 a 47), coerente com o status atual:
-- entregue    -> aberta, em execucao, concluida, entregue (4 eventos)
-- em execucao -> aberta, em execucao (2 eventos)
INSERT INTO status_historico (id_os, num_sequencia, status, data_hora_mudanca, observacao)
SELECT
  os.id_os,
  e.seq,
  e.status,
  CASE e.seq
    WHEN 1 THEN TIMESTAMP(os.data_abertura, '08:00:00')
    WHEN 2 THEN TIMESTAMP(os.data_abertura, '10:00:00')
    WHEN 3 THEN TIMESTAMP(os.data_entrega_real, '14:00:00')
    ELSE        TIMESTAMP(os.data_entrega_real, '17:00:00')
  END,
  NULL
FROM ordem_servico os
JOIN (SELECT 1 AS seq, 'aberta' AS status
      UNION ALL SELECT 2, 'em execucao'
      UNION ALL SELECT 3, 'concluida'
      UNION ALL SELECT 4, 'entregue') e
  ON e.seq <= CASE os.status_atual WHEN 'entregue' THEN 4 WHEN 'em execucao' THEN 2 ELSE 1 END
WHERE os.id_os > 22;
