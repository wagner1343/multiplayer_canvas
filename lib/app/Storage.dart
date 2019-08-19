import 'dart:io';

import 'package:online_canvas_drawer/app/Mapper.dart';
import 'package:online_canvas_drawer/app/core/Model.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';

class Storage<T extends Model> {
  Storage(this.mapper);
  Mapper<T> mapper;
  String dbName = T.toString();

  dynamic save(T data) async {
    Database db = await open();
    return await db.put(mapper.toMap(data));
  }

  Future<List<T>> list() async {
    Database db = await open();
    List<Record> records = await db.findRecords(Finder());
    List<T> dataList = <T>[];

    for(Record r in records){
      T data = mapper.fromMap(r.value);
      data.id = r.key;
      dataList.add(data);
    }
    return dataList;
  }

  Future<Database> open() async{
    print("db name: " + dbName);
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    return databaseFactoryIo.openDatabase(appDocDirectory.path + "/" + dbName);
  }

  Future<dynamic> deleteAll() async{
    Database db = await open();
    return db.deleteAll(await db.findKeys(Finder()));
  }

  Future<dynamic> delete(T data)  async{
    Database db = await open();
    return db.delete(data.id);
  }
}
