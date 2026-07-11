import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.details, super.key});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) return ErrorWidget(details.exception);

    return const ColoredBox(
      color: .new(0xFFF5F5F5),
      child: Directionality(
        textDirection: .ltr,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: .min,
              children: [
                Icon(Icons.error_outline, size: 48, color: .new(0xFF757575)),
                SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: .new(fontSize: 16, color: .new(0xFF424242)),
                  textAlign: .center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
