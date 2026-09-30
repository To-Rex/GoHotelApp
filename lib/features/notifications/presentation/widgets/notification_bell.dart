import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/notifications_cubit.dart';
import '../pages/notifications_page.dart';

/// Qo'ng'iroqcha + o'qilmaganlar soni — iOS toolbar ikonkasi uslubida.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unread = context.select(
      (NotificationsCubit cubit) => cubit.state.unreadCount,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => NotificationsPage.open(context),
          icon: Icon(CupertinoIcons.bell, size: 26, color: c.text),
        ),
        if (unread > 0)
          Positioned(
            top: 4,
            right: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: c.danger,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: c.background, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 19),
                alignment: Alignment.center,
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
