import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/explore_rooms/explore_rooms_view.dart';
import 'package:extera_next/widgets/adaptive_dialogs/show_text_input_dialog.dart';
import 'package:extera_next/widgets/matrix.dart';

class ExploreRooms extends StatefulWidget {
  const ExploreRooms({super.key});

  @override
  ExploreRoomsController createState() => ExploreRoomsController();
}

class ExploreRoomsController extends State<ExploreRooms> {
  final TextEditingController controller = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();

  Future<QueryPublicRoomsResponse?>? searchResponse;

  Timer? _searchCoolDown;

  static const Duration _coolDown = Duration(milliseconds: 500);

  String? _server;
  bool includeAllNetworks = false;
  String? selectedServer;

  List<String> joinedRooms = [];

  @override
  void initState() {
    super.initState();
    // Start with an initial search to show some rooms
    searchRooms();
    updateJoinedRooms();
  }

  Future<void> updateJoinedRooms() async {
    final client = Matrix.of(context).client;
    joinedRooms = await client.getJoinedRooms();
  }

  void searchRooms([String? input]) async {
    final searchTerm = input ?? controller.text;

    _searchCoolDown?.cancel();
    _searchCoolDown = Timer(_coolDown, () {
      setState(() {
        searchResponse = _searchPublicRooms(searchTerm);
      });
    });
  }

  Future<QueryPublicRoomsResponse?> _searchPublicRooms(
    String searchTerm,
  ) async {
    try {
      final client = Matrix.of(context).client;
      final response = await client.queryPublicRooms(
        server: _server,
        filter: PublicRoomQueryFilter(
          genericSearchTerm: searchTerm.isEmpty ? null : searchTerm,
        ),
        includeAllNetworks: includeAllNetworks,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void setServer() async {
    final newServer = await showTextInputDialog(
      useRootNavigator: false,
      title: L10n.of(context).changeTheHomeserver,
      context: context,
      okLabel: L10n.of(context).ok,
      cancelLabel: L10n.of(context).cancel,
      prefixText: 'https://',
      hintText: Matrix.of(context).client.homeserver?.host,
      initialText: _server,
      keyboardType: TextInputType.url,
      autocorrect: false,
      validator: (server) => server.contains('.') == true
          ? null
          : L10n.of(context).invalidServerName,
    );
    if (newServer == null) return;
    setState(() {
      _server = newServer;
      selectedServer = newServer;
    });
    searchRooms();
  }

  void toggleIncludeAllNetworks(bool? value) {
    setState(() {
      includeAllNetworks = value ?? false;
      searchRooms();
    });
  }

  void joinRoomAction(PublicRoomsChunk room) async {
    final client = Matrix.of(context).client;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final roomId = room.roomId;
      await client.joinRoom(roomId);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Joined ${room.name ?? room.roomId}')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to join room: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    textFieldFocus.dispose();
    _searchCoolDown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExploreRoomsView(this);
}
