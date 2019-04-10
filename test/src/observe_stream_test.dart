import 'dart:async';

import 'package:active_observers/active_observers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observeStream', () {
    testWidgets('should call onData when value comes', (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.add('1');
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      subject.add('2');
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      subject.close();
    });
    testWidgets('should call onError after error happened', (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.addError('1');
      await tester.pump();
      expect(find.text('error'), findsOneWidget);
      subject.close();
    });
    testWidgets('should call onDone after stream closed', (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.close();
      await tester.pump();
      expect(find.text('done'), findsOneWidget);
      subject.close();
    });
    testWidgets('should subscribe to new stream if stream updates',
        (tester) async {
      final subject = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject.stream));
      subject.add('1');
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      final subject2 = StreamController<String>(sync: true);
      await tester.pumpWidget(TestObserveStream(stream: subject2.stream));
      subject2.add('2');
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      subject.close();
      subject2.close();
    });
  });
}

class TestObserveStream extends StatefulWidget {
  const TestObserveStream({Key key, this.stream}) : super(key: key);

  final Stream<String> stream;

  @override
  _TestObserveStreamState createState() => _TestObserveStreamState();
}

class _TestObserveStreamState extends State<TestObserveStream>
    with ActiveObservers {
  assembleActiveObservers() {
    observeStream(() => widget.stream, onData: (value) {
      setState(() {
        state = value;
      });
    }, onDone: () {
      setState(() {
        state = 'done';
      });
    }, onError: (_, __) {
      setState(() {
        state = 'error';
      });
    });
  }

  String state = '';

  @override
  Widget build(BuildContext context) {
    return Text(state, textDirection: TextDirection.ltr);
  }
}
