import 'package:flutter/material.dart';
import 'package:popupwindow/popupwindow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: TextButton(
          key: globalKey,
          onPressed: () {
            showPopWindow(globalKey, context,
                location: PopLocation.right,

                ///popwindow显示在锚点位置（上下左右）
                showBarrer: true,

                ///是否显示遮罩
                showAnchor: true,

                ///是否显示三角形指示器
                width: 200,

                ///popwindow宽度
                height: 200,

                ///popwindow高度
                space: 10,

                ///popwindow与锚点之间的间距
                (context, animation, secondaryAnimation) {
              return Text("测试");
            });
          },
          child: Text("PopupWindow"),
        ),
      ),
    );
  }
}
