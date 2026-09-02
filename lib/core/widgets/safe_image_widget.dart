import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class SafeImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableZoomOnClick;

  const SafeImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.enableZoomOnClick = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(8);

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildPlaceholder(context, effectiveRadius, isError: false);
    }

    final url = imageUrl!.trim();
    Widget imageWidget;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      imageWidget = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: AppConstants.safeImageCacheWidth, // 嚴格降取樣 1024 寬度防 OOM
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading(context, effectiveRadius, loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context, effectiveRadius, isError: true);
        },
      );
    } else {
      // 本地 Asset 或快取
      imageWidget = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: AppConstants.safeImageCacheWidth,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context, effectiveRadius, isError: true);
        },
      );
    }

    final content = ClipRRect(
      borderRadius: effectiveRadius,
      child: imageWidget,
    );

    if (enableZoomOnClick) {
      return GestureDetector(
        onTap: () => _showZoomDialog(context, url),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            content,
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }

  Widget _buildLoading(
    BuildContext context,
    BorderRadius radius,
    ImageChunkEvent progress,
  ) {
    final total = progress.expectedTotalBytes;
    final loaded = progress.cumulativeBytesLoaded;
    final value = total != null ? loaded / total : null;

    return Container(
      width: width ?? double.infinity,
      height: height ?? 200,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightBackground,
        borderRadius: radius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context,
    BorderRadius radius, {
    required bool isError,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width ?? double.infinity,
      height: height ?? 160,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : const Color(0xFFEEEEEE),
        borderRadius: radius,
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image_outlined : Icons.image_outlined,
            size: 36,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            isError ? '拓撲圖載入失敗' : '暫無考題拓撲圖',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: SafeImageWidget(
            imageUrl: url,
            fit: BoxFit.contain,
            enableZoomOnClick: false,
          ),
        ),
      ),
    );
  }
}
