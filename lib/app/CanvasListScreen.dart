import 'package:flutter/material.dart';
import 'package:online_canvas_drawer/app/CreateOrEnterScreen.dart';
import 'package:online_canvas_drawer/app/Mapper.dart';
import 'package:online_canvas_drawer/app/OnlineCanvasScreen.dart';
import 'package:online_canvas_drawer/app/Storage.dart';
import 'package:online_canvas_drawer/app/core/CanvasData.dart';

class CanvasListScreen extends StatefulWidget {
  @override
  _CanvasListScreenState createState() => _CanvasListScreenState();
}

class _CanvasListScreenState extends State<CanvasListScreen> {
  bool loading;
  List<CanvasData> datas = <CanvasData>[];

  @override
  initState(){
    loading = true;
    canvasStorage.list().then((datas) {
      this.datas = datas;
      loading = false;
      setState((){});
    });
    super.initState();
  }
  Storage<CanvasData> canvasStorage = Storage(CanvasMapper());
  List<Widget> buildCanvasList(){
    List<Widget> dataWidgets = <Widget>[];

    for(CanvasData c in datas){
      dataWidgets.add(ListTile(title: Text(c.name, ), subtitle: Text(c.players.length.toString() + " jogadores, " + c.date.toIso8601String()), onTap: () => canvasOnTap(c),));
    }


    if(datas.length <= 0){
      dataWidgets.add(Container(alignment: Alignment.center, child: Text("Nenhum canvas encontrado"),));
    }

    return dataWidgets;

  }

  void canvasOnTap(CanvasData data){
    Navigator.push(context, MaterialPageRoute(builder: (c) => CanvasScreenDetail(data)));
  }

  void newCanvasOnTap(){
    Navigator.push(context, MaterialPageRoute(builder: (c) => CreateOrEnterScreen()));
  }

  Future<void> refreshCanvasList() async{
    List<CanvasData> newData = await canvasStorage.list();
    this.datas = newData;
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading ? Center(child: CircularProgressIndicator(),) : RefreshIndicator(
        onRefresh: refreshCanvasList,
        child: ListView(
          children: buildCanvasList()
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: newCanvasOnTap, label: Text("Novo canvas"),),
    );
  }
}
