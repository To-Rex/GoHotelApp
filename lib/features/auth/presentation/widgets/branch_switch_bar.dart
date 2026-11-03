import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../data/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import 'branch_switch_sheet.dart';

/// Filiallar qatori — administrator bosh sahifasida, app bar ostida.
///
/// Filiallar to'liq ajratilgan, shuning uchun "qaysi filialdaman" doim
/// ko'rinib turishi va almashtirish bir qadam bo'lishi kerak. Qator
/// mehmonxonaning barcha filiallarini segment ko'rinishida beradi: joriy
/// filial to'ldirilgan (brend rang, belgi bilan), qolganlari och — bosilsa
/// darhol o'sha filialga o'tiladi (`AuthCubit.switchBranch`: yangi
/// tokenlar, `/auth/me`, qobiq qayta quriladi). Almashish paytida bosilgan
/// segmentda aylanuvchi, qator bloklanadi; xato — snackbar, holat o'zgarmaydi.
///
/// Joriy filial bosilsa batafsil oyna ([showBranchSwitchSheet]) ochiladi —
/// kod, asosiy filial belgisi va to'liq ro'yxat o'sha yerda. Ro'yxat
/// yuklanmaguncha yoki yuklanmasa qatorda faqat joriy filial turadi, uni
/// bosib o'sha oynadan tanlash mumkin — hech qachon "bo'sh" qolmaydi.
///
/// Ro'yxat sessiya davomida mehmonxona bo'yicha bir marta so'raladi
/// (filial almashganda qobiq qayta quriladi, filiallar esa o'zgarmaydi).
class BranchSwitchBar extends StatefulWidget implements PreferredSizeWidget {
  const BranchSwitchBar({super.key});

  static const double height = 52;

  /// Sessiya keshi: mehmonxona → filiallar.
  static final Map<String, List<BranchOption>> _cache = {};

  @visibleForTesting
  static void clearCache() => _cache.clear();

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  State<BranchSwitchBar> createState() => _BranchSwitchBarState();
}

class _BranchSwitchBarState extends State<BranchSwitchBar> {
  List<BranchOption>? _options;
  String? _busy;
  final _keys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthCubit>();
    final hotelId = auth.state.user?.hotelId ?? '';
    final cached = BranchSwitchBar._cache[hotelId];
    if (cached != null) {
      _options = cached;
      _revealCurrent();
      return;
    }
    try {
      final options = await auth.repository.branchOptions(hotelId);
      BranchSwitchBar._cache[hotelId] = options;
      if (!mounted) return;
      setState(() => _options = options);
      _revealCurrent();
    } catch (_) {
      // Ro'yxat kelmadi — joriy filial chipi qoladi, oynadan tanlash mumkin
    }
  }

  /// Joriy filial ekrandan tashqarida qolmasin (ko'p filialda qator uzun).
  void _revealCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = context.read<AuthCubit>().state.user?.branchId;
      final key = _keys[current];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
        );
      }
    });
  }

  Future<void> _choose(BranchOption branch) async {
    if (_busy != null) return;
    final auth = context.read<AuthCubit>();
    if (branch.id == auth.state.user?.branchId) {
      await showBranchSwitchSheet(context);
      return;
    }
    setState(() => _busy = branch.id);
    final error = await auth.switchBranch(branch.id);
    if (!mounted) return;
    setState(() => _busy = null);
    if (error != null) context.showSnack(error, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit a) => a.state.user);
    final currentId = user?.branchId;
    // Ro'yxat bo'lmasa — faqat joriy filial
    final options = _options ??
        [
          if (currentId != null && (user?.branchName ?? '').isNotEmpty)
            BranchOption(id: currentId, name: user!.branchName!),
        ];
    if (options.isEmpty) return const SizedBox(height: BranchSwitchBar.height);

    return SizedBox(
      height: BranchSwitchBar.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final branch = options[i];
          return _BranchSegment(
            key: _keys.putIfAbsent(branch.id, GlobalKey.new),
            branch: branch,
            selected: branch.id == currentId,
            busy: _busy == branch.id,
            enabled: _busy == null,
            onTap: () => _choose(branch),
          );
        },
      ),
    );
  }
}

class _BranchSegment extends StatelessWidget {
  const _BranchSegment({
    super.key,
    required this.branch,
    required this.selected,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final BranchOption branch;
  final bool selected;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final fg = selected ? Colors.white : c.text;
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '${branch.name} · ${l10n.branchCurrent}' : branch.name,
      // Ichidagi matn alohida tugun bo'lmasin — bitta tugma, bitta nom
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? c.brand : c.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? c.brand : c.outline),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: c.brand.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (busy)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fg,
                      ),
                    )
                  else
                    Icon(
                      selected
                          ? CupertinoIcons.checkmark_alt
                          : CupertinoIcons.building_2_fill,
                      size: 14,
                      color: selected ? Colors.white : c.textMuted,
                    ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      branch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelLarge!.copyWith(
                        color: fg,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
