import 'package:flutter/widgets.dart';

import 'observe_lifecycle.dart';

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

  observeLifecycle((lifecycle) {
    switch (lifecycle) {
      case StateLifecyclePhase.didChangeDependencies:
      case StateLifecyclePhase.didUpdateWidget:
      case StateLifecyclePhase.didSetState:
        if (rerunWhen != null && rerunWhen()) scheduleCallback();
        break;
      default:
        break;
    }
  });
}
