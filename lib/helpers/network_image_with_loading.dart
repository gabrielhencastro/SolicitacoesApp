import 'package:flutter/material.dart';

class NetworkImageWithLoading extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const NetworkImageWithLoading({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  State<NetworkImageWithLoading> createState() => _NetworkImageWithLoadingState();
}

class _NetworkImageWithLoadingState extends State<NetworkImageWithLoading> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.url,
          fit: widget.fit,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              Future.microtask(() => setState(() => _isLoading = false));
              return child;
            }
            return const SizedBox.shrink();
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            size: 50,
          ),
        ),
        if (_isLoading)
          const CircularProgressIndicator(), // spinner central
      ],
    );
  }
}
