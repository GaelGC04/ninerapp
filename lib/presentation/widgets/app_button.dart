import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';

class AppButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final IconData? icon;
  final bool coloredBorder;
  final bool isLocked;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.text,
    required this.icon,
    required this.coloredBorder,
    this.isLocked = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isLocked = false;

  @override
  Widget build(BuildContext context) {
    _isLocked = widget.isLocked;
    Color backgroundColor = _isLocked
      ? HSLColor.fromColor(widget.backgroundColor).withSaturation(0.1).withLightness(0.6).toColor()
      : widget.backgroundColor;

    return ElevatedButton(
      onPressed: _isLocked ? (){} : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.coloredBorder ? widget.textColor : backgroundColor,
        shape: RoundedRectangleBorder(
          side: widget.coloredBorder ? BorderSide(color: backgroundColor, width: 2.5) : BorderSide(color: AppColors.invisible),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: _isLocked ? 0 : 3,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.text,
                style: TextStyle(color: widget.coloredBorder ? backgroundColor : widget.textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,softWrap: true,
                textAlign: TextAlign.center
              ),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: 15),
              Icon(widget.icon, size: 16, color: widget.coloredBorder ? backgroundColor : widget.textColor),
            ],
          ],
        ),
      ),
    );
  }

  void changeStateButton(bool isLocked) {
    setState(() {
      _isLocked = isLocked;
    });
  }
}