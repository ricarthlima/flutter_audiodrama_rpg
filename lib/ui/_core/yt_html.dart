import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class YouTubeEmbedWebOnly extends StatelessWidget {
  const YouTubeEmbedWebOnly({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return SizedBox(); // Oculta em mobile e desktop

    // Cria o iframe com o vídeo desejado
    final iframe = html.IFrameElement()
      ..width = '560'
      ..height = '315'
      ..src = 'https://www.youtube.com/embed/MMEyqWeJ52Y?si=O_YeqY8oUeq2qOSz'
      ..style.border = 'none'
      ..allowFullscreen = true
      ..allow =
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share';

    // Registra o iframe como viewType
    const viewId = 'youtube-embed';
    // evita registrar mais de uma vez
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) => iframe);

    return HtmlElementView(viewType: viewId);
  }
}
