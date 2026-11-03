import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/lang.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

Future<T?> _sheet<T>(BuildContext context, WidgetBuilder b, {bool full = false}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  constraints: full ? BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85) : null,
  builder: b,
);

// ───────────────────────── Full verse reader ─────────────────────────

class VerseReader extends StatelessWidget {
  const VerseReader({super.key, required this.reel});
  final Reel reel;

  static Future<void> show(BuildContext context, Reel reel) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => VerseReader(reel: reel)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(reel.referenceFor(context.isEnglish)),
      leading: IconButton(
        tooltip: context.tr('बंद करें', 'Close'),
        icon: const Icon(Icons.close_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: GlowBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reel.referenceLatin, style: AppText.metadata.copyWith(color: AppColors.gold)),
              const SizedBox(height: AppSpacing.s4),
              Text(context.tr('संस्कृत श्लोक', 'Sanskrit verse'), style: AppText.metadata),
              const SizedBox(height: AppSpacing.s2),
              SelectableText(reel.sanskrit, style: AppText.shlokReader),
              const SizedBox(height: AppSpacing.s8),
              Text(
                reel.meaningIsEnglish(context.isEnglish) ? 'English meaning' : 'हिन्दी अर्थ',
                style: AppText.metadata,
              ),
              const SizedBox(height: AppSpacing.s2),
              SelectableText(reel.meaning(context.isEnglish), style: AppText.body),
              if (context.isEnglish && reel.applicationEnglish != null) ...[
                const SizedBox(height: AppSpacing.s8),
                Text(reel.titleEnglish ?? 'In daily life', style: AppText.metadata),
                const SizedBox(height: AppSpacing.s2),
                Text(reel.applicationEnglish!, style: AppText.body),
              ],
              if (reel.takeaway != null) ...[
                const SizedBox(height: AppSpacing.s8),
                Text(
                  context.tr('संपादकीय सार (व्याख्या)', 'Editorial summary (interpretation)'),
                  style: AppText.metadata,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(reel.takeaway!, style: AppText.body),
              ],
              const SizedBox(height: AppSpacing.s8),
              Text(context.tr('स्रोत और श्रेय', 'Sources and credits'), style: AppText.metadata),
              const SizedBox(height: AppSpacing.s2),
              Text(reel.credit, style: AppText.metadata),
            ],
          ),
        ),
      ),
    ),
  );
}

// ───────────────────────── Sign-in sheet ─────────────────────────

Future<bool> showAuthSheet(BuildContext context) async =>
    await _sheet<bool>(context, (_) => const _AuthSheet()) ?? false;

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet();
  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final _email = TextEditingController(), _pass = TextEditingController(), _name = TextEditingController();
  bool _signUp = true, _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(repositoryProvider);
    try {
      _signUp
          ? await repo.signUp(_email.text.trim(), _pass.text, _name.text.trim())
          : await repo.signIn(_email.text.trim(), _pass.text);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst(RegExp(r'^\w*Exception:?\s*'), ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.s6,
      AppSpacing.s2,
      AppSpacing.s6,
      MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s6,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _signUp ? context.tr('खाता बनाएँ', 'Create an account') : context.tr('साइन इन करें', 'Sign in'),
            style: AppText.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            context.tr(
              'देखना और पसंद करना बिना खाते के भी संभव है।',
              'You can watch and like without an account.',
            ),
            style: AppText.metadata,
          ),
          const SizedBox(height: AppSpacing.s4),
          if (_signUp) ...[
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: context.tr('नाम (वैकल्पिक)', 'Name (optional)')),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(hintText: context.tr('ईमेल', 'Email')),
          ),
          const SizedBox(height: AppSpacing.s3),
          TextField(
            controller: _pass,
            obscureText: true,
            decoration: InputDecoration(
              hintText: context.tr('पासवर्ड (कम से कम 6 अक्षर)', 'Password (at least 6 characters)'),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s2),
              child: Text(_error!, style: AppText.metadata.copyWith(color: AppColors.error)),
            ),
          const SizedBox(height: AppSpacing.s4),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAction),
                  )
                : Text(
                    _signUp ? context.tr('खाता बनाएँ', 'Create account') : context.tr('साइन इन', 'Sign in'),
                  ),
          ),
          TextButton(
            onPressed: () => setState(() => _signUp = !_signUp),
            child: Text(
              _signUp
                  ? context.tr('पहले से खाता है? साइन इन', 'Already have an account? Sign in')
                  : context.tr('नया खाता बनाएँ', 'Create a new account'),
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────── More menu ─────────────────────────

enum MoreChoice { hide, showLess, report }

Future<MoreChoice?> showMoreMenu(BuildContext context) => showModalBottomSheet<MoreChoice>(
  context: context,
  builder: (context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.visibility_off_outlined),
          title: Text(context.tr('यह रील छिपाएँ', 'Hide this reel')),
          onTap: () => Navigator.pop(context, MoreChoice.hide),
        ),
        ListTile(
          leading: const Icon(Icons.thumb_down_alt_outlined),
          title: Text(context.tr('ऐसे विषय कम दिखाएँ', 'Show less like this')),
          onTap: () => Navigator.pop(context, MoreChoice.showLess),
        ),
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(context.tr('रिपोर्ट करें', 'Report')),
          onTap: () => Navigator.pop(context, MoreChoice.report),
        ),
      ],
    ),
  ),
);
