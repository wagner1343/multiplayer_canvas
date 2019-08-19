import 'dart:io';

import 'package:flutter/material.dart';
import 'package:online_canvas_drawer/app/OnlineCanvasScreen.dart';

class CreateOrEnterScreen extends StatefulWidget {
  @override
  _CreateOrEnterScreenState createState() => _CreateOrEnterScreenState();
}

class _CreateOrEnterScreenState extends State<CreateOrEnterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  TextEditingController portController = TextEditingController();

  void createOnTap() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (c) => OnlineCanvasScreen(
                  name: nameController.text,
                  date: DateTime.now(),
              port: int.parse(portController.text),
                )));
  }

  void enterOnTap() async{
    List<String> ipPort = addressController.text.split(":");
    print(ipPort);
    Socket socket = await Socket.connect(ipPort[0], int.parse(ipPort[1]));

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => OnlineCanvasScreen(
      name: "Online",
      date: DateTime.now(),
      socket: socket,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        alignment: Alignment.center,
        child: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Nome do canvas"),
                ),
                TextField(
                  controller: portController,
                  decoration: InputDecoration(hintText: "Porta do servidor a ser criado"),
                ),
                SizedBox(height: 8,),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(64)),
                    onPressed: createOnTap,
                    child: Text("Criar novo canvas"),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(hintText: "ip:porta do canvas"),
                ),
                SizedBox(height: 8,),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(64)),
                      onPressed: enterOnTap,
                      child: Text("Entrar em um canvas existente")),
                ),
              ],
            )),
      ),
    );
  }
}
