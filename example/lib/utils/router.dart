import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Router extends Navigator with DetailedLifecycleInState {
  const Router({
    @required RouteFactory onGenerateRoute,
    @required this.controller,
    Key key,
    String initialRoute,
    RouteFactory onUnknownRoute,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  })  : assert(onGenerateRoute != null),
        super(
          key: key,
          initialRoute: initialRoute,
          onGenerateRoute: onGenerateRoute,
          onUnknownRoute: onUnknownRoute,
          observers: observers,
        );

  final RouterController controller;

  @override
  _RouterState createState() => _RouterState();
}

class _RouterState extends NavigatorState with ActiveObservers {
  @override
  Router get widget => super.widget;

  @override
  void assembleActiveObservers() {
    observeEffect(() {
      widget.controller.value = this;
    }, restartWhen: () => widget.controller.value == null);
  }
}

class RouterController extends ValueNotifier<NavigatorState> {
  RouterController(NavigatorState value) : super(value);
}
