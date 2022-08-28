import 'package:flutter/material.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/auth/auth_state_tree.dart';
import 'package:tree_state_machine/tree_state_machine.dart';

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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                            child: Text('Don\'t have an account?'),
                          ),
                          ElevatedButton(
                              onPressed: () => currentState.post(Messages.goToRegister),
                              child: const Text('Register'))
                        ],
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

final registrationPage = TreeStatePage.forDataState<RegisterData>(
  AuthStates.registration,
  (_, __, ___) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text('New Registration'),
          Expanded(
            child: Router(
              routerDelegate: ChildTreeStateRouterDelegate(
                supportsFinalPage: false,
                pages: [
                  registerCredentialsPage,
                  registerDemographicsPage,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
);

final registerCredentialsPage = TreeStatePage.forDataState<RegisterData>(
  AuthStates.credentialsRegistration,
  (
    BuildContext context,
    RegisterData data,
    CurrentState currentState,
  ) {
    var formKey = GlobalKey<FormState>();
    String? email = data.email;
    String? password = data.password;

    String? _validateEmail(String? value) {
      return (email = value)?.isEmpty ?? true ? 'Please enter an email address.' : null;
    }

    String? _validatePassword(String? value) {
      return (password = value)?.isEmpty ?? true ? 'Please enter a password' : null;
    }

    void _submit(CurrentState currentState) {
      if (formKey.currentState?.validate() ?? false) {
        currentState.post(SubmitCredentials(email!, password!));
      }
    }

    return StatefulBuilder(builder: (context, setState) {
      return Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              AuthFormFieldGroup(
                title: 'Choose Credentials',
                formFields: [
                  AuthFormField(
                    'email',
                    'Email Address',
                    data.firstName,
                    validator: _validateEmail,
                  ),
                  AuthFormField(
                    'password',
                    'Password',
                    data.lastName,
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
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _submit(currentState);
                        },
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  },
);

final registerDemographicsPage = TreeStatePage.forDataState<RegisterData>(
  AuthStates.demographicsRegistration,
  (
    BuildContext context,
    RegisterData data,
    CurrentState currentState,
  ) {
    var formKey = GlobalKey<FormState>();
    String? firstName = data.firstName;
    String? lastName = data.lastName;

    String? _validateFirstName(String? value) {
      return (firstName = value)?.isEmpty ?? true ? 'First name is required' : null;
    }

    String? _validateLastName(String? value) {
      return (lastName = value)?.isEmpty ?? true ? 'Last name is required' : null;
    }

    void _submit(CurrentState currentState) {
      if (formKey.currentState?.validate() ?? false) {
        currentState.post(SubmitDemographics(firstName!, lastName!));
      }
    }

    return StatefulBuilder(builder: (context, setState) {
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
                    'First Name',
                    data.firstName,
                    validator: _validateFirstName,
                  ),
                  AuthFormField(
                    'lastName',
                    'Last Name',
                    data.lastName,
                    validator: _validateLastName,
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
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _submit(currentState);
                        },
                        child: data.isBusy
                            ? const Text('Creating account...')
                            : const Text('Register'),
                      ),
                      Center(
                        child: Text(
                          data.isBusy ? '' : data.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  },
);

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
