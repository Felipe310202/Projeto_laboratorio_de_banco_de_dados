-- ============================================================
-- B4 - Indices criados a partir do estudo de desempenho (EXPLAIN)
-- Tema: Oficina Mecanica
-- Medicoes com 100.047 OS e 5.045 clientes (07_volume_teste.sql),
-- MySQL 8.0.46. Detalhes no relatorio, secao B4.
-- ============================================================

USE oficina_mecanica;

-- Consulta 1: OS de um status num periodo (painel de acompanhamento).
--   WHERE status_atual = ? AND data_abertura BETWEEN ? AND ?
-- Ordem das colunas: status primeiro (filtro de IGUALDADE), data depois
-- (filtro de INTERVALO). Assim o indice vai direto ao bloco do status e
-- percorre so o intervalo de datas dentro dele.
-- Antes: leitura da tabela inteira (type ALL, 99.875 linhas, 36,3 ms)
-- Depois: range no indice, 411 linhas, 0,69 ms
CREATE INDEX idx_os_status_data ON ordem_servico (status_atual, data_abertura);

-- Consulta 2: faturamento por mecanico num periodo (tela da aplicacao).
--   JOIN os_mecanico ... WHERE os.data_abertura BETWEEN ? AND ? GROUP BY ...
-- O indice da consulta 1 NAO serve aqui: ele comeca por status, e esta
-- consulta nao filtra status. Por isso um indice so pela data.
-- Antes: 100.047 OS lidas, 62,5 ms. Depois: range com 4.124 OS, 25,1 ms
CREATE INDEX idx_os_data_abertura ON ordem_servico (data_abertura);

-- Consulta 3: busca de cliente por nome (tela de clientes).
--   WHERE nome LIKE 'texto%'  -> o indice ajuda (1,28 ms -> 0,09 ms)
--   WHERE nome LIKE '%texto%' -> o indice NAO ajuda: com curinga no
--   inicio o MySQL nao sabe por onde comecar e le o indice inteiro
--   (2,66 ms -> 1,89 ms, diferenca desprezivel). Resultado negativo
--   documentado no relatorio.
CREATE INDEX idx_cliente_nome ON cliente (nome);
