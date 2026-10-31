import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../settings/settings_screen.dart' show InterestPicker;

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<String> _picked = const [];

  void _finish() {
    ref.read(interestsProvider.notifier).set(_picked);
    ref.read(prefsProvider).setBool('onboarded', true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GlowBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Spacer(flex: 2),
                Text('गीता', style: AppText.display.copyWith(color: AppColors.gold)),
                const SizedBox(height: AppSpacing.s2),
                Text('श्रीमद्भगवद्गीता के श्लोक, शांत रील के रूप में।', style: AppText.body),
                const SizedBox(height: AppSpacing.s8),
                Text('आपकी रुचि (वैकल्पिक)', style: AppText.sectionTitle),
                const SizedBox(height: AppSpacing.s3),
                InterestPicker(selected: _picked, onChanged: (v) => setState(() => _picked = v)),
                const SizedBox(height: AppSpacing.s3),
                Text('संस्कृत श्लोक और हिन्दी अर्थ · आवाज़ डिफ़ॉल्ट रूप से बंद', style: AppText.metadata),
                const Spacer(flex: 3),
                FilledButton(onPressed: _finish, child: const Text('शुरू करें')),
                const SizedBox(height: AppSpacing.s2),
                Center(child: TextButton(onPressed: () { setState(() => _picked = const []); _finish(); }, child: const Text('अभी छोड़ें'))),
              ]),
            ),
          ),
        ),
      );
}
