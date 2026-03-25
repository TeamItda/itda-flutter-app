import "package:flutter/material.dart";
class FacilityDetailView extends StatelessWidget {
  final String facilityId;
  const FacilityDetailView({super.key, required this.facilityId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Detail: $facilityId")));
  }
}
