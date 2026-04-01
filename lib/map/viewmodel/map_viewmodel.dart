import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants.dart';
import '../model/map_facility.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<FacilityTypeOption> typeOptions = [
    FacilityTypeOption(
      id: 'all',
      label: '전체',
      color: Color(0xFF2563EB),
      icon: Icons.apps_rounded,
      collectionNames: [],
    ),
    FacilityTypeOption(
      id: 'hospital',
      label: '병원',
      color: Color(0xFFDC2626),
      icon: Icons.local_hospital_rounded,
      collectionNames: ['hospitals', 'hospital', 'medical_facilities'],
    ),
    FacilityTypeOption(
      id: 'pharmacy',
      label: '약국',
      color: Color(0xFF16A34A),
      icon: Icons.local_pharmacy_rounded,
      collectionNames: ['pharmacies', 'pharmacy'],
    ),
    FacilityTypeOption(
      id: 'restaurant',
      label: '음식점',
      color: Color(0xFFF97316),
      icon: Icons.restaurant_rounded,
      collectionNames: ['restaurants', 'restaurant'],
    ),
    FacilityTypeOption(
      id: 'school',
      label: '학교',
      color: Color(0xFF7C3AED),
      icon: Icons.school_rounded,
      collectionNames: ['schools', 'school'],
    ),
    FacilityTypeOption(
      id: 'childcare',
      label: '보육',
      color: Color(0xFFDB2777),
      icon: Icons.child_care_rounded,
      collectionNames: ['childcare', 'childcares', 'daycare_centers'],
    ),
    FacilityTypeOption(
      id: 'government',
      label: '행정',
      color: Color(0xFF0F766E),
      icon: Icons.account_balance_rounded,
      collectionNames: ['government', 'governments', 'public_offices'],
    ),
    FacilityTypeOption(
      id: 'welfare',
      label: '복지',
      color: Color(0xFF0891B2),
      icon: Icons.volunteer_activism_rounded,
      collectionNames: ['welfare', 'welfares', 'welfare_centers'],
    ),
    FacilityTypeOption(
      id: 'culture',
      label: '문화',
      color: Color(0xFFCA8A04),
      icon: Icons.museum_rounded,
      collectionNames: ['culture', 'cultures', 'cultural_facilities'],
    ),
  ];

  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;
  String _selectedTypeId = 'all';
  List<MapFacility> _facilities = const [];
  final Map<String, BitmapDescriptor> _markerIcons =
      <String, BitmapDescriptor>{};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTypeId => _selectedTypeId;

  List<MapFacility> get filteredFacilities {
    if (_selectedTypeId == 'all') {
      return _facilities;
    }
    return _facilities
        .where((facility) => facility.type == _selectedTypeId)
        .toList();
  }

  Set<Marker> get markers {
    return filteredFacilities.map((facility) {
      final option = optionFor(facility.type);
      return Marker(
        markerId: MarkerId(facility.id),
        position: facility.position,
        icon: _markerIcons[facility.type] ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: facility.name,
          snippet: [
            option.label,
            if (facility.address != null && facility.address!.isNotEmpty)
              facility.address!,
          ].join(' · '),
        ),
      );
    }).toSet();
  }

  CameraPosition get initialCameraPosition => const CameraPosition(
    target: LatLng(AppConstants.jongnoCenterLat, AppConstants.jongnoCenterLng),
    zoom: 13.2,
  );

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureMarkerIcons();
      _facilities = await _loadFacilities();
    } catch (error) {
      _errorMessage = '시설 데이터를 불러오지 못했습니다. Firebase 설정과 컬렉션명을 확인해주세요.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectType(String typeId) {
    if (_selectedTypeId == typeId) {
      return;
    }
    _selectedTypeId = typeId;
    notifyListeners();
  }

  FacilityTypeOption optionFor(String typeId) {
    return typeOptions.firstWhere(
      (option) => option.id == typeId,
      orElse: () => typeOptions.first,
    );
  }

  Future<void> _ensureMarkerIcons() async {
    for (final option in typeOptions.where((entry) => entry.id != 'all')) {
      _markerIcons.putIfAbsent(
        option.id,
        () => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _markerIcons[option.id] = await _buildMarkerIcon(option);
    }
  }

  Future<List<MapFacility>> _loadFacilities() async {
    final List<MapFacility> facilities = <MapFacility>[];

    for (final option in typeOptions.where((entry) => entry.id != 'all')) {
      for (final collectionName in option.collectionNames) {
        QuerySnapshot<Map<String, dynamic>> snapshot;
        try {
          snapshot = await _firestore.collection(collectionName).get();
        } catch (_) {
          continue;
        }

        for (final doc in snapshot.docs) {
          final facility = await _normalizeFacility(
            option: option,
            collectionName: collectionName,
            doc: doc,
          );
          if (facility != null) {
            facilities.add(facility);
          }
        }
      }
    }

    final deduped = <String, MapFacility>{};
    for (final facility in facilities) {
      deduped['${facility.type}:${facility.id}'] = facility;
    }

    final result = deduped.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  Future<MapFacility?> _normalizeFacility({
    required FacilityTypeOption option,
    required String collectionName,
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
  }) async {
    final data = doc.data();
    final name = _readString(data, const [
      'name',
      'facilityName',
      'title',
      '기관명',
      '시설명',
      '병원명',
      '약국명',
      '업소명',
      '학교명',
      '어린이집명',
    ]);
    if (name == null || name.isEmpty) {
      return null;
    }

    final address = _readString(data, const [
      'address',
      'roadAddress',
      'fullAddress',
      'addr',
      '도로명주소',
      '소재지도로명주소',
      '소재지지번주소',
      '주소',
    ]);

    final position = await _readLatLng(data, fallbackAddress: address);
    if (position == null || !_isNearJongno(position, address)) {
      return null;
    }

    return MapFacility(
      id: '$collectionName:${doc.id}',
      name: name,
      type: option.id,
      collectionName: collectionName,
      position: position,
      address: address,
      phone: _readString(data, const ['phone', 'tel', '전화번호', '연락처']),
    );
  }

  Future<LatLng?> _readLatLng(
    Map<String, dynamic> data, {
    String? fallbackAddress,
  }) async {
    final geopoint = _readGeoPoint(data, const [
      'location',
      'geoPoint',
      'geopoint',
      'coordinates',
      'coordinate',
      'position',
    ]);
    if (geopoint != null) {
      return LatLng(geopoint.latitude, geopoint.longitude);
    }

    final lat = _readDouble(data, const ['lat', 'latitude', '위도', 'y']);
    final lng = _readDouble(data, const ['lng', 'lon', 'longitude', '경도', 'x']);
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }

    if (fallbackAddress == null || fallbackAddress.isEmpty) {
      return null;
    }

    try {
      final placemarks = await locationFromAddress(fallbackAddress);
      if (placemarks.isEmpty) {
        return null;
      }
      return LatLng(placemarks.first.latitude, placemarks.first.longitude);
    } catch (_) {
      return null;
    }
  }

  bool _isNearJongno(LatLng position, String? address) {
    if (address != null && address.contains('종로')) {
      return true;
    }
    final latDelta = (position.latitude - AppConstants.jongnoCenterLat).abs();
    final lngDelta = (position.longitude - AppConstants.jongnoCenterLng).abs();
    return latDelta <= 0.13 && lngDelta <= 0.13;
  }

  String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  double? _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  GeoPoint? _readGeoPoint(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is GeoPoint) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final lat = _readDouble(value, const ['lat', 'latitude']);
        final lng = _readDouble(value, const ['lng', 'lon', 'longitude']);
        if (lat != null && lng != null) {
          return GeoPoint(lat, lng);
        }
      }
    }
    return null;
  }

  Future<BitmapDescriptor> _buildMarkerIcon(FacilityTypeOption option) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(132, 148);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final circleRect = Rect.fromLTWH(16, 0, 100, 100);
    final center = circleRect.center;

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.16);
    canvas.drawCircle(center.translate(0, 6), 46, shadowPaint);

    final circlePaint = Paint()..color = option.color;
    canvas.drawCircle(center, 44, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, 44, borderPaint);

    final pointerPath = Path()
      ..moveTo(66, 136)
      ..lineTo(45, 88)
      ..lineTo(87, 88)
      ..close();
    canvas.drawPath(pointerPath, circlePaint);
    canvas.drawPath(pointerPath, borderPaint);

    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(option.icon.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: option.icon.fontFamily,
        package: option.icon.fontPackage,
        color: Colors.white,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - (iconPainter.width / 2),
        center.dy - (iconPainter.height / 2),
      ),
    );

    final image = await recorder.endRecording().toImage(
      rect.width.toInt(),
      rect.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: 2,
      width: 66,
      height: 74,
    );
  }
}

class FacilityTypeOption {
  const FacilityTypeOption({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
    required this.collectionNames,
  });

  final String id;
  final String label;
  final Color color;
  final IconData icon;
  final List<String> collectionNames;
}
