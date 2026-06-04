import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/pages/chat_search/chat_search_view.dart';
import 'package:Pulsly/widgets/matrix.dart';

class ChatSearchPage extends StatefulWidget {
  final String roomId;
  const ChatSearchPage({required this.roomId, super.key});

  @override
  ChatSearchController createState() => ChatSearchController();
}

class ChatSearchController extends State<ChatSearchPage>
    with SingleTickerProviderStateMixin {
  Room? get room => Matrix.of(context).client.getRoomById(widget.roomId);

  final TextEditingController searchController = TextEditingController();
  late final TabController tabController;

  final List<Event> messages = [];
  final List<Event> images = [];
  final List<Event> files = [];

  String? messagesNextBatch;
  String? imagesNextBatch;
  String? filesNextBatch;

  bool messagesEndReached = false;
  bool imagesEndReached = false;
  bool filesEndReached = false;

  bool isLoading = false;
  DateTime? searchedUntil;

  // Search filters
  String? filterSenderId;
  DateTime? filterFromDate;
  DateTime? filterToDate;

  List<Event> _applyFilters(List<Event> events) {
    return events.where((event) {
      if (filterSenderId != null && event.senderId != filterSenderId)
        return false;
      if (filterFromDate != null &&
          event.originServerTs.isBefore(filterFromDate!))
        return false;
      if (filterToDate != null && event.originServerTs.isAfter(filterToDate!))
        return false;
      return true;
    }).toList();
  }

  List<Event> _applyTextFilter(List<Event> events, String query) {
    if (query.isEmpty) return events;
    final lower = query.toLowerCase();
    return events.where((e) {
      final body = e.body.toLowerCase();
      final filename = e.content.tryGet<String>('filename') ?? '';
      return body.contains(lower) || filename.toLowerCase().contains(lower);
    }).toList();
  }

  void restartSearch() {
    setState(() {
      messages.clear();
      images.clear();
      files.clear();
      messagesNextBatch = imagesNextBatch = filesNextBatch = null;
      messagesEndReached = imagesEndReached = filesEndReached = false;
      searchedUntil = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startSearch();
    });
  }

  Future<void> startSearch() async {
    final room = this.room;
    if (room == null) return;

    switch (tabController.index) {
      case 0:
        final searchQuery = searchController.text.trim();
        if (searchQuery.isEmpty) return;
        setState(() {
          isLoading = true;
        });
        final result = await room.searchEvents(
          searchTerm: searchQuery,
          nextBatch: messagesNextBatch,
          limit: 1500,
        );
        var events = result.events;
        events = _applyTextFilter(events, searchQuery);
        events = _applyFilters(events);
        // Deduplicate by eventId
        final existingIds = messages.map((e) => e.eventId).toSet();
        events = events.where((e) => !existingIds.contains(e.eventId)).toList();
        setState(() {
          isLoading = false;
          messages.addAll(events);
          messagesNextBatch = result.nextBatch;
          messagesEndReached = result.nextBatch == null;
          searchedUntil = result.searchedUntil;
        });
        return;
      case 1:
        setState(() {
          isLoading = true;
        });
        final result = await room.searchEvents(
          searchFunc: (event) => {
            MessageTypes.Image,
            MessageTypes.Video,
          }.contains(event.messageType),
          nextBatch: imagesNextBatch,
          limit: 1500,
        );
        var events = result.events;
        if (searchController.text.isNotEmpty) {
          events = _applyTextFilter(events, searchController.text);
        }
        events = _applyFilters(events);
        // Deduplicate by eventId
        final existingIds = images.map((e) => e.eventId).toSet();
        events = events.where((e) => !existingIds.contains(e.eventId)).toList();
        setState(() {
          isLoading = false;
          images.addAll(events);
          imagesNextBatch = result.nextBatch;
          imagesEndReached = result.nextBatch == null;
          searchedUntil = result.searchedUntil;
        });
        return;
      case 2:
        setState(() {
          isLoading = true;
        });
        final result = await room.searchEvents(
          searchFunc: (event) =>
              event.messageType == MessageTypes.File ||
              (event.messageType == MessageTypes.Audio &&
                  !event.content.containsKey('org.matrix.msc3245.voice')),
          nextBatch: filesNextBatch,
          limit: 1500,
        );
        var events = result.events;
        if (searchController.text.isNotEmpty) {
          events = _applyTextFilter(events, searchController.text);
        }
        events = _applyFilters(events);
        // Deduplicate by eventId
        final existingIds = files.map((e) => e.eventId).toSet();
        events = events.where((e) => !existingIds.contains(e.eventId)).toList();
        setState(() {
          isLoading = false;
          files.addAll(events);
          filesNextBatch = result.nextBatch;
          filesEndReached = result.nextBatch == null;
          searchedUntil = result.searchedUntil;
        });
        return;
      default:
        return;
    }
  }

  void _onTabChanged() {
    switch (tabController.index) {
      case 1:
      case 2:
        startSearch();
        break;
      case 0:
      default:
        restartSearch();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChatSearchView(this);
}
