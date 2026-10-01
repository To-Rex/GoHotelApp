import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../auth/presentation/widgets/brand_mark.dart';
import '../../data/management_repository.dart';
import 'pressable.dart';

/// E'lon: mehmonxonaning barcha xodimlariga bitta push.
///
/// Faqat admin uchun (server ham shuni talab qiladi). Yozayotganda
/// tepada bildirishnomaning JONLI ko'rinishi turadi — xodim telefonida
/// aynan nima chiqishi yuborishdan oldin ko'rinadi. Tez matnlar bir
/// bosishda sarlavhani to'ldiradi. [recipients] — nechta faol xodimga
/// borishi (ma'lum bo'lsa).
Future<void> showBroadcastSheet(BuildContext context, {int? recipients}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BroadcastSheet(recipients: recipients),
  );
}

class _BroadcastSheet extends StatefulWidget {
  const _BroadcastSheet({required this.recipients});

  final int? recipients;

  @override
  State<_BroadcastSheet> createState() => _BroadcastSheetState();
}

class _BroadcastSheetState extends State<_BroadcastSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Ko'rinish har harfda yangilanadi
    _title.addListener(_refresh);
    _body.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    if (_title.text.trim().isEmpty) {
      context.showSnack(l10n.fieldRequired, isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      final sent = await getIt<ManagementRepository>().broadcast(
        title: _title.text,
        body: _body.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(l10n.broadcastSent(sent));
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      context.showSnack(friendlyError(context, e), isError: true);
    }
  }

  void _useQuick(String text) {
    _title.text = text;
    _title.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final hasTitle = _title.text.trim().isNotEmpty;
    final hasBody = _body.text.trim().isNotEmpty;

    return GlassSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            bottom + MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sarlavha -------------------------------------------------
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: c.brand,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.speaker_2_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.broadcastTitle,
                          style: context.textStyles.titleLarge,
                        ),
                        Text(
                          widget.recipients != null && widget.recipients! > 0
                              ? l10n.broadcastRecipients(widget.recipients!)
                              : l10n.broadcastBody,
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- Jonli ko'rinish: telefon bildirishnomasi -----------------
              _Caption(text: l10n.broadcastPreview),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: c.outline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'GoHotel Staff',
                                  style: context.textStyles.labelSmall!.copyWith(
                                    color: c.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.broadcastNow,
                                style: context.textStyles.labelSmall!.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: context.textStyles.titleSmall!.copyWith(
                              color: hasTitle ? c.text : c.textMuted,
                            ),
                            child: Text(
                              hasTitle
                                  ? _title.text.trim()
                                  : l10n.broadcastTitlePlaceholder,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topLeft,
                            child: Text(
                              hasBody
                                  ? _body.text.trim()
                                  : l10n.broadcastBodyPlaceholder,
                              style: context.textStyles.bodyMedium!.copyWith(
                                color: hasBody ? c.text : c.textMuted,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // --- Tez matnlar ----------------------------------------------
              _Caption(text: l10n.broadcastQuick),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final text in [
                    l10n.broadcastQuick1,
                    l10n.broadcastQuick2,
                    l10n.broadcastQuick3,
                  ])
                    Pressable(
                      onTap: () => _useQuick(text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _title.text == text ? c.brand : c.brandSoft,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          text,
                          style: context.textStyles.labelMedium!.copyWith(
                            color: _title.text == text
                                ? Colors.white
                                : c.onBrandSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // --- Maydonlar ------------------------------------------------
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: l10n.broadcastTitleHint,
                  counterText: '',
                  fillColor: c.surface,
                  suffixText: '${_title.text.length}/120',
                  suffixStyle: context.textStyles.labelSmall!.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _body,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: l10n.broadcastMessageHint,
                  counterText: '',
                  fillColor: c.surface,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                label: Text(l10n.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall!.copyWith(
          color: context.colors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
