
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Um widget que recebe a [dashboardUrl] e exibe em WebView.
/// Se precisar de token, ajuste headers ou injete via JS postMessage.
class EmbeddedDashboard extends StatefulWidget {
  final String dashboardUrl;
  final String? title;

  const EmbeddedDashboard({
    super.key,
    required this.dashboardUrl,
    this.title,
  });

  @override
  State<EmbeddedDashboard> createState() => _EmbeddedDashboardState();
}

class _EmbeddedDashboardState extends State<EmbeddedDashboard> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller e configura callbacks se precisar injetar token
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.dashboardUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge,  // Mudança aqui para titleLarge
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}
