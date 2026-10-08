import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/roles/role_registry.dart';
import '../../../../app/settings/settings_cubit.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/branch_switch_sheet.dart';
import '../../../auth/presentation/widgets/face_settings_sheet.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/settings_sheets.dart';
import '../widgets/stats_grid.dart';

/// Xodim profili: ma'lumotlar, ish statistikasi, sozlamalar.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user != null) context.read<ProfileCubit>().load(user.id);
  }

  Future<void> _changePhoto() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (photo == null || !mounted) return;
    final cubit = context.read<ProfileCubit>();
    final ok = await cubit.uploadPhoto(user.id, photo.path);
    if (!mounted) return;
    if (!ok) {
      final error = cubit.state.error;
      context.showSnack(
        error is ApiException && error.isForbidden
            ? context.l10n.permissionDenied
            : context.l10n.serverError,
        isError: true,
      );
    }
  }

  Future<void> _logout() async {
    final l10n = context.l10n;
    final auth = context.read<AuthCubit>();
    final ok = await showConfirmSheet(
      context,
      title: l10n.logoutConfirmTitle,
      body: l10n.logoutConfirmBody,
      confirmLabel: l10n.logout,
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (ok) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    if (user == null) return const SizedBox.shrink();

    final role = RoleRegistry.resolve(user);

    final barPadding = MediaQuery.paddingOf(context);
    return RefreshIndicator(
      onRefresh: () async => context.read<ProfileCubit>().load(user.id),
      edgeOffset: barPadding.top,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          barPadding.top + 8,
          20,
          barPadding.bottom + 24,
        ),
        children: [
          // Sarlavha shell'dagi umumiy appbar'da.
          // --- Shaxsiy karta ---------------------------------------------
          AppCard(
            child: Column(
              children: [
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final cubit = context.read<ProfileCubit>();
                    return Stack(
                      children: [
                        AppAvatar(
                          name: user.fullName,
                          imageUrl: cubit.photoUrl(),
                          headers: cubit.photoHeaders(),
                          size: 96,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: c.brand,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: state.uploadingPhoto ? null : _changePhoto,
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: state.uploadingPhoto
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.photo_camera_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: context.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: c.brandSoft,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    role.label(l10n),
                    style: context.textStyles.labelLarge!.copyWith(
                      color: c.onBrandSoft,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.idLabel,
                  value: user.username,
                ),
                if (user.phone?.isNotEmpty == true)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: l10n.phoneLabel,
                    value: user.phone!,
                  ),
                if (user.hotelName?.isNotEmpty == true)
                  _InfoRow(
                    icon: Icons.apartment_rounded,
                    label: l10n.hotelLabel,
                    value: user.hotelName!,
                  ),
                if (user.branchName?.isNotEmpty == true)
                  _InfoRow(
                    icon: CupertinoIcons.arrow_branch,
                    label: l10n.branchLabel,
                    value: user.branchName!,
                  ),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  label: l10n.scheduleLabel,
                  value: '${user.workStart} – ${user.workEnd}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Ish statistikasi ------------------------------------------
          Text(l10n.statsTitle, style: context.textStyles.titleMedium),
          const SizedBox(height: 10),
          const StatsGrid(),
          const SizedBox(height: 20),

          // --- Sozlamalar -------------------------------------------------
          Text(l10n.settingsTitle, style: context.textStyles.titleMedium),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                // Administrator: filiallar alohida — boshqa filialga o'tish
                if (user.canSwitchBranch) ...[
                  ListTile(
                    leading: _settingIcon(
                      context,
                      CupertinoIcons.arrow_branch,
                      c.successSoft,
                      c.success,
                    ),
                    title: Text(l10n.branchSwitchTitle),
                    subtitle: Text(user.branchName ?? l10n.branchLabel),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                    ),
                    onTap: () => showBranchSwitchSheet(context),
                  ),
                  Divider(height: 1, indent: 72, color: c.outline),
                ],
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settings) => ListTile(
                    leading: _settingIcon(
                      context,
                      Icons.language_rounded,
                      c.infoSoft,
                      c.info,
                    ),
                    title: Text(l10n.languageLabel),
                    subtitle: Text(localeLabel(settings.locale)),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                    ),
                    onTap: () => showLanguageSheet(context),
                  ),
                ),
                Divider(height: 1, indent: 72, color: c.outline),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settings) => ListTile(
                    leading: _settingIcon(
                      context,
                      settings.themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      c.violetSoft,
                      c.violet,
                    ),
                    title: Text(l10n.themeLabel),
                    subtitle: Text(switch (settings.themeMode) {
                      ThemeMode.light => l10n.themeLight,
                      ThemeMode.dark => l10n.themeDark,
                      ThemeMode.system => l10n.themeSystem,
                    }),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                    ),
                    onTap: () => showThemeSheet(context),
                  ),
                ),
                Divider(height: 1, indent: 72, color: c.outline),
                // Serverdagi yuz bilan kirish (frontend'dagi kabi):
                // biriktirish, namuna qo'shish, o'chirish.
                ListTile(
                  leading: _settingIcon(
                    context,
                    Icons.face_retouching_natural_rounded,
                    c.brandSoft,
                    c.onBrandSoft,
                  ),
                  title: Text(l10n.faceSection),
                  subtitle: Text(l10n.faceEnrollAction),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: () => showFaceSettingsSheet(context),
                ),
                Divider(height: 1, indent: 72, color: c.outline),
                _BiometricTile(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: c.danger,
              side: BorderSide(color: c.danger.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.logout),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              l10n.appVersion('1.0.0'),
              style: context.textStyles.labelSmall!.copyWith(
                color: c.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingIcon(BuildContext context, IconData icon, Color bg, Color fg) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: fg),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: c.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: context.textStyles.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BiometricTile extends StatefulWidget {
  @override
  State<_BiometricTile> createState() => _BiometricTileState();
}

class _BiometricTileState extends State<_BiometricTile> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final enabled = context.read<AuthCubit>().prefs.biometricEnabled;

    return SwitchListTile(
      secondary: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.successSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.fingerprint_rounded, color: c.success),
      ),
      title: Text(l10n.quickUnlockLabel),
      subtitle: Text(l10n.quickUnlockDesc),
      value: enabled,
      onChanged: (value) async {
        final ok = await context.read<AuthCubit>().setBiometricEnabled(
          value,
          l10n.biometricReason,
        );
        if (!context.mounted) return;
        setState(() {}); // qiymat prefs'dan qayta o'qiladi
        if (!ok && value) {
          // Qurilmada biometrika yo'q yoki tasdiq bekor qilindi.
          context.showSnack(l10n.error, isError: true);
        }
      },
    );
  }
}
