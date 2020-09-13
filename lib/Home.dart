import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minhas_anotacoes_CRUD_SQLite/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes_CRUD_SQLite/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTelaCadastro({Anotacao anotacao}) {
    String textoSalvarAtualizar = "";
    if (anotacao == null) {
      //salvando
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      //atualizar
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: AlertDialog(
              shape: Border.all(
                width: 3,
                color: Color.fromRGBO(33, 150, 243, 2),
              ),
              title: Text("$textoSalvarAtualizar anotação",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.blueAccent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _tituloController,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: "Título", hintText: "Digite título..."),
                  ),
                  TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                        labelText: "Descrição",
                        hintText: "Digite descrição..."),
                  )
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    //salvar
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);

                    Navigator.pop(context);
                  },
                  child: Text(
                    textoSalvarAtualizar,
                  ),
                ),
              ],
            ),
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>();
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = null;

    //print("Lista anotacoes: " + anotacoesRecuperadas.toString() );
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      //salvar
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      //atualizar
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    //Year -> y month-> M Day -> d
    // Hour -> H minute -> m second -> s
    //var formatador = DateFormat(" d/MMMM/y H:m:s");
    var formatadorBr = DateFormat.yMMMEd("pt_BR");
    var formatadorHm = DateFormat.Hm("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatadorBr.format(dataConvertida);
    String dataFormatada2 = formatadorHm.format(dataConvertida);

    return dataFormatada + ' ' + dataFormatada2;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);

    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Color.fromRGBO(33, 150, 243, 5),
        elevation: 5,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.turned_in_not),
            onPressed: () {
              _exibirTelaCadastro();
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SingleChildScrollView(
                        child: CupertinoAlertDialog(
                          title: Text(
                            "Ajuda",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                " \n   Para excluir arraste para direita, \n\n   Para alterar arraste para esquerda. ",
                                style: TextStyle(
                                  color: Color(0xff171938),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(0),
                              child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "OK",
                                  style: TextStyle(color: Colors.blue),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index) {
                final anotacao = _anotacoes[index];

                return Dismissible(
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _exibirTelaCadastro(anotacao: anotacao);
                    } else if (direction == DismissDirection.startToEnd) {
                      _removerAnotacao(anotacao.id);

                      final snackbar = SnackBar(
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 3),
                        content: Text("Tarefa removida!!"),
                      );
                      Scaffold.of(context).showSnackBar(snackbar);
                    }
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.green,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.blue),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(20.0),
                          bottomLeft: const Radius.circular(20.0),
                          bottomRight: const Radius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            anotacao.titulo,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(5),
                              ),
                              Text(
                                "${anotacao.descricao}",
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Color(0xff171938),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                '${_formatarData(anotacao.data)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 20,
          child: Icon(Icons.add),
          onPressed: () {
            _exibirTelaCadastro();
          }),
    );
  }
}
