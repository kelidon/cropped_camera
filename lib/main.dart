import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'image_bloc.dart';
import 'image_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(BlocProvider<ImageBloc>(
      create: (context) => ImageBloc(), child: const CameraApp()));
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.setFlashMode(FlashMode.off);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.grey),
      home: Builder(builder: (context) {
        Future<String> _resizePhoto(String filePath) async {
          ImageProperties properties =
              await FlutterNativeImage.getImageProperties(filePath);

          int minSide = min(properties.width!, properties.height!);
          int maxSide = max(properties.width!, properties.height!);
          int minSize = (minSide * 6 / 9).ceil();
          int maxSize = (maxSide * 6 / 9).ceil();
          var xOffset = (minSide - minSize) / 2;
          var yOffset = (maxSide - maxSize) / 2;
          print("=============\n$yOffset\n===========");
          print(properties.height);
          print(properties.width);
          File croppedFile = await FlutterNativeImage.cropImage(
              filePath, xOffset.round(), yOffset.round(), minSize, minSize);

          return croppedFile.path;
        }

        double borderSize = MediaQuery.of(context).size.width * 6 / 9;
        return Scaffold(
          backgroundColor: Colors.black,
          body: CameraPreview(
            controller,
            child: Center(
              child: Container(
                width: borderSize,
                height: borderSize,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.white)),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () async {
              XFile xFile = await controller.takePicture();
              String croppedPath = await _resizePhoto(xFile.path);
              context.read<ImageBloc>().add(croppedPath);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ImageScreen()));
            },
            child: const Icon(
              Icons.camera,
              color: Colors.black,
            ),
          ),
        );
      }),
    );
  }
}
