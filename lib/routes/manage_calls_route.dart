import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../common/call.dart';
import '../common/call_dao.dart';
import 'add_call_route.dart';

class ManageCallsRoute extends StatefulWidget {
  const ManageCallsRoute({super.key, required this.dao, required this.camera});

  final CallDao dao;
  final CameraDescription camera;

  @override
  State<ManageCallsRoute> createState() => _ManageCallsRouteState();
}

class _ManageCallsRouteState extends State<ManageCallsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Manage calls'),
      ),
      body: StreamBuilder<List<Call>>(
        stream: widget.dao.getCallsAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final calls = snapshot.requireData;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: calls.length,
            itemBuilder: (_, index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(calls[index].tts,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                leading: AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.memory(base64Decode(calls[index].imageBase64),
                        fit: BoxFit.cover, alignment: Alignment.center),
                  ),
                ),
                trailing: Wrap(spacing: 4, children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: "Edit call",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCallRoute(
                                dao: widget.dao, camera: widget.camera),
                          ),
                        );
                      }),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete call",
                      onPressed: () {
                        widget.dao.deleteCall(calls[index]);
                      })
                ]),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddCallRoute(dao: widget.dao, camera: widget.camera),
            ),
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
