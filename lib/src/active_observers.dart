import 'dart:collection';

import 'package:flutter/widgets.dart';

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
  deactivate,
  dispose,
}

typedef ObserverHandler<T> = T Function(StateLifecyclePhase phase);

Set<ObserverHandler> observers;
