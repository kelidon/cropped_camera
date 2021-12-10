import 'dart:io';

import 'package:cropped_camera/image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String path = context.read<ImageBloc>().state;
    return Scaffold(
      body: Center(
        child: Image(
          image: FileImage(File(path)),
          fit: BoxFit.fill,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
      ),
    );
  }
}
