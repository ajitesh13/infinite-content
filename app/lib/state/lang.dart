import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// UI language: English (default) or Hindi. The Sanskrit shlok is never translated.
class EnglishNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsProvider).getBool('english') ?? true;
  void set(bool on) {
    state = on;
    ref.read(prefsProvider).setBool('english', on);
  }
}

final englishProvider = NotifierProvider<EnglishNotifier, bool>(EnglishNotifier.new);

/// Exposes the language to every widget so `context.tr` rebuilds on toggle.
class LangScope extends InheritedWidget {
  const LangScope({super.key, required this.english, required super.child});
  final bool english;

  @override
  bool updateShouldNotify(LangScope old) => english != old.english;
}

extension LangContext on BuildContext {
  bool get isEnglish => dependOnInheritedWidgetOfExactType<LangScope>()?.english ?? true;
  String tr(String hi, String en) => isEnglish ? en : hi;
}
