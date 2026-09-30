import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/glass.dart';
import '../../../../../core/widgets/camera_capture_page.dart';
import '../cubit/task_detail_cubit.dart';

/// Foto hisobot: kamera/galereyadan bir nechta rasm + izoh → serverga.
Future<void> showPhotoReportSheet(BuildContext context) {
  final cubit = context.read<TaskDetailCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _PhotoReportSheet()),
  );
}

class _PhotoReportSheet extends StatefulWidget {
  const _PhotoReportSheet();

  @override
  State<_PhotoReportSheet> createState() => _PhotoReportSheetState();
}

class _PhotoReportSheetState extends State<_PhotoReportSheet> {
  final _picker = ImagePicker();
  final _comment = TextEditingController();
  final List<String> _photos = [];
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _addFromCamera() async {
    // Ilova ichidagi tezkor kamera — ketma-ket bir necha rasm olinadi.
    final paths = await CameraCapturePage.openMulti(context);
    if (paths != null && paths.isNotEmpty) {
      setState(() => _photos.addAll(paths));
    }
  }

  Future<void> _addFromGallery() async {
    final photos = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (photos.isNotEmpty) {
      setState(() => _photos.addAll(photos.map((p) => p.path)));
    }
  }

  Future<void> _submit() async {
    if (_photos.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await context.read<TaskDetailCubit>().submitReport(
      photoPaths: _photos,
      comment: _comment.text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      Navigator.of(context).pop();
      context.showSnack(context.l10n.reportSentOk);
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
                  l10n.photoReportTitle,
                  style: context.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (_photos.isNotEmpty) ...[
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(_photos[i]),
                              width: 96,
                              height: 96,
                              // Eskiz uchun to'liq kadr dekodlanmasin
                              cacheWidth: 288,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(i)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addFromCamera,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.addPhoto),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 58,
                      child: OutlinedButton(
                        onPressed: _addFromGallery,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.photo_library_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _comment,
                  maxLines: 3,
                  minLines: 2,
                  decoration: InputDecoration(hintText: l10n.commentHint),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _photos.isEmpty || _sending ? null : _submit,
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
                  label: Text(l10n.sendReport),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
