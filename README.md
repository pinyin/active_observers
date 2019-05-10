# active_observers

[![Build Status](https://travis-ci.com/pinyin/active_observers.svg?branch=master)](https://travis-ci.com/pinyin/active_observers)

A new way to create composable UI logic, inspired by React hooks.

## Getting Started

```dart
import 'package:active_observers/active_observers.dart'; // 1.import package

class TestObserveState extends StatefulWidget with DetailedLifecyleInState {  // mixin is optional
  TestObserveState(this.stream);
  
  final Stream<String> stream;

  @override
  _TestObserveStateState createState() => _TestObserveStateState();
}

class _TestObserveStateState extends State<TestObserveState>
    with ActiveObservers { // 2. Add a mixin to your State
  @override
  assembleActiveObservers() {
    // 3. Setup active observers in assembleActiveObservers
    // codes in this method will be executed on hot reload
    observeUpdate(()=> widget.stream.listen((v){
      // subscription will be automatically restarted when any value in values updates
      setState((){
        value = v;
      });
    }).cancel, values: ()=> [widget.stream]);
  }

  String value;

  @override
  Widget build(BuildContext context) {
    return Text(value, textDirection: TextDirection.ltr);
  }
}
```
Under construction.

Please refer to `./test/src` for more active observers.
