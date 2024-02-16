import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqflite/sqflite.dart';

import 'Model/ModelTODO.dart';
import 'Utils/DatabaseHelper.dart';

class OpenseaController extends GetxController {

  List<DropdownMenuItem<Object>>? dropdownMenuItems ;

  var selectedCaption = "".obs;
  List<Object> statusList = ['TODO', 'In-Progress', 'Done'].obs;
  var fetchedList = <ModelTODO>[].obs;
  TextEditingController textEditTitle = TextEditingController();
  TextEditingController textEditDescription = TextEditingController();
  TextEditingController textEditTime = TextEditingController();
  var isloading = true.obs;
  // var isplay = false.obs;
  Timer? timer   ;
  var start = 60.obs;


  @override
  Future<void> onInit() async {
    super.onInit();

    query();
  }

  query() async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    // get all rows
    List<Map> result = await db!.query(DatabaseHelper.table);
    // print the results
    result.forEach((row) => print(row));

    fetchedList.value =
        result.map((f) => ModelTODO.fromJson(f)).toList();
    isloading.value = false;
  }

  void startTimer(int index) {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start.value == 0) {
          List<String> list = fetchedList[index].timer.toString().split(":");
          fetchedList[index].timer =
              list[0] + ":" + (int.parse(list[1]) + 1).toString();
          fetchedList
              .refresh();
          // setState(() {
            start.value = 60;
          // });
        } else {
          print(start.value);

          // setState(() {
            start.value--;

          // });
        }
      },
    );
  }
}