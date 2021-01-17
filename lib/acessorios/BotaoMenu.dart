import 'package:flutter/material.dart';

class BotaoMenu extends StatelessWidget {

  final IconData icone;
  final String nomBotao;
  final PageController pageController;
  //vai conter o numero para indicar ao sistema a qual pagina ir quando clicar no botao
  final int tela;

  BotaoMenu(this.icone, this.nomBotao, this.pageController, this.tela);

  @override
  Widget build(BuildContext context) {
    //Material e InkWell é para ter efeito visual ao clicar no botao
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Navigator.of(context).pop();
          pageController.jumpToPage(tela);
        },
        child: Container(
          height: 50.0,
          child: Row(
            children: <Widget>[
              Icon(icone,
                size: 32.0,
                color: pageController.page.round() == tela ? Colors.white : Colors.black,),
              //o round eh pq o pageController.page retorna um double que é mto proximo ao numero da
              //pagina que o sistema esta, usando o round, o numero fica correto
              SizedBox(width: 17.0,), //para colocar espaco entre icone e texto
              Text(nomBotao, style: TextStyle(
                  fontSize: 20.0,
                  color: pageController.page.round() == tela ? Colors.white : Colors.black),)
            ],
          ),
        ),
      ),
    );
  }
}
