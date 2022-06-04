import 'package:latlong2/latlong.dart';

class MapMarker {
  LatLng latLng;
  double? distanceFromOrigin;

  MapMarker({required this.latLng, this.distanceFromOrigin});
}
