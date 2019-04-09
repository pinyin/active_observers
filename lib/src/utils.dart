import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool alwaysReturnTrue() {
  return true;
}

abstract class Memo<T> implements ValueListenable<T> {
  T call();
}

class MemoController<T> extends ValueNotifier<T> implements Memo<T> {
  MemoController(T value) : super(value);

  call() => this.value;
}

class Ref<T> {
  T value;

  Ref(this.value);
}
