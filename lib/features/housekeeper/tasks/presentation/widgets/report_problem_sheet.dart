import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../app/di.dart';
import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/glass.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/widgets/camera_capture_page.dart';
import '../../data/tasks_repository.dart';
import '../../../../../l10n/gen/app_localizations.dart';

/// Muammo kategoriyalari — backend enum QIYMATLARI o'zbekcha satrlar
/// (ProblemCategory), shuning uchun serverga aynan shu matn ketadi,
/// ekranda esa tanlangan til ko'rinadi.
class _Category {
  const _Category(this.apiValue, this.label, this.icon);

  final String apiValue;
  final String Function(S) label;
  final IconData icon;
}

final List<_Category> _categories = [
  _Category('Siniq buyum', (l) => l.catBroken, Icons.broken_image_outlined),
  _Category('Texnik nosozlik', (l) => l.catTechnical, Icons.build_outlined),
  _Category('Suv sizishi', (l) => l.catWater, Icons.water_drop_outlined),
  _Category('Chiroy kuygan', (l) => l.catBurnt, Icons.lightbulb_outline),
  _Category(
    'Elektr nosozligi',
    (l) => l.catElectric,
    Icons.electric_bolt_outlined,
  ),
  _Category(
    'Mexanizm buzilgan',
    (l) => l.catMechanism,
    Icons.settings_outlined,
  ),
  _Category('Boshqa', (l) => l.catOther, Icons.more_horiz_rounded),
];

/// Muammo haqida xabar berish (vazifadan yoki alohida).
Future<void> showReportProblemSheet(
  BuildContext context, {
  String? taskId,
  String? roomNumber,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReportProblemSheet(taskId: taskId, roomNumber: roomNumber),
  );
}

class _ReportProblemSheet extends StatefulWidget {
  const _ReportProblemSheet({this.taskId, this.roomNumber});

  final String? taskId;
  final String? roomNumber;

  @override
  State<_ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<_ReportProblemSheet> {
  final _description = TextEditingController();
  final List<String> _photos = [];
  _Category _selected = _categories.first;
  bool _sending = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    // Ilova ichidagi tezkor kamera — ketma-ket bir necha rasm olinadi.
    final paths = await CameraCapturePage.openMulti(context);
    if (paths != null && paths.isNotEmpty) {
      setState(() => _photos.addAll(paths));
    }
  }

  Future<void> _submit() async {
    final description = _description.text.trim();
    if (description.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await getIt<TasksRepository>().reportProblem(
        category: _selected.apiValue,
        description: description,
        photoPaths: _photos,
        taskId: widget.taskId,
        roomNumber: widget.roomNumber,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(context.l10n.problemSentOk);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      context.showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      context.showSnack(context.l10n.serverError, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassSheet(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.roomNumber == null
                      ? l10n.problemTitle
                      : '${l10n.problemTitle} — ${l10n.roomTitle(widget.roomNumber!)}',
                  style: context.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.problemCategoryLabel,
                  style: context.textStyles.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in _categories)
                      ChoiceChip(
                        selected: _selected == category,
                        onSelected: (_) => setState(() => _selected = category),
                        avatar: Icon(
                          category.icon,
                          size: 18,
                          color: _selected == category
                              ? Colors.white
                              : c.textMuted,
                        ),
                        label: Text(category.label(l10n)),
                        labelStyle: context.textStyles.labelLarge!.copyWith(
                          color: _selected == category ? Colors.white : c.text,
                        ),
                        showCheckmark: false,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.problemDescLabel,
                  style: context.textStyles.titleSmall,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(hintText: l10n.problemDescHint),
                ),
                const SizedBox(height: 16),
                if (_photos.isNotEmpty) ...[
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_photos[i]),
                              width: 80,
                              height: 80,
                              // Eskiz uchun to'liq kadr dekodlanmasin
                              cacheWidth: 240,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(i)),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text('${l10n.problemPhotos} (${l10n.optional})'),
                ),
                const SizedBox(height: 14),
                /* Tugma matn kiritilishiga qarab yonadi/o'chadi. Ilgari
                   TextField'dagi setState har harfda BUTUN oynani (chiplar,
                   rasm lentasi) qayta chizardi; endi controller'ni faqat
                   shu tugmaning o'zi tinglaydi. */
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _description,
                  builder: (context, value, _) => FilledButton.icon(
                    onPressed: value.text.trim().isEmpty || _sending
                        ? null
                        : _submit,
                    icon: _sending
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: c.textMuted,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(l10n.problemSubmit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
