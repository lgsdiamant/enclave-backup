import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

import '../../data/repository.dart';
import 'constants.dart';

class AssetHelper extends Object {
  AssetHelper({required EnclaveRepository repo}) : _repo = repo;

  final EnclaveRepository _repo;

  // file extension
  String get enclaveCode => _repo.enclaveCode;

  static ImageProvider assetImageEnclaveLogo = AssetImage(path.join(Constants.assetImage, Constants.imageFileNameEnclaveLogo));
  static ImageProvider assetIconEnclave = AssetImage(path.join(Constants.assetIcon, Constants.iconNameEnclaveIconColor));

  static ImageProvider assetImageKADIS = AssetImage(path.join(Constants.assetImage, Constants.imageFileNameKADIS));
  static ImageProvider assetImageKMA = AssetImage(path.join(Constants.assetImage, Constants.imageFileNameKMA));
  static ImageProvider assetImageKPC = AssetImage(path.join(Constants.assetImage, Constants.imageFileNameKPC));
  static ImageProvider assetImageProfile = AssetImage(path.join(Constants.assetImage, Constants.imageFileNameProfile));

  String getAboutAppPdfPath() {
    return 'assets/pdf/aboutApp-KR.pdf';
  }
}
