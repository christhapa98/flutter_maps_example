import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:map_project/models/map_marker.dart';

class FlutterMapScreen extends StatefulWidget {
  const FlutterMapScreen({Key? key}) : super(key: key);

  @override
  State<FlutterMapScreen> createState() => _FlutterMapScreenState();
}

class _FlutterMapScreenState extends State<FlutterMapScreen> {
  TextEditingController latitudeController =
      TextEditingController(text: '27.6710');
  TextEditingController longitudeController = TextEditingController();
  MapController controller = MapController();
  double totalDistance = 0.0;
  LatLng mapCenter = LatLng(27.6588, 85.3247);
  List<MapMarker> mapMarkers = [
    MapMarker(LatLng(27.6588, 85.3247), ''),
    MapMarker(LatLng(27.6710, 85.4298), ''),
    MapMarker(LatLng(27.7172, 85.3240), ''),
    MapMarker(LatLng(27.727266, 85.317497), ''),
    MapMarker(LatLng(27.727288, 84.317497), ''),
    MapMarker(LatLng(27.727300, 82.317497), ''),
  ];
  List<MapMarker> visibleMarkers = [MapMarker(LatLng(27.6588, 85.3247), '')];

  @override
  void initState() {
    super.initState();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (BuildContext context) {
          return Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: ListView(
                  padding: EdgeInsets.only(
                      left: 15,
                      top: 15,
                      right: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  children: <Widget>[
                    TextFormField(
                        controller: latitudeController,
                        decoration: InputDecoration(
                            label: const Text('Latitude'),
                            hintText: 'Enter latitude',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 190, 216, 228),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10))),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: longitudeController,
                      decoration: InputDecoration(
                        // labelText: 'Longitude',
                        label: const Text('Longitude'),
                        hintText: 'Enter longitude',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.blueGrey.withOpacity(0.7),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            mapCenter = LatLng(
                                double.parse(latitudeController.text),
                                double.parse(longitudeController.text));
                            // mapMarkers.add(mapCenter);
                          });
                          controller.moveAndRotate(mapCenter, 12, 25);
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        const BorderSide(color: Colors.red)))),
                        child: const Text('Show on Map'))
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    log(visibleMarkers.map((e) => e.distanceFromOrigin).toString());

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: _returnFlutterMap(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showModalBottomSheet(context);
            },
            tooltip: 'Increment',
            child: const Icon(Icons.search)));
  }

  FlutterMap _returnFlutterMap() {
    return FlutterMap(
        mapController: controller,
        options: MapOptions(
            slideOnBoundaries: true,
            enableMultiFingerGestureRace: false,
            onTap: (position, LatLng ins) async {
              setState(() {
                visibleMarkers = [];
                mapCenter = ins;
              });
              controller.move(ins, 12);
              setState(() {
                for (var element in mapMarkers) {
                  totalDistance = calculateDistance(
                    ins.latitude,
                    ins.longitude,
                    element.latLng.latitude,
                    element.latLng.longitude,
                  );
                  element.distanceFromOrigin = totalDistance.toStringAsFixed(2);
                  if (double.parse(element.distanceFromOrigin) < 2.5) {
                    visibleMarkers.add(
                        MapMarker(element.latLng, totalDistance.toString()));
                  }
                }
              });
            },
            center: mapCenter,
            zoom: 13.0,
            minZoom: 10.0,
            maxZoom: 17.0),
        layers: [
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
                useRadiusInMeter: true),
          ]),
          MarkerLayerOptions(
              markers: visibleMarkers
                  .map((e) => Marker(
                      point: e.latLng,
                      rotate: false,
                      rotateAlignment: Alignment.center,
                      builder: (ctx) => GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (ctx) {
                                  return SizedBox(
                                    height: 200,
                                    child: Text(
                                        '${e.latLng.latitude} ${e.latLng.longitude}'),
                                  );
                                });
                          },
                          child: Icon(Icons.location_on_rounded,
                              color: e.latLng == mapCenter
                                  ? Colors.blue
                                  : Colors.amber,
                              size: 40))))
                  .toList())
        ]);
  }
}

class MyCustomPluginOptions extends LayerOptions {
  final String text;
  MyCustomPluginOptions({
    Key? key,
    this.text = '',
    Stream<void>? rebuild,
  }) : super(key: key);
}

class MyCustomPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    if (options is MyCustomPluginOptions) {
      var style = const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
        color: Colors.red,
      );
      return Text(
        options.text,
        key: options.key,
        style: style,
      );
    }
    throw Exception('Unknown options type for MyCustom'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MyCustomPluginOptions;
  }
}
