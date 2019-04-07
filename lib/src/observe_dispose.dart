import 'package:active_observers/active_observers.dart';

void observeDispose(void clean()) {
  observeLifecycle((phase) {
    if (phase == StateLifecyclePhase.dispose) {
      clean();
    }
  });
}
