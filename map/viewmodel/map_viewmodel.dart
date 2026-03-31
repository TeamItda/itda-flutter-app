import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../map_defaults.dart';

//viewmodel 기본 설정
class MapViewModel extends ChangeNotifier {
  CameraPosition get initialCameraPosition => MapDefaults.jongnoCamera;

  CameraTargetBounds get cameraTargetBounds =>
      CameraTargetBounds(MapDefaults.jongnoBounds);

  MinMaxZoomPreference get zoomPreference =>
      const MinMaxZoomPreference(MapDefaults.minZoom, MapDefaults.maxZoom);
}
