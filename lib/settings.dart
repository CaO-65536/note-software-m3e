import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

import 'libre.dart';

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

                  
                 Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24.0)
                  ),

                  child: Padding(
                    padding: EdgeInsets.all(10.0),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: <Widget>[
                         Text('    外觀（重啓應用后生效）'),
                  SizedBox(height: 8,),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0)
                      ),
                    ),
                    child: 
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
                  ),

                  SizedBox(height: 8,),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SwitchListTile(
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
                    ),
                  ),
                  child:  ListTile(
                    title: Text('應用主題顔色', style: TextStyle(fontSize: 22),),
                    subtitle: Text('調整應用的主色調'),
                    onTap: (){
                        showCupertinoDialog(
                        
                        
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
                              //backgroundColor: Colors.transparent,
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
                                      
                                      labelText: '輸入一個有效顏色碼',
                                    ),
                                  ),
                                ],
                              ),

                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    OutlinedButton(
                                      onPressed: () {Navigator.of(context).pop();},
                                      child: const Text('取消'),
                                    ),

                                    SizedBox(width: 8,),

                                    FilledButton(
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
                 ),
                      ],
                    ),
                  ),
                 ),

                  SizedBox(height: 28,),
                
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                        bottomLeft: Radius.circular(24.0),
                        bottomRight: Radius.circular(24.0)
                      )
                    ),

                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: <Widget>[
                           Text('    行爲'),
                  SizedBox(height: 8,),

                 Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0)
                    ),
                  ),
                  child:  SwitchListTile(
                    title: Text('崩潰后展示日志',style: TextStyle(fontSize: 22),),
                    subtitle: Text('會在你嘗試了一些不得了的操作後輸出一份非常長的日志文件'),
                    value: isCrashLog,
                    onChanged: null
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
                    ),
                  ),
                  child:  ListTile(
                    title: Text('Widget Library',style: TextStyle(fontSize: 22),),
                    subtitle: Text('Some example widgets'),
                    
                    onTap: (){
                      showCupertinoSheet(enableDrag: false,context: context, pageBuilder: (context){
                        return ComponentLibrary();
                      });
                    }
                  ),
                 ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 1024,)
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
