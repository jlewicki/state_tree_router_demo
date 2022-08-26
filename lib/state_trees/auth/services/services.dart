import 'package:async/async.dart';
import 'package:state_tree_router_demo/state_trees/auth/models/models.dart';

abstract class AuthService {
  Future<Result<AuthenticatedUser>> authenticate(AuthenticationRequest request);
  Future<Result<AuthenticatedUser>> register(RegistrationRequest request);
}

class AppAuthService implements AuthService {
  @override
  Future<Result<AuthenticatedUser>> authenticate(AuthenticationRequest request) async {
    await Future.delayed(const Duration(seconds: 3));
    if (request.email.toLowerCase() == 'fail') {
      return Result.error('Unrecognized email address or password.');
    }
    return Result.value(AuthenticatedUser('Joey', 'Tribbiani', request.email));
  }

  @override
  Future<Result<AuthenticatedUser>> register(RegistrationRequest request) async {
    await Future.delayed(const Duration(seconds: 3));
    return Result.value(AuthenticatedUser('Joey', 'Tribbiani', request.email));
  }
}
