import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';

import './observe_effect.dart';

ValueListenable<T> observeValue<T>(T compute(),
    {bool recomputeWhen(), Iterable deps()}) {
  final notifier = ValueNotifier<T>(compute());

  recomputeWhen =
      recomputeWhen == null && deps == null ? () => true : recomputeWhen;

  observeEffect(
    () {
      notifier.value = compute();
    },
    restartWhen: recomputeWhen,
    deps: deps,
  );

  return notifier;
}
