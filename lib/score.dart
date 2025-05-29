import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

class GroupScore extends StatefulWidget {
  const GroupScore({super.key, required this.title});
  final String title;

  @override
  State<GroupScore> createState() => _GroupScoreState();
}

class _GroupScoreState extends State<GroupScore> {
  bool isExpanded = false;
  bool isUnlocked = false;
  List<bool> isExpandedList = List.generate(8, (index) => false);

  File score = File(r'C:\Users\Public\note_files\score.json');
  static Map<String,dynamic> scores = {};
  static bool isDataLoaded = false;

  final controllerScore = TextEditingController();

  Future<void> preLoad() async{
    if (score.existsSync()) {
      String str = await score.readAsString();
      setState(() {
        scores = jsonDecode(str);
        isDataLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (!isDataLoaded) {
      preLoad();
    }
  }

  Future<void> updateScore(int groupIndex, int memberIndex, int changeValue) async {
  try {
    File scoreFile = File(r'C:\Users\Public\note_files\score.json');
    Map<String, dynamic> existingData = {};
    if (scoreFile.existsSync()) {
      String existingContent = await scoreFile.readAsString();
      try {
        existingData = jsonDecode(existingContent);
      } catch (e) {
        developer.log('Error decoding JSON in updateScore: $e');
      }
    }

    String key = 'G$groupIndex-M$memberIndex-score';
    int currentScore = int.tryParse(existingData[key]?? '0')?? 0;
    int newScore = currentScore + changeValue;
    existingData[key] = newScore.toString();

    String jsonStr = jsonEncode(existingData);
    await scoreFile.writeAsString(jsonStr);

    await preLoad(); 
  } catch (e) {
    developer.log('Error updating score: $e');
  }
}

Future<void> clearScore(int groupIndex, int memberIndex) async {
  try {
    File scoreFile = File(r'C:\Users\Public\note_files\score.json');
    Map<String, dynamic> existingData = {};
    if (scoreFile.existsSync()) {
      String existingContent = await scoreFile.readAsString();
      try {
        existingData = jsonDecode(existingContent);
      } catch (e) {
        developer.log('Error decoding JSON in clearScore: $e');
      }
    }

    String key = 'G$groupIndex-M$memberIndex-score';
    int newScore = 0;
    existingData[key] = newScore.toString();

    String jsonStr = jsonEncode(existingData);
    await scoreFile.writeAsString(jsonStr);

    await preLoad(); 
  } catch (e) {
    developer.log('Error updating score: $e');
  }
}

  int loadScore(int index){
    int cs = 0;
    for (int i = 0; i <= 5; i++) {
      var scoreStr = scores['G$index-M$i-score'];
      if (scoreStr != null) {
        try {
          int _str = int.parse(scoreStr);
          cs += _str;
        } catch (e) {
          developer.log('Error parsing score for G$index-M$i: $e');
        }
      }
    }
    return cs;
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.title),
        backgroundColor: Colors.transparent,

        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("清零積分"),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text("加/扣分記錄（未完成）"),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Text('解鎖'),
                )
              ];
            },
            onSelected: (value) async{
              if (value == 0 && isUnlocked == true) {
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text('清空所有積分？'),
                      content: Text('該操作不可回退'),

                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: <Widget>[
                            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消')),

                            TextButton(
                              child: Text('確定'),

                              onPressed: ()async{
                                for(int i=0;i<=7;i++){
                                  for(int j=0;j<=5;j++){
                                    await clearScore(i, j);
                                  }
                                }

                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        )
                      ],
                    );
                  }
                );
              } else if (value == 1) {
                
              } else if (value == 2) {
                final controllerPW = TextEditingController();
                showCupertinoDialog(
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      title: Text('輸入密碼'),
                      content: TextField(
                        controller: controllerPW,
                        obscureText: _obscureText,
                        obscuringCharacter: '·',
                        minLines: 1,
                        maxLines: 1,
                        decoration: InputDecoration(
                          
                          labelText: 'Password',
                        )
                      ),

                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: <Widget>[
                            Expanded(flex: 9,child: SizedBox()),

                            Expanded(flex: 5,child: OutlinedButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消')),),

                            Expanded(flex: 1,child: SizedBox()),

                            Expanded(flex: 5,child: FilledButton(onPressed: (){
                              if(controllerPW.text == 'SbqmyyQmyymm1126'){
                                isUnlocked = true;
                              }

                              _obscureText = true;
                              Navigator.of(context).pop();
                            }, child: Text('確定')))
                          ],
                        )
                      ],
                    );
                  }
                );
              }
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (!isDataLoaded)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        ListTile(
                          title: Text('第${index + 1}小組', style: TextStyle(fontSize: 26),),
                          trailing: Icon(isExpandedList[index]? Icons.expand_less : Icons.expand_more,),
                          onTap: (){
                            setState(() {
                              isExpandedList[index] =!isExpandedList[index];
                            });
                          },
                        ),
                  
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          firstChild: const SizedBox(),
                          secondChild: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: List.generate(6, (newIndex){
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start, 
                                    children: <Widget>[
                                      Expanded(
                                        flex:2,
                                        child: Text('${scores['G$index-M$newIndex-name']?? 'ERR'}', style: TextStyle(fontSize: 20),)
                                      ), 

                                      Expanded(
                                        flex:2,
                                        child: Text('-分數：${scores['G$index-M$newIndex-score']?? 'ERR'}', style: TextStyle(fontSize: 20),)
                                      ),

                                      Expanded(
                                        flex: 1, 
                                        child: TextButton(
                                          onPressed: isUnlocked?() async{
                                            showDialog(
                                              context: context, 
                                              builder: (context){
                                                return AlertDialog(
                                                  title: Text('分數修改'),
                                                  content: Text('該窗口為扣分窗口，請務必確認自己沒有點錯',style: TextStyle(color: Colors.red),),

                                                  actions: [
                                                    TextField(
                                                      controller: controllerScore,
                                                      minLines: 1,
                                                      maxLines: 1,
                                                      decoration: InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        labelText: '輸入要減少的分數',
                                                      )
                                                    ),

                                                    SizedBox(height: 14,),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        TextButton(
                                                          onPressed: (){
                                                            controllerScore.clear();
                                                            Navigator.of(context).pop();
                                                          }, 
                                                          child: Text('取消')
                                                        ),

                                                        TextButton(
                                                          onPressed: (){
                                                            String changed = controllerScore.text;
                                                            int changedScore = int.parse(changed);
                                                            changedScore = 0 - changedScore;

                                                            updateScore(index, newIndex, changedScore);
                                                            controllerScore.clear();
                                                            Navigator.of(context).pop();
                                                          }, 
                                                          child: Text('確定')
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                );
                                              }
                                            );
                                          } : null,
                                          child: Text('扣分')
                                        )
                                      ),

                                      Expanded(
                                        flex: 1, 
                                        child: TextButton(
                                          onPressed: isUnlocked? () async{
                                            showCupertinoDialog(
                                              context: context, 
                                              builder: (context){
                                                return AlertDialog(
                                                  title: Text('分數修改'),
                                                  content: Text('該窗口為加分窗口，請務必確認自己沒有點錯',style: TextStyle(color: Colors.red),),

                                                  actions: [
                                                    TextField(
                                                      controller: controllerScore,
                                                      minLines: 1,
                                                      maxLines: 1,
                                                      decoration: InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        labelText: '輸入要增加的分數',
                                                      )
                                                    ),

                                                    SizedBox(height: 14,),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        TextButton(
                                                          onPressed: (){
                                                            controllerScore.clear();
                                                            Navigator.of(context).pop();
                                                          }, 
                                                          child: Text('取消')
                                                        ),

                                                        TextButton(
                                                          onPressed: (){
                                                            String changed = controllerScore.text;
                                                            int changedScore = int.parse(changed);

                                                            updateScore(index, newIndex, changedScore);
                                                            controllerScore.clear();
                                                            Navigator.of(context).pop();
                                                          }, 
                                                          child: Text('確定')
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                );
                                              }
                                            );
                                          }:null,
                                          child: Text('加分')
                                        )
                                      ),
                                    ],
                                  );
                                })
                              )
                            ),
                          ),
                          crossFadeState: isExpandedList[index]
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        ),
                    ],
                  ),
                )
              ),

              Expanded(
                flex: 1,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (!isDataLoaded)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        ListTile(
                          title: Text('總分：${loadScore(index)}', style: TextStyle(fontSize: 26),),
                        ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
