import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_rpg_audiodrama/router.dart';
import 'package:go_router/go_router.dart';

import '../_core/app_colors.dart';
import '../_core/fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 42, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "AUDIODRAMA ",
                          style: TextStyle(
                            fontFamily: FontFamily.bungee,
                            fontSize: 42,
                          ),
                        ),
                        Text(
                          "RPG",
                          style: TextStyle(
                            fontFamily: FontFamily.bungee,
                            color: AppColors.red,
                            fontSize: 42,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _goToAuth(context),
                      child: Text("Entrar", style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  spacing: 8,
                  children: [
                    TextButton(onPressed: () {}, child: Text("Como jogar?")),
                    TextButton(onPressed: () {}, child: Text("Como narrar?")),
                    TextButton(onPressed: () {}, child: Text("Novidades")),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Row(
                  spacing: 16,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          MarkdownBody(
                            data:
                                "Mais que uma ferramenta, um **sistema** projetado para o digital.",
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w100,
                              ),
                              strong: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _goToAuth(context),
                            child: Text("Criar conta gratuitamente"),
                          ),
                          SizedBox(height: 4),
                          MarkdownBody(data: textDetails),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color!,
                          ),
                        ),
                        child: Image.asset(
                          "assets/images/press-kit/image-example.jpg",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get textDetails => """
  **Por que Audiodrama RPG?**
- Combates rápidos, letais e narrativos.
- Sem classes, sem limites: crie personagens únicos.
- Sistema leve para jogar e fácil de ouvir.
- Surpresas genuínas: sem cenário pré-definido.
- Muito simples e perfeito para iniciantes.
  """;

  void _goToAuth(BuildContext context) {
    context.go(AppRouter.auth);
  }
}
