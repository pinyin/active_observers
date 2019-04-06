import 'package:active_observers/active_observers.dart';
import 'package:active_observers/src/observe_memo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeMemo', () {
    testWidgets('should update value iff necessary', (tester) async {
      var computeCount = 0;
      await tester.pumpWidget(TestObserveMemo(
        value: 'a',
        recomputeWhen: () => false,
        onCompute: () => computeCount++,
      ));
      expect(find.text('a'), findsOneWidget);
      expect(computeCount, 1);
      await tester.pumpWidget(TestObserveMemo(
        value: 'b',
        recomputeWhen: () => false,
        onCompute: () => computeCount++,
      ));
      expect(find.text('b'), findsOneWidget);
      expect(computeCount, 2);
      await tester.pumpWidget(TestObserveMemo(
        value: 'b',
        recomputeWhen: () => false,
        onCompute: () => computeCount++,
      ));
      expect(find.text('b'), findsOneWidget);
      expect(computeCount, 2);
      await tester.pumpWidget(TestObserveMemo(
        value: 'b',
        recomputeWhen: () => true,
        onCompute: () => computeCount++,
      ));
      expect(find.text('b'), findsOneWidget);
      expect(computeCount, 3);
      await tester.pumpWidget(TestObserveMemo(
        value: 'b',
        recomputeWhen: () => false,
        onCompute: () => computeCount++,
      ));
      expect(find.text('b'), findsOneWidget);
      expect(computeCount, 3);
    });
  });
}

class TestObserveMemo extends StatefulWidget {
  final String value;
  final Function() onCompute;
  final bool Function() recomputeWhen;

  const TestObserveMemo(
      {Key key, this.value, this.onCompute, this.recomputeWhen})
      : super(key: key);

  @override
  _TestObserveMemoState createState() => _TestObserveMemoState();
}

class _TestObserveMemoState extends State<TestObserveMemo>
    with ActiveObservers {
  assembleActiveObservers() {
    memo = observeMemo(() {
      widget.onCompute();
      return widget.value;
    }, deps: () => [widget.value], recomputeWhen: () => widget.recomputeWhen());
  }

  ValueListenable<String> memo;

  @override
  Widget build(BuildContext context) {
    return Text(memo.value, textDirection: TextDirection.ltr);
  }
}
