import 'dart:ui';

import 'package:collection/collection.dart';

import 'active_observers.dart';

/// [effect] will be called in State's [initState].
/// [effect] should return a callback that will be called in [dispose]. Typically,
/// the callback should contain [effect]'s clean up logic.
/// Whenever the widget is updated([didUpdateWidget]), if [restartWhen] returns false
/// the callback returned by previous [effect] will be called to clean up previous
/// [effect] , then [effect] is called again. tl;dr [effect] will be restarted.
void observeUpdate(VoidCallback Function() effect,
    {bool restartWhen(), Iterable values()}) {
  VoidCallback cancel = effect();
  Iterable latestDeps = values != null ? values() : null;

  VoidCallback observer = () {
    final isForcingRestart = restartWhen != null ? restartWhen() : false;
    var hasDepsUpdated = false;
    if (values != null) {
      final currentDeps = values();
      hasDepsUpdated = !equals(latestDeps, currentDeps);
      latestDeps = currentDeps;
    }
    if (isForcingRestart || hasDepsUpdated) {
      if (cancel != null) cancel();
      cancel = effect();
    }
  };

  observeLifecycle(StateLifecyclePhase.didChangeDependencies, observer);
  observeLifecycle(StateLifecyclePhase.didUpdateWidget, observer);
  observeLifecycle(StateLifecyclePhase.didSetState, observer);
  observeLifecycle(StateLifecyclePhase.dispose, () {
    if (cancel != null) cancel();
  });
}

void observeUpdateToListener() {}

final equals = const IterableEquality().equals;
