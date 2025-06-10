import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../provider/FacilityProvider.dart';
import '../services/facility_service.dart';

class FacilitiesTab extends StatelessWidget {
  final FacilityService facilityService;

  const FacilitiesTab({super.key, required this.facilityService});

  @override
  Widget build(BuildContext context) {
    final facilityProvider = Provider.of<FacilityProvider>(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: facilityProvider.fetchFacilities(facilityService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView.builder(
            itemCount: facilityProvider.facilities.length,
            itemBuilder: (context, index) {
              final facility = facilityProvider.facilities[index];
              return ListTile(
                title: Text(facility['facility_name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await facilityProvider.deleteFacility(facility['id'], facilityService);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${facility['facility_name']} deleted.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting facility: ${e.toString()}')),
                      );
                    }
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}