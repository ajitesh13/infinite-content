import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/lang.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../feed/sheets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<bool> _confirm(BuildContext context, String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: AppText.sectionTitle),
          content: Text(body, style: AppText.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('रद्द करें', 'Cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('जारी रखें', 'Continue')),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final registered = ref.watch(isRegisteredProvider);
    final sound = ref.watch(soundOnProvider);
    final autoScroll = ref.watch(autoScrollProvider);
    final interests = ref.watch(interestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('सेटिंग्स', 'Settings'))),
      body: GlowBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          children: [
            _Card(
              children: [
                SwitchListTile(
                  title: Text(context.tr('आवाज़ डिफ़ॉल्ट रूप से चालू', 'Sound on by default')),
                  value: sound,
                  onChanged: (v) {
                    ref.read(soundOnProvider.notifier).set(v);
                    repo.saveProfile(soundDefault: v).catchError((_) {});
                  },
                ),
                SwitchListTile(
                  title: Text(context.tr('ऑटो स्क्रॉल', 'Auto scroll')),
                  subtitle: Text(
                    context.tr('श्लोक पाठ पूरा होने पर अगली रील', 'Next reel when the recitation ends'),
                  ),
                  value: autoScroll,
                  onChanged: (v) => ref.read(autoScrollProvider.notifier).set(v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            _Card(
              children: [
                SwitchListTile(
                  title: Text(context.tr('भाषा: अंग्रेज़ी', 'Language: English')),
                  subtitle: Text(
                    context.tr('श्लोक संस्कृत में ही रहेगा', 'The shlok always stays in Sanskrit'),
                  ),
                  value: ref.watch(englishProvider),
                  onChanged: (v) => ref.read(englishProvider.notifier).set(v),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s4, 0, AppSpacing.s4, AppSpacing.s4),
                  child: InterestPicker(
                    selected: interests,
                    onChanged: (v) {
                      ref.read(interestsProvider.notifier).set(v);
                      repo.saveProfile(interests: v).catchError((_) {});
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(context.tr('सुझाव रीसेट करें', 'Reset recommendations')),
                  subtitle: Text(
                    context.tr('रुचियाँ और छिपाए गए विषय हटाएँ', 'Clear your interests and hidden topics'),
                  ),
                  onTap: () async {
                    if (!await _confirm(
                      context,
                      context.tr('सुझाव रीसेट करें?', 'Reset recommendations?'),
                      context.tr(
                        'आपकी चुनी हुई रुचियाँ और छिपाए गए विषय हट जाएँगे।',
                        'Your chosen interests and hidden topics will be cleared.',
                      ),
                    )) {
                      return;
                    }
                    ref.read(interestsProvider.notifier).set(const []);
                    await repo.resetPersonalization();
                    await ref.read(feedProvider.notifier).refresh();
                    if (context.mounted) {
                      showStatus(context, context.tr('सुझाव रीसेट हो गए।', 'Recommendations reset.'));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            _Card(
              children: [
                if (!registered)
                  ListTile(
                    leading: const Icon(Icons.login_rounded),
                    title: Text(context.tr('साइन इन / खाता बनाएँ', 'Sign in / Create account')),
                    onTap: () => showAuthSheet(context),
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(repo.user?.email ?? context.tr('खाता', 'Account')),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(context.tr('साइन आउट', 'Sign out')),
                    onTap: () async {
                      await repo.signOut();
                      await ref.read(feedProvider.notifier).refresh();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                    title: Text(
                      context.tr('खाता हटाएँ', 'Delete account'),
                      style: AppText.body.copyWith(color: AppColors.error),
                    ),
                    onTap: () async {
                      if (!await _confirm(
                        context,
                        context.tr('खाता हटाएँ?', 'Delete account?'),
                        context.tr(
                          'आपका खाता और पसंद स्थायी रूप से हट जाएँगी।',
                          'Your account and likes will be permanently deleted.',
                        ),
                      )) {
                        return;
                      }
                      await repo.deleteAccount();
                      await ref.read(feedProvider.notifier).refresh();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              context.tr(
                'यह सामग्री प्रारम्भिक प्रति है और विद्वान द्वारा समीक्षा तक अंतिम नहीं है। AI-निर्मित दृश्य केवल चित्रण हैं।',
                'This content is a draft and is not final until a scholar has reviewed it. AI-generated visuals are illustrations only.',
              ),
              style: AppText.metadata,
            ),
            const SizedBox(height: AppSpacing.s3),
            Text(
              context.tr(
                'श्लोक पाठ: स्वामी ब्रह्मानन्द, Heritage IITK (CC BY-SA 4.0)।',
                'Shlok recitation: Swami Brahmananda, Heritage IITK (CC BY-SA 4.0).',
              ),
              style: AppText.metadata,
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(children: children),
  );
}

class InterestPicker extends StatelessWidget {
  const InterestPicker({super.key, required this.selected, required this.onChanged});
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.s2,
    runSpacing: AppSpacing.s2,
    children: [
      for (final e in kInterestThemes.entries)
        FilterChip(
          label: Text(context.isEnglish ? (kInterestThemesEn[e.key] ?? e.key) : e.value),
          selected: selected.contains(e.key),
          showCheckmark: false,
          selectedColor: AppColors.surfacePressed,
          side: BorderSide(color: selected.contains(e.key) ? AppColors.gold : AppColors.divider),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (on) =>
              onChanged(on ? [...selected, e.key] : selected.where((k) => k != e.key).toList()),
        ),
    ],
  );
}
