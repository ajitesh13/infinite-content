import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
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
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: AppText.sectionTitle),
          content: Text(body, style: AppText.body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('रद्द करें')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('जारी रखें')),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final registered = ref.watch(isRegisteredProvider);
    final sound = ref.watch(soundOnProvider);
    final interests = ref.watch(interestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('सेटिंग्स')),
      body: GlowBackdrop(
        child: ListView(padding: const EdgeInsets.all(AppSpacing.s4), children: [
          _Card(children: [
            SwitchListTile(
              title: const Text('आवाज़ डिफ़ॉल्ट रूप से चालू'),
              value: sound,
              onChanged: (v) {
                ref.read(soundOnProvider.notifier).set(v);
                repo.saveProfile(soundDefault: v).catchError((_) {});
              },
            ),
          ]),
          const SizedBox(height: AppSpacing.s4),
          _Card(children: [
            ListTile(title: const Text('भाषा'), subtitle: const Text('संस्कृत श्लोक · हिन्दी अर्थ')),
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
              title: const Text('सुझाव रीसेट करें'),
              subtitle: const Text('रुचियाँ और छिपाए गए विषय हटाएँ'),
              onTap: () async {
                if (!await _confirm(context, 'सुझाव रीसेट करें?', 'आपकी चुनी हुई रुचियाँ और छिपाए गए विषय हट जाएँगे।')) return;
                ref.read(interestsProvider.notifier).set(const []);
                await repo.resetPersonalization();
                await ref.read(feedProvider.notifier).refresh();
                if (context.mounted) showStatus(context, 'सुझाव रीसेट हो गए।');
              },
            ),
          ]),
          const SizedBox(height: AppSpacing.s4),
          _Card(children: [
            if (!registered)
              ListTile(
                leading: const Icon(Icons.login_rounded),
                title: const Text('साइन इन / खाता बनाएँ'),
                onTap: () => showAuthSheet(context),
              )
            else ...[
              ListTile(leading: const Icon(Icons.person_outline_rounded), title: Text(repo.user?.email ?? 'खाता')),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('साइन आउट'),
                onTap: () async {
                  await repo.signOut();
                  await ref.read(feedProvider.notifier).refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                title: Text('खाता हटाएँ', style: AppText.body.copyWith(color: AppColors.error)),
                onTap: () async {
                  if (!await _confirm(context, 'खाता हटाएँ?', 'आपका खाता, पसंद और टिप्पणियाँ स्थायी रूप से हट जाएँगी।')) return;
                  await repo.deleteAccount();
                  await ref.read(feedProvider.notifier).refresh();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ]),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'यह सामग्री प्रारम्भिक प्रति है और विद्वान द्वारा समीक्षा तक अंतिम नहीं है। '
            'AI-निर्मित दृश्य केवल चित्रण हैं।',
            style: AppText.metadata,
          ),
        ]),
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
  Widget build(BuildContext context) => Wrap(spacing: AppSpacing.s2, runSpacing: AppSpacing.s2, children: [
        for (final e in kInterestThemes.entries)
          FilterChip(
            label: Text(e.value),
            selected: selected.contains(e.key),
            showCheckmark: false,
            selectedColor: AppColors.surfacePressed,
            side: BorderSide(color: selected.contains(e.key) ? AppColors.gold : AppColors.divider),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            onSelected: (on) =>
                onChanged(on ? [...selected, e.key] : selected.where((k) => k != e.key).toList()),
          ),
      ]);
}
