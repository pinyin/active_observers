import 'dart:ui';

import 'active_observers.dart';
import 'utils.dart';

/// [effect] will be called in State's [initState].
/// [effect] should return a callback that will be called in [dispose]. Typically,
/// the callback should contain [effect]'s clean up logic.
/// Whenever the widget is updated([didUpdateWidget]), if [isIdentical] returns false
/// the callback returned by previous [effect] will be called to clean up previous
/// [effect] , then [effect] is called again. tl;dr [effect] will be restarted.
ActiveObserver<void> observeEffect(VoidCallback Function() effect,
    [bool Function() isIdentical = alwaysReturnTrue]) {
  return (ActiveObservers host) {
    VoidCallback cancel;
    host.activeObservers.add((phase) {
      switch (phase) {
        case StateLifecyclePhase.initState:
          cancel = effect();
          break;
        case StateLifecyclePhase.didUpdateWidget:
          if (isIdentical()) break;
          cancel();
          cancel = effect();
          break;
        case StateLifecyclePhase.reassemble:
          cancel();
          cancel = effect();
          break;
        case StateLifecyclePhase.dispose:
          cancel();
          break;
        default:
          {}
      }
    });
  };
}
