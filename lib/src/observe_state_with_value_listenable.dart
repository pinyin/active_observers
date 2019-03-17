import 'package:flutter/foundation.dart';

import 'observe_effect.dart';
import 'observe_state.dart';

/// Update [State] with a [ValueListenable].
/// This can also be used with [AnimationController] since [AnimationController] is a
/// [ValueListenable]
ObserveState<T> observeStateWithValueListenable<T>(
    ValueListenable<T> getValueListenable()) {
  ValueListenable<T> valueListenable;
  final state = observeState<T>(() => getValueListenable().value);
  observeEffect(() {
    valueListenable = getValueListenable();
    state.value = valueListenable.value;
    void updateState() {
      state.value = valueListenable.value;
    }

    valueListenable.addListener(updateState);
    return () => valueListenable.removeListener(updateState);
  }, () => valueListenable == getValueListenable());
  return state;
}
