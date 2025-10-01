import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/color_scheme_provider.dart';

/// Widget de demonstração do uso das duas cores
class ColorDemoWidget extends ConsumerWidget {
  const ColorDemoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appColorsProvider).when(
          data: (appColors) => _buildDemo(context, appColors),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Erro ao carregar cores')),
        );
  }

  Widget _buildDemo(BuildContext context, AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demonstração das Cores',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: appColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Cards com cores primária e secundária
          Row(
            children: [
              Expanded(
                child: _buildColorCard(
                  'Cor Primária',
                  appColors.primary,
                  appColors.primaryContrast,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColorCard(
                  'Cor Secundária',
                  appColors.secondary,
                  appColors.secondaryContrast,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Gradiente sutil
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: appColors.subtleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Gradiente Sutil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Gradiente vibrante
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: appColors.vibrantGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Gradiente Vibrante',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botões com as cores
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor: appColors.primaryContrast,
                  ),
                  child: const Text('Botão Primário'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appColors.secondary,
                    side: BorderSide(color: appColors.secondary),
                  ),
                  child: const Text('Botão Secundário'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(String title, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
