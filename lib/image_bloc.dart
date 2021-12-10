import 'package:flutter_bloc/flutter_bloc.dart';

class ImageBloc extends Bloc<String, String> {
  ImageBloc() : super("");

  @override
  Stream<String> mapEventToState(String imagePath) async* {
    yield imagePath;
  }
}
