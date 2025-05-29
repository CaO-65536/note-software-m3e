import 'package:flutter/material.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key, required this.title});
  final String title;

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,

                child: Card(
                  child: Stack(
                    

                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: <Widget>[
                            Center(child: Text('计算器',style: TextStyle(fontSize: 22),)),

                            Container()
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: SizedBox()
              ),
            ],
          )
        ],
      ),
    );
  }
}