import "package:flutter/material.dart";
class FacilityListView extends StatelessWidget {
  final String category;
  const FacilityListView({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Facility List: $category")));
  }
}
