library active_observers;

import 'dart:ui';

import 'package:observable_state_lifecycle/observable_state_lifecycle.dart';

typedef ActiveObserver<T> = T Function(ObservableStateLifecycle);

ActiveObserver<void> observeEffect(VoidCallback Function() effect,
    [bool Function() isIdentical = _alwaysReturnTrue]) {
  return (host) {
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
  };
}

ActiveObserver<ObserveState<S>> observeState<S>(S initialValue) {
  return (host) {
    return ObserveState(initialValue, host);
  };
}

ActiveObserver<void> observeStream<T>(Stream<T> stream, void onData(T event),
    {void Function(Object, StackTrace) onError, void onDone()}) {
  return (host) {
    return observeEffect(() {
      return stream.listen(onData, onError: onError, onDone: onDone).cancel;
    })(host);
  };
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

bool _alwaysReturnTrue() {
  return true;
}
