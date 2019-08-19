import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:online_canvas_drawer/app/core/Model.dart';

class Player extends Model{
  Player({this.name = "Novo jogador", this.color = Colors.black, this.points}){
    if(points == null){
      points = <Offset>[];
    }
  }
  String name;
  List<Offset> points = <Offset>[];
  Color color;
}