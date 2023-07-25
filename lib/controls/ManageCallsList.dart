import 'dart:convert';

import 'package:flutter/material.dart';

import '../common/call.dart';
import '../common/call_dao.dart';

class ManageCallsList extends StatefulWidget {
  const ManageCallsList(
      {super.key,
      required this.dao,
      required this.onEditCall,
      required this.onNewCall});

  final CallDao dao;
  final Function(Call call) onEditCall;
  final Function() onNewCall;

  @override
  State<ManageCallsList> createState() => _ManageCallsListState();
}

class _ManageCallsListState extends State<ManageCallsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => widget.onNewCall(),
        label: const Text('New call'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder<List<Call>>(
        stream: widget.dao.getCallsAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final calls = snapshot.requireData;

          if (calls.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('No Calls',
                      style:
                          TextStyle(fontSize: 38, fontWeight: FontWeight.w200)),
                  SizedBox(height: 24),
                  Text(
                      '"Calls" are images that are associated with a spoken phrase.'),
                  SizedBox(height: 4),
                  Text('Tap the "New call" button to create your first call!')
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: calls.length,
            itemBuilder: (_, index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(calls[index].tts,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.35),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.memory(
                          base64Decode(calls[index].imageBase64),
                          fit: BoxFit.cover,
                          alignment: Alignment.center),
                    ),
                  ),
                ),
                trailing: Wrap(spacing: 4, children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: "Edit call",
                      onPressed: () => widget.onEditCall(calls[index])),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete call",
                      onPressed: () => widget.dao.deleteCall(calls[index]))
                ]),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          );
        },
      ),
    );
  }
}
