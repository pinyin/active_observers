import 'package:flutter/widgets.dart';

import 'observe_lifecycle.dart';

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

  observeLifecycle((lifecycle) {
    switch (lifecycle) {
      case StateLifecyclePhase.initState:
        scheduleCallback();
        break;
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
