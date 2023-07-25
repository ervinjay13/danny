import 'package:flutter/material.dart';
import 'package:project_danny/controls/ManageCallsList.dart';

import '../common/call_dao.dart';
import 'calls/add_call_route.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key, required this.dao});

  final CallDao dao;

  @override
  State<StatefulWidget> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.settings),
                text: 'General',
              ),
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'Calls',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            const Center(
              child:
                  Text("Soon, there will be settings here, keep an eye out!"),
            ),
            ManageCallsList(
                dao: widget.dao,
                onEditCall: (call) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddCallRoute(dao: widget.dao, call: call),
                    ),
                  );
                },
                onNewCall: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCallRoute(dao: widget.dao),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
