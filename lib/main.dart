import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';
import 'dart:developer' as developer;
import 'package:restartfromos/restartatos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(560, 1024),
    skipTaskbar: true,
    alwaysOnTop: false,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: "Note",
  );

  File settings = File(r'C:\Users\Public\note_files\settings.json');
  String settingsJson = await settings.readAsString();
  Map<String, dynamic> _settings = jsonDecode(settingsJson);

  bool window_background_transparent = false;
  bool app_dark_theme = false;
  String app_seed_color = '${_settings['app-seed-color']}';
  
  if(_settings['window-background-transparent'] == 'true'){
    window_background_transparent = true;
  }

  if(_settings['app-dark-theme'] == 'true'){
    app_dark_theme = true;
  }

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setPosition(Offset(1360, 6));
    windowManager.setResizable(false);
    windowManager.setAspectRatio(1.3);
    windowManager.setHasShadow(false);
    if(app_dark_theme){
      windowManager.setBrightness(Brightness.dark);
    }
    
    if(window_background_transparent){
      windowManager.setAsFrameless();
    }
  });

  runApp(MyApp(window_background_transparent: window_background_transparent,app_dark_theme: app_dark_theme,app_seed_color: app_seed_color,));
  initSystemTray();
}

Future<void> initSystemTray() async {
  final SystemTray systemTray = SystemTray();

  await systemTray.initSystemTray(
    title: "Note",
    iconPath: 'assets/icon.ico', 
  );

  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: '關閉程式',
      onClicked: (menuItem) {
        systemTray.destroy();
        exit(0);
      },
    ),
    MenuItemLabel(
      label: '顯示窗體',
      onClicked: (menuItem) {
        windowManager.focus();
      }
    ),
    MenuItemLabel(
      label: '重啓程式',
      onClicked: (menuItem){
        RestartFromOS.restartApp(appName: 'learn');
      }
    )
  ]);

  await systemTray.setContextMenu(menu);

  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventRightClick) {
      systemTray.popUpContextMenu();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.window_background_transparent, required this.app_dark_theme, required this.app_seed_color});
  final bool window_background_transparent;
  final bool app_dark_theme;
  final String app_seed_color;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final int colorValue = int.parse(app_seed_color);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: app_dark_theme? Brightness.dark: Brightness.light,
        scaffoldBackgroundColor: window_background_transparent ? Colors.transparent : null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(colorValue),
          brightness: app_dark_theme? Brightness.dark: Brightness.light,
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    MyHomePage(title: '筆記'),
    GroupScore(title: '小組積分',),
    SettingPage()
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isTransparent = false;

  @override
  void initState(){
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async{
    try {
      File settings = File(r'C:\Users\Public\note_files\settings.json');
      if (!await settings.exists()) {
        developer.log('File does not exist: ${settings.path}');
        return;
      }
      String settingsJson = await settings.readAsString();
      Map<String, dynamic> _settings = jsonDecode(settingsJson);

      if (_settings.containsKey('window-background-transparent')) {
        String value = _settings['window-background-transparent'].toString().trim().toLowerCase();
        setState(() {
          isTransparent = value == 'true';
        });
      } else {
        developer.log('Field "window-background-transparent" not found in JSON.');
      }
    } catch (e) {
      developer.log('Error reading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      //Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: isTransparent? Colors.transparent: null,

        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.book),
            label: '筆記',
          ),

          NavigationDestination(
            icon: Icon(Icons.face),
            label: '小組積分',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class SettingPage extends StatefulWidget{
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isBackgroundTransparent = false;
  bool isAppDarkTheme = false;
  bool isCrashLog = true;

  @override
  void initState(){
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async{
    try {
      File settings = File(r'C:\Users\Public\note_files\settings.json');
      if (!await settings.exists()) {
        developer.log('File does not exist: ${settings.path}');
        return;
      }
      String settingsJson = await settings.readAsString();
      Map<String, dynamic> _settings = jsonDecode(settingsJson);

      if (_settings.containsKey('window-background-transparent')) {
        String value = _settings['window-background-transparent'].toString().trim().toLowerCase();
        setState(() {
          isBackgroundTransparent = value == 'true';
        });

        String value2 = _settings['app-dark-theme'].toString().trim().toLowerCase();
        setState(() {
          isAppDarkTheme = value2 == 'true';
        });
      } else {
        developer.log('Field "window-background-transparent" not found in JSON.');
      }
    } catch (e) {
      developer.log('Error reading file: $e');
    }
  }

  bool isHexColorFormat(String input) {
    final RegExp hexColorRegex = RegExp(r'^0xff[0-9a-fA-F]{6}$');
    return hexColorRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('設定', style: TextStyle(fontSize: 32),),
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16.0,
                bottom: 16.0,
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 14,),
                  Text('    外觀（重啓應用后生效）'),
                  SizedBox(height: 8,),

                  SwitchListTile(
                    title: Text('透明的應用程式背景', style: TextStyle(fontSize: 22),),
                    subtitle: Text('請注意該選項會增加運行内存占用'),
                    value: isBackgroundTransparent, 
                    onChanged: (bool value) async{
                      setState(() {
                        isBackgroundTransparent = value;
                      });

                      File settings = File(r'C:\Users\Public\note_files\settings.json');
                      try{
                        String settingsJson = await settings.readAsString();
                        Map<String, dynamic> _settings = jsonDecode(settingsJson);

                        _settings['window-background-transparent'] = '$isBackgroundTransparent';
                        String updatedJson = jsonEncode(_settings);

                        await settings.writeAsString(updatedJson);
                      }catch(e){
                        developer.log('Error writing file $e');
                      }
                    }
                  ),

                  SwitchListTile(
                    title: Text('暗色主題', style: TextStyle(fontSize: 22),),
                    subtitle: Text('相較於亮色主題，暗色主題在透明模式下對桌面適應更好'),
                    value: isAppDarkTheme, 
                    onChanged: (bool value) async{
                      setState(() {
                        isAppDarkTheme = value;
                      });

                      File settings = File(r'C:\Users\Public\note_files\settings.json');
                      try{
                        String settingsJson = await settings.readAsString();
                        Map<String, dynamic> _settings = jsonDecode(settingsJson);

                        _settings['app-dark-theme'] = '$isAppDarkTheme';
                        String updatedJson = jsonEncode(_settings);

                        await settings.writeAsString(updatedJson);
                      }catch(e){
                        developer.log('Error writing file $e');
                      }
                    }
                  ),

                  ListTile(
                    title: Text('應用主題顔色', style: TextStyle(fontSize: 22),),
                    subtitle: Text('調整應用的主色調'),
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (context){
                          final colorControl = TextEditingController();
                          
                          return StatefulBuilder(
                            builder: (context, setState) {
                              bool isColorValid = isHexColorFormat(colorControl.text);

                              colorControl.addListener(() {
                                setState(() {
                                  isColorValid = isHexColorFormat(colorControl.text);
                                });
                              });

                            return AlertDialog(
                              title: const Text('調整主題顔色'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('顏色碼格式：0xffxxxxxx，其中0xff為固定標頭'),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: colorControl,
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '輸入一個有效顏色碼',
                                    ),
                                  ),
                                ],
                              ),

                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () {Navigator.of(context).pop();},
                                      child: const Text('取消'),
                                    ),

                                    TextButton(
                                      child: Text('確定'),
                                      onPressed: isColorValid
                                        ? () async {
                                          try {
                                            File settingsFile = File(r'C:\Users\Public\note_files\settings.json');
                                            String str = await settingsFile.readAsString();
                                            Map<String, dynamic> editedSettings = jsonDecode(str);

                                            editedSettings['app-seed-color'] = colorControl.text;
                                            await settingsFile.writeAsString(jsonEncode(editedSettings));

                                            Navigator.of(context).pop();
                                          } catch (e) {
                                            developer.log('文件操作出错: $e');
                                          }
                                        }: null,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        );
                      },
                    );
                  }),

                  SizedBox(height: 28,),
                  Text('    行爲'),
                  SizedBox(height: 8,),

                  SwitchListTile(
                    title: Text('崩潰后展示日志',style: TextStyle(fontSize: 22),),
                    subtitle: Text('會在你嘗試了一些不得了的操作後輸出一份非常長的日志文件'),
                    value: isCrashLog,
                    onChanged: null
                    )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}

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
                showDialog(
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
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        )
                      ),

                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: <Widget>[
                            OutlinedButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消')),

                            SizedBox(width: 8,),

                            FilledButton(onPressed: (){
                              if(controllerPW.text == 'SbqmyyQmyymm1126'){
                                isUnlocked = true;
                              }

                              _obscureText = true;
                              Navigator.of(context).pop();
                            }, child: Text('確定'))
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
                                            showDialog(
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('清除所有筆記？'),
                      content: Text('這將會永久的刪除它們（真的很久！）'),

                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: Text('取消'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),

                            TextButton(
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('關於程式'),
                      content: Text('市面上的桌面便簽要麽價格高昂（對學生黨而言）要麽資源占用超高（60% RAM）所以我做了這個程式=w=\n\n因爲這個程式只打算給同學們用所以請不要隨意分發>_<\n\n可能有些功能實現方式過於粗暴(\n因爲製作這個程式的時候我的知識還是太過匱乏...給您造成困擾真的很對不起>w<\n\n-程式信息-\nProgram Work by CJ (Senior High Class 2)\n工具：Flutter & VS Code\n語言：Dart'),
                      
                      actions: [
                        TextButton(
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
                    subtitle: Text(cardData[index]['content']!, style: TextStyle(fontSize: 22, color: cardData[index]['state'] == 'enabled'?null:Color(0xffffffff)),),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,

                  child: IconButton(
                    icon: Icon(Icons.close, color: cardData[index]['state'] == 'enabled'?null:Color(0xffffdad6)),
                    onPressed: () async{
                      showDialog(
                        context: context, 
                        builder: (context){
                          return AlertDialog(
                            title: Text('刪除這份筆記？'),
                            content: Text('該操作不可回退'),

                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,

                                children: <Widget>[
                                  TextButton(
                                    child: Text('取消'),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  TextButton(
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

                      showDialog(
                        context: context, 
                        builder: (context){
                          return AlertDialog(
                            title: Text('複製成功！'),

                            actions: [
                              TextButton(
                                child: Text('瞭解'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
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
                  right: 88,

                  child: IconButton(
                    icon: Icon(Icons.edit, size: 18,color: cardData[index]['state'] == 'enabled'?null:Color(0xffffdad6)),

                    onPressed: (){
                      final _editText = TextEditingController(text: '${cardData[index]['content']}');
                      bool _isHighlighted = cardData[index]['state'] == 'highlight'?true:false;

                      showDialog(
                        context: context,
                        builder: (context){
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState){
                              return AlertDialog(
                                title: Text('修改筆記'),

                                actions: [
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
                                      TextButton(
                                        child: Text('取消'),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      ),

                                      TextButton(
                                        child: Text('確定'),

                                        onPressed: ()async{
                                          Map<String,dynamic> edited = {};
                                          File noteFile = File(r'C:\Users\Public\note_files\notes.json');
                                          String str = await noteFile.readAsString();
                                          edited = jsonDecode(str);

                                          edited['note${index + 1}'] = _editText.text;
                                          edited['state${index + 1}'] = _isHighlighted?'highlight':'enabled';

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
      
      //FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  final _noteTitle = TextEditingController();
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
                        TextButton(
                          child: Text('取消'),
                          onPressed: () {
                            _titleTxt.clear();
                            Navigator.of(context).pop();
                          },
                        ),

                        TextButton(
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
            },
          );
        },
        icon: Icon(Icons.add),
        label: Text('新建筆記'),
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

Future<void> clearJson() async {
  File noteFile = File(r'C:\Users\Public\note_files\notes.json');
  File varFile = File(r'C:\Users\Public\note_files\var.txt');

  await varFile.writeAsString('0');
  await noteFile.writeAsString('{}');
}