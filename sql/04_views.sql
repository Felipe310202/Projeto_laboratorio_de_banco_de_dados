-- ============================================================
-- B1/B5 - Visoes (views)
-- Tema: Oficina Mecanica
-- MySQL 8.0+ - rodar depois de 01_ddl.sql e 02_carga.sql
--
-- vw_resumo_os        -> relatorio consolidado da aplicacao (B1, RN20)
-- vw_mecanico_publico -> restringe COLUNAS: esconde salario, matricula
--                        e valor/hora (B5, perfil atendente)
-- vw_os_oficina       -> restringe LINHAS e COLUNAS: so OS em andamento,
--                        sem dados pessoais do cliente (B5, perfil mecanico)
-- vw_garantia_os      -> janela de garantia de cada OS entregue (RN14)
-- ============================================================

USE oficina_mecanica;

-- ------------------------------------------------------------
-- RN20: valor total da OS = pecas + mao de obra.
-- As somas ficam em subconsultas separadas de proposito: um JOIN direto
-- com os_peca E os_mecanico multiplicaria as linhas (3 pecas x 2 mecanicos
-- = 6 linhas) e inflaria os totais.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_resumo_os AS
SELECT
  t.id_os,
  t.cliente,
  t.placa,
  t.modelo,
  t.status_atual,
  t.data_abertura,
  t.data_entrega_real,
  t.retorno_garantia,
  CAST(t.total_pecas AS DECIMAL(10,2))                    AS total_pecas,
  CAST(t.total_mao_obra AS DECIMAL(10,2))                 AS total_mao_obra,
  CAST(t.total_pecas + t.total_mao_obra AS DECIMAL(10,2)) AS total_geral
FROM (
  SELECT
    os.id_os,
    c.nome         AS cliente,
    v.placa,
    v.modelo,
    os.status_atual,
    os.data_abertura,
    os.data_entrega_real,
    CASE WHEN os.id_os_garantia IS NULL THEN 'Nao' ELSE 'Sim' END AS retorno_garantia,
    COALESCE((SELECT SUM(op.quantidade * op.preco_unitario_praticado)
              FROM os_peca op
              WHERE op.id_os = os.id_os), 0) AS total_pecas,
    COALESCE((SELECT SUM(om.horas_trabalhadas * om.valor_hora_praticado)
              FROM os_mecanico om
              WHERE om.id_os = os.id_os), 0) AS total_mao_obra
  FROM ordem_servico os
  JOIN veiculo v ON v.id_veiculo = os.id_veiculo
  JOIN cliente c ON c.id_cliente = v.id_cliente
) t;

-- ------------------------------------------------------------
-- Restricao de colunas: dados de contratacao e remuneracao (salario,
-- matricula, data de contratacao, valor/hora) sao dados pessoais e
-- financeiros e nao aparecem aqui. O perfil atendente recebe SELECT
-- nesta visao, e nao nas tabelas mecanico_interno/mecanico_terceirizado.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_mecanico_publico AS
SELECT
  m.id_mecanico,
  m.nome,
  m.especialidade,
  CASE WHEN mi.id_mecanico IS NOT NULL THEN 'Interno' ELSE 'Terceirizado' END AS tipo,
  e.nome   AS empresa_parceira,
  sup.nome AS supervisor
FROM mecanico m
LEFT JOIN mecanico_interno mi      ON mi.id_mecanico = m.id_mecanico
LEFT JOIN mecanico_terceirizado mt ON mt.id_mecanico = m.id_mecanico
LEFT JOIN empresa_parceira e       ON e.id_empresa  = mt.id_empresa
LEFT JOIN mecanico sup             ON sup.id_mecanico = m.id_supervisor;

-- ------------------------------------------------------------
-- Restricao de linhas e colunas: o mecanico precisa saber QUAL carro e
-- QUAL problema, mas nao quem e o dono. Ficam de fora nome, CPF/CNPJ,
-- telefone, e-mail e endereco do cliente, e so aparecem as OS que ainda
-- estao na oficina (sem as concluidas e entregues).
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_os_oficina AS
SELECT
  os.id_os,
  v.placa,
  v.marca,
  v.modelo,
  v.ano_fabricacao,
  os.problema_relatado,
  os.status_atual,
  os.data_abertura,
  os.data_previsao_entrega,
  os.id_os_garantia
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
WHERE os.status_atual IN ('aberta', 'em execucao', 'aguardando peca');

-- ------------------------------------------------------------
-- RN14: a garantia dura 90 dias corridos a partir da entrega real.
-- A situacao e calculada na hora da consulta (CURDATE()), entao a mesma
-- OS passa de 'Em garantia' para 'Expirada' sozinha com o tempo.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_garantia_os AS
SELECT
  os.id_os,
  v.placa,
  os.problema_relatado,
  os.data_entrega_real,
  DATE_ADD(os.data_entrega_real, INTERVAL 90 DAY) AS fim_garantia,
  CASE
    WHEN CURDATE() <= DATE_ADD(os.data_entrega_real, INTERVAL 90 DAY) THEN 'Em garantia'
    ELSE 'Expirada'
  END AS situacao,
  (SELECT COUNT(*) FROM ordem_servico r WHERE r.id_os_garantia = os.id_os) AS retornos
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
WHERE os.status_atual = 'entregue';
