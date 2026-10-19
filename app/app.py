"""
Oficina Mecanica - aplicacao da Etapa 2 (Laboratorio de Banco de Dados)

Boas praticas exigidas pelo enunciado (B2):
  * TODO comando SQL usa parametros (%s) - nenhum valor digitado pelo
    usuario e concatenado no texto do SQL.
  * Credenciais ficam no arquivo .env (fora do Git), lidas com python-dotenv.
  * Cada perfil conversa com o banco usando a conta do MySQL daquele perfil
    (oficina_atendente, oficina_mecanico, oficina_gerente), entao os
    GRANT/REVOKE do 06_seguranca.sql valem tambem dentro da aplicacao.
  * Erros do banco sao traduzidos para mensagens em portugues (traduzir_erro).
"""
import os
from functools import wraps

import bcrypt
import mysql.connector
from mysql.connector import errorcode
from dotenv import load_dotenv
from flask import (Flask, flash, redirect, render_template, request,
                   session, url_for)

load_dotenv()

app = Flask(__name__)
app.secret_key = os.environ["SECRET_KEY"]

# ----------------------------------------------------------------------
# Conexao com o banco: uma conta do MySQL por perfil
# ----------------------------------------------------------------------
CONTAS = {
    "login":     ("DB_USER_LOGIN", "DB_PASS_LOGIN"),
    "atendente": ("DB_USER_ATENDENTE", "DB_PASS_ATENDENTE"),
    "mecanico":  ("DB_USER_MECANICO", "DB_PASS_MECANICO"),
    "gerente":   ("DB_USER_GERENTE", "DB_PASS_GERENTE"),
}


def conectar(perfil):
    var_user, var_pass = CONTAS[perfil]
    return mysql.connector.connect(
        host=os.environ.get("DB_HOST", "127.0.0.1"),
        port=int(os.environ.get("DB_PORT", "3306")),
        database=os.environ.get("DB_NAME", "oficina_mecanica"),
        user=os.environ[var_user],
        password=os.environ[var_pass],
        autocommit=False,
    )


def db():
    """Conexao do perfil de quem esta logado."""
    return conectar(session["perfil"])


def consultar(sql, params=()):
    conn = db()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params)
        return cur.fetchall()
    finally:
        conn.close()


def executar(sql, params=()):
    """INSERT/UPDATE/DELETE simples, com o autor informado aos gatilhos."""
    conn = db()
    try:
        cur = conn.cursor()
        cur.execute("SET @usuario_app = %s", (session["login"],))
        cur.execute(sql, params)
        conn.commit()
        return cur
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ----------------------------------------------------------------------
# Traducao de erros do MySQL para mensagens compreensiveis (B1)
# ----------------------------------------------------------------------
MSG_RESTRICAO = {
    "uq_cliente_cpf_cnpj": "Ja existe um cliente com esse CPF/CNPJ.",
    "uq_veiculo_placa": "Ja existe um veiculo com essa placa.",
    "uq_mecint_matricula": "Ja existe um mecanico com essa matricula.",
    "uq_fornecedor_cnpj": "Ja existe um fornecedor com esse CNPJ.",
    "os_peca.PRIMARY": "Essa peca ja foi lancada nesta OS. Altere a quantidade com o gerente.",
    "PRIMARY": "Esse registro ja existe.",
    "ck_cliente_cpf_cnpj": "CPF deve ter 11 digitos e CNPJ 14 digitos, somente numeros.",
    "ck_veiculo_ano": "Ano de fabricacao invalido (entre 1950 e 2100).",
    "ck_peca_preco": "O preco nao pode ser negativo.",
    "ck_peca_estoque": "O estoque nao pode ficar negativo.",
    "ck_mecint_salario": "O salario deve ser maior que zero.",
    "ck_mecterc_valor_hora": "O valor da hora deve ser maior que zero.",
    "ck_ospeca_quantidade": "A quantidade deve ser maior que zero.",
    "ck_os_status": "Status invalido.",
}


def traduzir_erro(e):
    texto = str(e.msg) if hasattr(e, "msg") else str(e)
    for nome, msg in MSG_RESTRICAO.items():
        if f"'{nome}'" in texto or f".{nome}'" in texto:
            return msg
    if e.errno == errorcode.ER_DUP_ENTRY:
        return "Esse valor ja esta cadastrado."
    if e.errno == errorcode.ER_ROW_IS_REFERENCED_2:
        return ("Este registro esta em uso por outros dados (ex.: cliente com "
                "veiculos, peca ja usada em OS) e nao pode ser excluido.")
    if e.errno == errorcode.ER_NO_REFERENCED_ROW_2:
        return "O item selecionado nao existe mais. Atualize a pagina."
    if e.errno == errorcode.ER_SIGNAL_EXCEPTION:          # gatilho (SIGNAL)
        return texto.replace("RN08: ", "") .capitalize()
    if e.errno in (errorcode.ER_TABLEACCESS_DENIED_ERROR,
                   errorcode.ER_COLUMNACCESS_DENIED_ERROR):
        return "Seu perfil nao tem permissao para esta operacao."
    if e.errno == errorcode.ER_DATA_TOO_LONG:
        return "Um dos campos passou do tamanho permitido."
    if e.errno == errorcode.ER_BAD_NULL_ERROR:
        return "Preencha todos os campos obrigatorios."
    if e.errno == 3819:                                    # CHECK sem mensagem propria
        return "Um dos valores informados nao e permitido."
    return "Nao foi possivel concluir a operacao. Verifique os dados."


def vazio_para_none(valor):
    valor = (valor or "").strip()
    return valor if valor else None


# ----------------------------------------------------------------------
# Login e perfis
# ----------------------------------------------------------------------
def requer(*perfis):
    def decorador(f):
        @wraps(f)
        def interno(*args, **kwargs):
            if "perfil" not in session:
                return redirect(url_for("login"))
            if perfis and session["perfil"] not in perfis:
                flash("Seu perfil nao tem acesso a esta tela.", "erro")
                return redirect(url_for("inicio"))
            return f(*args, **kwargs)
        return interno
    return decorador


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        login_digitado = request.form.get("login", "")
        senha = request.form.get("senha", "").encode()
        conn = conectar("login")
        try:
            cur = conn.cursor(dictionary=True)
            cur.execute(
                "SELECT login, senha_hash, perfil, ativo FROM usuario WHERE login = %s",
                (login_digitado,))
            u = cur.fetchone()
        finally:
            conn.close()
        if u and u["ativo"] and bcrypt.checkpw(senha, u["senha_hash"].encode()):
            session.clear()
            session["login"] = u["login"]
            session["perfil"] = u["perfil"]
            return redirect(url_for("inicio"))
        flash("Usuario ou senha invalidos.", "erro")
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/")
@requer()
def inicio():
    return render_template("inicio.html")


# ----------------------------------------------------------------------
# CRUD 1: Clientes (atendente, gerente)
# ----------------------------------------------------------------------
@app.route("/clientes")
@requer("atendente", "gerente")
def clientes():
    busca = request.args.get("busca", "")
    linhas = consultar(
        "SELECT id_cliente, nome, cpf_cnpj, telefone, email FROM cliente "
        "WHERE nome LIKE %s ORDER BY nome", (f"%{busca}%",))
    return render_template("clientes.html", linhas=linhas, busca=busca)


@app.route("/clientes/novo", methods=["GET", "POST"])
@app.route("/clientes/<int:id>/editar", methods=["GET", "POST"])
@requer("atendente", "gerente")
def cliente_form(id=None):
    if request.method == "POST":
        f = request.form
        dados = (f["nome"].strip(), f["cpf_cnpj"].strip(), vazio_para_none(f["telefone"]),
                 vazio_para_none(f["email"]), vazio_para_none(f["endereco"]))
        try:
            if id is None:
                executar("INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco) "
                         "VALUES (%s, %s, %s, %s, %s)", dados)
            else:
                executar("UPDATE cliente SET nome=%s, cpf_cnpj=%s, telefone=%s, email=%s, "
                         "endereco=%s WHERE id_cliente=%s", dados + (id,))
            flash("Cliente salvo.", "ok")
            return redirect(url_for("clientes"))
        except mysql.connector.Error as e:
            flash(traduzir_erro(e), "erro")
            item = dict(zip(["nome", "cpf_cnpj", "telefone", "email", "endereco"], dados))
            return render_template("cliente_form.html", item=item, id=id)
    item = {}
    if id is not None:
        item = consultar("SELECT * FROM cliente WHERE id_cliente = %s", (id,))[0]
    return render_template("cliente_form.html", item=item, id=id)


@app.route("/clientes/<int:id>/excluir", methods=["POST"])
@requer("atendente", "gerente")
def cliente_excluir(id):
    try:
        executar("DELETE FROM cliente WHERE id_cliente = %s", (id,))
        flash("Cliente excluido.", "ok")
    except mysql.connector.Error as e:
        flash(traduzir_erro(e), "erro")
    return redirect(url_for("clientes"))


# ----------------------------------------------------------------------
# CRUD 2: Veiculos (atendente, gerente)
# ----------------------------------------------------------------------
@app.route("/veiculos")
@requer("atendente", "gerente")
def veiculos():
    busca = request.args.get("busca", "")
    linhas = consultar(
        "SELECT v.id_veiculo, v.placa, v.marca, v.modelo, v.ano_fabricacao, c.nome AS dono "
        "FROM veiculo v JOIN cliente c ON c.id_cliente = v.id_cliente "
        "WHERE v.placa LIKE %s ORDER BY v.placa", (f"%{busca}%",))
    return render_template("veiculos.html", linhas=linhas, busca=busca)


@app.route("/veiculos/novo", methods=["GET", "POST"])
@app.route("/veiculos/<int:id>/editar", methods=["GET", "POST"])
@requer("atendente", "gerente")
def veiculo_form(id=None):
    clientes_lista = consultar("SELECT id_cliente, nome FROM cliente ORDER BY nome")
    if request.method == "POST":
        f = request.form
        dados = (f["placa"].strip().upper(), f["modelo"].strip(), f["marca"].strip(),
                 f["ano_fabricacao"] or None, f["id_cliente"])
        try:
            if id is None:
                executar("INSERT INTO veiculo (placa, modelo, marca, ano_fabricacao, id_cliente) "
                         "VALUES (%s, %s, %s, %s, %s)", dados)
            else:
                executar("UPDATE veiculo SET placa=%s, modelo=%s, marca=%s, ano_fabricacao=%s, "
                         "id_cliente=%s WHERE id_veiculo=%s", dados + (id,))
            flash("Veiculo salvo.", "ok")
            return redirect(url_for("veiculos"))
        except mysql.connector.Error as e:
            flash(traduzir_erro(e), "erro")
            item = dict(zip(["placa", "modelo", "marca", "ano_fabricacao", "id_cliente"], dados))
            return render_template("veiculo_form.html", item=item, id=id, clientes=clientes_lista)
    item = {}
    if id is not None:
        item = consultar("SELECT * FROM veiculo WHERE id_veiculo = %s", (id,))[0]
    return render_template("veiculo_form.html", item=item, id=id, clientes=clientes_lista)


@app.route("/veiculos/<int:id>/excluir", methods=["POST"])
@requer("atendente", "gerente")
def veiculo_excluir(id):
    try:
        executar("DELETE FROM veiculo WHERE id_veiculo = %s", (id,))
        flash("Veiculo excluido.", "ok")
    except mysql.connector.Error as e:
        flash(traduzir_erro(e), "erro")
    return redirect(url_for("veiculos"))


# ----------------------------------------------------------------------
# CRUD 3: Pecas (todos consultam; so o gerente altera)
# ----------------------------------------------------------------------
@app.route("/pecas")
@requer("atendente", "mecanico", "gerente")
def pecas():
    busca = request.args.get("busca", "")
    linhas = consultar(
        "SELECT p.id_peca, p.nome, p.preco_atual, p.estoque_atual, p.id_fornecedor "
        "FROM peca p WHERE p.nome LIKE %s ORDER BY p.nome", (f"%{busca}%",))
    return render_template("pecas.html", linhas=linhas, busca=busca)


@app.route("/pecas/novo", methods=["GET", "POST"])
@app.route("/pecas/<int:id>/editar", methods=["GET", "POST"])
@requer("gerente")
def peca_form(id=None):
    fornecedores = consultar("SELECT id_fornecedor, nome FROM fornecedor ORDER BY nome")
    if request.method == "POST":
        f = request.form
        dados = (f["nome"].strip(), vazio_para_none(f["descricao"]), f["id_fornecedor"],
                 f["preco_atual"] or None, f["estoque_atual"] or 0)
        try:
            if id is None:
                executar("INSERT INTO peca (nome, descricao, id_fornecedor, preco_atual, "
                         "estoque_atual) VALUES (%s, %s, %s, %s, %s)", dados)
            else:
                executar("UPDATE peca SET nome=%s, descricao=%s, id_fornecedor=%s, "
                         "preco_atual=%s, estoque_atual=%s WHERE id_peca=%s", dados + (id,))
            flash("Peca salva.", "ok")
            return redirect(url_for("pecas"))
        except mysql.connector.Error as e:
            flash(traduzir_erro(e), "erro")
            item = dict(zip(["nome", "descricao", "id_fornecedor", "preco_atual",
                             "estoque_atual"], dados))
            return render_template("peca_form.html", item=item, id=id, fornecedores=fornecedores)
    item = {}
    if id is not None:
        item = consultar("SELECT * FROM peca WHERE id_peca = %s", (id,))[0]
    return render_template("peca_form.html", item=item, id=id, fornecedores=fornecedores)


@app.route("/pecas/<int:id>/excluir", methods=["POST"])
@requer("gerente")
def peca_excluir(id):
    try:
        executar("DELETE FROM peca WHERE id_peca = %s", (id,))
        flash("Peca excluida.", "ok")
    except mysql.connector.Error as e:
        flash(traduzir_erro(e), "erro")
    return redirect(url_for("pecas"))


# ----------------------------------------------------------------------
# CRUD 4: Mecanicos (gerente) - grava em DUAS tabelas na mesma transacao
# (mecanico + mecanico_interno ou mecanico_terceirizado)
# ----------------------------------------------------------------------
@app.route("/mecanicos")
@requer("gerente")
def mecanicos():
    linhas = consultar(
        "SELECT m.id_mecanico, m.nome, m.especialidade, s.nome AS supervisor, "
        "CASE WHEN mi.id_mecanico IS NOT NULL THEN 'Interno' ELSE 'Terceirizado' END AS tipo, "
        "mi.salario, mt.valor_hora_padrao, e.nome AS empresa "
        "FROM mecanico m "
        "LEFT JOIN mecanico s ON s.id_mecanico = m.id_supervisor "
        "LEFT JOIN mecanico_interno mi ON mi.id_mecanico = m.id_mecanico "
        "LEFT JOIN mecanico_terceirizado mt ON mt.id_mecanico = m.id_mecanico "
        "LEFT JOIN empresa_parceira e ON e.id_empresa = mt.id_empresa "
        "ORDER BY m.nome")
    return render_template("mecanicos.html", linhas=linhas)


@app.route("/mecanicos/novo", methods=["GET", "POST"])
@app.route("/mecanicos/<int:id>/editar", methods=["GET", "POST"])
@requer("gerente")
def mecanico_form(id=None):
    supervisores = consultar("SELECT id_mecanico, nome FROM mecanico ORDER BY nome")
    empresas = consultar("SELECT id_empresa, nome FROM empresa_parceira ORDER BY nome")
    if request.method == "POST":
        f = request.form
        tipo = f.get("tipo")
        conn = db()
        try:
            cur = conn.cursor()
            conn.start_transaction()
            cur.execute("SET @usuario_app = %s", (session["login"],))
            if id is None:
                cur.execute("INSERT INTO mecanico (nome, especialidade, id_supervisor) "
                            "VALUES (%s, %s, %s)",
                            (f["nome"].strip(), vazio_para_none(f["especialidade"]),
                             vazio_para_none(f["id_supervisor"])))
                novo_id = cur.lastrowid
                if tipo == "interno":
                    cur.execute("INSERT INTO mecanico_interno (id_mecanico, matricula, salario, "
                                "data_contratacao) VALUES (%s, %s, %s, %s)",
                                (novo_id, f["matricula"].strip(), f["salario"] or None,
                                 f["data_contratacao"] or None))
                else:
                    cur.execute("INSERT INTO mecanico_terceirizado (id_mecanico, id_empresa, "
                                "valor_hora_padrao) VALUES (%s, %s, %s)",
                                (novo_id, f["id_empresa"], f["valor_hora_padrao"] or None))
            else:
                cur.execute("UPDATE mecanico SET nome=%s, especialidade=%s, id_supervisor=%s "
                            "WHERE id_mecanico=%s",
                            (f["nome"].strip(), vazio_para_none(f["especialidade"]),
                             vazio_para_none(f["id_supervisor"]), id))
                if tipo == "interno":
                    cur.execute("UPDATE mecanico_interno SET matricula=%s, salario=%s, "
                                "data_contratacao=%s WHERE id_mecanico=%s",
                                (f["matricula"].strip(), f["salario"] or None,
                                 f["data_contratacao"] or None, id))
                else:
                    cur.execute("UPDATE mecanico_terceirizado SET id_empresa=%s, "
                                "valor_hora_padrao=%s WHERE id_mecanico=%s",
                                (f["id_empresa"], f["valor_hora_padrao"] or None, id))
            conn.commit()
            flash("Mecanico salvo.", "ok")
            return redirect(url_for("mecanicos"))
        except mysql.connector.Error as e:
            conn.rollback()     # se a subclasse falhar, o mecanico tambem nao fica gravado
            flash(traduzir_erro(e), "erro")
            item = dict(f)
            return render_template("mecanico_form.html", item=item, id=id,
                                   supervisores=supervisores, empresas=empresas)
        finally:
            conn.close()
    item = {"tipo": "interno"}
    if id is not None:
        item = consultar(
            "SELECT m.*, mi.matricula, mi.salario, mi.data_contratacao, mt.id_empresa, "
            "mt.valor_hora_padrao, "
            "CASE WHEN mi.id_mecanico IS NOT NULL THEN 'interno' ELSE 'terceirizado' END AS tipo "
            "FROM mecanico m "
            "LEFT JOIN mecanico_interno mi ON mi.id_mecanico = m.id_mecanico "
            "LEFT JOIN mecanico_terceirizado mt ON mt.id_mecanico = m.id_mecanico "
            "WHERE m.id_mecanico = %s", (id,))[0]
    return render_template("mecanico_form.html", item=item, id=id,
                           supervisores=supervisores, empresas=empresas)


@app.route("/mecanicos/<int:id>/excluir", methods=["POST"])
@requer("gerente")
def mecanico_excluir(id):
    try:
        executar("DELETE FROM mecanico WHERE id_mecanico = %s", (id,))
        flash("Mecanico excluido.", "ok")
    except mysql.connector.Error as e:
        flash(traduzir_erro(e), "erro")
    return redirect(url_for("mecanicos"))


# ----------------------------------------------------------------------
# Consulta parametrizada 1: faturamento por mecanico (juncao + agregacao)
# ----------------------------------------------------------------------
@app.route("/consultas/faturamento")
@requer("gerente")
def consulta_faturamento():
    ini = request.args.get("data_ini", "2026-01-01")
    fim = request.args.get("data_fim", "2026-12-31")
    tipo = request.args.get("tipo", "todos")
    linhas = consultar(
        "SELECT m.nome, "
        "CASE WHEN mt.id_mecanico IS NULL THEN 'Interno' ELSE 'Terceirizado' END AS tipo, "
        "COUNT(DISTINCT om.id_os) AS qtd_os, SUM(om.horas_trabalhadas) AS horas, "
        "SUM(om.horas_trabalhadas * om.valor_hora_praticado) AS valor "
        "FROM mecanico m "
        "JOIN os_mecanico om ON om.id_mecanico = m.id_mecanico "
        "JOIN ordem_servico os ON os.id_os = om.id_os "
        "LEFT JOIN mecanico_terceirizado mt ON mt.id_mecanico = m.id_mecanico "
        "WHERE os.data_abertura BETWEEN %s AND %s "
        "AND (%s = 'todos' "
        "     OR (%s = 'interno' AND mt.id_mecanico IS NULL) "
        "     OR (%s = 'terceirizado' AND mt.id_mecanico IS NOT NULL)) "
        "GROUP BY m.id_mecanico, m.nome, tipo ORDER BY valor DESC, horas DESC",
        (ini, fim, tipo, tipo, tipo))
    return render_template("consulta_faturamento.html", linhas=linhas,
                           ini=ini, fim=fim, tipo=tipo)


# ----------------------------------------------------------------------
# Consulta parametrizada 2: historico de um veiculo (juncao + agregacao)
# ----------------------------------------------------------------------
@app.route("/consultas/historico")
@requer("gerente")
def consulta_historico():
    placa = request.args.get("placa", "").strip().upper()
    ini = request.args.get("data_ini", "2026-01-01")
    fim = request.args.get("data_fim", "2026-12-31")
    linhas = []
    if placa:
        linhas = consultar(
            "SELECT os.id_os, os.data_abertura, os.status_atual, os.problema_relatado, "
            "COALESCE(SUM(op.quantidade), 0) AS qtd_pecas, "
            "COALESCE(SUM(op.quantidade * op.preco_unitario_praticado), 0) AS total_pecas, "
            "(SELECT COALESCE(SUM(om.horas_trabalhadas * om.valor_hora_praticado), 0) "
            " FROM os_mecanico om WHERE om.id_os = os.id_os) AS total_mao_obra "
            "FROM veiculo v "
            "JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo "
            "LEFT JOIN os_peca op ON op.id_os = os.id_os "
            "WHERE v.placa = %s AND os.data_abertura BETWEEN %s AND %s "
            "GROUP BY os.id_os, os.data_abertura, os.status_atual, os.problema_relatado "
            "ORDER BY os.data_abertura DESC",
            (placa, ini, fim))
    return render_template("consulta_historico.html", linhas=linhas,
                           placa=placa, ini=ini, fim=fim)


# ----------------------------------------------------------------------
# Relatorio alimentado pela visao vw_resumo_os
# ----------------------------------------------------------------------
@app.route("/relatorio")
@requer("atendente", "gerente")
def relatorio():
    status = request.args.get("status", "")
    if status:
        linhas = consultar("SELECT * FROM vw_resumo_os WHERE status_atual = %s "
                           "ORDER BY id_os", (status,))
    else:
        linhas = consultar("SELECT * FROM vw_resumo_os ORDER BY id_os")
    total = sum(l["total_geral"] for l in linhas)
    return render_template("relatorio.html", linhas=linhas, status=status, total=total)


# ----------------------------------------------------------------------
# OPERACAO TRANSACIONAL (B1/B3): lancar peca na OS
# Altera DUAS tabelas: insere em os_peca e baixa o estoque em peca.
# Ou as duas acontecem (COMMIT), ou nenhuma (ROLLBACK).
# ----------------------------------------------------------------------
@app.route("/lancar-peca", methods=["GET", "POST"])
@requer("mecanico", "gerente")
def lancar_peca():
    passos = []
    if request.method == "POST":
        id_os = request.form["id_os"]
        id_peca = request.form["id_peca"]
        qtd = int(request.form["quantidade"] or 0)
        conn = db()
        try:
            cur = conn.cursor()
            conn.start_transaction()
            passos.append("START TRANSACTION")
            cur.execute("SET @usuario_app = %s", (session["login"],))

            # 1) lanca a peca com o preco do momento (RN10)
            cur.execute("INSERT INTO os_peca (id_os, id_peca, quantidade, "
                        "preco_unitario_praticado) "
                        "SELECT %s, id_peca, %s, preco_atual FROM peca WHERE id_peca = %s",
                        (id_os, qtd, id_peca))
            passos.append(f"INSERT INTO os_peca -> {cur.rowcount} linha(s)")

            # 2) baixa o estoque so se houver quantidade suficiente (RN09)
            cur.execute("UPDATE peca SET estoque_atual = estoque_atual - %s "
                        "WHERE id_peca = %s AND estoque_atual >= %s",
                        (qtd, id_peca, qtd))
            passos.append(f"UPDATE peca (baixa de estoque) -> {cur.rowcount} linha(s)")

            if cur.rowcount == 0:
                conn.rollback()
                passos.append("ROLLBACK (estoque insuficiente: nada foi gravado)")
                cur.execute("SELECT estoque_atual FROM peca WHERE id_peca = %s", (id_peca,))
                disp = cur.fetchone()[0]
                flash(f"Estoque insuficiente (disponivel: {disp}). Nada foi alterado.", "erro")
            else:
                conn.commit()
                passos.append("COMMIT")
                cur.execute("SELECT nome, estoque_atual FROM peca WHERE id_peca = %s", (id_peca,))
                nome, resto = cur.fetchone()
                flash(f"{qtd} unidade(s) de {nome} lancada(s) na OS {id_os}. "
                      f"Estoque restante: {resto}.", "ok")
        except mysql.connector.Error as e:
            conn.rollback()
            passos.append(f"ERRO {e.errno} -> ROLLBACK")
            flash(traduzir_erro(e), "erro")
        finally:
            conn.close()
    lista_os = consultar("SELECT id_os, placa, modelo, status_atual FROM vw_os_oficina "
                         "ORDER BY id_os")
    lista_pecas = consultar("SELECT id_peca, nome, estoque_atual FROM peca ORDER BY nome")
    return render_template("lancar_peca.html", lista_os=lista_os,
                           lista_pecas=lista_pecas, passos=passos)


# ----------------------------------------------------------------------
# Mudar status da OS (dispara o gatilho de auditoria e historico)
# ----------------------------------------------------------------------
STATUS = ["aberta", "em execucao", "aguardando peca", "concluida", "entregue"]


@app.route("/status-os", methods=["GET", "POST"])
@requer("atendente", "mecanico", "gerente")
def status_os():
    if request.method == "POST":
        conn = db()
        try:
            cur = conn.cursor()
            conn.start_transaction()
            cur.execute("SET @usuario_app = %s", (session["login"],))
            cur.execute("SET @obs_status = %s", (vazio_para_none(request.form.get("obs")),))
            cur.execute("UPDATE ordem_servico SET status_atual = %s WHERE id_os = %s",
                        (request.form["status"], request.form["id_os"]))
            conn.commit()
            flash("Status atualizado e registrado no historico.", "ok")
        except mysql.connector.Error as e:
            conn.rollback()
            flash(traduzir_erro(e), "erro")
        finally:
            conn.close()
    if session["perfil"] == "mecanico":
        lista_os = consultar("SELECT id_os, placa, status_atual FROM vw_os_oficina ORDER BY id_os")
    else:
        lista_os = consultar("SELECT os.id_os, v.placa, os.status_atual FROM ordem_servico os "
                             "JOIN veiculo v ON v.id_veiculo = os.id_veiculo "
                             "WHERE os.status_atual <> 'entregue' ORDER BY os.id_os")
    return render_template("status_os.html", lista_os=lista_os, status=STATUS)


# ----------------------------------------------------------------------
# Auditoria (somente leitura, gerente)
# ----------------------------------------------------------------------
@app.route("/auditoria")
@requer("gerente")
def auditoria():
    linhas = consultar("SELECT * FROM auditoria ORDER BY id_auditoria DESC")
    return render_template("auditoria.html", linhas=linhas)


if __name__ == "__main__":
    app.run(debug=False, port=5000)
