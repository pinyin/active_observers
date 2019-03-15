import 'package:active_observers/active_observers.dart';
import 'package:active_observers/src/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeEffect', () {
    testWidgets('should run between initState & dispose', (tester) async {
      List<Report> report = [];
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      expect(report, [Report.EffectStart, Report.InitState]);
      report.clear();
      await tester.pumpWidget(Container());
      expect(report, [Report.Dispose, Report.EffectCleanUp]);
      report.clear();
    });

    testWidgets('should restart iff identical() returns false after update',
        (tester) async {
      List<Report> report = [];
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }));
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }, true));
      expect(report, [Report.DidUpdateState]);
      report.clear();
      await tester.pumpWidget(TestObserveEffect((phase) {
        report.add(phase);
      }, false));
      expect(report,
          [Report.EffectCleanUp, Report.EffectStart, Report.DidUpdateState]);
      report.clear();
    });
  });
}

enum Report { InitState, EffectStart, EffectCleanUp, DidUpdateState, Dispose }

class TestObserveEffect extends StatefulWidget {
  TestObserveEffect(this.report, [this.isIdentical = true]);

  final bool isIdentical;
  final void Function(Report) report;

  @override
  _TestObserveEffectState createState() => _TestObserveEffectState();
}

class _TestObserveEffectState extends State<TestObserveEffect>
    with ActiveObservers {
  _TestObserveEffectState() {
    observeEffect(() {
      widget.report(Report.EffectStart);
      return () => {widget.report(Report.EffectCleanUp)};
    }, () => widget.isIdentical)(this);
  }

  @override
  void initState() {
    super.initState();
    widget.report(Report.InitState);
  }

  @override
  void didUpdateWidget(TestObserveEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.report(Report.DidUpdateState);
  }

  @override
  void dispose() {
    widget.report(Report.Dispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}