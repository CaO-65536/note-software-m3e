import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:system_tray/system_tray.dart';
import 'dart:developer' as developer;
import 'package:restartfromos/restartatos.dart';
import 'package:provider/provider.dart';

import 'settings.dart';
import 'score.dart';
import 'note.dart';
import 'toolspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(560, 1032),
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
    windowManager.setPosition(Offset(1360, 0));
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

  runApp(
    ChangeNotifierProvider(
      create: (context) => RoundedChoicesData(),
      builder: (context, child) => MyApp(window_background_transparent: window_background_transparent,app_dark_theme: app_dark_theme,app_seed_color: app_seed_color,),
    ),
  );

  
  initSystemTray();
}

int _selectedChoice = 0;
int _selectedIndex = 0;

class RoundedChoicesData extends ChangeNotifier {
  

  int get selectedChoice => _selectedChoice;

  set selectedChoice(int value) {
    _selectedChoice = value;
    
    notifyListeners();
  }
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
      title: 'Flutter Release',
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
  
  final List<Widget> _pages = [
    MyHomePage(title: '筆記'),
    GroupScore(title: '小組積分',),
    //ToolsPage(title:'工具'),
    SettingPage()
  ];


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

    void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final roundedChoicesData = Provider.of<RoundedChoicesData>(context);
    final selectedChoice = roundedChoicesData.selectedChoice;
    final borderRadius = BorderRadius.circular(24.0);

    return Scaffold(
      body: _pages[_selectedIndex],

      //Bar
      /*bottomNavigationBar: NavigationBar(
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
            icon: Icon(Icons.toys_outlined),
            label: '工具‘未完成’',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings),
            label:'設定',
          ),
        ],
      ),*/

      bottomNavigationBar: Row(
      children: <Widget>[
        Expanded(flex: 1,child: SizedBox()),

        Expanded(flex: 2,child:SizedBox(),),

        Expanded(flex: 1,child: SizedBox())
      ],
    ),
  //123,

  floatingActionButton:  Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            offset: Offset(0.0, 4.0),
            blurRadius: 10.0,
            spreadRadius: 0.1
          )
        ]
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Ensure the column doesn't take up infinite space
        children: [
          Wrap(
            spacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Note'),
                selected: selectedChoice == 0,
                onSelected: (bool selected) {
                  if (selected) {
                    roundedChoicesData.selectedChoice = 0;
                    _onItemTapped(0);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
              ),
              ChoiceChip(
                label: const Text('Score'),
                selected: selectedChoice == 1,
                onSelected: (bool selected) {
                  if (selected) {
                    roundedChoicesData.selectedChoice = 1;
                    _onItemTapped(1);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
              ),
              ChoiceChip(
                label: const Text('Setting'),
                selected: selectedChoice == 2,
                onSelected: (bool selected) {
                  if (selected) {
                    roundedChoicesData.selectedChoice = 2;
                    _onItemTapped(2);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
              ),
            ],
          ),
        ],
      ),
    ),

    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

          
        
      
    );
  }
}

/*class RoundedChoices extends StatefulWidget {
  const RoundedChoices({super.key});

  @override
  State<RoundedChoices> createState() => RoundedChoicesState();
}

class RoundedChoicesState extends State<RoundedChoices> {

  

  @override
  Widget build(BuildContext context) {
    
  
  }
}*/