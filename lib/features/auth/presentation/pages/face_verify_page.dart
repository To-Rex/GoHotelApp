import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';
import 'face_capture_page.dart';

/// Kirishning ikkinchi bosqichi: yuz surati bilan tasdiqlash.
///
/// Old kamera ochiladi, surat serverdagi yuz profili bilan solishtiriladi.
/// Kamera ishlamasa "kamerasiz kirish" yo'li bor (server sessiya yozuviga
/// sababni saqlaydi).
class FaceVerifyPage extends StatefulWidget {
  const FaceVerifyPage({super.key});

  @override
  State<FaceVerifyPage> createState() => _FaceVerifyPageState();
}

class _FaceVerifyPageState extends State<FaceVerifyPage> {
  String? _imagePath;

  Future<void> _capture() async {
    // MyID uslubidagi avtomatik yuz suratga olish: yuz ovalga to'g'ri
    // joylashib, qimirlamay turganda surat O'ZI olinadi va serverdagi
    // profil bilan solishtiriladi.
    final path = await FaceCapturePage.open(context);
    if (path == null || !mounted) return;
    setState(() => _imagePath = path);
    context.read<AuthCubit>().verifyFace(path);
  }

  Future<void> _skipNoCamera() async {
    context.read<AuthCubit>().skipFace(context.l10n.faceNoCameraReason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.read<AuthCubit>().cancelFaceStep(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.brandSoft,
                      border: Border.all(color: c.brand, width: 3),
                      image: _imagePath == null
                          ? null
                          : DecorationImage(
                              // 210px doira uchun kadr kichraytirib
                              // dekodlanadi
                              image: ResizeImage(
                                FileImage(File(_imagePath!)),
                                width: 630,
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: _imagePath == null
                        ? Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 96,
                            color: c.onBrandSoft,
                          )
                        : null,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.faceStepTitle,
                    style: context.textStyles.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.faceStepBody,
                    style: context.textStyles.bodyLarge!.copyWith(
                      color: c.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (state.error != null && !state.submitting)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.dangerSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: c.danger,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _faceError(context, state),
                              style: context.textStyles.bodyMedium!.copyWith(
                                color: c.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (state.submitting)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    FilledButton.icon(
                      onPressed: _capture,
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: Text(
                        _imagePath == null
                            ? l10n.faceOpenCamera
                            : l10n.faceRetry,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _skipNoCamera,
                      icon: const Icon(Icons.no_photography_outlined),
                      label: Text(l10n.faceNoCameraBtn),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _faceError(BuildContext context, AuthState state) {
    final l10n = context.l10n;
    switch (state.errorCode) {
      case 'NO_FACE':
        return l10n.faceNotDetected;
      case 'FACE_MISMATCH':
        return l10n.faceNotRecognized;
      default:
        return state.error ?? l10n.faceNotRecognized;
    }
  }
}
