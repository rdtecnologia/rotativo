import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rotativo/debug_page.dart';
import 'package:rotativo/widgets/environment_indicator.dart';

import '../../../providers/city_config_provider.dart';

class HomeTopBar extends ConsumerWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onRefresh;

  const HomeTopBar({
    super.key,
    required this.onMenuTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Menu button
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 28,
            ),
          ),

          // City name
          Expanded(
            child: GestureDetector(
              onTap: onRefresh,
              child: Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    final cityNameAsync = ref.watch(cityNameProvider);
                    return cityNameAsync.when(
                      data: (cityName) => Text(
                        cityName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const Text(
                        'Carregando...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      error: (error, stack) => const Text(
                        'Erro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Environment indicator (only in debug mode)
          //if (kDebugMode) ...[
          const EnvironmentIndicator(),
          //const SizedBox(width: 8),
          //],

          // Debug button (only in debug mode) or Logo (in release mode)
          if (kDebugMode)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.bug_report,
                color: Colors.black,
                size: 24,
              ),
            )
          else
            // Show logo.svg in release mode (non-clickable)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/images/svg/logo.svg',
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
