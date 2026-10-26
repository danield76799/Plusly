import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/pages/chat/events/gallery_content.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/event_extension.dart';

/// Minimale room-implementatie: het Event-vereist een Room, maar de
/// galerij-logica gebruikt er niets van.
class _FakeRoom implements Room {
  @override
  final String id;

  _FakeRoom({required this.id});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Tests voor de MSC4274-galerij (`dm.filament.gallery`): één bericht met
/// meerdere media.
void main() {
  group('galleryItemtypeToMsgtype', () {
    test('zet de MSC4274-itemtypes om naar Matrix-msgtypes', () {
      expect(galleryItemtypeToMsgtype('m.image'), MessageTypes.Image);
      expect(galleryItemtypeToMsgtype('m.video'), MessageTypes.Video);
      expect(galleryItemtypeToMsgtype('m.audio'), MessageTypes.Audio);
      expect(galleryItemtypeToMsgtype('m.file'), MessageTypes.File);
    });

    test('onbekende itemtypes vallen terug op m.file', () {
      expect(galleryItemtypeToMsgtype('m.onzin'), MessageTypes.File);
      expect(galleryItemtypeToMsgtype(''), MessageTypes.File);
    });
  });

  group('galleryItems', () {
    test('leest de itemtypes uit de content', () {
      final event = Event(
        eventId: 'test',
        senderId: '@test:example.org',
        originServerTs: DateTime.now(),
        room: _FakeRoom(id: '!kamer:example.org'),
        type: EventTypes.Message,
        content: {
          'msgtype': galleryMessageType,
          'body': 'Zomer',
          'itemtypes': [
            {
              'itemtype': 'm.image',
              'body': 'een.jpg',
              'url': 'mxc://example.org/een',
            },
            {
              'itemtype': 'm.image',
              'body': 'twee.jpg',
              'url': 'mxc://example.org/twee',
            },
          ],
        },
      );
      final items = galleryItems(event);
      expect(items.length, 2);
      expect(items.first['body'], 'een.jpg');
      expect(items.last['url'], 'mxc://example.org/twee');
    });

    test('een bericht zonder items levert een lege lijst', () {
      final event = Event(
        eventId: 'test',
        senderId: '@test:example.org',
        originServerTs: DateTime.now(),
        room: _FakeRoom(id: '!kamer:example.org'),
        type: EventTypes.Message,
        content: {'msgtype': galleryMessageType, 'body': 'leeg'},
      );
      expect(galleryItems(event), isEmpty);
    });
  });

  group('galleryItemEvent', () {
    test('maakt een pseudo-event met het juiste msgtype', () {
      final parent = Event(
        eventId: 'parent',
        senderId: '@test:example.org',
        originServerTs: DateTime.now(),
        room: _FakeRoom(id: '!kamer:example.org'),
        type: EventTypes.Message,
        content: {
          'msgtype': galleryMessageType,
          'itemtypes': [
            {
              'itemtype': 'm.image',
              'body': 'een.jpg',
              'url': 'mxc://example.org/een',
            },
          ],
        },
      );
      final item = galleryItemEvent(parent, galleryItems(parent).first, 0);
      expect(item.messageType, MessageTypes.Image);
      expect(item.content['body'], 'een.jpg');
      expect(item.content['msgtype'], MessageTypes.Image);
    });
  });

  group('raster', () {
    test('één tegel krijgt één kolom, meer tegels twee', () {
      expect(GalleryContent.gridColumnCount(0), 2);
      expect(GalleryContent.gridColumnCount(1), 1);
      expect(GalleryContent.gridColumnCount(2), 2);
      expect(GalleryContent.gridColumnCount(3), 2);
      expect(GalleryContent.gridColumnCount(9), 2);
    });

    test('de rasterbreedte groeit met het aantal kolommen', () {
      final one = GalleryContent.gridWidth(1);
      final two = GalleryContent.gridWidth(2);
      expect(one, closeTo(176, 0.5));
      expect(two, greaterThan(one));
      expect(two, closeTo(176 * 2 + 2, 0.5));
    });
  });
}
