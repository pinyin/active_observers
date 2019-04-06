import './observe_effect.dart';
import './utils.dart';

Memo<T> observeMemo<T>(T compute(), {bool recomputeWhen(), Iterable deps()}) {
  final notifier = MemoImpl<T>(compute());

  observeEffect(
    () {
      notifier.value = compute();
    },
    restartWhen: recomputeWhen,
    deps: deps,
  );

  return notifier;
}
