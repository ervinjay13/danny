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
            itemCount: calls.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(calls[index].tts,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                leading: AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
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
                            fullscreenDialog: true,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) =>
                  AddCallRoute(dao: widget.dao, camera: widget.camera),
            ),
          );
        },
        tooltip: 'New call',
        child: const Icon(Icons.add),
      ),
    );
  }
}
