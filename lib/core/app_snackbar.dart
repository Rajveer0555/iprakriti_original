import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

enum AppSnackBarTone { success, error, warning, info }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarTone tone = AppSnackBarTone.info,
  String? title,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final config = _snackBarConfig(tone);
  messenger.showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? config.title,
        message: message,
        contentType: config.contentType,
        color: config.color,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        messageTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    ),
  );
}

({String title, ContentType contentType, Color color}) _snackBarConfig(
  AppSnackBarTone tone,
) {
  switch (tone) {
    case AppSnackBarTone.success:
      return (
        title: 'Success',
        contentType: ContentType.success,
        color: AppColors.primary,
      );
    case AppSnackBarTone.error:
      return (
        title: 'Something went wrong',
        contentType: ContentType.failure,
        color: AppColors.error,
      );
    case AppSnackBarTone.warning:
      return (
        title: 'Heads up',
        contentType: ContentType.warning,
        color: const Color(0xFFC68A12),
      );
    case AppSnackBarTone.info:
      return (
        title: 'Notice',
        contentType: ContentType.help,
        color: AppColors.primaryDark,
      );
  }
}
