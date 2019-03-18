import 'dart:ui';

import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('active_observers', () {
    // TODO: check other exports
    test('should export expected active observers', () {
      expect(
          observeEffect is void Function(VoidCallback Function(),
              [bool Function()]),
          true);
      expect(
          observeLifecycle is void Function(
              StateLifecyclePhase, void Function()),
          true);
      expect(
          observeListenable is void Function(
              Listenable Function(), VoidCallback Function()),
          true);
      expect(
          observeStream is void Function<T>(
              Stream<T> Function(), void Function(T)),
          true);
    });
  });
}
