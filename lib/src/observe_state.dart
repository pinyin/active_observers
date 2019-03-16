import 'package:active_observers/src/active_observers.dart';

/// Create a value. Updating the value would cause [StatefulWidget] to rebuild.
ActiveObserver<ObserveState<S>> observeState<S>(S getInitialValue()) {
  return (ActiveObservers host) {
    return ObserveState(getInitialValue, host);
  };
}

class ObserveState<S> {
  ObserveState(S getInitialValue(), ActiveObservers host) : _host = host {
    host.activeObservers.add((phase) {
      switch (phase) {
        case StateLifecyclePhase.initState:
          _value = getInitialValue();
          break;
        default:
          {}
      }
    });
  }

  S _value;
  final ActiveObservers _host;

  /// stored value, [State] will rebuild after a new value is set
  S get value => _value;
  set value(S newValue) {
    if (newValue == _value) return;
    _value = newValue;
    _host.setState(() {});
  }

  /// get stored value
  S get() {
    return value;
  }

  /// set store value, [State] will rebuild if the old and new values are not identical
  void set(S newValue) {
    value = newValue;
  }
}
