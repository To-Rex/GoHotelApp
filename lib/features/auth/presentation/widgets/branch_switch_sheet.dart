import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/glass.dart';
import '../../data/auth_repository.dart';
import '../cubit/auth_cubit.dart';

/// Administrator: o'z mehmonxonasining filialini tanlash.
///
/// Filiallar to'liq ajratilgan — xonalar, mehmonlar, bronlar, kassa,
/// hisobotlar va sozlamalar har filialniki. Boshqa filial ma'lumotini
/// administrator shu yerda o'sha filialni tanlab ko'radi; tanlangach ilova
/// qobig'i yangi filial bilan qayta quriladi.
Future<void> showBranchSwitchSheet(BuildContext context) {
  final auth = context.read<AuthCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: auth,
      child: const GlassSheet(child: _BranchSwitchBody()),
    ),
  );
}

class _BranchSwitchBody extends StatefulWidget {
  const _BranchSwitchBody();

  @override
  State<_BranchSwitchBody> createState() => _BranchSwitchBodyState();
}

class _BranchSwitchBodyState extends State<_BranchSwitchBody> {
  late Future<List<BranchOption>> _options;
  String? _busy;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthCubit>();
    _options = auth.repository.branchOptions(auth.state.user?.hotelId ?? '');
  }

  Future<void> _choose(BranchOption branch) async {
    final auth = context.read<AuthCubit>();
    if (_busy != null || branch.id == auth.state.user?.branchId) return;
    setState(() => _busy = branch.id);
    final error = await auth.switchBranch(branch.id);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _busy = null);
    context.showSnack(error, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final current = context.select((AuthCubit a) => a.state.user?.branchId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.branchSwitchTitle,
              style: context.textStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.branchSwitchHint,
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall!.copyWith(
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<BranchOption>>(
              future: _options,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      error is ApiException ? error.message : l10n.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.danger),
                    ),
                  );
                }
                final branches = snapshot.data ?? const [];
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: branches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final branch = branches[i];
                      return _BranchTile(
                        branch: branch,
                        selected: branch.id == current,
                        busy: _busy == branch.id,
                        onTap: () => _choose(branch),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({
    required this.branch,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  final BranchOption branch;
  final bool selected;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final details = [
      if ((branch.code ?? '').isNotEmpty) branch.code!,
      if (branch.isMain) l10n.branchMain,
    ].join(' · ');
    return Material(
      color: selected ? c.brandSoft : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? c.brand : c.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              // Bino belgisi — yumshoq fonli kvadratda (tanlanganida brend)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? c.brand : c.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.building_2_fill,
                  size: 20,
                  color: selected ? Colors.white : c.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: context.textStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        style: context.textStyles.labelSmall!.copyWith(
                          color: c.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (selected)
                // "Hozirgi" belgisi — qaysi filialda turganini aniq ko'rsatadi
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: c.brand,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_alt,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.branchCurrent,
                        style: context.textStyles.labelSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(CupertinoIcons.chevron_right, size: 16, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
