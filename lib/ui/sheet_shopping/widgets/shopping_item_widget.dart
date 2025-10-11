import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../domain/dto/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/helpers/icon_maps.dart';
import 'item_tooltip.dart';

class ShoppingItemWidget extends StatefulWidget {
  final Item item;
  final ItemSheet? itemSheet;
  const ShoppingItemWidget({super.key, required this.item, this.itemSheet});

  @override
  State<ShoppingItemWidget> createState() => ShoppingItemWidgetState();
}

class ShoppingItemWidgetState extends State<ShoppingItemWidget> {
  OverlayEntry? _overlayEntry;
  Offset? _mousePosition;

  bool _hoveringMain = false;
  bool _hoveringTooltip = false;

  @override
  Widget build(BuildContext context) {
    return Draggable<Item>(
      feedback: Material(child: _buildBody(context)),
      maxSimultaneousDrags: (widget.itemSheet == null) ? null : 0,
      data: widget.item,
      child: MouseRegion(
        onEnter: (PointerEnterEvent event) {
          _hoveringMain = true;
          _mousePosition = event.position;
          _showTooltip();
        },
        onExit: (PointerExitEvent event) {
          _hoveringMain = false;
          delayedHideCheck();
        },
        child: _buildBody(context),
      ),
    );
  }

  Container _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
      ),
      child: Stack(
        children: [
          if (widget.itemSheet == null)
            Align(
              alignment: Alignment.topRight,
              child: Opacity(
                opacity: 0.65,
                child: Text(
                  "\$${widget.item.price}",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          Align(alignment: Alignment(0, -0.3), child: _resolveIcon()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              (widget.itemSheet != null)
                  ? "${widget.item.name} (x${widget.itemSheet!.amount})"
                  : widget.item.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resolveIcon() {
    double size = 40;
    switch (widget.item.iconType) {
      case ItemIconType.icons:
        return Icon(flutterIconMap[widget.item.icon!]);
      case ItemIconType.materialDesignIcons:
        return Icon(MdiIcons.fromString(widget.item.icon!), size: size);
      case ItemIconType.fontAwesome:
        return FaIcon(fontAwesomeIconMap[widget.item.icon!]);
      case null:
        return Icon(MdiIcons.treasureChestOutline, size: size);
    }
  }

  void _showTooltip() {
    if (_overlayEntry != null || _mousePosition == null) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final overlaySize = overlay.size;

    const tooltipWidth = 400.0;
    const tooltipHeight = 250.0;
    const margin = 8.0;

    final pointer = _mousePosition!;
    double left = pointer.dx + margin;
    double top = pointer.dy + margin;

    // Verifica se o tooltip extrapola a largura da tela
    if (left + tooltipWidth > overlaySize.width - margin) {
      left = pointer.dx - tooltipWidth - margin;
    }
    if (left < margin) left = margin;

    // Verifica se o tooltip extrapola a altura da tela
    if (top + tooltipHeight > overlaySize.height - margin) {
      top = pointer.dy - tooltipHeight - margin;
    }
    if (top < margin) top = margin;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        width: tooltipWidth,
        child: Material(
          color: Colors.transparent,
          child: ItemTooltip(
            item: widget.item,
            itemSheet: widget.itemSheet,
            onEnter: () {
              _hoveringTooltip = true;
            },
            onExit: () {
              _hoveringTooltip = false;
              delayedHideCheck();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void delayedHideCheck() {
    Future.delayed(Duration(milliseconds: 25)).then((_) {
      if (!_hoveringMain && !_hoveringTooltip) {
        _hideTooltip();
      }
    });
  }
}
