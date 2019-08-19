

import 'package:flutter/painting.dart';
import 'package:online_canvas_drawer/app/core/CanvasData.dart';
import 'package:online_canvas_drawer/app/core/Player.dart';

abstract class Mapper<T> {
  Map<dynamic, dynamic> toMap(T t);
  T fromMap(Map<dynamic, dynamic> map);
}

class CanvasMapper implements Mapper<CanvasData> {
  PlayerMapper playerMapper = PlayerMapper();
  @override
  CanvasData fromMap(Map map) {
    List<Player> players = <Player>[];
    List<dynamic> rawPlayers = map["players"] as List<dynamic>;
    for(dynamic d in rawPlayers){
      players.add(playerMapper.fromMap(d));
    }

    return CanvasData(name: map["name"], date: DateTime.fromMillisecondsSinceEpoch(map["millisecondsSinceEpoch"]), players: players);
  }

  @override
  Map toMap(CanvasData t) {
    Map<String, dynamic> map = Map();
    List<dynamic> players = <dynamic>[];
    for(Player p in t.players){
      players.add(playerMapper.toMap(p));
    }
    map["name"] = t.name;
    map["millisecondsSinceEpoch"] = t.date.millisecondsSinceEpoch;
    map["players"] = players;

    return map;
  }

}

class PlayerMapper implements Mapper<Player>{
  @override
  Player fromMap(Map map) {
    List<Offset> points = <Offset>[];
    List<dynamic> rawOffsets = map["points"] as List<dynamic>;
    for(dynamic p in rawOffsets){
      if(p == null)
        points.add(null);
        else
      points.add(Offset(p["dx"], p["dy"]));
    }
    return Player(name: map["name"], color: Color(map["color"]), points: points);
  }

  @override
  Map toMap(Player t) {
    Map<String, dynamic> map = Map();
    List<dynamic> points = <dynamic>[];
    for(Offset p in t.points){
      if(p == null){
        points.add(null);
      }
      else
      points.add({"dx": p.dx, "dy": p.dy});
    }

    map["name"] = t.name;
    map["color"] = t.color.value;
    map["points"] = points;
    return map;
  }

}
