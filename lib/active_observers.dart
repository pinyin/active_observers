library active_observers;

import 'dart:ui';

import 'package:observable_state_lifecycle/observable_state_lifecycle.dart';

void observeEffect(VoidCallback Function() effect, bool Function() isIdentical,
    ObservableStateLifecycle host) {
  VoidCallback cancel;

  host.addLifecycleObserver((phase) {
    switch (phase) {
      case StateLifecyclePhase.initState:
        cancel = effect();
        break;
      case StateLifecyclePhase.didUpdateWidget:
        if (isIdentical()) break;
        cancel();
        cancel = effect();
        break;
      case StateLifecyclePhase.dispose:
        cancel();
        break;
      default:
        {}
    }
  });
}

ObserveState<S> observeState<S>(S initialValue, ObservableStateLifecycle host) {
  return ObserveState(initialValue, host);
}

class ObserveState<S> {
  ObserveState(S initialValue, ObservableStateLifecycle state)
      : _state = state,
        _value = initialValue;

  S _value;
  final ObservableStateLifecycle _state;

  S get value => _value;
  set value(S newValue) {
    if (newValue == _value) return;
    _value = newValue;
    _state.setState(() {});
  }

  S get() {
    return value;
  }

  void set(S newValue) {
    value = newValue;
  }
}
