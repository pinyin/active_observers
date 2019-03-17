import 'active_observers.dart';

ActiveObserver<void> observeLifecycle(
    StateLifecyclePhase on, void Function() run) {
  return (ActiveObservers host) {
    host.activeObservers.add((phase) {
      if (on == phase) run();
    });
  };
}
