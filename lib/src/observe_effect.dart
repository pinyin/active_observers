import 'dart:ui';

import 'package:collection/collection.dart';

import 'observe_lifecycle.dart';

/// [effect] will be called in State's [initState].
/// [effect] should return a callback that will be called in [dispose]. Typically,
/// the callback should contain [effect]'s clean up logic.
/// Whenever the widget is updated([didUpdateWidget]), if [restartWhen] returns false
/// the callback returned by previous [effect] will be called to clean up previous
/// [effect] , then [effect] is called again. tl;dr [effect] will be restarted.
void observeEffect(VoidCallback Function() effect,
    {bool restartWhen(), Iterable deps()}) {
  VoidCallback cancel = effect();
  Iterable latestDeps = deps != null ? deps() : null;

  void restartIfNecessary() {
    final isForcingRestart = restartWhen != null ? restartWhen() : false;
    var hasDepsUpdated = false;
    if (deps != null) {
      final currentDeps = deps();
      hasDepsUpdated = !equals(latestDeps, currentDeps);
      latestDeps = currentDeps;
    }
    if (isForcingRestart || hasDepsUpdated) {
      if (cancel != null) cancel();
      cancel = effect();
    }
  }

  observeLifecycle((phase) {
    switch (phase) {
      case StateLifecyclePhase.initState:
      case StateLifecyclePhase.didChangeDependencies:
      case StateLifecyclePhase.didUpdateWidget:
      case StateLifecyclePhase.didSetState:
        restartIfNecessary();
        break;
      case StateLifecyclePhase.dispose:
        if (cancel != null) cancel();
        break;
      default:
        {}
    }
  });
}

final equals = const IterableEquality().equals;
