import 'package:state_tree_router_demo/state_trees/auth/auth_state_tree.dart';
import 'package:state_tree_router_demo/state_trees/auth/models/models.dart';
import 'package:state_tree_router_demo/state_trees/auth/services/services.dart';
import 'package:state_tree_router_demo/state_trees/simple/simple_state_tree.dart';
import 'package:tree_state_machine/tree_state_machine.dart';
import 'package:tree_state_machine/tree_builders.dart';
import 'package:state_tree_router/state_tree_router.dart';

//
// State keys
//
class AppStates {
  static const root = StateKey('app_root');
  static const landing = StateKey('app_landing');
  static const simpleStateMachineDemo = StateKey('app_simpleStateMachineDemo');
  static const simpleStateMachineDemoReady = StateKey('app_simpleStateMachineDemo_ready');
  static const simpleStateMachineDemoRunning = StateKey('app_simpleStateMachineDemo_running');
  static const authStateMachineDemo = StateKey('app_authStateMachineDemo');
  static const authStateMachineDemoReady = StateKey('app_authStateMachineDemo_ready');
  static const authStateMachineDemoRunning = StateKey('app_authStateMachineDemo_running');
  static const authStateMachineFinished = StateKey('app_authStateMachineDemo_finished');
}

const _authenticatedChannel = Channel<AuthenticatedUser>(AppStates.authStateMachineFinished);

typedef _S = AppStates;

//
// Messages
//
enum Messages { goToSimpleStateMachineDemo, goToAuthStateMachineDemo, startStateMachine }

class AppStateTree {
  StateTreeBuilder treeBuilder() {
    var builder = StateTreeBuilder.withRoot(
      _S.root,
      (b) {
        b.onMessageValue(
          Messages.goToSimpleStateMachineDemo,
          (b) => b.goTo(_S.simpleStateMachineDemo),
        );
        b.onMessageValue(
          Messages.goToAuthStateMachineDemo,
          (b) => b.goTo(_S.authStateMachineDemo),
        );
      },
      InitialChild(_S.landing),
      logName: 'app',
      extensions: (b) => b.isRoutingHandler(),
    );

    builder.state(_S.landing, emptyState);

    builder
        .state(
          _S.simpleStateMachineDemo,
          emptyState,
          initialChild: InitialChild(_S.simpleStateMachineDemoReady),
        )
        .routable();
    builder.state(
      _S.simpleStateMachineDemoReady,
      (b) {
        b.onMessageValue(
          Messages.startStateMachine,
          (b) => b.goTo(_S.simpleStateMachineDemoRunning),
        );
      },
      parent: _S.simpleStateMachineDemo,
    );
    builder.machineState(
      _S.simpleStateMachineDemoRunning,
      InitialMachine.fromTree(
        (_) => SimpleStateTree().treeBuilder(),
        label: 'Simple State Machine',
      ),
      (b) => b.onMachineDone((b) => b.goTo(_S.simpleStateMachineDemo)),
      parent: _S.simpleStateMachineDemo,
    );

    builder
        .state(
          _S.authStateMachineDemo,
          initialChild: InitialChild(_S.authStateMachineDemoReady),
          emptyState,
        )
        .routable();
    builder.state(
      _S.authStateMachineDemoReady,
      (b) {
        b.onMessageValue(
          Messages.startStateMachine,
          (b) => b.goTo(_S.authStateMachineDemoRunning),
        );
      },
      parent: _S.authStateMachineDemo,
    );
    builder.machineState(
      _S.authStateMachineDemoRunning,
      parent: _S.authStateMachineDemo,
      InitialMachine.fromTree(
        (_) => AuthStateTree(AppAuthService()).treeBuilder(),
        label: 'Auth State Machine',
      ),
      (b) => b.onMachineDone((b) => b.enterChannel(_authenticatedChannel, (ctx) {
            // var user = ctx.data.nestedState.dataValue<AuthenticatedData>()!.user;
            // return user;

            var user = ctx.data.nestedCurrentState.dataValue<AuthenticatedUser>();
            return user;
          })),
    );
    builder.dataState<AuthenticatedUser>(
      _S.authStateMachineFinished,
      parent: _S.authStateMachineDemo,
      InitialData.fromChannel(
        _authenticatedChannel,
        (AuthenticatedUser user) => user,
      ),
      (b) {},
    );

    return builder;
  }
}
