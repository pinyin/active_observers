import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeDispose', () {
    testWidgets('should run clean function on dispose', (tester) async {
      List<Report> report = [];
      await tester.pumpWidget(TestObserveDispose((phase) {
        report.add(phase);
      }));
      expect(report, []);
      await tester.pumpWidget(Container());
      expect(report, [Report.Dispose, Report.CleanUp]);
      report.clear();
    });
  });
}

enum Report { Dispose, CleanUp }

class TestObserveDispose extends StatefulWidget {
  TestObserveDispose(this.report, [this.isIdentical = true]);

  final bool isIdentical;
  final void Function(Report) report;

  @override
  _TestObserveDisposeState createState() => _TestObserveDisposeState();
}

class _TestObserveDisposeState extends State<TestObserveDispose>
    with ActiveObservers {
  @override
  assembleActiveObservers() {
    observeDispose(() {
      widget.report(Report.CleanUp);
    });
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
