import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';

import './active_observers.dart';
import './utils.dart';

Memo<T> observeInheritedWidget<T extends InheritedWidget>([T orElse()]) {
  final target = activeObservable;
  final result = MemoController<T>(
      target.context.inheritFromWidgetOfExactType(T) ?? orElse());

  observeLifecycle((phase) {
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
  });

  return result;
}
