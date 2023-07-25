import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_danny/controls/ManageCallsList.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/call_dao.dart';
import 'calls/add_call_route.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute(
      {super.key, required this.dao, required this.preferences});

  final CallDao dao;
  final SharedPreferences preferences;

  @override
  State<StatefulWidget> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the current value (or default)
    pinController.text = widget.preferences.getString('pin') ?? '0000';
  }

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
            Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Form(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                          'Modify application settings below, or tap on the "Calls" tab to manage calls'),
                      const SizedBox(height: 16),
                      TextFormField(
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: pinController,
                        onChanged: (value) {
                          widget.preferences.setString('pin', value);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'PIN',
                        ),
                      )
                    ]),
              ),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
