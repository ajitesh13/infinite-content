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
            _signUp
                ? context.tr('टिप्पणी करने के लिए खाता बनाएँ', 'Create an account to comment')
                : context.tr('साइन इन करें', 'Sign in'),
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

// ───────────────────────── Comments ─────────────────────────

Future<void> showComments(BuildContext context, Reel reel) =>
    _sheet<void>(context, (_) => _CommentsSheet(reel: reel), full: true);

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.reel});
  final Reel reel;
  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _input = TextEditingController();
  List<Comment>? _items;
  Object? _error;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final items = await ref.read(repositoryProvider).comments(widget.reel.id);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    if (!ref.read(repositoryProvider).isRegistered) {
      if (!await showAuthSheet(context)) return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(repositoryProvider).postComment(widget.reel.id, text);
      _input.clear();
      ref.read(feedProvider.notifier).bumpComments(widget.reel.id, 1);
      await _load();
    } catch (_) {
      if (mounted) {
        showStatus(
          context,
          context.tr(
            'टिप्पणी नहीं भेजी जा सकी। फिर प्रयास करें।',
            'Could not post your comment. Please try again.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _menu(Comment c) async {
    final repo = ref.read(repositoryProvider);
    final mine = repo.user?.id == c.userId;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mine)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(context.tr('हटाएँ', 'Delete')),
                onTap: () => Navigator.pop(context, 'delete'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(context.tr('रिपोर्ट करें', 'Report')),
                onTap: () => Navigator.pop(context, 'report'),
              ),
              ListTile(
                leading: const Icon(Icons.block_rounded),
                title: Text(context.tr('उपयोगकर्ता को ब्लॉक करें', 'Block user')),
                onTap: () => Navigator.pop(context, 'block'),
              ),
            ],
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    try {
      switch (choice) {
        case 'delete':
          await repo.deleteComment(c.id);
          ref.read(feedProvider.notifier).bumpComments(widget.reel.id, -1);
        case 'report':
          await repo.reportComment(c.id, 'reported');
          if (mounted) {
            showStatus(context, context.tr('रिपोर्ट मिल गई। धन्यवाद।', 'Report received. Thank you.'));
          }
        case 'block':
          await repo.blockUser(c.userId);
          if (mounted) showStatus(context, context.tr('उपयोगकर्ता ब्लॉक किया गया।', 'User blocked.'));
      }
      await _load();
    } catch (_) {
      if (mounted) {
        showStatus(
          context,
          context.tr('कार्रवाई पूरी नहीं हुई। फिर प्रयास करें।', 'That did not work. Please try again.'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      feedProvider.select(
        (s) => s.reels.where((r) => r.id == widget.reel.id).map((r) => r.commentCount).firstOrNull ?? 0,
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('टिप्पणियाँ ($count)', 'Comments ($count)'),
                    style: AppText.sectionTitle,
                  ),
                ),
                IconButton(
                  tooltip: context.tr('बंद करें', 'Close'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(child: _list()),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                    decoration: InputDecoration(hintText: context.tr('टिप्पणी लिखें…', 'Write a comment…')),
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                IconButton.filled(
                  tooltip: context.tr('भेजें', 'Send'),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.actionYellow,
                    foregroundColor: AppColors.onAction,
                    minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
                  ),
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    if (_error != null) {
      return ErrorRetry(
        message: context.tr('टिप्पणियाँ लोड नहीं हुईं।', 'Could not load comments.'),
        onRetry: _load,
      );
    }
    final items = _items;
    if (items == null) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    if (items.isEmpty) {
      return Center(
        child: Text(
          context.tr('अभी कोई टिप्पणी नहीं। पहली टिप्पणी आप लिखें।', 'No comments yet. Be the first.'),
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(color: context.geeta.divider, height: 1),
      itemBuilder: (_, i) {
        final c = items[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.author} · ${_ago(context, c.createdAt)}', style: AppText.metadata),
                    const SizedBox(height: 2),
                    Text(c.body, style: AppText.body),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('टिप्पणी विकल्प', 'Comment options'),
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _menu(c),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _ago(BuildContext context, DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return context.tr('अभी', 'just now');
    if (d.inHours < 1) return context.tr('${d.inMinutes} मि.', '${d.inMinutes}m ago');
    if (d.inDays < 1) return context.tr('${d.inHours} घं.', '${d.inHours}h ago');
    return context.tr('${d.inDays} दिन', '${d.inDays}d ago');
  }
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
