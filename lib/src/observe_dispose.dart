import 'package:active_observers/active_observers.dart';

void observeDispose(void onDispose()) {
  observeLifecycle(StateLifecyclePhase.dispose, onDispose);
}
