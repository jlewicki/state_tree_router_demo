import 'package:flutter/material.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/auth/auth_state_tree.dart';
import 'package:tree_state_machine/tree_state_machine.dart';

class AuthStateTreeView extends StatelessWidget {
  const AuthStateTreeView({
    Key? key,
    required this.nestedMachineStateKey,
  }) : super(key: key);

  final StateKey nestedMachineStateKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Router(
        routerDelegate: NestedStateTreeRouterDelegate(
          pages: [
            loginPage,
          ],
        ),
      ),
    );
  }
}

final loginPage = TreeStatePage.forDataState<LoginData>(AuthStates.login, (
  BuildContext context,
  LoginData data,
  CurrentState currentState,
) {
  var formKey = GlobalKey<FormState>();
  bool isAuthenticating = currentState.isInState(AuthStates.authenticating);
  String? email = data.email;
  String? password = data.password;

  return StatefulBuilder(
    builder: (context, setState) {
      String? _validateEmail(String? value) {
        return (email = value)?.isEmpty ?? true ? 'Please enter an email address.' : null;
      }

      String? _validatePassword(String? value) {
        return (password = value)?.isEmpty ?? true ? 'Please enter a password' : null;
      }

      String _errorMessage(LoginData data) {
        return isAuthenticating ? '' : data.errorMessage;
      }

      void _submit(CurrentState currentState) {
        if (formKey.currentState?.validate() ?? false) {
          currentState.post(SubmitCredentials(email!, password!));
        }
      }

      return Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              AuthFormFieldGroup(
                title: 'What is your name?',
                formFields: [
                  AuthFormField(
                    'firstName',
                    'Email Addres',
                    data.email,
                    validator: _validateEmail,
                    isEnabled: !isAuthenticating,
                  ),
                  AuthFormField(
                    'lastName',
                    'Password',
                    data.password,
                    validator: _validatePassword,
                  )
                ],
              ),
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: isAuthenticating
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                _submit(currentState);
                              },
                        child: Text(isAuthenticating ? 'Authenticating...' : 'Log In'),
                      ),
                      Center(
                        child: Text(_errorMessage(data), style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
});

class AuthFormFieldGroup extends StatelessWidget {
  const AuthFormFieldGroup({
    Key? key,
    required this.formFields,
    this.title = '',
  }) : super(key: key);

  final String title;
  final List<AuthFormField> formFields;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          for (var field in formFields)
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              constraints: const BoxConstraints(maxWidth: 250),
              child: TextFormField(
                enabled: field.isEnabled,
                // key: ValueKey(field.key),
                initialValue: field.initialValue,
                validator: field.validator,
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: field.label,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AuthFormField {
  final String key;
  final String label;
  final String initialValue;
  final bool isRequired;
  final bool isEnabled;
  final FormFieldValidator<String>? validator;
  const AuthFormField(
    this.key,
    this.label,
    this.initialValue, {
    this.isRequired = true,
    this.validator,
    this.isEnabled = true,
  });
}
