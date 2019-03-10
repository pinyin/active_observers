library active_observers;

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:observable_state_lifecycle/observable_state_lifecycle.dart';

/// A type of observers that subscribes itself actively to the target [State].
/// Like ordinary observers, an active observer listens from one or many observables
/// and reactive to the events, but the subscription is done by the active observer
/// rather than the observable. After subscription, data flows from the observable
/// to the active observer.
/// The word "active" means the observer acts actively, rather than "passively":
/// ```dart
/// // passively:
/// observable.addListener(observer)
/// // actively:
/// observer.listenTo(observable)
/// observer(observable) // when lambda is supported
/// ```
/// Active observers pattern allows us to compose observers in a scalable way and
/// make observers much more powerful.
/// Inspired by React hooks.
/// In this case, the [observable] being observed is a Flutter [StatefulWidget] [State].
typedef ActiveObserver<T> = T Function(ObservableStateLifecycle observable);

/// [effect] will be called in State's [initState].
/// [effect] should return a callback that will be called in [dispose]. Typically,
/// the callback should contain [effect]'s clean up logic.
/// Whenever the widget is updated([didUpdateWidget]), if [isIdentical] returns false
/// the callback returned by previous [effect] will be called to clean up previous
/// [effect] , then [effect] is called again. tl;dr [effect] will be restarted.
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

/// Create a value. Updating the value would cause [StatefulWidget] to rebuild.
ActiveObserver<ObserveState<S>> observeState<S>(S initialValue) {
  return (host) {
    return ObserveState(initialValue, host);
  };
}

/// Add a listener to a stream. The listener will be automatically cancelled
/// when the [State] is disposed.
ActiveObserver<void> observeStream<T>(Stream<T> stream, void onData(T event),
    {void Function(Object, StackTrace) onError, void onDone()}) {
  return (host) {
    return observeEffect(() {
      return stream.listen(onData, onError: onError, onDone: onDone).cancel;
    })(host);
  };
}

/// Add a listener to a [Listenable]. The listener will be automatically cancelled
/// when the [State] is disposed.
ActiveObserver<void> observeListenable(
    Listenable listenable, VoidCallback callback) {
  return (host) {
    observeEffect(() {
      listenable.addListener(callback);
      return () {
        listenable.removeListener(callback);
      };
    })(host);
  };
}

/// Update [State] with a [ValueListenable].
/// This can also be used with [AnimationController] since [AnimationController] is a
/// [ValueListenable]
ActiveObserver<ObserveState<T>> observeValueListenableState<T>(
    ValueListenable<T> listenable) {
  return (host) {
    final state = observeState(listenable.value)(host);
    observeListenable(listenable, () => state.set(listenable.value))(host);
    return state;
  };
}

class ObserveState<S> {
  ObserveState(S initialValue, ObservableStateLifecycle state)
      : _state = state,
        _value = initialValue;

  S _value;
  final ObservableStateLifecycle _state;

  /// stored value, [State] will rebuild after a new value is set
  S get value => _value;
  set value(S newValue) {
    if (newValue == _value) return;
    _value = newValue;
    _state.setState(() {});
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

bool _alwaysReturnTrue() {
  return true;
}
