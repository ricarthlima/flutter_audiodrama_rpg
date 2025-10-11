import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Comprime qualquer imagem selecionada do galeria para **WebP**,
/// mantendo a **mesma resolução** (sem redimensionar) e ajustando
/// apenas a qualidade até ficar **< targetMaxBytes** (padrão: 2 MB).
///
/// Retorna os bytes **WebP** (Uint8List) ou `null` se o usuário cancelar.
Future<Uint8List?> loadAndCompressImage(
  BuildContext context, {
  int targetMaxBytes = 2 * 1024 * 1024, // 2MB
  int initialQuality = 95,
}) async {
  final ImagePicker picker = ImagePicker();
  final XFile? imageFile = await picker.pickImage(
    source: ImageSource.gallery,
    requestFullMetadata: true,
  );
  if (imageFile == null) return null;

  // Lê os bytes originais (qualquer formato) e sempre converte para WebP.
  final Uint8List originalBytes = await imageFile.readAsBytes();

  // 1) Tentativa única com qualidade inicial (rápida).
  Uint8List candidate = await FlutterImageCompress.compressWithList(
    originalBytes,
    format: CompressFormat.webp,
    quality: initialQuality,
    // Não setar minWidth/minHeight para não alterar a resolução.
  );

  if (candidate.lengthInBytes <= targetMaxBytes) {
    return candidate;
  }

  // 2) Ajuste por busca binária na qualidade para ficar < alvo mantendo resolução.
  int low = 1; // qualidade mínima permissiva
  int high = initialQuality; // qualidade máxima inicial
  Uint8List best =
      candidate; // melhor até agora (menor que já atingiu o alvo, se algum)

  // Faz no máx. ~10 passos (suficiente para convergir).
  for (int i = 0; i < 10 && low <= high; i++) {
    final int mid = (low + high) ~/ 2;

    final Uint8List test = await FlutterImageCompress.compressWithList(
      originalBytes,
      format: CompressFormat.webp,
      quality: mid,
    );

    if (test.lengthInBytes <= targetMaxBytes) {
      // Achou um nível que cabe: guarda e tenta qualidade maior.
      best = test;
      low = mid + 1;
    } else {
      // Ainda grande: baixa a qualidade.
      high = mid - 1;
    }
  }

  // Se nunca atingiu o alvo, 'best' continuará sendo o primeiro candidato;
  // nesse caso, fazemos uma última queda agressiva para tentar garantir < alvo.
  if (best.lengthInBytes > targetMaxBytes) {
    final Uint8List fallback = await FlutterImageCompress.compressWithList(
      originalBytes,
      format: CompressFormat.webp,
      quality: 1,
    );
    // Se ainda assim ficar maior (raríssimo), retorna o menor entre best e fallback.
    if (fallback.lengthInBytes < best.lengthInBytes) {
      return fallback;
    }
  }

  return best;
}
