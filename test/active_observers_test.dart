import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:observable_state_lifecycle/observable_state_lifecycle.dart';

void main() {
  group('observeState', () {
    testWidgets('should update widget with value', (tester) async {
      ObserveState<String> state;
      await tester.pumpWidget(TestObserveState((s) {
        state = s;
      }));
      expect(state.value, 'a');
      expect(find.text('a'), findsOneWidget);
      state.value = 'b';
      await tester.pump();
      expect(state.value, 'b');
      expect(find.text('b'), findsOneWidget);
    });
  });

  group('observeEffect', () {
    testWidgets('should run between initState & dispose', (tester) async {
      List<StateLifecyclePhase> report = [];
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      expect(report,
          [StateLifecyclePhase.initState, StateLifecyclePhase.didUpdateWidget]);
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      expect(report, [StateLifecyclePhase.didUpdateWidget]);
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }, false));
      expect(report, [
        StateLifecyclePhase.dispose, // previous effect terminated
        StateLifecyclePhase.didUpdateWidget,
        StateLifecyclePhase.didUpdateWidget
      ]);
      await tester.pumpWidget(Container());
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      await tester.pumpWidget(Container());
      expect(report, [
        StateLifecyclePhase.initState,
        StateLifecyclePhase.didUpdateWidget,
        StateLifecyclePhase.dispose,
        StateLifecyclePhase.dispose
      ]);
    });
  });
}

class TestObserveState extends StatefulWidget {
  TestObserveState(this.reportState);

  final void Function(ObserveState<String>) reportState;

  @override
  _TestObserveStateState createState() => _TestObserveStateState();
}

class _TestObserveStateState extends State<TestObserveState>
    with ObservableStateLifecycle<TestObserveState> {
  @override
  initState() {
    super.initState();
    state = observeState('a', this);
  }

  ObserveState<String> state;

  @override
  Widget build(BuildContext context) {
    widget.reportState(state);
    return Text(state.value, textDirection: TextDirection.ltr);
  }
}

class TestObserveEffect extends StatefulWidget {
  TestObserveEffect(this.reportState, [this.isIdentical = true]);

  final bool isIdentical;
  final void Function(StateLifecyclePhase) reportState;

  @override
  _TestObserveEffectState createState() => _TestObserveEffectState();
}

class _TestObserveEffectState extends State<TestObserveEffect>
    with ObservableStateLifecycle<TestObserveEffect> {
  @override
  initState() {
    super.initState();
    widget.reportState(StateLifecyclePhase.initState);
    observeEffect(() {
      widget.reportState(StateLifecyclePhase.didUpdateWidget);
      return () => {widget.reportState(StateLifecyclePhase.dispose)};
    }, () => widget.isIdentical, this);
  }

  @override
  void didUpdateWidget(TestObserveEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.reportState(StateLifecyclePhase.didUpdateWidget);
  }

  @override
  void dispose() {
    widget.reportState(StateLifecyclePhase.dispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
