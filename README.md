# active_observers

A new way to create composable UI logic, inspired by React hooks.

## Getting Started

```dart
class TestObserveState extends StatefulWidget {
  TestObserveState();

  @override
  _TestObserveStateState createState() => _TestObserveStateState();
}

class _TestObserveStateState extends State<TestObserveState>
    with ObservableStateLifecycle<TestObserveState> { // 1. Add a mixin to your State
  @override
  initState() {
    super.initState();
    state = observeState('a', this); // 2. Call active observers in initState
  }

  ObserveState<String> state;

  @override
  Widget build(BuildContext context) {
    // 3. Get & set value. The widget will be automatically updated.
    return Text(state.value, textDirection: TextDirection.ltr);
  }
}
```

More observers are on the way.
