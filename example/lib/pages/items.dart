import 'dart:async';

import 'package:active_observers/active_observers.dart';
import 'package:example/utils/observe_sticky_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/keep_scroll_controller.dart';
import '../utils/observable.dart';

class Items extends StatefulWidget {
  const Items({Key key, this.onNeedFullView, this.onOpenItem})
      : super(key: key);

  final void Function(bool) onNeedFullView;
  final void Function(int) onOpenItem;

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items>
    with TickerProviderStateMixin, ActiveObservers {
  @override
  void assembleActiveObservers() {
    tabController = TabController(length: 3, vsync: this);

    scrollControllers = [
      KeepScrollController(),
      KeepScrollController(),
      KeepScrollController(),
    ];

    final currentTab$ = listen$(tabController, () => tabController.index)
        .startWith(tabController.index)
        .shareReplay(maxSize: 1);
    final scrollPositions = scrollControllers.map((c) =>
        listen$(c, () => c.mostRecentlyUpdatedPosition)
            .shareReplay(maxSize: 1));
    // keep latest currentTab & scrollPosition
    {
      observeStream(() => currentTab$);
      scrollPositions.forEach((s) {
        observeStream(() => s);
      });
    }

    // elevate toolbar
    {
      final initialScrollController = scrollControllers[tabController.index];
      elevateToolbar = AnimationController(
          value: initialScrollController.initialScrollOffset, vsync: this);

      final Observable<bool> shouldElevate$ = currentTab$
          .switchMap((t) => scrollPositions
              .elementAt(t)
              .map((p) => p.pixels)
              .startWith(scrollControllers[t].initialScrollOffset))
          .map((o) => o > kToolbarHeight)
          .distinct();

      observeStream(() => shouldElevate$, onData: (shouldElevate) {
        elevateToolbar.value = shouldElevate ? 1 : 0;
      });
    }

    // sticky header
    hideTitleBar = observeStickyHeader(scrollPositions, this);

    // request full view on scrolling
    {
      final shouldRequestFullView$ = Observable.merge(scrollPositions)
          .map((p) => p.userScrollDirection)
          .where((d) => d != ScrollDirection.idle)
          .map((d) => d == ScrollDirection.reverse);

      observeStream(() => shouldRequestFullView$,
          onData: (bool shouldRequestFullView) {
        if (widget.onNeedFullView != null)
          widget.onNeedFullView(shouldRequestFullView);
      });
    }

    // forward tapped item
    {
      tappedItem = (int index) {
        if (widget.onOpenItem != null) widget.onOpenItem(index);
      };
    }
  }

  TabController tabController;
  List<KeepScrollController> scrollControllers;
  AnimationController hideTitleBar;
  AnimationController elevateToolbar;
  void Function(int) tappedItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Stack(
        children: <Widget>[
          TabBarView(
            controller: tabController,
            children: <Widget>[
              ListView.builder(
                controller: scrollControllers[0],
                padding: EdgeInsets.only(top: tabBarHeight + kToolbarHeight),
                itemBuilder: (BuildContext context, int item) {
                  return Material(
                    child: InkWell(
                      onTap: () => tappedItem(item),
                      child: Container(
                        child: Hero(
                          tag: '$item',
                          child: Text('content $item'),
                        ),
                        height: 200,
                      ),
                    ),
                  );
                },
              ),
              ListView.builder(
                controller: scrollControllers[1],
                padding: EdgeInsets.only(top: tabBarHeight + kToolbarHeight),
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    child: InkWell(
                      onTap: () => tappedItem(index),
                      child: Container(
                        child: Text('content $index'),
                        height: 200,
                      ),
                    ),
                  );
                },
              ),
              ListView.builder(
                controller: scrollControllers[2],
                padding: EdgeInsets.only(top: tabBarHeight + kToolbarHeight),
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    child: InkWell(
                      onTap: () => tappedItem(index),
                      child: Container(
                        child: Text('content $index'),
                        height: 200,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          AnimatedBuilder(
            animation: elevateToolbar,
            builder: (context, child) {
              return AnimatedBuilder(
                animation: hideTitleBar,
                builder: (context, child) {
                  return Container(
                    height: tabBarHeight + kToolbarHeight * hideTitleBar.value,
                    child: AppBar(
                      leading: FadeTransition(
                        opacity: hideTitleBar,
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                      backgroundColor: theme.canvasColor,
                      elevation: elevateToolbar.value * 3 + 1,
                      bottom: TabBar(
                        controller: tabController,
                        labelColor: theme.primaryColor,
                        unselectedLabelColor: theme.textTheme.caption.color,
                        indicatorColor: theme.primaryColor,
                        tabs: [
                          Tab(text: 'Tab1'),
                          Tab(text: 'Tab2'),
                          Tab(text: 'Tab3'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}

const tabBarHeight = 48;

Stream<ScrollDirection> Function(ScrollDirection) returnIdleAfter(
        Duration duration) =>
    (ScrollDirection d) =>
        Observable.timer(ScrollDirection.idle, Duration(milliseconds: 300))
            .startWith(d);
