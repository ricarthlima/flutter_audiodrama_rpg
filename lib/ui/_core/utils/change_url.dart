import 'dart:html' as html;

void changeURL(String novaURL) {
  html.window.history.pushState(null, '', "#/$novaURL");
}
