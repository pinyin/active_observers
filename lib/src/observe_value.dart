import './observe_effect.dart';
import './utils.dart';

Memo<T> observeValue<T>(T compute(), {bool recomputeWhen(), Iterable deps()}) {
  final notifier = MemoController<T>(null);

  observeEffect(
    () {
      notifier.value = compute();
    },
    restartWhen: recomputeWhen,
    deps: deps,
  );

  return notifier;
}
