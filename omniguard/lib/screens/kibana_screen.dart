import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class KibanaScreen extends StatefulWidget {
  const KibanaScreen({super.key});

  @override
  State<KibanaScreen> createState() => _KibanaScreenState();
}

class _KibanaScreenState extends State<KibanaScreen> {
  static const String viewType = 'kibana-dashboard-view';
  static bool registered = false;

  @override
  void initState() {
    super.initState();

    if (!registered) {
      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..src =
                'http://localhost:5601/app/dashboards#/view/f0ae583a-c79a-4e08-81d2-6f74c67d6736?embed=true'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';

          return iframe;
        },
      );

      registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: HtmlElementView(viewType: viewType),
    );
  }
}