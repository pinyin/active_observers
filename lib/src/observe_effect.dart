import 'dart:ui';

import 'active_observers.dart';
import 'observe_lifecycle.dart';
import 'utils.dart';

/// [effect] will be called in State's [initState].
/// [effect] should return a callback that will be called in [dispose]. Typically,
/// the callback should contain [effect]'s clean up logic.
/// Whenever the widget is updated([didUpdateWidget]), if [isIdentical] returns false
/// the callback returned by previous [effect] will be called to clean up previous
/// [effect] , then [effect] is called again. tl;dr [effect] will be restarted.
void observeEffect(VoidCallback Function() effect,
    [bool Function() isIdentical = alwaysReturnTrue]) {
  VoidCallback cancel;
  observeLifecycle((phase) {
    switch (phase) {
      case StateLifecyclePhase.initState:
        cancel = effect();
        break;
      case StateLifecyclePhase.didChangeDependencies:
      case StateLifecyclePhase.didUpdateWidget:
        if (isIdentical()) return;
        if (cancel != null) cancel();
        cancel = effect();
        break;
      case StateLifecyclePhase.dispose:
        if (cancel != null) cancel();
        break;
      default:
        {}
    }
  });
}
