import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../Core/provider/FacilityProvider.dart';
import '../../Core/services/facility_service.dart';


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
          return Scaffold(
            appBar: AppBar(
              title: Text('Facilities'),
            ),
            body: ListView.builder(
              itemCount: facilityProvider.facilities.length,
              itemBuilder: (context, index) {
                final facility = facilityProvider.facilities[index];
                return ListTile(
                  title: Text(facility['facility_name']),
                  trailing: SizedBox(
                    height: MediaQuery.of(context).size.height * .05,
                    width: MediaQuery.of(context).size.width * .29,
                    child: Row(
                      children: [
                        Switch(
                            value: facility['availability'],
                            onChanged: (value) async {
                              try {
                                await facilityProvider.updateFacility(facility['id'], value, facilityService);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${facility['facility_name']} updated.')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error updated facility: ${e.toString()}')),
                                );
                              }
                            }
                        ),
                        IconButton(
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
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}