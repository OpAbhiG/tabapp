// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

Widget customAvatarBuilder(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
    ) {
  return CachedNetworkImage(
    imageUrl: 'https://robohash.org/${user?.id}.png',
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress, color: Color(0xFF243B6D),),
    errorWidget: (context, url, error) {
      // Log the error or user information as needed
      ZegoLoggerService.logInfo('Error loading avatar for user: ${user?.id}');

      // Return a fallback widget, such as a default avatar
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.error, color: Colors.white),
      );
    },
  );
}
