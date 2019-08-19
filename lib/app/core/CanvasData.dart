import 'package:online_canvas_drawer/app/core/Model.dart';
import 'package:online_canvas_drawer/app/core/Player.dart';

class CanvasData extends Model {
  CanvasData({this.name, this.date, this.players});
  String name;
  DateTime date;
  List<Player> players;
}