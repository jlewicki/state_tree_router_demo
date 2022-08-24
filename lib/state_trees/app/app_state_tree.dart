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
//  static const simpleStateMachineDemoFinished = StateKey('app_simpleStateMachineDemo_finishsed');
}

typedef _S = AppStates;

//
// Messages
//
enum Messages { goToSimpleStateMachineDemo, startSimpleStateMachine }

class AppStateTree {
  StateTreeBuilder treeBuilder() {
    var b = StateTreeBuilder(initialState: _S.landing, logName: 'app');

    b.state(_S.landing, (b) {
      b.onMessageValue(
        Messages.goToSimpleStateMachineDemo,
        (b) => b.goTo(_S.simpleStateMachineDemo),
      );
    });

    b.state(
      _S.simpleStateMachineDemo,
      emptyState,
      initialChild: InitialChild(_S.simpleStateMachineDemoReady),
    );
    b.state(
        _S.simpleStateMachineDemoReady,
        (b) => b.onMessageValue(
              Messages.startSimpleStateMachine,
              (b) => b.goTo(_S.simpleStateMachineDemoRunning),
            ),
        parent: _S.simpleStateMachineDemo);
    b.machineState(
      _S.simpleStateMachineDemoRunning,
      InitialMachine.fromTree(
        (_) => SimpleStateTree().treeBuilder(),
        label: 'Simple State Machine',
      ),
      (b) => b.onMachineDone((b) => b.goTo(_S.simpleStateMachineDemoReady)),
      parent: _S.simpleStateMachineDemo,
    );
    //b.state(_S.simpleStateMachineDemoFinished, emptyState, parent: _S.simpleStateMachineDemo);

    return b;
  }
}
