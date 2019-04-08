import './observe_effect.dart';
import './utils.dart';

Memo<T> observeValue<T>(T compute(), {bool recomputeWhen(), Iterable deps()}) {
  final notifier = MemoController<T>(null);

  recomputeWhen =
      recomputeWhen == null && deps == null ? () => true : recomputeWhen;

  observeEffect(
    () {
      final currentValue = compute();
      if (currentValue == notifier.value) return;
      notifier.value = currentValue;
    },
    restartWhen: recomputeWhen,
    deps: deps,
  );

  return notifier;
}
