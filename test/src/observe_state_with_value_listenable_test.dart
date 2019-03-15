import 'package:active_observers/active_observers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeStateWithValueListenable', () {
    testWidgets('should update widget with value', (tester) async {
      final source = ValueNotifier('a');
      await tester
          .pumpWidget(TestObserveValueListenableState(listenable: source));
      expect(find.text('a'), findsOneWidget);
      source.value = 'b';
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
    });
    testWidgets(
        'should automatically unsubscribe from ValueListenable on dispose',
        (tester) async {
      final source = ValueNotifier('a');
      await tester
          .pumpWidget(TestObserveValueListenableState(listenable: source));
      expect(find.text('a'), findsOneWidget);
      expect(source.hasListeners, true);
      await tester.pumpWidget(Container());
      source.value = 'b';
      expect(source.hasListeners, false);
    });
    testWidgets('should resubscribe on widget update if necessary',
        (tester) async {
      final source = ValueNotifier('a');
      await tester
          .pumpWidget(TestObserveValueListenableState(listenable: source));
      expect(find.text('a'), findsOneWidget);
      final source2 = ValueNotifier('b');
      await tester
          .pumpWidget(TestObserveValueListenableState(listenable: source2));
      expect(find.text('b'), findsOneWidget);
      expect(source.hasListeners, false);
      expect(source2.hasListeners, true);
    });
  });
}

class TestObserveValueListenableState extends StatefulWidget {
  final ValueListenable<String> listenable;

  const TestObserveValueListenableState({Key key, this.listenable})
      : super(key: key);

  @override
  _TestObserveValueListenableStateState createState() =>
      _TestObserveValueListenableStateState();
}

class _TestObserveValueListenableStateState
    extends State<TestObserveValueListenableState> with ActiveObservers {
  _TestObserveValueListenableStateState() {
    value = observeStateWithValueListenable(() => widget.listenable)(this);
  }

  ObserveState<String> value;

  @override
  Widget build(BuildContext context) {
    return Text(value.value, textDirection: TextDirection.ltr);
  }
}
