import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rotativo/config/dynamic_app_config.dart';
import 'package:rotativo/screens/help/faq_screen.dart';
import 'package:rotativo/screens/help/chat_online_screen.dart';
import 'package:rotativo/screens/help/contact_us_screen.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String cityName = '';
  String? termsLink;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final city = await DynamicAppConfig.cityName;
      final terms = await DynamicAppConfig.termsLink;
      setState(() {
        cityName = city;
        termsLink = terms;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar configurações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleTermsTap() async {
    try {
      if (termsLink != null && termsLink!.isNotEmpty) {
        // Abre os termos em uma nova tela com visualizador de PDF, igual à tela de cadastro
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Termos de Uso'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      onPressed: () => _launchTermsInBrowser(termsLink!),
                      tooltip: 'Abrir no navegador',
                    ),
                  ],
                ),
                body: SfPdfViewer.network(
                  termsLink!,
                  canShowPaginationDialog: true,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  enableDoubleTapZooming: true,
                  enableTextSelection: true,
                  enableHyperlinkNavigation: true,
                ),
              ),
            ),
          );
        }
      } else {
        // Se não houver link, mostra mensagem
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Termos de Uso'),
              content: const Text(
                  'Os termos de uso não estão disponíveis no momento.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Se houver erro, tenta abrir no navegador
      try {
        if (termsLink != null && termsLink!.isNotEmpty) {
          await _launchTermsInBrowser(termsLink!);
        } else {
          throw Exception('Link não disponível');
        }
      } catch (browserError) {
        // Se falhar tudo, mostra mensagem genérica
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Termos de Uso'),
              content: const Text(
                  'Os termos de uso estão disponíveis em nosso site.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _launchTermsInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Não foi possível abrir o link');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Central de ajuda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            // Top section with city name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // First row of menu items
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHelpMenuItem(
                  icon: Icons.question_mark_rounded,
                  label: 'Perguntas\nFrequentes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FAQScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildHelpMenuItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat Online',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatOnlineScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Second row of menu items
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHelpMenuItem(
                  icon: Icons.phone,
                  label: 'Central\nTelefônica',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildHelpMenuItem(
                  icon: Icons.shield_outlined,
                  label: 'Termos de uso',
                  onTap: () => _handleTermsTap(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.grey.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 150,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
