import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/biometric_settings_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/vehicles/register_vehicle_screen.dart';
import '../screens/cards/cards_screen.dart';

import '../screens/purchase/choose_value_screen.dart';
import '../services/biometric_service.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Drawer(
      child: Column(
        children: [
          // Header with user info
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            accountName: Text(
              user?.name != null
                  ? 'Olá, ${user!.name!.split(' ').first}'
                  : 'Usuário',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          // Main menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_cart,
                  title: 'Comprar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChooseValueScreen(
                            vehicleType: 1), // 1 = carro
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'Histórico',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.directions_car,
                  title: 'Veículos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterVehicleScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.credit_card,
                  title: 'Cartões de crédito',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CardsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configurações',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                // Biometric settings - only show if biometrics are available
                FutureBuilder<bool>(
                  future: BiometricService.isBiometricAvailable(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return _buildMenuItem(
                        context,
                        icon: Icons.fingerprint,
                        title: 'Configurações Biométricas',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BiometricSettingsScreen(),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox
                        .shrink(); // Hide if biometrics not available
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.star,
                  title: 'Avalie o app',
                  onTap: () async {
                    Navigator.pop(context);
                    // TODO: Get download link from config
                    const url =
                        'https://play.google.com/store/apps/details?id=com.example.rotativo';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help,
                  title: 'Quero ajuda',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help screen
                  },
                ),
              ],
            ),
          ),

          // Bottom menu - Logout
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Sair',
            onTap: () async {
              try {
                // Fecha o drawer
                Navigator.pop(context);

                // Executa o logout
                await ref.read(authProvider.notifier).logout();

                // Redireciona para login (o AuthWrapper deve fazer isso automaticamente)
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao sair: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
