import 'package:audioplayers/audioplayers.dart';

import '../data/app_setting.dart';
import '../pages/setting/setting_logic.dart';

late EnclaveSound gEnSound;

enum AudioKind {
  forwardSelection,
  backwardSelection,
  cancel,
  tap,
  stateChange,
}

class EnclaveSound {
  static const String audioNameBackwardSelection = 'backward_selection.mp3';
  static const String audioNameCancel = 'cancel.mp3';
  static const String audioNameForwardSelection = 'forward_selection.mp3';
  static const String audioNameStateChange = 'state_change.mp3';
  static const String audioNameTap = 'tap.mp3';

  static EnclaveSound? _instance;
  late AudioCache _player;

  factory EnclaveSound() => _instance ??= EnclaveSound._();

  EnclaveSound._() {
    _player = AudioCache(prefix: 'assets/audio/');
  }

  /// Save soundOnOff to local storage
  void _saveSoundOnOffToBox(bool soundOnOff) => gAppStorage.write(PrefKey.soundOn.name, soundOnOff);

  void toggleSound() {
    gAppSetting.rxPrefSoundOn.value = !gAppSetting.rxPrefSoundOn.value;
    _saveSoundOnOffToBox(gAppSetting.rxPrefSoundOn.value);

    gEnSound.playAudio(AudioKind.stateChange);
  }

  void playAudio(AudioKind kind) {
    if (!gAppSetting.rxPrefSoundOn.value) return;

    String audioName = '';
    switch (kind) {
      case AudioKind.forwardSelection:
        audioName = audioNameBackwardSelection;
        break;
      case AudioKind.backwardSelection:
        audioName = audioNameBackwardSelection;
        break;
      case AudioKind.cancel:
        audioName = audioNameCancel;
        break;
      case AudioKind.tap:
        audioName = audioNameTap;
        break;
      case AudioKind.stateChange:
        audioName = audioNameStateChange;
        break;
    }
    if (audioName.isEmpty) return;

    _player.play(audioName);
  }
}
