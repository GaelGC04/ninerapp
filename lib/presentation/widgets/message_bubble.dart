import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const MessageBubble({
    super.key, 
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isSender ? AppColors.currentSectionColor : AppColors.lightGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isSender ? const Radius.circular(15) : const Radius.circular(5),
            bottomRight: isSender ? const Radius.circular(5) : const Radius.circular(15),
          ),
        ),
        child: Text(
          message,
          style: AppTextstyles.bodyText.copyWith(
            color: isSender ? AppColors.white : AppColors.fontColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
