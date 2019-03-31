import 'dart:collection';

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
mixin ActiveObservers<T extends StatefulWidget> on State<T> {
  void assembleActiveObservers();

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    observers = this._activeObservers;
    assembleActiveObservers();
    observers = null;
    _activeObservers.forEach((observer) {
      observer(StateLifecyclePhase.initState);
    });
  }

  @override
  @mustCallSuper
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activeObservers.forEach((observer) {
      observer(StateLifecyclePhase.didUpdateWidget);
    });
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeObservers.forEach((observer) {
      observer(StateLifecyclePhase.didChangeDependencies);
    });
  }

  @override
  @mustCallSuper
  @protected
  void setState(VoidCallback fn) {
    super.setState(fn);
    _activeObservers.forEach((observer) {
      observer(StateLifecyclePhase.didSetState);
    });
  }

  @override
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    _activeObservers.toList(growable: false).reversed.forEach((observer) {
      observer(StateLifecyclePhase.dispose);
    });
    _activeObservers.clear();
    observers = this._activeObservers;
    assembleActiveObservers();
    observers = null;
    _activeObservers.forEach((observer) {
      observer(StateLifecyclePhase.initState);
    });
  }

  @override
  @mustCallSuper
  void deactivate() {
    _activeObservers.toList(growable: false).reversed.forEach((observer) {
      observer(StateLifecyclePhase.deactivate);
    });
    super.deactivate();
  }

  @override
  @mustCallSuper
  void dispose() {
    _activeObservers.toList(growable: false).reversed.forEach((observer) {
      observer(StateLifecyclePhase.dispose);
    });
    super.dispose();
  }

  final Set<ObserverHandler> _activeObservers =
      LinkedHashSet<ObserverHandler>();
}

enum StateLifecyclePhase {
  initState,
  didUpdateWidget,
  didChangeDependencies,
  didSetState,
  deactivate,
  dispose,
}

typedef ObserverHandler<T> = T Function(StateLifecyclePhase phase);

Set<ObserverHandler> observers;
