import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/app/app_state_tree.dart';
import 'package:state_tree_router_demo/state_trees/app/app_state_tree_pages.dart';
import 'package:tree_state_machine/tree_builders.dart';
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
  late final _routeParser = StateTreeRouteInformationParser(_appStateTreeBuilder.rootKey);
  late final _buildContext = TreeBuildContext(onTreeNodeBuilt: _routeParser.onTreeNodeBuilt);
  late final _appStateMachine = TreeStateMachine(_appStateTreeBuilder, buildContext: _buildContext);
  late final _routerDelegate = StateTreeRouterDelegate(
    stateMachine: _appStateMachine,
    scaffoldPages: true,
    displayStateMachineErrors: true,
    pages: [
      landingPage,
      simpleStateMachineDemoPage,
      authStateMachineDemoPage,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _routeParser,
      routerDelegate: _routerDelegate,
      color: Colors.amberAccent,
    );
  }
}

void _initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message} ${record.error?.toString() ?? ''}');
  });
}
