# Aplicacao - Oficina Mecanica (Etapa 2)

Python 3 + Flask, conectando ao MySQL com uma conta por perfil.

## Como rodar (macOS / Linux)

    cd app
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env        # preencha as senhas (as mesmas do sql/06b_usuarios_banco.sql)
    python3 app.py

Abra http://127.0.0.1:5000 no navegador.

Pre-requisito: banco criado com sql/01, 02, 04, 05, 06 e a copia local do 06b.

## Usuarios de demonstracao

Logins `ana.atendente`, `jose.mecanico` e `sebastiao.gerente`. As senhas
sao combinadas com a equipe e nao ficam no repositorio.
