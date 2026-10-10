import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Renders the supplied Streamline SVG set through the same API shape as
/// Flutter's [Icon]. Existing screens can therefore share one semantic icon
/// system without loading oversized raster artwork or swapping meanings.
class AppIcon extends StatelessWidget {
  final Object icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  static const _root = 'assets/icons/';

  static String _asset(String name) => '$_root$name--Streamline-Core.svg';

  static ({String path, int quarterTurns})? _resolve(Object value) {
    String asset(String name) => _asset(name);
    final path = switch (value) {
      PhosphorIcons.filePlus => '$_root/document-new-svgrepo-com.svg',
      PhosphorIcons.filePdf ||
      PhosphorIcons.filePdfDuotone =>
        '$_root/pdf-svgrepo-com.svg',
      PhosphorIcons.arrowLeftDuotone => asset('Next'),
      PhosphorIcons.arrowRight || PhosphorIcons.caretRight => asset('Next'),
      PhosphorIcons.arrowClockwise ||
      PhosphorIcons.arrowsClockwise =>
        asset('Cloud-Refresh'),
      PhosphorIcons.arrowCounterClockwise => asset('Undo'),
      PhosphorIcons.arrowsLeftRight => asset('One-Finger-Drag-Horizontal'),
      PhosphorIcons.article ||
      PhosphorIcons.fileText ||
      PhosphorIcons.fileTextDuotone =>
        asset('App Manual-Book'),
      PhosphorIcons.at => asset('User-Identifier-Card'),
      PhosphorIcons.bellRinging => asset('Ringing-Bell-Notification'),
      PhosphorIcons.bookOpen => asset('Open-Book'),
      PhosphorIcons.bookmarkSimple ||
      PhosphorIcons.bookmarkSimpleDuotone ||
      PhosphorIcons.bookmarksSimpleDuotone =>
        asset('Bookmark'),
      PhosphorIcons.camera || PhosphorIcons.cameraDuotone => asset('Camera-1'),
      PhosphorIcons.cameraSlash => asset('Camera-1'),
      PhosphorIcons.chartBar ||
      PhosphorIcons.chartBarDuotone =>
        asset('Graph-Bar-Increase'),
      PhosphorIcons.checkCircle || PhosphorIcons.circle => asset('Check'),
      PhosphorIcons.clock ||
      PhosphorIcons.clockCounterClockwiseDuotone =>
        asset('Circle-Clock'),
      PhosphorIcons.cloudSlash => asset('Wifi-Disabled'),
      PhosphorIcons.copy => asset('Copy-'),
      PhosphorIcons.crop => asset('Crop-Selection'),
      PhosphorIcons.crown || PhosphorIcons.trophy => asset('Crown'),
      PhosphorIcons.cubeDuotone => asset('Scanner'),
      PhosphorIcons.deviceMobile => asset('User-Identifier-Card'),
      PhosphorIcons.envelopeOpen => asset('Receipt-Check'),
      PhosphorIcons.eye || PhosphorIcons.eyeDuotone => asset('Eye'),
      PhosphorIcons.eyeSlash => asset('hide-1'),
      PhosphorIcons.flagDuotone => asset('Bookmark'),
      PhosphorIcons.floppyDiskDuotone => asset('Floppy-Disk'),
      PhosphorIcons.gear => asset('Cog'),
      PhosphorIcons.headset => asset('Customer-Support-1'),
      PhosphorIcons.hourglass => asset('Circle-Clock'),
      PhosphorIcons.house => asset('Home-3'),
      PhosphorIcons.identificationBadge ||
      PhosphorIcons.personSimple =>
        asset('User-Identifier-Card'),
      PhosphorIcons.imageBroken ||
      PhosphorIcons.imagesDuotone =>
        asset('Multiple-image-2'),
      PhosphorIcons.info ||
      PhosphorIcons.question =>
        asset('Chat-Bubble-Square-Question'),
      PhosphorIcons.keyDuotone || PhosphorIcons.password => asset('Key'),
      PhosphorIcons.lock ||
      PhosphorIcons.lockKeyOpen =>
        asset('Padlock-Square-1'),
      PhosphorIcons.magicWand ||
      PhosphorIcons.magicWandDuotone ||
      PhosphorIcons.rocketLaunch ||
      PhosphorIcons.sparkle =>
        asset('Artificial-Intelligence-Spark'),
      PhosphorIcons.minusCircle ||
      PhosphorIcons.minusCircleDuotone =>
        asset('Minus-Circle'),
      PhosphorIcons.notePencil ||
      PhosphorIcons.pencilSimple ||
      PhosphorIcons.pencilSimpleDuotone =>
        asset('Edit-Image-Photo'),
      PhosphorIcons.plusCircle ||
      PhosphorIcons.plusCircleDuotone =>
        asset('Plus-Circle'),
      PhosphorIcons.printerDuotone => asset('Printer'),
      PhosphorIcons.qrCode || PhosphorIcons.qrCodeDuotone => asset('Qr-Code'),
      PhosphorIcons.receipt ||
      PhosphorIcons.sealCheck =>
        asset('Receipt-Check'),
      PhosphorIcons.scan || PhosphorIcons.scanDuotone => asset('OMR'),
      PhosphorIcons.shareDuotone => asset('Share-Link'),
      PhosphorIcons.shield || PhosphorIcons.shieldCheck => asset('Shield-2'),
      PhosphorIcons.signIn => asset('Login-1'),
      PhosphorIcons.signOut => asset('Logout-1'),
      PhosphorIcons.table || PhosphorIcons.textT => asset('App Manual-Book'),
      PhosphorIcons.trash || PhosphorIcons.trashDuotone => asset('Delete-2'),
      PhosphorIcons.user ||
      PhosphorIcons.userDuotone =>
        asset('User-Circle-Single'),
      PhosphorIcons.userPlus => asset('Add-Square'),
      PhosphorIcons.usersThreeDuotone => asset('User-Multiple-Group'),
      PhosphorIcons.wallet => asset('Shopping-Cart-1'),
      PhosphorIcons.warning ||
      PhosphorIcons.warningCircle =>
        asset('Warning-Triangle'),
      PhosphorIcons.wifiHigh => asset('Wifi'),
      PhosphorIcons.wrench => asset('Wrench'),
      PhosphorIcons.x || PhosphorIcons.xDuotone => asset('Close-1'),
      _ => null,
    };
    if (path == null) return null;
    return (
      path: path,
      quarterTurns: value == PhosphorIcons.arrowLeftDuotone ? 2 : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolve(icon);
    final effectiveSize = size ?? IconTheme.of(context).size ?? 24;
    final effectiveColor = color ?? IconTheme.of(context).color;
    if (resolved == null) {
      return PhosphorIcon(icon, size: effectiveSize, color: effectiveColor);
    }
    final svg = SvgPicture.asset(
      resolved.path,
      width: effectiveSize,
      height: effectiveSize,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      colorFilter: effectiveColor == null
          ? null
          : ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
    return resolved.quarterTurns == 0
        ? svg
        : RotatedBox(quarterTurns: resolved.quarterTurns, child: svg);
  }
}

/// Compatibility wrapper retained for call sites that previously requested a
/// Phosphor duotone icon. The supplied set is intentionally one-colour.
class AppDuotoneIcon extends StatelessWidget {
  final Object icon;
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final double secondaryOpacity;
  final String? semanticLabel;

  const AppDuotoneIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.secondaryColor,
    this.secondaryOpacity = .34,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) =>
      AppIcon(icon, size: size, color: color, semanticLabel: semanticLabel);
}
