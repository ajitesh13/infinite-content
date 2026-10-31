import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
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

  static Future<void> show(BuildContext context, Reel reel) => Navigator.of(context)
      .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => VerseReader(reel: reel)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(reel.reference),
          leading: IconButton(
              tooltip: 'बंद करें', icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        ),
        body: GlowBackdrop(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(reel.referenceLatin, style: AppText.metadata.copyWith(color: AppColors.gold)),
                const SizedBox(height: AppSpacing.s4),
                Text('संस्कृत श्लोक', style: AppText.metadata),
                const SizedBox(height: AppSpacing.s2),
                SelectableText(reel.sanskrit, style: AppText.shlokReader),
                const SizedBox(height: AppSpacing.s8),
                Text('हिन्दी अर्थ', style: AppText.metadata),
                const SizedBox(height: AppSpacing.s2),
                SelectableText(reel.hindiMeaning, style: AppText.body),
                if (reel.takeaway != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text('संपादकीय सार (व्याख्या)', style: AppText.metadata),
                  const SizedBox(height: AppSpacing.s2),
                  Text(reel.takeaway!, style: AppText.body),
                ],
                const SizedBox(height: AppSpacing.s8),
                Divider(color: context.geeta.divider),
                const SizedBox(height: AppSpacing.s3),
                Text(reel.credit, style: AppText.metadata),
              ]),
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
            AppSpacing.s6, AppSpacing.s2, AppSpacing.s6, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s6),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_signUp ? 'टिप्पणी करने के लिए खाता बनाएँ' : 'साइन इन करें', style: AppText.sectionTitle),
            const SizedBox(height: AppSpacing.s1),
            Text('देखना और पसंद करना बिना खाते के भी संभव है।', style: AppText.metadata),
            const SizedBox(height: AppSpacing.s4),
            if (_signUp) ...[
              TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'नाम (वैकल्पिक)')),
              const SizedBox(height: AppSpacing.s3),
            ],
            TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(hintText: 'ईमेल')),
            const SizedBox(height: AppSpacing.s3),
            TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'पासवर्ड (कम से कम 6 अक्षर)')),
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAction))
                    : Text(_signUp ? 'खाता बनाएँ' : 'साइन इन')),
            TextButton(
                onPressed: () => setState(() => _signUp = !_signUp),
                child: Text(_signUp ? 'पहले से खाता है? साइन इन' : 'नया खाता बनाएँ')),
          ]),
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
      if (mounted) showStatus(context, 'टिप्पणी नहीं भेजी जा सकी। फिर प्रयास करें।');
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (mine)
            ListTile(leading: const Icon(Icons.delete_outline_rounded), title: const Text('हटाएँ'), onTap: () => Navigator.pop(context, 'delete'))
          else ...[
            ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('रिपोर्ट करें'), onTap: () => Navigator.pop(context, 'report')),
            ListTile(leading: const Icon(Icons.block_rounded), title: const Text('उपयोगकर्ता को ब्लॉक करें'), onTap: () => Navigator.pop(context, 'block')),
          ],
        ]),
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
          if (mounted) showStatus(context, 'रिपोर्ट मिल गई। धन्यवाद।');
        case 'block':
          await repo.blockUser(c.userId);
          if (mounted) showStatus(context, 'उपयोगकर्ता ब्लॉक किया गया।');
      }
      await _load();
    } catch (_) {
      if (mounted) showStatus(context, 'कार्रवाई पूरी नहीं हुई। फिर प्रयास करें।');
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(feedProvider.select((s) =>
        s.reels.where((r) => r.id == widget.reel.id).map((r) => r.commentCount).firstOrNull ?? 0));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          child: Row(children: [
            Expanded(child: Text('टिप्पणियाँ ($count)', style: AppText.sectionTitle)),
            IconButton(
                tooltip: 'बंद करें', icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
          ]),
        ),
        Expanded(child: _list()),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                maxLength: 500,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                decoration: const InputDecoration(hintText: 'टिप्पणी लिखें…'),
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            IconButton.filled(
              tooltip: 'भेजें',
              style: IconButton.styleFrom(
                  backgroundColor: AppColors.actionYellow,
                  foregroundColor: AppColors.onAction,
                  minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget)),
              onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send_rounded),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _list() {
    if (_error != null) return ErrorRetry(message: 'टिप्पणियाँ लोड नहीं हुईं।', onRetry: _load);
    final items = _items;
    if (items == null) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    if (items.isEmpty) {
      return Center(child: Text('अभी कोई टिप्पणी नहीं। पहली टिप्पणी आप लिखें।', style: AppText.body.copyWith(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(color: context.geeta.divider, height: 1),
      itemBuilder: (_, i) {
        final c = items[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${c.author} · ${_ago(c.createdAt)}', style: AppText.metadata),
                const SizedBox(height: 2),
                Text(c.body, style: AppText.body),
              ]),
            ),
            IconButton(
                tooltip: 'टिप्पणी विकल्प', icon: const Icon(Icons.more_vert_rounded), onPressed: () => _menu(c)),
          ]),
        );
      },
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'अभी';
    if (d.inHours < 1) return '${d.inMinutes} मि.';
    if (d.inDays < 1) return '${d.inHours} घं.';
    return '${d.inDays} दिन';
  }
}

// ───────────────────────── More menu ─────────────────────────

enum MoreChoice { hide, showLess, report }

Future<MoreChoice?> showMoreMenu(BuildContext context) => showModalBottomSheet<MoreChoice>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text('यह रील छिपाएँ'),
              onTap: () => Navigator.pop(context, MoreChoice.hide)),
          ListTile(
              leading: const Icon(Icons.thumb_down_alt_outlined),
              title: const Text('ऐसे विषय कम दिखाएँ'),
              onTap: () => Navigator.pop(context, MoreChoice.showLess)),
          ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('रिपोर्ट करें'),
              onTap: () => Navigator.pop(context, MoreChoice.report)),
        ]),
      ),
    );
