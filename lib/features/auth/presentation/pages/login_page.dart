import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/brand_mark.dart';

/// Kirish sahifasi: login + parol. Qurilma tasdiqlanmagan bo'lsa alohida
/// tushunarli kartochka ko'rsatiladi.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final saved = context.read<AuthCubit>().prefs.lastUsername;
    _username = TextEditingController(text: saved ?? '');
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(_username.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandMark(size: 84)),
                    const SizedBox(height: 24),
                    Text(
                      l10n.welcomeTitle,
                      style: context.textStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.welcomeSubtitle,
                      style: context.textStyles.bodyLarge!.copyWith(
                        color: c.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _ErrorBanner(),
                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        labelText: l10n.username,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (a, b) => a.submitting != b.submitting,
                      builder: (context, state) => FilledButton(
                        onPressed: state.submitting ? null : _submit,
                        child: state.submitting
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.signIn),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Xato holatlari: noto'g'ri parol / qurilma kutmoqda / qurilma bloklangan.
class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) => a.error != b.error || a.errorCode != b.errorCode,
      builder: (context, state) {
        if (state.error == null && state.errorCode == null) {
          return const SizedBox.shrink();
        }

        String title;
        String? body;
        IconData icon;
        Color bg = c.dangerSoft;
        Color fg = c.danger;

        switch (state.errorCode) {
          case 'DEVICE_PENDING':
          case 'DEVICE_UNKNOWN':
            title = l10n.devicePendingTitle;
            body = l10n.devicePendingBody;
            icon = Icons.phonelink_lock_outlined;
            bg = c.warningSoft;
            fg = c.warning;
          case 'DEVICE_BLOCKED':
          case 'DEVICE_REVOKED':
            title = l10n.deviceBlockedTitle;
            body = l10n.deviceBlockedBody;
            icon = Icons.block_rounded;
          case 'HOTEL_INACTIVE':
          case 'HOTEL_SUSPENDED':
          case 'HOTEL_NOT_FOUND':
            // Login va parol to'g'ri — muammo xodimda emas
            title = l10n.serviceStoppedTitle;
            body = state.error ?? l10n.serviceStoppedBody;
            icon = Icons.pause_circle_outline_rounded;
            bg = c.warningSoft;
            fg = c.warning;
          case 'WRONG_CREDENTIALS':
          case 'UNAUTHORIZED':
          case 'INVALID_CREDENTIALS':
            title = l10n.wrongCredentials;
            icon = Icons.error_outline_rounded;
          default:
            title = state.error ?? l10n.serverError;
            icon = Icons.error_outline_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fg, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.titleSmall!.copyWith(color: fg),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: context.textStyles.bodyMedium!.copyWith(
                          color: fg,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
