import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:online_canvas_drawer/app/Mapper.dart';
import 'package:online_canvas_drawer/app/Storage.dart';
import 'package:online_canvas_drawer/app/core/CanvasData.dart';
import 'package:online_canvas_drawer/app/core/Player.dart';

class OnlineCanvasScreen extends StatefulWidget {
  OnlineCanvasScreen({this.name, this.date, this.socket, this.port});
  final Socket socket;
  final String name;
  final DateTime date;
  final int port;
  @override
  _OnlineCanvasScreenState createState() =>
      _OnlineCanvasScreenState(name: name, date: date, socket: socket, port: port);
}

class _OnlineCanvasScreenState extends State<OnlineCanvasScreen> {
  int port;

  StreamSubscription socketSub;

  _OnlineCanvasScreenState({this.name, this.date, this.socket, this.port}){
    if(socket == null){
      sockets = <Socket>[];
      listening = true;
      startListening();
    }
    else{
      if(socketSub != null){
        socketSub.cancel();
        print("cancellign old sub");
      }
      socketSub = socket.listen((data) { handleData(data, null);});
    }
  }

  bool listening = false;
  List<Socket> sockets;
  final Socket socket;
  final String name;
  final DateTime date;
  List<Player> players = <Player>[]..add(Player(color: Colors.red));

  double minDistance = 5;
  ServerSocket server;
  StreamSubscription serverSub;
  List<StreamSubscription> socketsSubs = <StreamSubscription>[];

  Future<void> startListening() async{
    server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    serverSub = server.listen((Socket s) {
      sockets.add(s);
      print("novo cliente: " + s.address.toString());

      socketsSubs.add(s.listen((data)  { handleData(data, s);}));

      for(Offset p in players[0].points){
        if(p != null)
        s.add(utf8.encode(p.dx.toString() + ":" + p.dy.toString() + "\n"));
        else{
          s.add(utf8.encode("-1.000000:-1.00000000\n"));
        }
      }
    });
  }

  void handleData(Uint8List data, Socket sender){
    if(sockets != null){
      print("sockets lenght = " + sockets.length.toString());
    }
    print("data.lenght gflushed " + data.length.toString());
    String raw = utf8.decode(data, allowMalformed: true);
    print("raw: "  + raw);
    List<String> rawLines = raw.split("\n");
    for(String s in rawLines){
      print("line: " + s);

      List<String> rawData = s.trim().split(":");
      if(!s.contains(".") || rawData.length > 2) {
        continue;
      }

      Offset p = Offset(double.parse(rawData[0]), double.parse(rawData[1]));
      if(p.dx == -1 && p.dy == -1)
        players[0].points.add(null);
      else{
        players[0].points.add(p);
      }
      if(server != null){
        for(Socket s in sockets){
          if(sender == null || s != sender) {
            s.write(raw);
            print("Broadcasting to " + s.address.toString() + " " + s.address.host);
          }
        }
      }
    }

    setState((){});
  }

  Storage<CanvasData> canvasStorage = Storage(CanvasMapper());

  void exitOnTap() async {
    await canvasStorage
        .save(CanvasData(name: name, date: date, players: players));
    for(StreamSubscription s in socketsSubs){
      s.cancel();
    }

    if(serverSub != null){
      serverSub.cancel();
    }

    if(socketSub != null ){
      socketSub.cancel();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
        child: GestureDetector(
          onPanUpdate: (details) => onPanUpdate(details, context),
          onPanEnd: (details) => onPanEnd(),
          child: CustomPaint(
            painter: PlayerDrawingCanvas(players),
            size: Size.infinite,
          ),
        ),
      ),
      Container(
        height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
        child: AppBar(
          title: Text(name),
          actions: <Widget>[
            IconButton(
              onPressed: exitOnTap,
              icon: Icon(Icons.exit_to_app),
            )
          ],
        ),
      ),
    ]));
  }

  void onPanEnd(){
    print("onpanEnd");
    if(server != null)
      handleData(utf8.encode("-1.0000000:-1.0000000\n"), null);
    else {
      players[0].points.add(null);
      socket.write("-1.000000:-1.00000000\n");
    }
  }

  void onPanUpdate(DragUpdateDetails dragDetails, BuildContext context) {
    setState(() {
      RenderBox box = context.findRenderObject();
      Offset p = box.localToGlobal(dragDetails.globalPosition);
      p = dragDetails.globalPosition;
      if (players[0].points.length <= 0 || players[0].points.last == null) {
        if(server != null)
          handleData(utf8.encode(p.dx.toString() + ":" + p.dy.toString() + "\n"), null);
        else {
          players[0].points.add(p);
          socket.write(p.dx.toString() + ":" + p.dy.toString() + "\n");
        }

      }
      else {
        Offset last = players[0].points.last;
        double distance =
            sqrt(pow((last.dx - p.dx), 2) + pow((last.dy - p.dy), 2));
        if (distance >= minDistance) {
          if(server != null) {
            handleData(utf8.encode(p.dx.toString() + ":" + p.dy.toString() + "\n"), null);
          }
          else {
            players[0].points.add(p);
            socket.write(p.dx.toString() + ":" + p.dy.toString() + "\n");
          }
        }
      }
    });
  }
}

class PlayerDrawingCanvas extends CustomPainter {
  List<Player> players;

  PlayerDrawingCanvas(this.players);

  @override
  void paint(Canvas canvas, Size size) {
    for (Player p in players) {
      Paint paint = Paint();
      paint.color = p.color;
      paint.strokeWidth = 5;

      for (int x = 1; x < p.points.length; x++) {
        if (p.points[x] != null && p.points[x - 1] != null) {
          canvas.drawLine(p.points[x - 1], p.points[x], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PlayerDrawingCanvas oldDelegate) {
    for (int x = 0; x < players.length; x++) {
      return true;
    }

    return false;
  }
}


class CanvasScreenDetail extends StatefulWidget {
  CanvasScreenDetail(this.canvasData);
  final CanvasData canvasData;
  @override
  _CanvasScreenDetailState createState() =>
      _CanvasScreenDetailState(canvasData);
}

class _CanvasScreenDetailState extends State<CanvasScreenDetail> {
  _CanvasScreenDetailState(this.canvasData);

  final CanvasData canvasData;
  Storage<CanvasData> canvasStorage = Storage(CanvasMapper());

  void deleteOnTap() async {
    await canvasStorage
        .delete(canvasData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
          Container(
            child: CustomPaint(
              painter: PlayerDrawingCanvas(canvasData.players),
              size: Size.infinite,
            ),
          ),
          Container(
            height: AppBar().preferredSize.height + MediaQuery
                .of(context)
                .padding
                .top,
            child: AppBar(
              title: Text(canvasData.name),
              actions: <Widget>[
                IconButton(
                  onPressed: deleteOnTap,
                  icon: Icon(Icons.delete),
                )
              ],
            ),
          ),
        ]));
  }
}