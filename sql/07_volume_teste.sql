-- ============================================================
-- B4 - Volume de dados para o estudo de desempenho (EXPLAIN)
-- Tema: Oficina Mecanica
--
-- ATENCAO: use SO para o estudo de indices. Acrescenta 100.000 OS e
-- 300.000 itens de peca. Para voltar ao banco normal, rode de novo
-- 01, 02, 04, 05 e 06.
--
-- Com as 47 OS da carga normal, o MySQL le a tabela inteira mais rapido
-- do que usaria um indice, entao nenhum indice faria diferenca. Com
-- 100 mil OS (cerca de 2 anos de uma rede de oficinas) o efeito aparece.
-- ============================================================

USE oficina_mecanica;
SET SESSION cte_max_recursion_depth = 200000;

-- 100.000 OS espalhadas em 2 anos (2025-2026), nos 43 veiculos
INSERT INTO ordem_servico (id_veiculo, problema_relatado, data_abertura,
                           data_previsao_entrega, data_entrega_real, status_atual)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 100000)
SELECT
  1 + MOD(i * 7, 43),
  ELT(1 + MOD(i, 6), 'Revisao periodica', 'Troca de oleo', 'Freio fazendo ruido',
      'Falha na partida', 'Barulho na suspensao', 'Luz de injecao acesa'),
  DATE_ADD('2025-01-01', INTERVAL MOD(i * 13, 730) DAY),
  DATE_ADD('2025-01-01', INTERVAL MOD(i * 13, 730) + 3 DAY),
  CASE WHEN MOD(i, 10) < 8 THEN DATE_ADD('2025-01-01', INTERVAL MOD(i * 13, 730) + 3 DAY) END,
  CASE WHEN MOD(i, 10) < 8 THEN 'entregue'
       WHEN MOD(i, 10) = 8 THEN 'em execucao' ELSE 'aguardando peca' END
FROM n;

-- 3 itens de peca por OS nova (300.000 linhas em os_peca)
INSERT INTO os_peca (id_os, id_peca, quantidade, preco_unitario_praticado)
SELECT os.id_os, 1 + MOD(os.id_os * 7 + k.k, 42), 1 + k.k, 50.00
FROM ordem_servico os
CROSS JOIN (SELECT 0 AS k UNION ALL SELECT 1 UNION ALL SELECT 2) k
WHERE os.id_os > 47;

-- 1 lancamento de mao de obra por OS nova (100.000 linhas em os_mecanico)
INSERT INTO os_mecanico (id_os, id_mecanico, horas_trabalhadas, valor_hora_praticado)
SELECT os.id_os, 1 + MOD(os.id_os, 18), 1 + MOD(os.id_os, 4), 0.00
FROM ordem_servico os
WHERE os.id_os > 47;

-- 5.000 clientes a mais, para a busca por nome
INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 5000)
SELECT CONCAT(ELT(1 + MOD(i, 8), 'Ana', 'Bruno', 'Carla', 'Daniel', 'Elisa', 'Felipe', 'Gabriela', 'Hugo'),
              ' Teste ', i),
       LPAD(80000000000 + i, 11, '0'), NULL, NULL, NULL
FROM n;

-- Atualiza as estatisticas que o otimizador usa para escolher o plano
ANALYZE TABLE ordem_servico, os_peca, os_mecanico, cliente;
