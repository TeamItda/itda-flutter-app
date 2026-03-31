import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../viewmodel/map_viewmodel.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('종로구 지도')),
      body: GoogleMap(
        initialCameraPosition: vm.initialCameraPosition,
        cameraTargetBounds: vm.cameraTargetBounds,
        minMaxZoomPreference: vm.zoomPreference,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
