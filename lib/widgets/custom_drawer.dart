import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/vehicles/register_vehicle_screen.dart';
import '../screens/purchase/vehicle_type_screen.dart';

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
            otherAccountsPictures: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
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
                        builder: (context) => const VehicleTypeScreen(),
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
                    _showVehicleOptions(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.credit_card,
                  title: 'Cartões de crédito',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to credit cards screen
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
                    const url = 'https://play.google.com/store/apps/details?id=com.example.rotativo';
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
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
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

  void _showVehicleOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Veículos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(
                Icons.add_circle,
                color: Colors.green,
                size: 28,
              ),
              title: const Text(
                'Cadastrar Novo Veículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text('Adicione um novo veículo à sua conta'),
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
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.list,
                color: Colors.blue,
                size: 28,
              ),
              title: const Text(
                'Meus Veículos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text('Ver e gerenciar veículos cadastrados'),
              onTap: () {
                Navigator.pop(context);
                // This will show in main screen - the vehicle carousel
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seus veículos estão na tela principal'),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}