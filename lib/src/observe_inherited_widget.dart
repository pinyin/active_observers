import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import './active_observers.dart';

ValueListenable<T> observeInheritedWidget<T extends InheritedWidget>(
    [T orElse()]) {
  final target = activeObservable;
  final result = ValueNotifier<T>(
      target.context.inheritFromWidgetOfExactType(T) ?? orElse());

  ActiveObserver observer = (phase) {
    switch (phase) {
      case StateLifecyclePhase.didChangeDependencies:
        final T widget =
            target.context.inheritFromWidgetOfExactType(T) ?? orElse();
        if (widget == result.value) return;
        result.value = widget;
        break;
      default:
        break;
    }
  };
  observeLifecycle(StateLifecyclePhase.didChangeDependencies, observer);

  return result;
}
