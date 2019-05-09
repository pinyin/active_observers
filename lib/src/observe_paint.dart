import 'package:flutter/widgets.dart';

import 'active_observers.dart';

/// Run [callback] after initial paint, then call it again when this state
/// is updated and [rerunWhen] returns true.
/// Since [callback] is called after paint, it can read geometric information in
/// current and descendant widgets.
/// Notice: this observer will not be triggered by paints caused by parent
/// widgets, e.g. constraint updates from parent widget.
void observePaint(void callback(), {bool Function() rerunWhen}) {
  var hasScheduledTask = false;

  void scheduleCallback() {
    if (hasScheduledTask) return;
    hasScheduledTask = true;
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      callback();
      hasScheduledTask = false;
    });
  }

  scheduleCallback();

  VoidCallback observer = () {
    if (rerunWhen != null && rerunWhen()) scheduleCallback();
  };
  observeLifecycle(StateLifecyclePhase.didChangeDependencies, observer);
  observeLifecycle(StateLifecyclePhase.didUpdateWidget, observer);
  observeLifecycle(StateLifecyclePhase.didSetState, observer);
}
