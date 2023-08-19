import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/popup_helper.dart';

class ProfilePictureWidget extends StatefulWidget {
  final String photoUrl;
  final double size;
  final bool showError;

  const ProfilePictureWidget(
      {super.key,
      required this.photoUrl,
      required this.size,
      this.showError = false});

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  final curveDuration = const Duration(milliseconds: 500);

  Widget retryButton() {
    return IconButton(
        onPressed: () {
          setState(() {});
        },
        icon: const Icon(Icons.refresh));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: widget.photoUrl.isEmpty
            ? Icon(Icons.person, size: widget.size, color: Colors.grey)
            : CachedNetworkImage(
                fit: BoxFit.cover,
                fadeInCurve: Curves.easeIn,
                fadeOutCurve: Curves.easeOut,
                fadeOutDuration: curveDuration,
                fadeInDuration: curveDuration,
                imageUrl: widget.photoUrl,
                progressIndicatorBuilder: (context, child, loadingProgress) {
                  return Center(
                      child: CircularProgressIndicator(
                          value: loadingProgress.totalSize != null
                              ? loadingProgress.downloaded /
                                  loadingProgress.totalSize!
                              : null));
                },
                errorWidget: (context, error, stackTrace) {
                  if (widget.showError) {
                    PopupHelper.showSnackBar(
                        message:
                            //TODO localization
                            "Profil fotoğrafı yüklenirken hata oluştu",
                        error: true);
                  }
                  return retryButton();
                }),
      ),
    );
  }
}
