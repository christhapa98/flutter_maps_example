import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_project/models/map_marker.dart';
import 'package:map_project/utils/conversion.dart';

class FlutterMapScreen extends StatefulWidget {
  const FlutterMapScreen({Key? key}) : super(key: key);

  @override
  State<FlutterMapScreen> createState() => _FlutterMapScreenState();
}

class _FlutterMapScreenState extends State<FlutterMapScreen> {
  MapController controller = MapController();

  List<MapMarker> mapMarkers = [
    MapMarker(latLng: LatLng(27.6588, 85.3247)),
    MapMarker(latLng: LatLng(27.6710, 85.4298)),
    MapMarker(latLng: LatLng(27.7172, 85.3240)),
    MapMarker(latLng: LatLng(27.727266, 85.317497)),
    MapMarker(latLng: LatLng(27.727288, 84.317497)),
    MapMarker(latLng: LatLng(27.727300, 82.317497)),
    MapMarker(latLng: LatLng(27.354712, 87.667488)),
  ];

  List<MapMarker> onRangeMarkers = [];

  LatLng mapCenter = LatLng(27.6588, 85.3247);
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
  }

  MarkerLayerOptions _mapMarkerLayer(BuildContext context) {
    return MarkerLayerOptions(
        markers: onRangeMarkers
            .map((e) => Marker(
                point: e.latLng,
                rotate: false,
                rotateAlignment: Alignment.center,
                builder: (ctx) => GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.location_on_rounded,
                        color:
                            e.latLng == mapCenter ? Colors.blue : Colors.amber,
                        size: 40))))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    var mapOptions = MapOptions(
        bounds: LatLngBounds(LatLng(27.700769,85.300140)),
        rotationWinGestures: 2,
        slideOnBoundaries: true,
        enableMultiFingerGestureRace: false,
        onTap: (position, LatLng ins) async {
          setState(() {
            onRangeMarkers = [];
            mapCenter = ins;
          });
          controller.move(ins, 13);
          setState(() {
            for (var element in mapMarkers) {
              totalDistance = calculateDistance(
                ins.latitude,
                ins.longitude,
                element.latLng.latitude,
                element.latLng.longitude,
              );
              element.distanceFromOrigin = totalDistance;
              if (element.distanceFromOrigin! < 2.5) {
                onRangeMarkers.add(MapMarker(
                    latLng: element.latLng, distanceFromOrigin: totalDistance));
              }
            }
          });
        },
        center: mapCenter,
        zoom: 13.0,
        minZoom: 10.0,
        maxZoom: 17.0);
    return Scaffold(
        body: Stack(children: [
      FlutterMap(mapController: controller, options: mapOptions, layers: [
        TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/christhapa9/cksta28xk0q8417qulxb4qpve/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY2hyaXN0aGFwYTkiLCJhIjoiY2tzcjZ1ZXU0MGsxOTJxb2Rzc24xNG5jaCJ9.ZmL-vTc76lKw8crhEAFAcw"),
        CircleLayerOptions(circles: [
          CircleMarker(
              point: mapCenter,
              radius: 2500.0,
              borderStrokeWidth: 2.0,
              borderColor: Colors.white,
              color: Colors.red.withOpacity(0.5),
              useRadiusInMeter: true)
        ]),
        _mapMarkerLayer(context)
      ]),
      if (onRangeMarkers.isNotEmpty)
        Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: SizedBox(
                height: 200,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: onRangeMarkers.length,
                    itemBuilder: (ctx, ind) {
                      return Center(
                          child: Container(
                              margin: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0)),
                              height: 200,
                              width: 200));
                    })))
    ]));
  }
}
