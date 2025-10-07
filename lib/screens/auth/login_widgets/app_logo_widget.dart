import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/dynamic_app_config.dart';
import '../../../config/environment.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DynamicAppConfig.cityName,
      builder: (context, snapshot) {
        final cityName = snapshot.data ?? 'Rotativo Digital';
        final flavor = Environment.flavor;

        // Mapear flavor para nome da pasta da cidade
        final cityFolder = _getCityFolder(flavor);
        final logoPath = 'assets/config/cities/$cityFolder/logo_login.png';

        return Column(
          children: [
            Container(
              width: 200,
              //height: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(60),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withValues(alpha: 0.1),
                //     blurRadius: 10,
                //     spreadRadius: 2,
                //   ),
                // ],
              ),
              child: Center(
                child: Image.asset(
                  logoPath,
                  width: 250,
                  //height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback para o logo SVG original se a imagem não existir
                    return SvgPicture.asset(
                      'assets/images/svg/logo.svg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rotativo $cityName',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  /// Mapear flavor para nome da pasta da cidade
  String _getCityFolder(String flavor) {
    const flavorToFolder = {
      'demo': 'Main',
      'ouroPreto': 'OuroPreto',
      'vicosa': 'Vicosa',
    };

    return flavorToFolder[flavor] ?? 'Main';
  }
}
