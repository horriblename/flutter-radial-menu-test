import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:pie_menu/pie_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var transparentTheme = ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        background: Colors.transparent,
        onBackground: Colors.transparent);

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Radial Menu',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: transparentTheme,
        ),
        home: MyHomePage(title: 'Home Page?'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // WheelModel focus;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PieCanvas(
          theme: const PieTheme(
              delayDuration: Duration.zero, overlayColor: Colors.transparent),
          child: Scaffold(
              body: PieMenu(
            onTap: _incrementCounter,
            actions: defaultWheelModel()
                .actions
                .map((action) => action.toPieAction(null))
                .toList(),
            child: const SizedBox.expand(),
          ))),
    );
  }
}

class WheelModel {
  // position data
  final List<Action> actions;

  WheelModel(this.actions);
}

class Action {
  final String name;
  final IconData? icon;
  final List<String>? command;
  final WheelModel? subwheel;

  Action({required this.name, this.icon, this.command, this.subwheel}) {
    // FIXME lol
    if ((command == null) == (subwheel == null)) {
      throw ArgumentError(
          "either 'command' or 'subwheel' (not both) must be provided");
    }
  }

  PieAction toPieAction(Widget? child) {
    dynamic Function() onSelect;

    final command = this.command;
    if (command != null) {
      if (command.isEmpty) {
        onSelect = () => {};
      }

      onSelect = () => {Process.runSync(command[0], command.sublist(1))};
    } else {
      // TODO
      onSelect = () => {};
    }

    return PieAction(
      tooltip: name,
      onSelect: onSelect,
      child: Icon(icon ?? Icons.home),
    );
  }
}

WheelModel defaultWheelModel() {
  return WheelModel([
    Action(
        name: 'Left',
        icon: Icons.arrow_left,
        command: ['hyprctl', 'dispatch', 'workspace', '-1']),
    Action(
        name: 'Right',
        icon: Icons.arrow_right,
        command: ['hyprctl', 'dispatch', 'workspace', '+1']),
    Action(name: 'Up', command: ['notify-send', 'up']),
    Action(name: 'Hang', command: ['sleep', '3s']),
    Action(
        name: 'Subwheel',
        subwheel: WheelModel([
          Action(name: 'a', command: ['notify-send', 'a']),
          Action(name: 'b', command: ['notify-send', 'b']),
        ]))
  ]);
}
