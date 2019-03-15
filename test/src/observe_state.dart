import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeState', () {
    testWidgets('should rebuild widget when value changes', (tester) async {
      ObserveState<String> state;
      int rebuildCount = 0;
      await tester.pumpWidget(TestObserveState((s) {
        state = s;
        rebuildCount++;
      }));
      expect(state.value, 'a');
      expect(find.text('a'), findsOneWidget);
      int prevRebuildCount = rebuildCount;
      state.value = 'b';
      await tester.pump();
      expect(state.value, 'b');
      expect(find.text('b'), findsOneWidget);
      expect(rebuildCount, prevRebuildCount + 1);
      prevRebuildCount = rebuildCount;
      state.value = 'b';
      await tester.pump();
      expect(state.value, 'b');
      expect(find.text('b'), findsOneWidget);
      expect(rebuildCount, prevRebuildCount);
    });
  });
}

class TestObserveState extends StatefulWidget {
  TestObserveState(this.onBuild);

  final void Function(ObserveState<String>) onBuild;

  @override
  _TestObserveStateState createState() => _TestObserveStateState();
}

class _TestObserveStateState extends State<TestObserveState>
    with ActiveObservers {
  _TestObserveStateState() {
    state = observeState(() => 'a')(this);
  }

  ObserveState<String> state;

  @override
  Widget build(BuildContext context) {
    widget.onBuild(state);
    return Text(state.value, textDirection: TextDirection.ltr);
  }
}
