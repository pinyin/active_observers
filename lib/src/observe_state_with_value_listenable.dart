import 'package:flutter/foundation.dart';

import 'active_observers.dart';
import 'observe_effect.dart';
import 'observe_state.dart';

/// Update [State] with a [ValueListenable].
/// This can also be used with [AnimationController] since [AnimationController] is a
/// [ValueListenable]
ActiveObserver<ObserveState<T>> observeStateWithValueListenable<T>(
    ValueListenable<T> getValueListenable()) {
  return (host) {
    ValueListenable<T> valueListenable;
    final state = observeState<T>(() => getValueListenable().value)(host);
    observeEffect(() {
      valueListenable = getValueListenable();
      state.value = valueListenable.value;
      void updateState() {
        state.value = valueListenable.value;
      }

      valueListenable.addListener(updateState);
      return () => valueListenable.removeListener(updateState);
    }, () => valueListenable == getValueListenable())(host);
    return state;
  };
}
