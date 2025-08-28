import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/config/dynamic_app_config.dart';
import 'package:rotativo/screens/help/contact_us_screen.dart';

class FAQScreen extends ConsumerStatefulWidget {
  const FAQScreen({super.key});

  @override
  ConsumerState<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends ConsumerState<FAQScreen> {
  int? openQuestionIndex;
  List<Map<String, dynamic>> faqList = [];

  @override
  void initState() {
    super.initState();
    _loadFAQ();
  }

  Future<void> _loadFAQ() async {
    try {
      final faq = await DynamicAppConfig.faq;
      setState(() {
        faqList = faq;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar FAQ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleQuestion(int index) {
    setState(() {
      if (openQuestionIndex == index) {
        openQuestionIndex = null;
      } else {
        openQuestionIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perguntas Frequentes'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final item = faqList[index];
                final isOpen = openQuestionIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          item['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          isOpen
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () => _toggleQuestion(index),
                      ),
                      if (isOpen)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            item['content'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer with contact button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Não encontrou sua dúvida?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Fale conosco',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
