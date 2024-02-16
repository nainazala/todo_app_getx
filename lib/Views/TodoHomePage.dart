import 'dart:ffi';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/ModelClass.dart';
import '../Model/ModelTODO.dart';
import '../OpenseaController.dart';
import '../Utils/DatabaseHelper.dart';
import '../Utils/GlobalColorCode.dart';
import '../Utils/GlobalConstant.dart';
import '../Utils/GlobalTextStyle.dart';
import 'TodoUpdatePage.dart';

class TodoHomePage extends StatelessWidget {
  OpenseaController openseaController = Get.put(OpenseaController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Todo App'),
        ),
        body: Obx(
          () => openseaController.isloading.value == true
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: openseaController.fetchedList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 5,
                            shadowColor: Colors.black,
                            color: COLOR_CODE_WHITE,
                            surfaceTintColor: COLOR_CODE_WHITE,
                            margin: EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        openseaController
                                            .fetchedList[index].title
                                            .toString(),
                                        style: TextStyle_PURPLE_W400_18,
                                      ),
                                      Expanded(child: Container()),
                                      InkWell(
                                          onTap: () {
                                            ModelTODO model = openseaController
                                                .fetchedList[index];
                                            showBottomSheetUpdateTask(
                                                model, context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Icon(
                                              Icons.edit,
                                              color: COLOR_CODE_RED,
                                              size: 25,
                                            ),
                                          )),
                                      InkWell(
                                          onTap: () {
                                            _Deletequery(openseaController
                                                .fetchedList[index].id);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Icon(
                                              Icons.cancel,
                                              color: COLOR_CODE_RED,
                                              size: 25,
                                            ),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        openseaController
                                            .fetchedList[index].status
                                            .toString(),
                                        style: TextStyle_BLACK_W400_14,
                                      ),
                                      Expanded(child: Container()),
                                      Text(
                                        openseaController
                                            .fetchedList[index].timer
                                            .toString(),
                                        style: TextStyle_PURPLE_W400_18,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        openseaController
                                            .fetchedList[index].description
                                            .toString(),
                                        style: TextStyle_BLACK_W400_14,
                                      ),
                                      Expanded(child: Container()),
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: openseaController
                                                      .fetchedList[index]
                                                      .isplay ==
                                                  false
                                              ? Icon(
                                                  Icons.play_arrow,
                                                  color: COLOR_CODE_GREEN,
                                                  size: 30,
                                                )
                                              : Icon(
                                                  Icons.pause,
                                                  color: COLOR_CODE_GREEN,
                                                  size: 30,
                                                ),
                                        ),
                                        onTap: () {
                                          if (openseaController
                                                  .fetchedList[index].isplay ==
                                              true) {
                                            openseaController.fetchedList[index]
                                                .isplay = false;
                                          } else {
                                            openseaController.fetchedList[index]
                                                .isplay = true;
                                          }
                                          openseaController.fetchedList.refresh();
                                          print(openseaController.fetchedList[index].isplay);

                                          if (openseaController.fetchedList[index].isplay == false) {
                                            openseaController.start.value = 60;
                                            openseaController.startTimer(index);
                                          } else {
                                            print(openseaController.fetchedList[index].timer);
                                            if(openseaController.timer!=null)
                                            openseaController.timer!.cancel();
                                            ModelClass modelClass = ModelClass(
                                                title: openseaController.fetchedList[index].title,
                                                description: openseaController.fetchedList[index]
                                                    .description,
                                                timer: openseaController.fetchedList[index].timer,
                                                status:
                                                openseaController.fetchedList[index].status);
                                            ModelTODO model =
                                            openseaController.fetchedList[index];
                                            _Updatequery(modelClass, model);
                                          }


                                          // openseaController.query();
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              showBottomSheetAddTask(context);
                            },
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: COLOR_CODE_PURPLE),
                              child: Text("Add TODO",
                                  style: TextStyle_BLACK_W500_16),
                            ),
                          ),
                        ))
                  ],
                ),
        ));
  }

  _Deletequery(int? id) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    databaseHelper.delete(id!);
    List<Map> result = await db!.query(DatabaseHelper.table);
    result.forEach((row) => print(row));
    openseaController.fetchedList.value =
        result.map((f) => ModelTODO.fromJson(f)).toList();
    openseaController.isloading.value = false;
    openseaController.query();
  }

  _Insertquery(ModelClass modelClass) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    databaseHelper.insert(modelClass);
    // get all rows
    List<Map> result = await db!.query(DatabaseHelper.table);
    // print the results
    result.forEach((row) => print(row));
    openseaController.fetchedList.value =
        result.map((f) => ModelTODO.fromJson(f)).toList();
    openseaController.isloading.value = false;
  }

  void showBottomSheetAddTask(BuildContext context) {
    openseaController.textEditTitle.text = "";
    openseaController.textEditDescription.text = "";
    openseaController.dropdownMenuItems =
        buildDropdownMenuItems(openseaController.statusList);
    openseaController.selectedCaption.value =
        openseaController.dropdownMenuItems![0].value.toString();
    openseaController.textEditTime.text = "0:0";
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(FIXED_SIZE_10))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
            return AnimatedPadding(
                padding: MediaQuery.of(context1).viewInsets,
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Container(
                    padding: const EdgeInsets.only(
                      left: FIXED_SIZE_20,
                      right: FIXED_SIZE_20,
                      top: FIXED_SIZE_20,
                      bottom: FIXED_SIZE_10,
                    ),
                    margin: const EdgeInsets.only(bottom: FIXED_SIZE_10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(strTitle, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: openseaController.textEditTitle,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strDescription, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: openseaController.textEditDescription,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strStatus, style: TextStyle_BLACK_W500_16),
                          Container(
                            height: FIXED_SIZE_50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(FIXED_SIZE_8),
                              color: COLOR_CODE_WHITE,
                              border: Border.all(
                                  width: FIXED_SIZE_1,
                                  color: COLOR_CODE_BLACK,
                                  style: BorderStyle.solid),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                items: openseaController.dropdownMenuItems,
                                value: openseaController.selectedCaption.value,
                                onChanged: (Object? value1) {
                                  setState1(() {
                                    openseaController.selectedCaption.value =
                                        value1.toString();
                                  });
                                },
                                buttonHeight: FIXED_SIZE_40,
                                itemHeight: FIXED_SIZE_50,
                                isExpanded: true,
                                itemPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                dropdownDecoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(FIXED_SIZE_14),
                                  color: COLOR_CODE_WHITE,
                                ),
                                buttonPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Timer", style: TextStyle_BLACK_W500_16),
                          InkWell(
                            onTap: () async {
                              List<String> list = openseaController
                                  .textEditTime.text
                                  .split(":");
                              TimeOfDay initialTime = TimeOfDay(
                                  hour: int.parse(list[0]),
                                  minute: int.parse(list[1]));

                              // TimeOfDay initialTime = TimeOfDay.now();
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context1,
                                initialTime: initialTime,
                              );
                              openseaController.textEditTime.text =
                                  pickedTime!.hour.toString() +
                                      ":" +
                                      pickedTime.minute.toString();
                            },
                            child: TextField(
                              controller: openseaController.textEditTime,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                filled: true,
                                enabled: false,
                                prefixIcon: Icon(Icons.timer),
                                fillColor: COLOR_CODE_WHITE,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: COLOR_CODE_PURPLE, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  String validation = '';
                                  openseaController.textEditTitle.text.isEmpty
                                      ? validation = 'Please enter Title'
                                      : openseaController
                                              .textEditDescription.text.isEmpty
                                          ? validation =
                                              'Please enter Description'
                                          : '';
                                  if (validation == "") {
                                    ModelClass modelClass = ModelClass(
                                        title: openseaController
                                            .textEditTitle.text,
                                        description: openseaController
                                            .textEditDescription.text,
                                        timer:
                                            openseaController.textEditTime.text,
                                        status: openseaController
                                            .selectedCaption.value);
                                    _Insertquery(modelClass);
                                    Navigator.of(context1).pop(true);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: validation,
                                      backgroundColor: COLOR_CODE_PURPLE,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context1).size.width / 2 -
                                          25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Save",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context1).pop(false);
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context1).size.width / 2 -
                                          25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Cancel",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )));
          });
        }).then((value) => openseaController.query());
  }

  void showBottomSheetUpdateTask(ModelTODO model, BuildContext context) {
    openseaController.textEditTitle.text = model.title.toString();
    openseaController.textEditDescription.text = model.description.toString();
    openseaController.dropdownMenuItems =
        buildDropdownMenuItems(openseaController.statusList);
    openseaController.selectedCaption.value = model.status.toString();

    openseaController.textEditTime.text = model.timer.toString();

    print(model.timer);
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(FIXED_SIZE_10))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
            return AnimatedPadding(
                padding: MediaQuery.of(context1).viewInsets,
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Container(
                    padding: const EdgeInsets.only(
                      left: FIXED_SIZE_20,
                      right: FIXED_SIZE_20,
                      top: FIXED_SIZE_20,
                      bottom: FIXED_SIZE_10,
                    ),
                    margin: const EdgeInsets.only(bottom: FIXED_SIZE_10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(strTitle, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: openseaController.textEditTitle,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strDescription, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: openseaController.textEditDescription,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strStatus, style: TextStyle_BLACK_W500_16),
                          Container(
                            height: FIXED_SIZE_50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(FIXED_SIZE_8),
                              color: COLOR_CODE_WHITE,
                              border: Border.all(
                                  width: FIXED_SIZE_1,
                                  color: COLOR_CODE_BLACK,
                                  style: BorderStyle.solid),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                items: openseaController.dropdownMenuItems,
                                value: openseaController.selectedCaption.value,
                                onChanged: (Object? value1) {
                                  setState1(() {
                                    openseaController.selectedCaption.value =
                                        value1.toString();
                                  });
                                },
                                buttonHeight: FIXED_SIZE_40,
                                itemHeight: FIXED_SIZE_50,
                                isExpanded: true,
                                itemPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                dropdownDecoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(FIXED_SIZE_14),
                                  color: COLOR_CODE_WHITE,
                                ),
                                buttonPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Timer", style: TextStyle_BLACK_W500_16),
                          InkWell(
                            onTap: () async {
                              List<String> list = openseaController
                                  .textEditTime.text
                                  .split(":");
                              TimeOfDay initialTime = TimeOfDay(
                                  hour: int.parse(list[0]),
                                  minute: int.parse(list[1]));

                              print(initialTime);

                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );
                              openseaController.textEditTime.text =
                                  pickedTime!.hour.toString() +
                                      ":" +
                                      pickedTime.minute.toString();
                            },
                            child: TextField(
                              controller: openseaController.textEditTime,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                filled: true,
                                enabled: false,
                                prefixIcon: Icon(Icons.timer),
                                fillColor: COLOR_CODE_WHITE,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: COLOR_CODE_PURPLE, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  String validation = '';
                                  openseaController.textEditTitle.text.isEmpty
                                      ? validation = 'Please enter Title'
                                      : openseaController
                                              .textEditDescription.text.isEmpty
                                          ? validation =
                                              'Please enter Description'
                                          : '';
                                  if (validation == "") {
                                    ModelClass modelClass = ModelClass(
                                        title: openseaController
                                            .textEditTitle.text,
                                        description: openseaController
                                            .textEditDescription.text,
                                        timer:
                                            openseaController.textEditTime.text,
                                        status: openseaController
                                            .selectedCaption.value);
                                    _Updatequery(modelClass, model);
                                    Navigator.of(context).pop();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: validation,
                                      backgroundColor: COLOR_CODE_PURPLE,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Save",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Cancel",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )));
          });
        }).then((value) => openseaController.query());
  }

  _Updatequery(ModelClass modelClass, ModelTODO model) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    databaseHelper.update(modelClass, model.id);
    openseaController.query();
    // get all rows
    // List<Map> result = await db!.query(DatabaseHelper.table);
    // // print the results
    // result.forEach((row) => print(row));
    // openseaController.isloading.value = false;
    // openseaController.fetchedList.value = [];
    // openseaController.fetchedList.value =
    //     result.map((f) => ModelTODO.fromJson(f)).toList();
  }

  List<DropdownMenuItem<Object>> buildDropdownMenuItems(List captions) {
    List<DropdownMenuItem<Object>> items = [];
    for (Object value in captions as Iterable<Object>) {
      items.add(DropdownMenuItem(
        alignment: Alignment.centerLeft,
        value: value,
        child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              value.toString(),
              style: TextStyle_BLACK_W400_14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
      ));
    }

    return items;
  }
}
