import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/app/app_state_tree.dart';
import 'package:state_tree_router_demo/state_trees/app/app_state_tree_pages.dart';
import 'package:tree_state_machine/tree_state_machine.dart';

void main() async {
  _initLogging();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _appStateTree = AppStateTree();
  late final _appStateTreeBuilder = _appStateTree.treeBuilder();
  late final _routerDelegate = StateTreeRouterDelegate(
    stateMachine: TreeStateMachine(_appStateTreeBuilder),
    scaffoldPages: true,
    treeStatePages: [
      landingPage,
      simpleStateMachineDemoPage,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: StateTreeRouteInfoParser(_appStateTreeBuilder.rootKey),
      routerDelegate: _routerDelegate,
      color: Colors.amberAccent,
    );
  }
}

void _initLogging() {
  // Capture logging output generated by the state machine
  // hierarchicalLoggingEnabled = true;
  //Logger('tree_state_machine').level = Level.ALL;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}');
  });
}
