import 'package:state_tree_router_demo/state_trees/auth/auth_state_tree.dart';
import 'package:state_tree_router_demo/state_trees/auth/services/services.dart';
import 'package:state_tree_router_demo/state_trees/simple/simple_state_tree.dart';
import 'package:tree_state_machine/tree_state_machine.dart';
import 'package:tree_state_machine/tree_builders.dart';

//
// State keys
//
class AppStates {
  static const landing = StateKey('app_landing');
  static const simpleStateMachineDemo = StateKey('app_simpleStateMachineDemo');
  static const simpleStateMachineDemoReady = StateKey('app_simpleStateMachineDemo_ready');
  static const simpleStateMachineDemoRunning = StateKey('app_simpleStateMachineDemo_running');
  static const authStateMachineDemo = StateKey('app_authStateMachineDemo');
  static const authStateMachineDemoReady = StateKey('app_authStateMachineDemo_ready');
  static const authStateMachineDemoRunning = StateKey('app_authStateMachineDemo_running');
}

typedef _S = AppStates;

//
// Messages
//
enum Messages { goToSimpleStateMachineDemo, goToAuthStateMachineDemo, startStateMachine }

class AppStateTree {
  StateTreeBuilder treeBuilder() {
    var b = StateTreeBuilder(initialState: _S.landing, logName: 'app');

    b.state(_S.landing, (b) {
      b.onMessageValue(
        Messages.goToSimpleStateMachineDemo,
        (b) => b.goTo(_S.simpleStateMachineDemo),
      );
      b.onMessageValue(
        Messages.goToAuthStateMachineDemo,
        (b) => b.goTo(_S.authStateMachineDemo),
      );
    });

    b.state(
      _S.simpleStateMachineDemo,
      emptyState,
      initialChild: InitialChild(_S.simpleStateMachineDemoReady),
    );
    b.state(
      _S.simpleStateMachineDemoReady,
      (b) {
        b.onMessageValue(
          Messages.startStateMachine,
          (b) => b.goTo(_S.simpleStateMachineDemoRunning),
        );
      },
      parent: _S.simpleStateMachineDemo,
    );
    b.machineState(
      _S.simpleStateMachineDemoRunning,
      InitialMachine.fromTree(
        (_) => SimpleStateTree().treeBuilder(),
        label: 'Simple State Machine',
      ),
      (b) => b.onMachineDone((b) => b.goTo(_S.simpleStateMachineDemo)),
      parent: _S.simpleStateMachineDemo,
    );

    b.state(
      _S.authStateMachineDemo,
      initialChild: InitialChild(_S.authStateMachineDemoReady),
      emptyState,
    );
    b.state(
      _S.authStateMachineDemoReady,
      (b) {
        b.onMessageValue(
          Messages.startStateMachine,
          (b) => b.goTo(_S.authStateMachineDemoRunning),
        );
      },
      parent: _S.authStateMachineDemo,
    );
    b.machineState(
      _S.authStateMachineDemoRunning,
      parent: _S.authStateMachineDemo,
      InitialMachine.fromTree(
        (_) => AuthStateTree(AppAuthService()).treeBuilder(),
        label: 'Auth State Machine',
      ),
      (b) => b.onMachineDone((b) => b.goTo(_S.authStateMachineDemo)),
    );

    return b;
  }
}
