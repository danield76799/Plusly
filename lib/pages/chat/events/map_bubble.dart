import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/url_launcher.dart';

/// Geeft de kaart expliciete intrinsieke maten.
///
/// FlutterMap gebruikt intern een LayoutBuilder, en die kan geen intrinsieke
/// dimensies berekenen — Flutter gooit dan "LayoutBuilder does not support
/// returning intrinsic dimensions". Plusly's chatbubble wikkelt de
/// berichtinhoud in een IntrinsicWidth (message_bubble.dart r583), dus die
/// vraag bereikt de kaart en de layout breekt af: de kaart wordt 0x0, wat op
/// het scherm als één pixel verschijnt. FluffyChat heeft op die plek geen
/// IntrinsicWidth (grep op `IntrinsicWidth` in FC's pages/chat: nul treffers),
/// dus daar doet het probleem zich nooit voor.
///
/// Deze wrapper beantwoordt de intrinsieke vraag zelf — de kaart is vierkant —
/// en geeft hem NIET door aan de kaart eronder. De gewone layout loopt
/// ongewijzigd door naar de AspectRatio, dus de kaart blijft responsief.
class _MapIntrinsicBox extends SingleChildRenderObjectWidget {
  const _MapIntrinsicBox({required this.side, required super.child});

  /// De intrinsieke maat die aan een IntrinsicWidth/Height wordt gemeld.
  /// Dit is de natuurlijke kaartmaat, niet een vaste layoutmaat: de echte
  /// breedte komt nog steeds van de ouder.
  final double side;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMapIntrinsicBox(side);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMapIntrinsicBox renderObject,
  ) {
    renderObject.side = side;
  }
}

class _RenderMapIntrinsicBox extends RenderProxyBox {
  _RenderMapIntrinsicBox(this.side);

  double side;

  @override
  double computeMinIntrinsicWidth(double height) => side;

  @override
  double computeMaxIntrinsicWidth(double height) => side;

  @override
  double computeMinIntrinsicHeight(double width) => side;

  @override
  double computeMaxIntrinsicHeight(double width) => side;
}

class MapBubble extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final double width;
  final double height;
  final double radius;
  final Uri? geoUri;
  const MapBubble({
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
    this.width = 400,
    this.height = 400,
    this.radius = 10.0,
    this.geoUri,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: geoUri != null
          ? () => UrlLauncher(context, geoUri.toString()).launchUrl()
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: _MapIntrinsicBox(
          side: width < height ? width : height,
          child: Container(
            constraints: BoxConstraints.loose(Size(width, height)),
            // AspectRatio is wat de kaart vierkant houdt. Zonder deze wrapper
            // rekt de kaart op tot de volledige dialoogbreedte terwijl de
            // hoogte op `height` blijft staan — het resultaat is een platte
            // strook in plaats van een kaart. Upstream (FluffyChat
            // map_bubble.dart r39) heeft deze wrapper wel; commit d73690fcc
            // haalde hem weg samen met height 400 -> 200.
            child: AspectRatio(
              aspectRatio: width / height,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: zoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        maxZoom: 20,
                        minZoom: 0,
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            '${PlatformInfos.clientName} (flutter_map)',
                      ),
                      MarkerLayer(
                        rotate: true,
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 30,
                            height: 30,
                            child: Transform.translate(
                              offset: const Offset(0, -12.5),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Gradient overlay voor betere leesbaarheid onderin
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(179),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Coördinaten + "Open in Maps"
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (geoUri != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  size: 12,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Openen',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
