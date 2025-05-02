
# Audiodrama RPG
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-nd/4.0/)

O Audiodrama RPG (ADRPG) é um sistema de RPG de mesa criado por mim, Ricarth Lima, pensado desde o início para funcionar bem como audiodrama – ou seja, para ser agradável de ouvir, não só de jogar.

Ele elimina conceitos como classes, atributos e modificadores numéricos, focando em ações narrativas diretas, combates rápidos e personagens construídos de forma livre. É um sistema simples de aprender, acessível para iniciantes e flexível o suficiente para qualquer ambientação.

Este repositório traz uma plataforma completa que desenvolvi em Flutter, onde você pode criar fichas, montar campanhas e jogar em tempo real com seus amigos usando o ADRPG.


## 🎥 Demonstração

| Em breve :D


## 🚀 Tecnologias Utilizadas

Este projeto foi desenvolvido com **Flutter** e **Dart**, aproveitando o ecossistema da linguagem para criar uma aplicação robusta, responsiva e escalável, com foco na experiência mobile e compatibilidade com web.

Para persistência de dados e autenticação, utilizo uma combinação entre **Firebase** e **Supabase**. O **Firebase Auth** gerencia o login via Google, enquanto o **Firestore** é responsável pelo armazenamento das campanhas e fichas dos usuários, com atualização em tempo real. O **Firebase Realtime Database** complementa isso com uma camada de presença online, exibindo quais jogadores estão ativos em cada campanha.

Além disso, integro o **Supabase** para funcionalidades complementares, como sincronização de arquivos e gerenciamento de sessões mais controladas no backend, mantendo uma arquitetura que pode ser expandida para uso offline-first ou multiplataforma.

A navegação é feita com o **GoRouter**, permitindo controle avançado de rotas nomeadas, redirecionamentos baseados em autenticação, e estrutura de navegação declarativa e testável.

O estado da aplicação é controlado com o **Provider**, seguindo o padrão `ChangeNotifier`, o que permite uma arquitetura em camadas com separação clara entre `UI`, `ViewModel`, `Repository` e `Service`. 

Para armazenamento local e preferências do usuário, utilizo o **SharedPreferences**, especialmente para manter dados como idioma, tema ou nome de usuário offline.

A interface visual é enriquecida com várias bibliotecas:
- **Lottie** é usada para animações que melhoram a experiência do usuário em feedbacks de ação.
- **Flutter Expandable FAB** implementa o botão flutuante expansível em telas com múltiplas ações.
- **fl_chart** é utilizado para exibir gráficos e estatísticas de personagens de forma visualmente agradável.
- **Staggered Grid View** ajuda a compor grades de fichas com layout fluido, principalmente em exibição de campanhas ou ações.
- **Cached Network Image** melhora o desempenho de imagens carregadas da internet, com cache local automático.
- **Image Picker** e **File Picker** oferecem ao usuário a possibilidade de importar imagens ou arquivos personalizados para suas campanhas ou personagens.

Para manipulações adicionais:
- **uuid** gera identificadores únicos para itens como fichas, mensagens e sessões.
- **string_similarity** melhora a UX no chat e busca, oferecendo sugestões com base em similaridade textual.
- **intl** cuida de internacionalização e formatação de datas e moedas.
- **url_launcher** permite abrir links externos (como um manual de regras ou referência externa).
- **logger** fornece uma camada de log customizada para debugging e análise durante o desenvolvimento.

Além disso, **flutter_dotenv** permite carregar configurações sensíveis do `.env`, como chaves de API ou variáveis de build.



## ✅ Técnicas e Boas Práticas Aplicadas

- Arquitetura baseada em camadas (MVVM) com `Repository` e `Service`, conforme a recomendação oficial do Flutter.
- Separação de responsabilidades entre UI, lógica de negócio e persistência.
- Gerenciamento explícito de estado com `ChangeNotifier`, mantendo rastreabilidade e performance.
- Fallbacks visuais com `FutureBuilder` e feedbacks sutis com animações Lottie.
- Filtro e busca com diacríticos tratados para melhor experiência de usuário.
- Validações e feedbacks visuais e temporizados no controle de saldo e inventário.
- Carregamento dinâmico e local de configurações com `.env`.



## 📌 Melhorias Futuras

- [ ] Centralização completa da lógica de comando em `CommandExecutor`.
- [ ] Reimplementação do chat com suporte a rich content e edição de mensagens.
- [ ] Adição de testes unitários e de widget com `flutter_test`.
- [ ] Sincronização das estatísticas com banco remoto.
- [ ] Controle offline com cache local para campanhas e fichas.



## 📄 Licença

[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-nd/4.0/)

Este projeto está licenciado sob a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International](http://creativecommons.org/licenses/by-nc-nd/4.0/).  
Ele está disponível publicamente apenas para fins de demonstração e portfólio.  
Uso comercial ou modificação do código **não são permitidos** sem autorização prévia.


Para mais informações sobre a licença, acesse: [creativecommons.org/licenses/by-nc-nd/4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)



Desenvolvido por [Ricarth Lima](https://www.github.com/ricarthlima) 💙
