import 'package:flutter/material.dart';
import 'package:state_tree_router/state_tree_router.dart';
import 'package:state_tree_router_demo/state_trees/simple/simple_state_tree.dart';

final enterTextPage = TreeStatePage.forState(
  SimpleStates.enterText,
  (buildContext, currentState) {
    var currentText = '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StatefulBuilder(
            builder: (context, setState) => Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                onChanged: (val) => currentText = val,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter some text',
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: const Text('To Uppercase'),
                  onPressed: () => currentState.post(ToUppercase(currentText)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: const Text('To Lowercase'),
                  onPressed: () => currentState.post(ToLowercase(currentText)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
);

final toUppercasePage = TreeStatePage.forDataState<String>(
  SimpleStates.showUppercase,
  (buildContext, text, currentState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Uppercase text: $text',
          style: const TextStyle(fontSize: 24),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('Done'),
            onPressed: () => currentState.post(Messages.finish),
          ),
        ),
      ],
    );
  },
);

final toLowercasePage = TreeStatePage.forDataState<String>(
  SimpleStates.showLowercase,
  (buildContext, text, currentState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Lowercase text: $text',
          style: const TextStyle(fontSize: 24),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('Done'),
            onPressed: () => currentState.post(Messages.finish),
          ),
        ),
      ],
    );
  },
);
