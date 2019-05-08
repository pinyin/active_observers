import 'package:active_observers/src/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeLifecycle', () {
    testWidgets('should call callbacks on specified lifecycle phases',
        (tester) async {
      List<StateLifecyclePhase> report = [];
      await tester.pumpWidget(TestObserveLifecycle(report.add));
      expect(report, [
        StateLifecyclePhase.didChangeDependencies,
        StateLifecyclePhase.willBuild,
        StateLifecyclePhase.didBuild,
      ]);
      report.clear();
      await tester.pumpWidget(TestObserveLifecycle((v) => report.add(v)));
      expect(report, [
        StateLifecyclePhase.didUpdateWidget,
        StateLifecyclePhase.willBuild,
        StateLifecyclePhase.didBuild,
      ]);
      report.clear();
      await tester.pumpWidget(Container());
      expect(report,
          [StateLifecyclePhase.deactivate, StateLifecyclePhase.dispose]);
      report.clear();
    });
  });
}

class TestObserveLifecycle extends StatefulWidget
    with DetailedLifecycleInState {
  TestObserveLifecycle(this.report);

  final void Function(StateLifecyclePhase) report;

  @override
  _TestObserveLifecycleState createState() => _TestObserveLifecycleState();
}

class _TestObserveLifecycleState extends State<TestObserveLifecycle>
    with ActiveObservers {
  @override
  assembleActiveObservers() {
    observeLifecycle(StateLifecyclePhase.didChangeDependencies, widget.report);
    observeLifecycle(StateLifecyclePhase.didSetState, widget.report);
    observeLifecycle(StateLifecyclePhase.didUpdateWidget, widget.report);
    observeLifecycle(StateLifecyclePhase.deactivate, widget.report);
    observeLifecycle(StateLifecyclePhase.dispose, widget.report);
    observeLifecycle(StateLifecyclePhase.willBuild, widget.report);
    observeLifecycle(StateLifecyclePhase.didBuild, widget.report);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
