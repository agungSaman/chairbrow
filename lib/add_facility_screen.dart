import 'dart:io';

import 'package:chairbrow/services/facility_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFacilityDialog extends StatelessWidget {
  final FacilityService facilityService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late String imageUrl = "";

  AddFacilityDialog({super.key, required this.facilityService});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Facility'),
      content: StatefulBuilder(
          builder: (c, setStates) {
            return Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Facility Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Conditions'),
                ),

                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    print("getImage $image");
                    if (image != null) {
                      final imageFile = File(image.path);
                      final imageName = imageFile.path.split('/').last;
                      final imageUrls = await facilityService.uploadImage(imageName, imageFile);
                      setStates(() {
                        imageUrl = imageUrls;
                      });
                      print("getImage $imageUrl");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${nameController.text} added successfully.')),
                      );}
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: imageUrl == "" ? Icon(Icons.image) : Image.network("https://echzfralcilauanafqcu.supabase.co/storage/v1/object/public/$imageUrl"),
                      title: Text('Upload Image'),
                    ),
                  ),
                )
              ],
            );
          }
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await facilityService.addFacility(nameController.text, descController.text, "https://echzfralcilauanafqcu.supabase.co/storage/v1/object/public/$imageUrl");
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${nameController.text} added successfully.')),
            );
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}