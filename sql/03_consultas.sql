-- ============================================================
-- A8 - Consultas de verificacao
-- Tema: Oficina Mecanica
-- MySQL 8.0+
-- 5 basicas, 5 juncoes/agregacao, 5 avancadas
-- Todas testadas contra o banco carregado
-- ============================================================

-- ---------- BASICAS ----------

-- 1. Quais veiculos tem placa comecando com "ABC" ou "DEF"? (LIKE)
SELECT placa, modelo, marca
FROM veiculo
WHERE placa LIKE 'ABC%' OR placa LIKE 'DEF%';

-- 2. Quais ordens de servico foram abertas entre duas datas especificas, ordenadas pela data? (BETWEEN, ORDER BY)
SELECT id_os, data_abertura, status_atual
FROM ordem_servico
WHERE data_abertura BETWEEN '2026-06-01' AND '2026-07-31'
ORDER BY data_abertura;

-- 3. Quais pecas estao com estoque abaixo de 15 unidades? (WHERE, ORDER BY)
SELECT nome, estoque_atual
FROM peca
WHERE estoque_atual < 15
ORDER BY estoque_atual ASC;

-- 4. Quais mecanicos nao tem supervisor definido? (IS NULL)
SELECT nome, especialidade
FROM mecanico
WHERE id_supervisor IS NULL;

-- 5. Quais clientes tem cadastro de telefone ou email em branco? (IN + tratamento de NULL)
SELECT nome, telefone, email
FROM cliente
WHERE telefone IS NULL OR email IS NULL;

-- ---------- JUNCOES E AGREGACAO ----------

-- 6. Nome do cliente, veiculo e status da OS mais recente de cada veiculo (3 tabelas)
SELECT c.nome AS cliente, v.placa, v.modelo, os.status_atual, os.data_abertura
FROM cliente c
JOIN veiculo v ON v.id_cliente = c.id_cliente
JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
ORDER BY c.nome, os.data_abertura DESC;

-- 7. Todos os veiculos com sua ultima OS, incluindo os que nunca tiveram OS (LEFT JOIN)
SELECT v.placa, v.modelo, MAX(os.data_abertura) AS ultima_os
FROM veiculo v
LEFT JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
GROUP BY v.placa, v.modelo
ORDER BY (ultima_os IS NULL), ultima_os; -- MySQL nao tem NULLS LAST, esse truque joga os NULL pro fim

-- 8. Total faturado por mecanico terceirizado (soma de horas x valor/hora praticado)
SELECT m.nome, mt.empresa_parceira,
       SUM(osm.horas_trabalhadas * osm.valor_hora_praticado) AS total_faturado
FROM mecanico m
JOIN mecanico_terceirizado mt ON mt.id_mecanico = m.id_mecanico
JOIN os_mecanico osm ON osm.id_mecanico = m.id_mecanico
GROUP BY m.nome, mt.empresa_parceira
ORDER BY total_faturado DESC;

-- 9. Pecas mais usadas por quantidade total, so as que passaram de 3 unidades no total (GROUP BY + HAVING)
SELECT p.nome, SUM(op.quantidade) AS quantidade_total
FROM peca p
JOIN os_peca op ON op.id_peca = p.id_peca
GROUP BY p.nome
HAVING SUM(op.quantidade) > 3
ORDER BY quantidade_total DESC;

-- 10. Quantidade de ordens de servico por status, considerando todo o periodo carregado
SELECT status_atual, COUNT(*) AS quantidade
FROM ordem_servico
GROUP BY status_atual
ORDER BY quantidade DESC;

-- ---------- AVANCADAS ----------

-- 11. Mecanicos cujo total de horas trabalhadas esta acima da media geral (subconsulta correlacionada)
SELECT m.nome,
       (SELECT SUM(osm2.horas_trabalhadas) FROM os_mecanico osm2 WHERE osm2.id_mecanico = m.id_mecanico) AS horas_totais
FROM mecanico m
WHERE (SELECT SUM(osm2.horas_trabalhadas) FROM os_mecanico osm2 WHERE osm2.id_mecanico = m.id_mecanico)
      > (SELECT AVG(soma_horas) FROM (SELECT SUM(horas_trabalhadas) AS soma_horas FROM os_mecanico GROUP BY id_mecanico) t)
ORDER BY horas_totais DESC;

-- 12. Clientes que possuem ao menos uma OS ainda nao entregue (EXISTS)
SELECT c.nome
FROM cliente c
WHERE EXISTS (
  SELECT 1
  FROM veiculo v
  JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
  WHERE v.id_cliente = c.id_cliente
    AND os.status_atual <> 'entregue'
);

-- 13. Pecas que nunca foram utilizadas em nenhuma ordem de servico (NOT EXISTS)
SELECT p.nome
FROM peca p
WHERE NOT EXISTS (
  SELECT 1 FROM os_peca op WHERE op.id_peca = p.id_peca
);

-- 14. Tempo medio, em dias, entre abertura e entrega das OS ja entregues, por mes de abertura
--     (pergunta de negocio nao trivial: ajuda a entender se a oficina esta ficando mais lenta ou mais rapida)
SELECT DATE_FORMAT(data_abertura, '%Y-%m-01') AS mes,
       ROUND(AVG(DATEDIFF(data_entrega_real, data_abertura)), 1) AS media_dias_ate_entrega
FROM ordem_servico
WHERE data_entrega_real IS NOT NULL
GROUP BY DATE_FORMAT(data_abertura, '%Y-%m-01')
ORDER BY mes;

-- 15. Mecanico terceirizado com maior faturamento acumulado, mostrando quem o supervisiona (autorrelacionamento)
SELECT m.nome AS mecanico, mt.empresa_parceira,
       sup.nome AS supervisor,
       SUM(osm.horas_trabalhadas * osm.valor_hora_praticado) AS faturamento
FROM mecanico m
JOIN mecanico_terceirizado mt ON mt.id_mecanico = m.id_mecanico
JOIN os_mecanico osm ON osm.id_mecanico = m.id_mecanico
LEFT JOIN mecanico sup ON sup.id_mecanico = m.id_supervisor
GROUP BY m.nome, mt.empresa_parceira, sup.nome
ORDER BY faturamento DESC
LIMIT 1;
