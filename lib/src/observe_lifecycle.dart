import 'active_observers.dart';

void observeLifecycle(void Function(StateLifecyclePhase) run) {
  if (currentHost == null)
    throw 'Active observers can only be initialized in assembleActiveObservers() method in State';
  currentHost.activeObservers.add(run);
}
