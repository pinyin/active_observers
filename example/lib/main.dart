import 'package:active_observers/active_observers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screen/screen.dart';

import 'pages/item.dart';
import 'pages/items.dart';
import 'utils/router.dart';

void main() {
  assert(() {
    Screen.keepOn(true);
    return true;
  }());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, ActiveObservers {
  @override
  void assembleActiveObservers() {
    // hide bottom nav when scrolling
    {
      needFullView$ = PublishSubject();
      hideFooter = AnimationController(
          duration: Duration(milliseconds: 300), value: 0, vsync: this);
      final shouldHideFooter$ = needFullView$.distinct();

      observeStream(() => shouldHideFooter$).listen((bool u) {
        hideFooter.animateTo(u ? 1 : 0);
      });
    }

    // update route
    {
      routerController = RouterController(null);
      heroController = HeroController(
          createRectTween: (begin, end) =>
              MaterialRectArcTween(begin: begin, end: end));
      openItem = (int item) {
        routerController.value
            .pushNamed('item', arguments: ItemArguments(item));
      };
    }
  }

  AnimationController hideFooter;
  Subject<bool> needFullView$;
  void Function(int) openItem;
  RouterController routerController;
  HeroController heroController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          WillPopScope(
            child: Router(
              initialRoute: 'items',
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case 'item':
                    return MaterialPageRoute(
                      builder: (context) => Item(
                            onNeedFullView: needFullView$.add,
                            item: (settings.arguments as ItemArguments).item,
                          ),
                    );
                  case 'items':
                    return MaterialPageRoute(
                      builder: (context) => Items(
                            onNeedFullView: needFullView$.add,
                            onOpenItem: openItem,
                          ),
                    );
                }
              },
              onUnknownRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => Items(
                        onNeedFullView: needFullView$.add,
                        onOpenItem: openItem,
                      ),
                );
              },
              controller: routerController,
              observers: [heroController],
            ),
            onWillPop: () async {
              routerController.value.maybePop();
              return false;
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              AnimatedBuilder(
                animation: hideFooter,
                builder: (BuildContext context, Widget child) {
                  final translateY = hideFooter.value * 54;
                  return Transform(
                    transform: Matrix4.translationValues(0, translateY, 0),
                    child: Material(
                      elevation: 8,
                      child: BottomNavigationBar(
                        items: [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.cloud),
                            title: Text('Icon1'),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.add),
                            title: Text('Icon2'),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person),
                            title: Text('Icon3'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
