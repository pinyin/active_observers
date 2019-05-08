import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A type of observers that subscribes itself to the target [State]'s lifecycle.
/// Like ordinary observers, an active observer listens from one or many observables
/// and reactive to the events, but the subscription is managed by the active observer
/// rather than the observable. After subscription, data still flows from the observable
/// to the observer.
/// The word "active" means the observer acts actively, rather than "passively":
/// ```dart
/// // passively:
/// observable.addListener(observer)
/// // actively:
/// observer(observable)
/// ```
/// Active Observers pattern allows us to compose observers in a scalable way and
/// make observers much more powerful.
/// Inspired by React hooks.
/// In this case, the observable being observed is a Flutter [StatefulWidget] [State].
mixin ActiveObservers<T extends StatefulWidget> on State<T>
    implements DetailedLifecycle<T> {
  void assembleActiveObservers();

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    (_observerRegistry.value[StateLifecyclePhase.didUpdateWidget] ??=
            QueueList())
        .forEach((observer) => observer(StateLifecyclePhase.didUpdateWidget));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialized.value) {
      activeObservable = this;
      assembleActiveObservers();
      activeObservable = null;
      _didInitialized.value = true;
    }
    (_observerRegistry.value[StateLifecyclePhase.didChangeDependencies] ??=
            QueueList())
        .forEach(
            (observer) => observer(StateLifecyclePhase.didChangeDependencies));
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    (_observerRegistry.value[StateLifecyclePhase.didSetState] ??= QueueList())
        .forEach((observer) => observer(StateLifecyclePhase.didSetState));
  }

  @override
  void reassemble() {
    (_observerRegistry.value[StateLifecyclePhase.dispose] ??= QueueList())
        .reversed
        .forEach((observer) => observer(StateLifecyclePhase.dispose));
    _observerRegistry.value = Map();
    if (this.widget is! DetailedLifecycleInState) {
      // will never call didReassemble, so restart observers here
      // otherwise, restart observers before next build to get more correct behavior
      activeObservable = this;
      assembleActiveObservers();
      activeObservable = null;
    }
    super.reassemble();
  }

  @override
  void didReassemble() {
    activeObservable = this;
    assembleActiveObservers();
    activeObservable = null;
  }

  @override
  bool shouldRebuild() {
    return true;
  }

  @override
  void willBuild() {
    (_observerRegistry.value[StateLifecyclePhase.willBuild] ??= QueueList())
        .reversed
        .forEach((observer) => observer(StateLifecyclePhase.willBuild));
  }

  @override
  didBuild() {
    (_observerRegistry.value[StateLifecyclePhase.didBuild] ??= QueueList())
        .reversed
        .forEach((observer) => observer(StateLifecyclePhase.didBuild));
  }

  @override
  void deactivate() {
    (_observerRegistry.value[StateLifecyclePhase.deactivate] ??= QueueList())
        .reversed
        .forEach((observer) => observer(StateLifecyclePhase.deactivate));
    super.deactivate();
  }

  @override
  void reactivate() {
    (_observerRegistry.value[StateLifecyclePhase.reactivate] ??= QueueList())
        .forEach((observer) => observer(StateLifecyclePhase.reactivate));
  }

  @override
  void dispose() {
    (_observerRegistry.value[StateLifecyclePhase.dispose] ??= QueueList())
        .reversed
        .forEach((observer) => observer(StateLifecyclePhase.dispose));
    super.dispose();
  }

  final _observerRegistry =
      Ref(Map<StateLifecyclePhase, QueueList<ActiveObserver>>());
  final _didInitialized = Ref(false);
}

void observeLifecycle(StateLifecyclePhase on, ActiveObserver observer) {
  if (activeObservable == null)
    throw 'Active observers can only be initialized in assembleActiveObservers() method in State';
  (activeObservable._observerRegistry.value[on] ??= QueueList()).add(observer);
}

mixin DetailedLifecycle<T extends StatefulWidget> on State<T> {
  @protected
  @mustCallSuper
  willBuild() {}

  @protected
  @mustCallSuper
  didBuild() {}

  @protected
  @mustCallSuper
  bool shouldRebuild() {
    return true;
  }

  @protected
  @mustCallSuper
  didReassemble() {}

  @protected
  @mustCallSuper
  reactivate() {}
}

// TODO test this
mixin DetailedLifecycleInState on StatefulWidget {
  @override
  StatefulElement createElement() {
    return _DetailedLifecycleProxy(this); // TODO make this composable
  }
}

class _DetailedLifecycleProxy extends StatefulElement {
  _DetailedLifecycleProxy(StatefulWidget widget) : super(widget);

  @override
  DetailedLifecycle get state => super.state;

  Widget _built;

  @override
  Widget build() {
    if (_justReassembled) {
      state.didReassemble();
      _justReassembled = false;
    }
    if (!state.shouldRebuild() && _built != null) return _built;
    state.willBuild();
    _built = super.build();
    state.didBuild();
    return _built;
  }

  bool _justReassembled = false;

  @override
  void reassemble() {
    super.reassemble();
    _justReassembled = true;
  }

  @override
  void activate() {
    super.activate();
    state.reactivate();
  }
}

enum StateLifecyclePhase {
  didUpdateWidget,
  didChangeDependencies,
  didSetState,
  willBuild,
  didBuild,
  deactivate,
  reactivate,
  dispose,
}

typedef ActiveObserver = void Function(StateLifecyclePhase phase);

ActiveObservers activeObservable;

class Ref<T> {
  T value;

  Ref(this.value);
}
