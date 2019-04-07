import 'active_observers.dart';

export 'active_observers.dart' show StateLifecyclePhase;

/// During every lifecycle of [State], [run] will get called and receive a
/// [StateLifecyclePhase] representing current lifecycle.
void observeLifecycle(void Function(StateLifecyclePhase) run) {
  if (activeObservable == null)
    throw 'Active observers can only be initialized in assembleActiveObservers() method in State';
  activeObservable.activeObservers.add(run);
}
