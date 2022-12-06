import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// final GlobalKey<NavigatorState> _rootNavigatorKey =
//     GlobalKey<NavigatorState>(debugLabel: 'root');
// final GlobalKey<NavigatorState> _shellNavigatorKey =
//     GlobalKey<NavigatorState>(debugLabel: 'shell');

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  // static final Key _homeKey = UniqueKey();

  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      ShellRoute(
        // navigatorKey: _rootNavigatorKey,
        builder: (context, state, child) => MyHomePage(
          key: state.pageKey,
          child: child,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: '/home/:tabid',
            routes: [
              GoRoute(
                  path: 'detail/:detailid',
                  builder: (context, state) => _DetailPage(
                      index:
                          int.tryParse(state.params['detailid'] ?? '') ?? 1)),
            ],
            builder: (context, state) {
              final tabId = max(
                      0,
                      min(3,
                          (int.tryParse(state.params['tabid'] ?? '') ?? 1))) -
                  1;

              return Column(
                children: [
                  AppBar(title: const Text('Home Page')),
                  Expanded(
                    child: IndexedStack(
                      index: tabId,
                      key: const ValueKey('indexed_stack'),
                      children: [
                        _StatefulTab(
                          key: const Key('tab1'),
                          builder: (context, index) => Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                            ),
                            child: Material(
                              color: Colors.white,
                              elevation: 4.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 200.0,
                                    width: double.infinity,
                                    child: Placeholder(),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                      top: 8.0,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text('$index: '),
                                        Expanded(
                                          child: Container(
                                            color: Colors.black,
                                            height: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Container(
                                      color: Colors.black,
                                      height: 16.0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _StatefulTab(
                          key: const Key('tab2'),
                          builder: (context, index) => ListTile(
                            onTap: () => context.go(
                              '/home/2/detail/$index',
                            ),
                            title: Row(
                              children: <Widget>[
                                Text('$index: '),
                                Expanded(
                                  child: Container(
                                    color: Colors.black,
                                    height: 12.0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _StatefulTab(
                          key: const Key('tab3'),
                          builder: (context, index) => Center(
                            child: Text('$index'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home/1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
      title: 'Go Router Example',
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'^/home/(?<tabid>\d*)/?.*');
    final matches = regex.allMatches(GoRouter.of(context).location);

    var tab = 0;
    if (matches.isNotEmpty) {
      final first = matches.first;
      tab = (int.tryParse(first.namedGroup('tabid') ?? '') ?? 1) - 1;
    }

    // (int.tryParse(matches.first as RegExpMatch)?.namedGroup('tabid')) ?? 1) - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.panorama),
            label: 'Card',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Text',
          ),
        ],
        onTap: (value) => context.go('/home/${value + 1}'),
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  _DetailPage({
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Detail: $index'),
        ),
        backgroundColor: index % 2 == 0 ? Colors.black : Colors.white,
        body: Center(
          child: Text(
            '$index',
            style: TextStyle(
              color: index % 2 == 0 ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
}

class _StatefulTab extends StatefulWidget {
  _StatefulTab({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, int index) builder;

  @override
  _StatefulTabState createState() => _StatefulTabState();
}

class _StatefulTabState extends State<_StatefulTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      itemBuilder: widget.builder,
    );
  }
}
