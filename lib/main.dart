import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/screens/TelaInicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //O scopedModel eh para conseguir acessar a classe usuario de qualquer lugar do app
    return ScopedModel<UsuarioController>(
      model: UsuarioController(),
      child: MaterialApp(
        title: 'Easy Management',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Color.fromARGB(255, 0, 120, 189)
        ),
        debugShowCheckedModeBanner: false,
        home: TelaInicial(),
      ),
    );
  }
}
