import 'package:criteria/chips/chip_controllers.dart';
import 'package:flutter/material.dart';
import 'package:toolbox/toolbox.dart';

class ChipDecorator extends StatelessWidget {
  const ChipDecorator({
    required this.controller,
    required this.child,
    this.actionButtons,
    this.onTap,
    super.key,
  });

  final ChipItemController controller;
  final Widget child;
  final Widget? actionButtons;
  final VoidCallback? onTap;

  static const double _iconSize = 20;

  Widget get _deleteIcon => const Tooltip(
    message: "Supprimer",
    child: Icon(Icons.recycling, color: Colors.orange, size: _iconSize),
  );

  Widget get _eraseIcon => const Tooltip(
    message: "Effacer",
    child: Icon(Icons.recycling, color: Colors.grey, size: _iconSize),
  );

  @override
  Widget build(BuildContext context) {
    final Widget? effectiveActionButtons =
        actionButtons ?? _buildDefaultActionButtons(context);

    double? currentWidth = controller.updating
        ? (controller.editingWidth ??
              controller.chipWidth ??
              controller.recordedWidth)
        : controller.chipWidth;

    Widget chipContent = InkWell(
      //borderRadius: BorderRadius.circular(8.0),
      onTap: controller.disable ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar/icône
          if (!controller.hideAvatar && controller.avatar != null)
            Tooltip(
              message: controller.comments ?? '',
              child: controller.avatar,
            ),
          const SizedBox(width: 2),
          if (controller.chipType == ChipType.boolean)
            Text(controller.label, style: controller.labelStyle),

          // Contenu principal
          if (controller.chipType == ChipType.boolean && controller.expandable)
            const Expanded(child: SizedBox.shrink()),

          if ((controller.expandable ||
                  currentWidth != null ||
                  controller.updating) &&
              controller.chipType != ChipType.boolean)
            Expanded(child: child)
          else
            child,
          const SizedBox(width: 2),
          if (effectiveActionButtons != null) effectiveActionButtons,
          if (effectiveActionButtons == null) const SizedBox(width: 10),
        ],
      ),
    );

    if (controller.removeBorder) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Opacity(
          opacity: controller.disable ? 0.5 : 1.0,
          child: SizedBox(
            width: currentWidth,
            height: controller.chipHeight,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: chipContent,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Opacity(
        opacity: controller.disable ? 0.5 : 1.0,
        child: SizedBox(
          width: currentWidth,
          height: controller.chipHeight,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: TitleBorderBox(
              title:
                  ((controller.updating || controller.hasValue()) &&
                          !controller.hideLabelIfNotEmpty) &&
                      (controller.chipType != ChipType.boolean)
                  ? controller.label
                  : null,
              titleStyle: controller.labelStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.only(left: 4),
              backgroundColor: controller.disable
                  ? Colors.grey.shade300
                  : controller.backgroundColor,
              borderColor: controller.hasError
                  ? Colors.red
                  : Colors.grey.shade700,
              child: chipContent,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildDefaultActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    if (controller.onPopupPressed != null) {
      buttons.add(
        IconButton(
          tooltip: controller.tooltipMessagePopup,
          icon: controller.popupIcon,
          onPressed: controller.disable
              ? null
              : () {
                  controller.onPopupPressed?.call(context);
                },
        ),
      );
    }
    Widget? tmp = _tailIcons(
      controller,
      onErase: controller.disable
          ? null
          : () {
              controller.clean();
              controller.focusNode?.requestFocus();
            },
      onDelete: controller.disable
          ? null
          : () {
              controller.remove();
            },
    );
    if (tmp != null) {
      buttons.add(tmp);
    }

    return buttons.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  Widget? _tailIcons(
    ChipItemController controller, {
    Function()? onErase,
    Function()? onDelete,
  }) {
    if (onErase == null || onDelete == null) {
      if (controller.hasValue()) {
        return _eraseIcon;
      } else {
        if (!controller.alwaysDisplayed) {
          return _deleteIcon;
        } else {
          return const SizedBox(width: _iconSize, height: _iconSize);
        }
      }
    }
    if (controller.hasValue()) {
      if (controller.displayEraseButton) {
        return IconButton(
          padding: const EdgeInsets.all(4),
          icon: _eraseIcon,
          tooltip: controller.tooltipMessageErase,
          onPressed: onErase,
          constraints: const BoxConstraints(),
        );
      }
    } else {
      if (!controller.alwaysDisplayed && controller.displayRemoveButton) {
        return IconButton(
          padding: const EdgeInsets.all(4),
          icon: _deleteIcon,
          tooltip: controller.tooltipMessageRemove,
          onPressed: onDelete,
          constraints: const BoxConstraints(),
        );
      }
    }
    return null;
  }
}
