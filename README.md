# Projeto Final - Laboratório de Banco de Dados

**Tema:** Oficina Mecânica
**Disciplina:** Laboratório de Banco de Dados (GPE17M40083) - UCB
**Etapa entregue:** Etapa 1

## Integrantes

- Felipe Ricardo Silva - Analista de domínio
- Fernando Rodrigues Cunha - Modelador de dados (MER)
- Gabriel Wolney Drumond - Modelador lógico e normalização
- Guilherme Comaccio - Documentação e dicionário de dados
- Davi Rodrigues Trida - Administrador do banco (DDL, carga, consultas)

## Sobre o tema

O banco modela uma oficina mecânica: clientes e seus veículos, ordens de serviço que consomem peças (de fornecedores) e mão de obra de mecânicos (internos ou terceirizados), com histórico de status, garantia de serviço e controle de estoque. Detalhes completos no `docs/relatorio-etapa1.pdf`.

## Estrutura do repositório

repositorio/
├── README.md
├── docs/
│ ├── relatorio-etapa1.pdf
│ ├── mer-conceitual.pdf
│ └── mer-conceitual.drawio
└── sql/
├── 01_ddl.sql
├── 02_carga.sql
└── 03_consultas.sql


## Como rodar

Testado em MySQL 8.0.46.

```bash
mysql -u root -p -e "CREATE DATABASE oficina_mecanica;"
mysql -u root -p oficina_mecanica < sql/01_ddl.sql
mysql -u root -p oficina_mecanica < sql/02_carga.sql
mysql -u root -p oficina_mecanica < sql/03_consultas.sql
```

O script `01_ddl.sql` foi testado do zero em base limpa e roda sem erro, criando 11 tabelas. O `02_carga.sql` popula o banco com dados fictícios (45 clientes, 43 veículos, 42 peças, 47 ordens de serviço, 118 itens de peça em OS, entre outros). O `03_consultas.sql` traz as 15 consultas exigidas, todas testadas e retornando resultado coerente.

Observação sobre a RN08 (mecânico não pode se autosupervisionar): o MySQL não permite CHECK constraint numa coluna que já tem ação de FK (ON DELETE SET NULL), então essa regra não virou restrição de banco. Fica documentada no A1 como pendente para trigger (Etapa 2) e validação da aplicação.
