import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/Usuario.dart';

//Classe abstrata do pedido
//o extends Modelpermite que outras classes vejam modificações nas classes de pedido
//e se atualizem conforme isso (Usa-se alguma extensões nas outras classes para permitir isso)
abstract class Pedido extends Model {
  String id;
  //A empresa será o cliente em pedidos de venda e o fornecedor em pedidos de compra
  Empresa empresa = Empresa();
  Usuario user = Usuario();
  double valorTotal;
  double valorComDesconto;
  double percentualDesconto;
  String tipoPagamento;
  bool ehPedidoVenda;
  DateTime dataPedido;
  DateTime dataFinalPedido;
  bool pedidoFinalizado;
  String labelTelaPedidos;
}
