import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../data/face_repository.dart';
import '../pages/face_capture_page.dart';

/// Profildagi "Yuz bilan kirish" bo'limi: holat, namuna qo'shish, o'chirish —
/// frontend'dagi FaceEnrollDialog'ning mobil ekvivalenti.
Future<void> showFaceSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const GlassSheet(child: _FaceSettingsSheet()),
  );
}

class _FaceSettingsSheet extends StatefulWidget {
  const _FaceSettingsSheet();

  @override
  State<_FaceSettingsSheet> createState() => _FaceSettingsSheetState();
}

class _FaceSettingsSheetState extends State<_FaceSettingsSheet> {
  FaceStatus? _status;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final status = await getIt<FaceRepository>().getStatus();
      if (mounted) setState(() => _status = status);
    } catch (e) {
      if (mounted) {
        setState(() => _error = friendlyError(context, e));
      }
    }
  }

  Future<void> _enroll() async {
    final l10n = context.l10n;
    final path = await FaceCapturePage.open(context);
    if (path == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final status = await getIt<FaceRepository>().enroll(path);
      if (!mounted) return;
      setState(() {
        _status = status;
        _busy = false;
      });
      context.showSnack(l10n.faceEnrolledOk);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.code == 'NO_FACE' ? l10n.faceNotDetected : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.serverError;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showConfirmSheet(
      context,
      title: l10n.faceDeleteTitle,
      body: l10n.faceDeleteBody,
      confirmLabel: l10n.faceDeleteAction,
      icon: Icons.face_retouching_off_rounded,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await getIt<FaceRepository>().deleteMyProfiles();
      if (!mounted) return;
      setState(() {
        _status = const FaceStatus(
          engineAvailable: true,
          enrolled: false,
          count: 0,
        );
        _busy = false;
      });
      context.showSnack(l10n.faceDeletedOk);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = friendlyError(context, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final status = _status;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.faceSection,
              style: context.textStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            if (status == null && _error == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (status != null) ...[
              // Holat qatori
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: status.enrolled ? c.successSoft : c.warningSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      status.enrolled
                          ? Icons.verified_user_rounded
                          : Icons.face_retouching_natural_rounded,
                      color: status.enrolled ? c.success : c.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        !status.engineAvailable
                            ? l10n.faceEngineOff
                            : status.enrolled
                            ? l10n.faceStatusEnrolled(status.count)
                            : l10n.faceStatusNotEnrolled,
                        style: context.textStyles.titleSmall!.copyWith(
                          color: status.enrolled ? c.success : c.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (status.engineAvailable) ...[
                FilledButton.icon(
                  onPressed: _busy ? null : _enroll,
                  icon: _busy
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: c.textMuted,
                          ),
                        )
                      : const Icon(Icons.photo_camera_rounded),
                  label: Text(
                    status.enrolled
                        ? l10n.faceAddSample
                        : l10n.faceEnrollAction,
                  ),
                ),
                if (status.enrolled) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _delete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.danger,
                      side: BorderSide(color: c.danger.withValues(alpha: 0.4)),
                    ),
                    icon: const Icon(Icons.face_retouching_off_rounded),
                    label: Text(l10n.faceDeleteAction),
                  ),
                ],
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: context.textStyles.bodySmall!.copyWith(
                    color: c.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
