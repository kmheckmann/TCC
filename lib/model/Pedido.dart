import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/Usuario.dart';

//Classe abstrata do pedido
//o extends Modelpermite que outras classes vejam modificações nas classes de pedido
//e se atualizem conforme isso (Usa-se alguma extensões nas outras classes para permitir isso)
abstract class Pedido extends Model {
  String _id;
  //A empresa será o cliente em pedidos de venda e o fornecedor em pedidos de compra
  Empresa _empresa = Empresa();
  Usuario _user = Usuario();
  double _valorTotal;
  double _valorComDesconto;
  double _percentualDesconto;
  String _tipoPagamento;
  bool _ehPedidoVenda;
  DateTime _dataPedido;
  DateTime _dataFinalPedido;
  bool _pedidoFinalizado;
  String _labelTelaPedidos;

  String get getID {
    return _id;
  }

  set setID(String id) {
    _id = id;
  }

  Empresa get getEmpresa {
    return _empresa;
  }

  set setEmpresa(Empresa empresa) {
    _empresa = empresa;
  }

  Usuario get getUser {
    return _user;
  }

  set setUser(Usuario user) {
    _user = user;
  }

  double get getValorTotal {
    return _valorTotal;
  }

  set setValorTotal(double valorTotal) {
    _valorTotal = valorTotal;
  }

  double get getValorDesconto {
    return _valorComDesconto;
  }

  set setValorDesconto(double valorDesc) {
    _valorComDesconto = valorDesc;
  }

  double get getPercentDesconto {
    return _percentualDesconto;
  }

  set setPercentDesconto(double percentDesc) {
    _percentualDesconto = percentDesc;
  }

  String get getTipoPgto {
    return _tipoPagamento;
  }

  set setTipoPgto(String tipoPgto) {
    _tipoPagamento = tipoPgto;
  }

  bool get getEhPedidoVenda {
    return _ehPedidoVenda;
  }

  set setEhPedidoVenda(bool ehPedidoVenda) {
    _ehPedidoVenda = ehPedidoVenda;
  }

  DateTime get getDataPedido {
    return _dataPedido;
  }

  set setDataPedido(DateTime dt) {
    _dataPedido = dt;
  }

  DateTime get getDataFinal {
    return _dataFinalPedido;
  }

  set setDataFinal(DateTime dtFinal) {
    _dataFinalPedido = dtFinal;
  }

  bool get getPedidoFinalizado {
    return _pedidoFinalizado;
  }

  set setPedidoFinalizado(bool finalizado) {
    _pedidoFinalizado = finalizado;
  }

  String get getLabel {
    return _labelTelaPedidos;
  }

  set setLabel(String label) {
    _labelTelaPedidos = label;
  }
}
