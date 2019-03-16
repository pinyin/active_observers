# active_observers

[![Build Status](https://travis-ci.com/pinyin/active_observers.svg?branch=master)](https://travis-ci.com/pinyin/active_observers)

A new way to create composable UI logic, inspired by React hooks.

## Getting Started

```dart
import 'package:active_observers/active_observers.dart'; // 1.import package

class TestObserveState extends StatefulWidget {
  TestObserveState();

  @override
  _TestObserveStateState createState() => _TestObserveStateState();
}

class _TestObserveStateState extends State<TestObserveState>
    with ActiveObservers { // 2. Add a mixin to your State
  _TestObserveStateState() {
    state = observeState('a')(this); // 3. Setup active observers in constructor
  }

  ObserveState<String> state;

  @override
  Widget build(BuildContext context) {
    // 3. Get & set value. The widget will be automatically rebuilt.
    return Text(state.value, textDirection: TextDirection.ltr);
  }
}
```
Under construction.

Please refer to `./test/src` for more active observers.
