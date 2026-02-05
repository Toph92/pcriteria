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

  /*@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Opacity(
        opacity: controller.disable ? 0.5 : 1.0,
        child: IntrinsicWidth(
          child: Container(
            color: Colors.amber,
            // We keep the constraints from ChipText as a baseline.
            // If other chips need different constraints, we might need to parameterize this.
            // But ChipText had minWidth 100, maxWidth 200.
            // Let's see if we can make it flexible.
            // For now, I will use the same constraints as ChipText because the user wants "Comme ChipText".
            height: chipHeightSize,
            /*constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 800,
              //minHeight: 52,
            ),*/
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText:
                      (controller.updating || controller.hasValue()) &&
                          !controller.hideLabelIfNotEmpty
                      ? controller.label
                      : null,
                  labelStyle: controller.labelStyle,
                  enabled: !controller.disable,
                  filled: true,
                  fillColor: controller.disable
                      ? Colors.grey.shade300
                      : controller.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  isDense: true,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
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

                      // Contenu principal
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 6),
                        child: SizedBox(
                          height: double.infinity,
                          child: Center(child: child),
                        ),
                      ),
                      const SizedBox(width: 2),
                      if (actionButtons != null) actionButtons!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  */
  @override
  Widget build(BuildContext context) {
    final Widget? effectiveActionButtons =
        actionButtons ?? _buildDefaultActionButtons(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Opacity(
        opacity: controller.disable ? 0.5 : 1.0,
        child: SizedBox(
          height: chipHeightSize,
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

              //borderColor: Colors.grey,

              /* decoration: InputDecoration(
                labelText:
                    (controller.updating || controller.hasValue()) &&
                        !controller.hideLabelIfNotEmpty
                    ? controller.label
                    : null,
                labelStyle: controller.labelStyle,
                enabled: !controller.disable,
                filled: true,
                fillColor: controller.disable
                    ? Colors.grey.shade300
                    : controller.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                isDense: true,
              ),*/
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
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
                    child,
                    const SizedBox(width: 2),
                    if (effectiveActionButtons != null) effectiveActionButtons,
                    if (effectiveActionButtons == null)
                      const SizedBox(width: 10),
                  ],
                ),
              ),
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
