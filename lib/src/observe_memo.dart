import 'package:collection/collection.dart';

import './observe_effect.dart';

T Function() observeMemo<T>(T compute(),
    {bool recomputeWhen(), Iterable deps()}) {
  Iterable latestDeps = deps != null ? deps() : null;
  T latestValue;

  observeEffect(
    () {
      latestValue = compute();
    },
    restartWhen: () {
      final isForcingRecompute =
          recomputeWhen != null ? recomputeWhen() : false;
      var hasDepsUpdated = false;
      if (deps != null) {
        final currentDeps = deps();
        hasDepsUpdated = !equals(latestDeps, currentDeps);
        latestDeps = currentDeps;
      }
      return isForcingRecompute || hasDepsUpdated;
    },
  );

  return () => latestValue;
}

final equals = const IterableEquality().equals;
