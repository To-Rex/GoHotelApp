import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/face_repository.dart';
import '../../domain/staff_user.dart';
import '../cubit/auth_cubit.dart';
import '../pages/face_capture_page.dart';

/// Yuzi biriktirilmagan xodimdan uni biriktirishni TALAB qiladi —
/// frontend'dagi `FaceRequiredGate` bilan bir xil qoidalar:
///
/// - Faqat EMPLOYEE uchun (administrator majburlanmaydi — kamera/dvigatel
///   ishlamay qolsa tizimni boshqaradigan odam ham qamalib qolardi).
/// - Server dvigateli ishlamasa yoki holatni bilib bo'lmasa (tarmoq xatosi)
///   talab qilinmaydi — xodimni ishdan to'xtatib qo'yish xavfliroq.
/// - Oynani yopib bo'lmaydi: bu talab, taklif emas. Chiqish yo'li bitta —
///   hisobdan chiqish.
///
/// Yuz biriktirilgach keyingi kirishlar ikki bosqichli bo'ladi:
/// parol → yuz tasdig'i (`/auth/face/verify-login`).
class FaceEnrollGate extends StatefulWidget {
  const FaceEnrollGate({super.key, required this.user, required this.child});

  final StaffUser user;
  final Widget child;

  @override
  State<FaceEnrollGate> createState() => _FaceEnrollGateState();
}

class _FaceEnrollGateState extends State<FaceEnrollGate> {
  bool _required = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (widget.user.userType != 'EMPLOYEE') return;
    try {
      final status = await getIt<FaceRepository>().getStatus();
      if (!mounted) return;
      setState(() => _required = status.engineAvailable && !status.enrolled);
    } catch (_) {
      // Holatni bilib bo'lmasa majburlamaymiz (frontend bilan bir xil).
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
      await getIt<FaceRepository>().enroll(path);
      if (!mounted) return;
      setState(() {
        _required = false;
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Stack(
      children: [
        widget.child,
        if (_required) ...[
          const ModalBarrier(dismissible: false, color: Colors.black54),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Material(
                color: c.surface,
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.warningSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 38,
                          color: c.warning,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.faceGateTitle,
                        style: context.textStyles.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.faceGateBody,
                        style: context.textStyles.bodyMedium!.copyWith(
                          color: c.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                      const SizedBox(height: 20),
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
                        label: Text(l10n.faceEnrollAction),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: _busy
                            ? null
                            : () => context.read<AuthCubit>().logout(),
                        style: TextButton.styleFrom(
                          foregroundColor: c.textMuted,
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: Text(l10n.logout),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
