import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import './active_observers.dart';

ValueListenable<T> observeContext<T>(T Function(BuildContext) dependency) {
  final target = activeObservable;
  final result = ValueNotifier<T>(dependency(target.context));

  observeLifecycle(StateLifecyclePhase.didChangeDependencies, () {
    final currentDependency = dependency(target.context);
    if (currentDependency == result.value) return;
    result.value = currentDependency;
  });

  return result;
}
