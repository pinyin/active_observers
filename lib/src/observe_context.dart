import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';

import './active_observers.dart';
import './utils.dart';

Memo<T> observeContext<T>(T Function(BuildContext) dependency) {
  final target = activeObservable;
  final result = MemoController<T>(dependency(target.context));

  void forwardContextIfUpdated() {
    final currentDependency = dependency(target.context);
    if (currentDependency == result.value) return;
    result.value = currentDependency;
  }

  observeLifecycle((phase) {
    switch (phase) {
      case StateLifecyclePhase.initState:
      case StateLifecyclePhase.didChangeDependencies:
        forwardContextIfUpdated();
        break;
      default:
        break;
    }
  });

  return result;
}
