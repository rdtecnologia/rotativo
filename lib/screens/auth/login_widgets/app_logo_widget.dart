import 'package:flutter/material.dart';
import '../../../config/dynamic_app_config.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DynamicAppConfig.cityName,
      builder: (context, snapshot) {
        final cityName = snapshot.data ?? 'Rotativo Digital';
        return Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_parking,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rotativo $cityName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
