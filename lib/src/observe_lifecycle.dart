import 'active_observers.dart';

/// During every lifecycle of [State], [run] will get called and receive a
/// [StateLifecyclePhase] representing current lifecycle.
void observeLifecycle(void Function(StateLifecyclePhase) run) {
  if (observers == null)
    throw 'Active observers can only be initialized in assembleActiveObservers() method in State';
  observers.add(run);
}
