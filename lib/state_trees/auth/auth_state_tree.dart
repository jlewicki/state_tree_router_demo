import 'dart:async';

import 'package:async/async.dart';
import 'package:state_tree_router_demo/state_trees/auth/models/models.dart';
import 'package:state_tree_router_demo/state_trees/auth/services/services.dart';
import 'package:tree_state_machine/tree_builders.dart';
import 'package:tree_state_machine/tree_state_machine.dart';

//
// States
//
class AuthStates {
  static const unauthenticated = StateKey('unauthenticated');
  static const login = StateKey('login');
  static const loginEntry = StateKey('loginEntry');
  static const authenticating = StateKey('authenticating');
  static const registration = StateKey('registration');
  static const credentialsRegistration = StateKey('credentialsRegistration');
  static const demographicsRegistration = StateKey('demographicsRegistration');
  static const authenticated = StateKey('authenticated');
}

typedef _S = AuthStates;

//
// Messages
//
class SubmitCredentials implements AuthenticationRequest {
  @override
  final String email;
  @override
  final String password;
  SubmitCredentials(this.email, this.password);
}

class SubmitDemographics {
  final String firstName;
  final String lastName;
  SubmitDemographics(this.firstName, this.lastName);
}

class AuthFuture {
  final FutureOr<Result<AuthenticatedUser>> futureOr;
  AuthFuture(this.futureOr);
}

enum Messages { goToLogin, goToRegister, back, logout, submitRegistration }

//
// State Data
//
class RegisterData implements RegistrationRequest {
  @override
  String email = '';
  @override
  String password = '';
  @override
  String firstName = '';
  @override
  String lastName = '';
  bool isBusy = false;
  String errorMessage = '';
}

class LoginData implements AuthenticationRequest {
  @override
  String email = '';
  @override
  String password = '';
  bool rememberMe = false;
  String errorMessage = '';
}

class AuthenticatedData {
  final AuthenticatedUser user;
  AuthenticatedData(this.user);
}

//
// State Tree
//
class AuthStateTree {
  AuthStateTree(this._authService);

  final AuthService _authService;
  final _authenticatingChannel = const Channel<SubmitCredentials>(_S.authenticating);
  final _authenticatedChannel = const Channel<AuthenticatedUser>(_S.authenticated);

  StateTreeBuilder treeBuilder({StateKey initialUnauthenticatedState = _S.login}) {
    var b = StateTreeBuilder(initialState: _S.unauthenticated, logName: 'auth');

    b.state(
      _S.unauthenticated,
      emptyState,
      initialChild: InitialChild(initialUnauthenticatedState),
    );

    b.dataState<RegisterData>(
      _S.registration,
      InitialData(() => RegisterData()),
      (b) {
        b.onMessage<SubmitDemographics>((b) {
          // Model the registration action as an asynchronous Result. The 'registering' status while the
          // operation is in progress is modeled as flag in RegisterData, and a state transition (to
          // Authenticated) does not occur until the operation is complete.
          b.whenResult<AuthenticatedUser>(
            (ctx) => _register(ctx.messageContext, ctx.data),
            (b) {
              b.enterChannel(_authenticatedChannel, (ctx) => ctx.context);
            },
            label: 'register user',
          ).otherwise(((b) {
            b.stay();
          }));
        });
      },
      initialChild: InitialChild(_S.credentialsRegistration),
      parent: _S.unauthenticated,
    );

    b.state(_S.credentialsRegistration, (b) {
      b.onMessage<SubmitCredentials>((b) {
        b.goTo(_S.demographicsRegistration,
            action: b.act.updateData<RegisterData>((ctx, data) => data
              ..email = ctx.message.email
              ..password = ctx.message.password));
      });
    }, parent: _S.registration);

    b.state(_S.demographicsRegistration, (b) {
      b.onMessage<SubmitDemographics>((b) {
        b.unhandled(
          action: b.act.updateData<RegisterData>((ctx, data) => data
            ..firstName = ctx.message.firstName
            ..lastName = ctx.message.lastName),
        );
      });
    }, parent: _S.registration);

    b.dataState<LoginData>(
      _S.login,
      InitialData(() => LoginData()),
      (b) {
        b.onMessageValue(Messages.goToRegister, (b) => b.goTo(AuthStates.registration));
      },
      initialChild: InitialChild(_S.loginEntry),
      parent: _S.unauthenticated,
    );

    b.state(_S.loginEntry, (b) {
      b.onMessage<SubmitCredentials>((b) {
        // Model the 'logging in' status as a distinct state in the state machine. This is an
        // alternative design to modeling with a flag in state data, as was done with 'registering'
        // status.
        b.enterChannel(_authenticatingChannel, (ctx) => ctx.message,
            action: b.act.updateData<LoginData>((ctx, data) => data
              ..email = ctx.message.email
              ..password = ctx.message.password));
      });
    }, parent: _S.login);

    b.state(_S.authenticating, (b) {
      b.onEnterFromChannel<SubmitCredentials>(_authenticatingChannel, (b) {
        b.post<AuthFuture>(getMessage: (ctx) => _login(ctx.context));
      });
      b.onMessage<AuthFuture>((b) {
        b.whenResult<AuthenticatedUser>((ctx) => ctx.message.futureOr, (b) {
          b.enterChannel<AuthenticatedUser>(_authenticatedChannel, (ctx) => ctx.context);
        }).otherwise((b) {
          b.goTo(
            _S.loginEntry,
            action: b.act.updateData<LoginData>(
                (ctx, err) => err..errorMessage = ctx.context.error.toString()),
          );
        });
      });
    }, parent: _S.login);

    b.finalDataState<AuthenticatedData>(
      _S.authenticated,
      InitialData.fromChannel(
        _authenticatedChannel,
        (AuthenticatedUser user) => AuthenticatedData(user),
      ),
      emptyFinalState,
    );

    var sb = StringBuffer();
    b.format(sb, DotFormatter());
    sb.toString();

    return b;
  }

  AuthFuture _login(SubmitCredentials creds) {
    return AuthFuture(_authService.authenticate(creds));
  }

  Future<Result<AuthenticatedUser>> _register(
      MessageContext msgCtx, RegisterData registerData) async {
    var errorMessage = '';
    var dataVal = msgCtx.dataOrThrow<RegisterData>();
    try {
      dataVal.update((_) => registerData
        ..isBusy = true
        ..errorMessage = '');

      var result = await _authService.register(registerData);

      if (result.isError) {
        errorMessage = result.asError!.error.toString();
      }
      return result;
    } finally {
      dataVal.update((_) => registerData
        ..isBusy = false
        ..errorMessage = errorMessage);
    }
  }
}
