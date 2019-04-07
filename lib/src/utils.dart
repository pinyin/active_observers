import 'package:flutter/foundation.dart';

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
