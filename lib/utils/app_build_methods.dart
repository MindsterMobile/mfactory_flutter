
import 'package:flutter/foundation.dart';

import 'extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget buildCachedNetworkImage(
  String? url, {
  double? height,
  BoxFit fit = BoxFit.cover,
  BoxFit? placeholderFit,
  double? width,
  EdgeInsets placeholderPadding = EdgeInsets.zero,
}) {
  placeholderFit ??= fit;
  return CachedNetworkImage(
    imageUrl: url ?? "",
    height: height,
    width: width,
    fit: fit,
    placeholder: (context, url) => Padding(
      padding: placeholderPadding,
      // child: SvgPicture.asset(
      //   'place_holder'.asAssetSvg(),
      //   fit: placeholderFit!,
      // ),
      child: const SizedBox(),
    ),
    errorWidget: (
      context,
      url,
      error,
    ) =>
        Padding(
      padding: placeholderPadding,
      child: Image.asset('lock_image.png'.asAssetImg()),
    ),
  );
}

double rssiTosignalStrength([double rssi = 0.0]) {
  double minRssi = -100; // Reference RSSI value for minimum signal strength
  double maxRssi = 0; // Reference RSSI value for maximum signal strength
  double minSignalStrength = 0; // Minimum signal strength value
  double maxSignalStrength = 1; // Maximum signal strength value

  double signalStrength = ((rssi - minRssi) *
          (maxSignalStrength - minSignalStrength) /
          (maxRssi - minRssi)) +
      minSignalStrength;

  return (signalStrength); // Output: 0.78
}

showToast(String msg,
    {ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize}) {
  if (msg.trim().isEmpty) return;
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: gravity ?? ToastGravity.BOTTOM,
    backgroundColor: backgroundColor ?? const Color(0xE6212121),
    textColor: textColor ?? Colors.white,
    fontSize: fontSize ?? 14.0,
  );
}

printApiResponse(object, {String? head = "Head"}) {
  String coloredHead = '\x1B[32m $head \x1B[0m \x1B[31m ->>>> \x1B[0m';
  if (kDebugMode) {
    debugPrint("$coloredHead"
        "${'\x1B[32m $object \x1B[0m'}");
  }

 
}
