import 'active_observers.dart';

void observeLifecycle(StateLifecyclePhase on, void Function() run) {
  if (currentHost == null)
    throw 'Active observers can only be initialized in assembleActiveObservers() method in State';
  currentHost.activeObservers.add((phase) {
    if (on == phase) run();
  });
}
