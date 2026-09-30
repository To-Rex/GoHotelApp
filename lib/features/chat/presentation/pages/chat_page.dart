import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/datetime_x.dart';
import '../../../../core/widgets/camera_capture_page.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/image_viewer_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/staff_message.dart';
import '../cubit/chat_cubit.dart';

/// Resepshn (va barcha xodimlar) bilan chat.
///
/// Xabarlar umumiy taxtada: farrosh so'rov yozadi, resepshn ko'radi, kimdir
/// bajarsa "Bajarildi" belgilanadi. Rasm ham yuborish mumkin.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await context.read<ChatCubit>().send(text);
  }

  Future<void> _sendImage() async {
    final cubit = context.read<ChatCubit>();
    final l10n = context.l10n;
    if (cubit.state.uploadDenied) {
      context.showSnack(l10n.uploadImageDenied, isError: true);
      return;
    }
    // Manba tanlash: kamera yoki galereya.
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => GlassSheet(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.attachPhoto,
                  style: sheetContext.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(sheetContext).pop(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.faceOpenCamera),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(sheetContext).pop(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.addPhoto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    // Kamera — ilova ichidagi tezkor kamera; galereya — tizim tanlagichi.
    final String? path;
    if (source == ImageSource.camera) {
      path = await CameraCapturePage.openSingle(context);
    } else {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      path = photo?.path;
    }
    if (path == null || !mounted) return;
    await cubit.sendImage(path, l10n.imageMessageBody);
    // Xato bo'lsa yuqoridagi BlocListener o'zi aytadi.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myId = context.select((AuthCubit cubit) => cubit.state.user?.id);
    final barPadding = MediaQuery.paddingOf(context);

    return BlocListener<ChatCubit, ChatState>(
      // Yuborish xatosini darhol aytamiz — xabar "jimgina yo'qolib" qolmasin.
      listenWhen: (a, b) => b.error != null && a.error != b.error,
      listener: (context, state) {
        if (state.uploadDenied) {
          context.showSnack(l10n.uploadImageDenied, isError: true);
        } else {
          context.showSnack(
            friendlyError(context, state.error!),
            isError: true,
          );
        }
      },
      // Sarlavha va yangilash tugmasi shell'dagi umumiy appbar'da.
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                Widget centered(Widget child) => Padding(
                  padding: EdgeInsets.only(top: barPadding.top),
                  child: child,
                );
                if (state.loading && state.messages.isEmpty) {
                  return centered(
                    const Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.error != null && state.messages.isEmpty) {
                  return centered(
                    ErrorState(
                      error: state.error!,
                      onRetry: () => context.read<ChatCubit>().load(),
                    ),
                  );
                }
                if (state.messages.isEmpty) {
                  return centered(
                    EmptyState(
                      icon: Icons.chat_bubble_rounded,
                      title: l10n.noMessagesTitle,
                      body: l10n.noMessagesBody,
                    ),
                  );
                }
                final reversed = state.messages.reversed.toList();
                return ListView.builder(
                  reverse: true,
                  // reverse ro'yxatda: top — vizual yuqori (shisha appbar
                  // tagidan chiqish joyi), bottom — input yaqinidagi bo'shliq.
                  padding: EdgeInsets.fromLTRB(16, barPadding.top + 8, 16, 8),
                  itemCount: reversed.length,
                  itemBuilder: (context, index) {
                    final message = reversed[index];
                    return _MessageBubble(
                      message: message,
                      isMine: message.createdBy == myId,
                      attachments: state.attachments[message.id] ?? const [],
                    );
                  },
                );
              },
            ),
          ),
          /* Klaviatura ochiq bo'lsa input to'g'ridan-to'g'ri uning ustida
             turadi, yopiq bo'lsa — shisha tab-bar ustida. Inset Builder
             ICHIDA o'qiladi: klaviatura animatsiyasining har kadrida
             (Android'da ~15 kadr) butun sahifa va barcha xabar pufakchalari
             emas, faqat shu padding qayta chiziladi. */
          Builder(
            builder: (context) {
              final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: keyboardOpen ? 0 : barPadding.bottom,
                ),
                child: _InputBar(
                  controller: _input,
                  onSend: _send,
                  onAttach: _sendImage,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.attachments,
  });

  final StaffMessage message;
  final bool isMine;
  final List<MessageAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final cubit = context.read<ChatCubit>();

    // iMessage uslubi: meniki — ko'k, boshqalarniki — kulrang pufakcha.
    final isDark = context.isDark;
    final bubbleColor = isMine
        ? c.brand
        : (isDark ? c.surfaceAlt : const Color(0xFFE9E9EB));
    final textColor = isMine ? Colors.white : c.text;
    final mutedColor = isMine ? Colors.white70 : c.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: message.isOpen
                  ? () async {
                      final ok = await showConfirmSheet(
                        context,
                        title: l10n.markDone,
                        body: message.body,
                        confirmLabel: l10n.done,
                        icon: Icons.task_alt_rounded,
                      );
                      if (ok) cubit.markDone(message.id);
                    }
                  : null,
              child: Container(
                constraints: BoxConstraints(
                  // sizeOf — faqat o'lchamga obuna: MediaQuery.of pufakchani
                  // klaviatura inset'larining har kadrida ham qayta chizardi
                  maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 6),
                    bottomRight: Radius.circular(isMine ? 6 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMine)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          message.createdByName,
                          style: context.textStyles.labelMedium!.copyWith(
                            color: c.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    for (final attachment in attachments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 2),
                        child: GestureDetector(
                          onTap: () => ImageViewerPage.open(
                            context,
                            imageUrl: cubit.imageUrl(attachment.fileId),
                            headers: cubit.imageHeaders(),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: cubit.imageUrl(attachment.fileId),
                              httpHeaders: cubit.imageHeaders(),
                              width: 220,
                              // Eskiz uchun to'liq surat dekodlanmasin —
                              // to'lig'i bosilganda ochiladi
                              memCacheWidth:
                                  (220 *
                                          MediaQuery.devicePixelRatioOf(
                                            context,
                                          ))
                                      .round(),
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                width: 220,
                                height: 160,
                                color: c.surfaceAlt,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                width: 220,
                                height: 100,
                                color: c.surfaceAlt,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      message.body,
                      style: context.textStyles.bodyLarge!.copyWith(
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.roomNumber != null) ...[
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 14,
                            color: mutedColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            l10n.roomTitle(message.roomNumber!),
                            style: context.textStyles.labelSmall!.copyWith(
                              color: mutedColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (message.createdAt != null)
                          Text(
                            message.createdAt!.hhmm,
                            style: context.textStyles.labelSmall!.copyWith(
                              color: mutedColor,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (message.isOpen)
                          Text(
                            l10n.openBadge,
                            style: context.textStyles.labelSmall!.copyWith(
                              color: isMine ? Colors.white : c.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: isMine ? Colors.white : c.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                message.doneByName == null
                                    ? l10n.done
                                    : l10n.doneByName(message.doneByName!),
                                style: context.textStyles.labelSmall!.copyWith(
                                  color: isMine ? Colors.white : c.success,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final sending = context.select((ChatCubit cubit) => cubit.state.sending);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.outline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: sending ? null : onAttach,
            icon: const Icon(Icons.photo_camera_outlined, size: 28),
            tooltip: l10n.attachPhoto,
            color: c.textMuted,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.messageHint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 50,
            child: FilledButton(
              onPressed: sending ? null : onSend,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 50),
                shape: const CircleBorder(),
              ),
              child: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.arrow_up, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
