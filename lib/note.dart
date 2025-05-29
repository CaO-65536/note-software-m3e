import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
//import 'package:flutter/scheduler.dart';
//import 'package:learn/settings.dart';

Future<void> clearJson() async {
  File noteFile = File(r'C:\Users\Public\note_files\notes.json');
  File varFile = File(r'C:\Users\Public\note_files\var.txt');

  await varFile.writeAsString('0');
  await noteFile.writeAsString('{}');
}

Future<void> writeJson(Map<String, dynamic> content) async {
  try {
    File noteFile = File(r'C:\Users\Public\note_files\notes.json');

    Map<String, dynamic> existingData = {};
    if (await noteFile.exists()) {
      String existingContent = await noteFile.readAsString();
      try {
        existingData = jsonDecode(existingContent);
      } catch (e) {
        developer.log('Error decoding JSON: $e');
      }
    }
    if (existingData.isNotEmpty) {
      Map<String, dynamic> tempData = existingData;
      existingData = {...tempData, ...content};
    } else {
      existingData = content;
    }
    await noteFile.writeAsString(jsonEncode(existingData));
  } catch (e) {
    developer.log('Error writing file: $e');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String content = "FARQ";
  bool isIncludeTime = false;
  bool isHighlight = false;
  final _titleTxt = TextEditingController();
  final _noteTitle = TextEditingController();

  bool flag = true;

  List<Map<String, String>> cardData = [];

  void _addCard(String cardTitle, String cardContent, String cardState) {
    setState(() {
      cardData.add({
        'title': cardTitle,
        'content': cardContent,
        'state': cardState
      });
    });
  }

  void _removeCard() {
    setState(() {
      cardData.clear();
    });
  }

  Future<void> _deleteCardIndex(int index) async {    
     File noteFile = File(r'C:\Users\Public\note_files\notes.json');
     File countVar = File(r'C:\Users\Public\note_files\var.txt');

     try{
      String str = await noteFile.readAsString();
      Map<String, dynamic> existingData = jsonDecode(str);

      int num = index + 1;
      existingData.remove('time$num');
      existingData.remove('note$num');
      existingData.remove('state$num');

      Map<String, dynamic> newData = {};
      int newIndex = 1;
      for (int i = 1; i <= cardData.length; i++) {
        if (i != num) {
          newData['time$newIndex'] = existingData['time$i'];
          newData['note$newIndex'] = existingData['note$i'];
          newData['state$newIndex'] = existingData['state$i'];
          newIndex++;
        }
      }

      int cs = newIndex - 1;
      await countVar.writeAsString('$cs');
      await noteFile.writeAsString(jsonEncode(newData));
     }catch(e){
      developer.log('Error loading cards: $e');
     }
    cardData.removeAt(index);
  }

  Future<void> _loadCards() async {
    cardData.clear();
    File noteFile = File(r'C:\Users\Public\note_files\notes.json');
    File countVar = File(r'C:\Users\Public\note_files\var.txt');

    try {
      if (await countVar.exists()) {
        String noteNum = await countVar.readAsString();
        int notenumUpdated = int.parse(noteNum);

        if(notenumUpdated != 0){
          if (await noteFile.exists()) {
            String existingContent = await noteFile.readAsString();

            Map<String, dynamic> existingData = jsonDecode(existingContent);
            for (int i = 1; i <= notenumUpdated; i++) {
                _addCard(existingData['time$i'], existingData['note$i'], existingData['state$i']);          
            }
          }
        }else{
          cardData.clear();
        } 
      }
    } catch (e) {
      developer.log('Error loading cards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if(flag){
      _loadCards();
      flag = false;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'clearNote',
                  child: Text('清除筆記'),
                ),

                const PopupMenuItem<String>(
                  value: 'aboutMe',
                  child: Text('關於'),
                )
              ];
            },
            onSelected: (String value) {
              if (value == 'clearNote') {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('清除所有筆記？'),
                      content: Text('這將會永久的刪除它們（真的很久！）'),
                      //backgroundColor: Colors.transparent,

                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            OutlinedButton(
                              child: Text('取消'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),

                            SizedBox(width: 8,),

                            FilledButton(
                              child: Text('確定'),
                              onPressed: () {
                                clearJson();
                                _removeCard();
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        )
                      ],
                    );
                  },
                );
              }
              if (value == 'aboutMe') {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('關於程式'),
                      content: Text('市面上的桌面便簽要麽價格高昂（對學生黨而言）要麽資源占用超高（60% RAM）所以我做了這個程式=w=\n\n因爲這個程式只打算給同學們用所以請不要隨意分發>_<\n\n可能有些功能實現方式過於粗暴(\n因爲製作這個程式的時候我的知識還是太過匱乏...給您造成困擾真的很對不起>w<\n\n-程式信息-\nProgram Work by CJ (Senior High Class 2)\n工具：Flutter & VS Code\n語言：Dart'),
                      
                      actions: [
                        FilledButton(
                          child: Text('瞭解'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          )
        ],
      ),

      body: ListView.builder(
        itemCount: cardData.length,
        itemBuilder: (context, index) {
          return Card(
            color: cardData[index]['state'] == 'enabled'?null:Color(0xffba1a1a),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: ListTile(
                    title: Text(cardData[index]['title']!, style: TextStyle(fontSize: 18, color: cardData[index]['state'] == 'enabled'?null:Color(0xffffdad6)),),
                    subtitle: SelectableText(cardData[index]['content']!, style: TextStyle(fontSize: 22, color: cardData[index]['state'] == 'enabled'?null:Color(0xffffffff)),),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,

                  child: IconButton(
                    icon: Icon(Icons.close, color: cardData[index]['state'] == 'enabled'?null:Color(0xffffdad6)),
                    onPressed: () async{
                      showCupertinoDialog(
                        context: context, 
                        builder: (context){
                          return AlertDialog(
                            title: Text('刪除這份筆記？'),
                            content: Text('該操作不可回退'),

                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,

                                children: <Widget>[
                                  OutlinedButton(
                                    child: Text('取消'),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  SizedBox(width: 8,),

                                  FilledButton(
                                    child: Text('確定'),
                                    onPressed: () async{
                                      await _deleteCardIndex(index);
                                      _removeCard();
                                      await _loadCards();

                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              )
                            ],
                          );
                        }
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 48,

                  child: IconButton(
                    icon: Icon(Icons.copy, size: 18,color: cardData[index]['state'] == 'enabled'?null:Color(0xffffdad6),),

                    onPressed: ()async{
                      await Clipboard.setData(ClipboardData(text: '${cardData[index]['content']}'));

                      showCupertinoDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: Text('Copy Succeed!'),

                          actions: [FilledButton(onPressed: (){Navigator.of(context).pop();}, child: Text('OK'))],
                        );
                      });
                    },
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 88,

                  child: IconButton(
                    icon: Icon(Icons.edit, size: 18,color: cardData[index]['state'] == 'enabled'?null:Color(0xffffdad6)),

                    onPressed: (){
                      final _editText = TextEditingController(text: '${cardData[index]['content']}');
                      final _editTitle = TextEditingController(text: '${cardData[index]['title']}');
                      bool _isHighlighted = cardData[index]['state'] == 'highlight'?true:false;

                      showCupertinoDialog(
                        context: context,
                        builder: (context){
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState){
                              return AlertDialog(
                                title: Text('修改筆記'),

                                actions: [
                                  TextField(
                                    controller: _editTitle,
                                    minLines: 1,
                                    maxLines: 10,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '在這裏輸入新的筆記标题',
                                    ),
                                  ),

                                  SizedBox(height: 14,),

                                  TextField(
                                    controller: _editText,
                                    minLines: 1,
                                    maxLines: 10,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '在這裏輸入新的筆記内容',
                                    ),
                                  ),

                                  SizedBox(height: 14,),

                                  SwitchListTile(
                                    title: Text('高亮便簽'),
                                    subtitle: Text('變更高亮狀態'),
                                    value: _isHighlighted, 
                                    onChanged: (bool value){
                                      setState(() {
                                        _isHighlighted = value;
                                      });
                                    }
                                  ),

                                  SizedBox(height: 14,),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,

                                    children: <Widget>[
                                      OutlinedButton(
                                        child: Text('取消'),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      ),

                                      SizedBox(width: 8,),

                                      FilledButton(
                                        child: Text('確定'),

                                        onPressed: ()async{
                                          Map<String,dynamic> edited = {};
                                          File noteFile = File(r'C:\Users\Public\note_files\notes.json');
                                          String str = await noteFile.readAsString();
                                          edited = jsonDecode(str);

                                          edited['note${index + 1}'] = _editText.text;
                                          edited['state${index + 1}'] = _isHighlighted?'highlight':'enabled';

                                          if(_editTitle.text != ''){
                                            edited['time${index + 1}'] = _editTitle.text;
                                          }

                                          await noteFile.writeAsString(jsonEncode(edited));
                                          _removeCard();
                                          _loadCards();

                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  )
                                ],
                              );
                            }
                          );
                        }
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),

      //floatingActionButtonLocation: FloatingActionButtonLocation.,
      //FAB
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          showModalBottomSheet(showDragHandle: true,context: context, builder: (context){
            return Padding(
              padding: EdgeInsets.only(
                //top: 12.0,
                right: 12.0,
                left: 12.0
              ),

              child: Container(
              //color: Theme.of(context).colorScheme.surface,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0)
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: <Widget>[
                    Text('Add Note',style: TextStyle(fontSize: 24.0),),

                    SizedBox(height: 16,),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0)
                        ),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),

                      child: ListTile(
                        title: Text('Text Note'),
                        subtitle: Text('Create a note with just text.'),

                        onTap: () {
                          Navigator.of(context).pop();
                          showCupertinoSheet(enableDrag: false,context: context, pageBuilder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  _noteTitle.clear();
                  return AlertDialog(
                    title: Text('新增一篇筆記'),
                    actions: [
                      TextField(
                        controller: _noteTitle,
                        minLines: 1,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '輸入標題（留空則為Note）',
                        ),
                      ),

                      SizedBox(height: 8,),

                      TextField(
                        controller: _titleTxt,
                        minLines: 1,
                        maxLines: 10,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '在這裏輸入你的筆記内容',
                      ),
                    ),

                    SizedBox(height: 8,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('    選項'),
                    ),

                    SwitchListTile(
                      title: Text('添加時間戳'),
                      subtitle: Text('這個便簽將會附上當前系統時間'),
                      value: isIncludeTime,
                      onChanged: (bool value) {
                        setState(() {
                          isIncludeTime = value;
                        });
                      },
                    ),

                    SwitchListTile(
                      title: Text('高亮便簽'),
                      subtitle: Text('將便簽的背景改爲更顯眼的紅色'),
                      value: isHighlight,
                      onChanged: (bool value) {
                        setState(() {
                          isHighlight = value;
                        });
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,

                      children: <Widget>[
                        OutlinedButton(
                          child: Text('取消'),
                          onPressed: () {
                            _titleTxt.clear();
                            Navigator.of(context).pop();
                          },
                        ),

                        SizedBox(width: 8,),

                        FilledButton(
                          child: Text('完成'),
                          onPressed: () async {
                            //Add Note
                            content = _titleTxt.text;
                            File varPath = File(r'C:\Users\Public\note_files\var.txt');
                            int cs;
                            try {
                              if (await varPath.exists()) {
                                String csVar = await varPath.readAsString();
                                cs = int.parse(csVar);
                              } else {
                                cs = 0;
                              }
                            } catch (e) {
                              cs = 0;
                            }

                            cs++;
                            DateTime dateTime = DateTime.now();
                            DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
                            
                            String formattedDate = formatter.format(dateTime);
                            String defaultTitle = 'Note';
                            Map<String, dynamic> contentConverted = {};

                            defaultTitle = _noteTitle.text == ''?'Note':_noteTitle.text;

                            if (isIncludeTime) {
                              if(isHighlight){
                                contentConverted = {
                                  "time$cs": formattedDate,
                                  "note$cs": content,
                                  "state$cs": "highlight"
                                };
                              }else{
                                contentConverted = {
                                  "time$cs": formattedDate,
                                  "note$cs": content,
                                  "state$cs": "enabled"
                                };
                              }
                            } else {
                              if(isHighlight){
                                contentConverted = {
                                  "time$cs": defaultTitle,
                                  "note$cs": content,
                                  "state$cs": "highlight"
                                };
                              }else{
                                contentConverted = {
                                  "time$cs": defaultTitle,
                                  "note$cs": content,
                                  "state$cs": "enabled"
                                };
                              }
                            }

                            String csVar = '$cs';

                            await writeJson(contentConverted);
                            await varPath.writeAsString(csVar);

                            _titleTxt.clear();
                            await _loadCards();

                            isHighlight = false;
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    )
                  ],
                );
              });
            },);
        //try
                        },
                      ),
                    ),

                    SizedBox(height: 8,),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(24.0),
                          bottomRight: Radius.circular(24.0)
                        )
                      ),

                      child: ListTile(
                        title: Text('Image Note'),
                        subtitle: Text('Create a note with just image.'),

                        onTap: () {
                          Navigator.of(context).pop();
                          showCupertinoSheet(enableDrag: false,context: context, pageBuilder: (context){
                            return AlertDialog(
                              title: Text('别急'),
                              content: Text('施工中❤️...'),

                              actions: [
                                FilledButton(onPressed: (){Navigator.of(context).pop();}, child: Text('好的🖐️😭🖐️'))
                              ],
                            );
                          });
                        },
                      ),
                    )
                  ],
                ),
              )
            ),
          //try,
            );
          });
        },
        //icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondaryContainer,),
        //label: Text('New Note',style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),),
        //backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleTxt.dispose();
    super.dispose();
  }
}