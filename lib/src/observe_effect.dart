import 'dart:ui';

import 'observe_lifecycle.dart';

/// [effect] will be called in State's [initState].
/// [effect] should return a callback that will be called in [dispose]. Typically,
/// the callback should contain [effect]'s clean up logic.
/// Whenever the widget is updated([didUpdateWidget]), if [restartWhen] returns false
/// the callback returned by previous [effect] will be called to clean up previous
/// [effect] , then [effect] is called again. tl;dr [effect] will be restarted.
void observeEffect(VoidCallback Function() effect,
    {bool Function() restartWhen}) {
  VoidCallback cancel;
  observeLifecycle((phase) {
    switch (phase) {
      case StateLifecyclePhase.initState:
        cancel = effect();
        break;
      case StateLifecyclePhase.didChangeDependencies:
      case StateLifecyclePhase.didUpdateWidget:
      case StateLifecyclePhase.didSetState:
        if (restartWhen != null && restartWhen()) {
          if (cancel != null) cancel();
          cancel = effect();
        }
        break;
      case StateLifecyclePhase.dispose:
        if (cancel != null) cancel();
        break;
      default:
        {}
    }
  });
}
