import 'package:flutter/material.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/app/app_state_tree.dart';
import 'package:state_tree_router_demo/state_trees/simple/simple_state_tree_pages.dart' as simple;
import 'package:state_tree_router_demo/state_trees/auth/auth_state_tree_pages.dart' as auth;
import 'package:tree_state_machine/tree_state_machine.dart';

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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('Simple State Machine Demo'),
            onPressed: () => currentState.post(Messages.goToSimpleStateMachineDemo),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('Authentication State Machine Demo'),
            onPressed: () => currentState.post(Messages.goToAuthStateMachineDemo),
          ),
        ),
      ],
    ),
  ),
);

final simpleStateMachineDemoPage = TreeStatePage.forState(
  AppStates.simpleStateMachineDemo,
  (buildContext, currentState) {
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
                simpleStateMachineReadyPage,
                simpleStateMachineRunninPage,
              ],
            ),
          ),
        ),
      ],
    );
  },
);

final simpleStateMachineReadyPage = makeStateMachineReadyPage(
  AppStates.simpleStateMachineDemoReady,
);
final simpleStateMachineRunninPage = makeStateMachineRunningPage(
  AppStates.simpleStateMachineDemoRunning,
  NestedStateTreeRouterDelegate(
    pages: [
      simple.enterTextPage,
      simple.toLowercasePage,
      simple.toUppercasePage,
    ],
  ),
);

final authStateMachineDemoPage = TreeStatePage.forState(
  AppStates.authStateMachineDemo,
  (buildContext, currentState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 64.0),
          constraints: const BoxConstraints(maxWidth: 300),
          child: const Text(
            'Auth state machine',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        Expanded(
          child: Router(
            routerDelegate: ChildTreeStateRouterDelegate(
              pages: [
                authStateMachineReadyPage,
                authStateMachineRunninPage,
              ],
            ),
          ),
        ),
      ],
    );
  },
);

final authStateMachineReadyPage = makeStateMachineReadyPage(
  AppStates.authStateMachineDemoReady,
);

final authStateMachineRunninPage = makeStateMachineRunningPage(
  AppStates.authStateMachineDemoRunning,
  NestedStateTreeRouterDelegate(
    pages: [
      auth.loginPage,
    ],
  ),
);

TreeStatePage makeStateMachineReadyPage(StateKey stateKey) {
  return TreeStatePage.forState(
    stateKey,
    (b, cs) => Stack(
      alignment: Alignment.topCenter,
      children: [
        ElevatedButton(
          child: const Text('Start'),
          onPressed: () => cs.post(Messages.startStateMachine),
        ),
      ],
    ),
  );
}

TreeStatePage makeStateMachineRunningPage(
  StateKey stateKey,
  NestedStateTreeRouterDelegate routerDelegate,
) {
  return TreeStatePage.forState(
    stateKey,
    (_, __) => Stack(
      alignment: Alignment.topCenter,
      children: [
        Router(routerDelegate: routerDelegate),
      ],
    ),
  );
}
