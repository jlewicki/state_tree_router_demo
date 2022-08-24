import 'package:flutter/material.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/app/app_state_tree.dart';
import 'package:state_tree_router_demo/state_trees/simple/simple_state_tree_pages.dart' as simple;

final landingPage = TreeStatePage.forState(
  AppStates.landing,
  (buildContext, currentState) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 64.0),
          constraints: const BoxConstraints(maxWidth: 300),
          child: const Text(
            'Tree State Machine Routing Demo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        ElevatedButton(
          child: const Text('Simple State Machine Demo'),
          onPressed: () => currentState.post(Messages.goToSimpleStateMachineDemo),
        ),
      ],
    ),
  ),
);

final simpleStateMachineDemoPage = TreeStatePage.forState(
  AppStates.simpleStateMachineDemo,
  (buildContext, currentState) {
    var isReadyPage = TreeStatePage.forState(
      AppStates.simpleStateMachineDemoReady,
      (b, cs) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ElevatedButton(
            child: const Text('Start'),
            onPressed: () => cs.post(Messages.startSimpleStateMachine),
          ),
        ],
      ),
    );

    var isRunningPage = TreeStatePage.forState(
      AppStates.simpleStateMachineDemoRunning,
      (_, __) => Stack(
        alignment: Alignment.topCenter,
        children: [
          Router(
            routerDelegate: NestedStateTreeRouterDelegate(
              stateKey: AppStates.simpleStateMachineDemoRunning,
              pages: [
                simple.enterTextPage,
                simple.toLowercasePage,
                simple.toUppercasePage,
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 64.0),
          constraints: const BoxConstraints(maxWidth: 300),
          child: const Text(
            'Simple state machine',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        Expanded(
          child: Router(
            routerDelegate: ChildTreeStateRouterDelegate(
              pages: [
                isReadyPage,
                isRunningPage,
              ],
            ),
          ),
        ),
      ],
    );
  },
);
