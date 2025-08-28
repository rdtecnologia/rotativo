import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:rotativo/config/dynamic_app_config.dart';

class ChatOnlineScreen extends ConsumerStatefulWidget {
  const ChatOnlineScreen({super.key});

  @override
  ConsumerState<ChatOnlineScreen> createState() => _ChatOnlineScreenState();
}

class _ChatOnlineScreenState extends ConsumerState<ChatOnlineScreen> {
  String? chatBotURL;
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _loadChatBotURL();
  }

  Future<void> _loadChatBotURL() async {
    try {
      final url = await DynamicAppConfig.chatBotURL;
      setState(() {
        chatBotURL = url;
        isLoading = false;
      });

      // Initialize WebView controller
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar if needed
            },
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro no chat: ${error.description}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        );

      // Load the chat URL
      if (chatBotURL != null) {
        await _controller.loadRequest(Uri.parse(chatBotURL!));
      } else {
        // Fallback URL like in React Native
        await _controller.loadRequest(
          Uri.parse(
              'https://chat.blip.ai/?appKey=Y29udGF0b3JkMTpjNTU1NDdmNi1kODJjLTQ3MjQtYjA5NS0wZTdkYWY4YTc5MDU=='),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar chat: $e'),
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
        title: const Text('Chat Online'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando chat...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : WebViewWidget(
              controller: _controller,
            ),
    );
  }
}
