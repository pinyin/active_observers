import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import './active_observers.dart';

ValueListenable<T> observeContext<T>(T Function(BuildContext) dependency) {
  final target = activeObservable;
  final result = ValueNotifier<T>(dependency(target.context));

  final ActiveObserver observer = (phase) {
    switch (phase) {
      case StateLifecyclePhase.didChangeDependencies:
        final currentDependency = dependency(target.context);
        if (currentDependency == result.value) return;
        result.value = currentDependency;
        break;
      default:
        break;
    }
  };
  observeLifecycle(StateLifecyclePhase.didChangeDependencies, observer);

  return result;
}
