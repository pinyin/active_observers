import 'active_observers.dart';

void observeLifecycle(void Function(StateLifecyclePhase) run) {
  if (observers == null)
    throw 'Active observers can only be initialized in assembleActiveObservers() method in State';
  observers.add(run);
}
