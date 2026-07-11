import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.details, super.key});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) return ErrorWidget(details.exception);

    return const ColoredBox(
      color: Color(0xFFF5F5F5),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Color(0xFF757575)),
                SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 16, color: Color(0xFF424242)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
