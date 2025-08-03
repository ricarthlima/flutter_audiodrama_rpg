import 'package:flutter/material.dart';

class TextMarkdown extends StatelessWidget {
  final String data;
  final TextStyle? regularStyle;
  final TextStyle? boldStyle;
  final TextAlign? textAlign;
  const TextMarkdown(this.data,
      {super.key, this.textAlign, this.regularStyle, this.boldStyle});

  @override
  Widget build(BuildContext context) {
    List<_TextMarkdownData> listData = [];

    // int i = 0;
    // for (String str in data.split("**")) {
    //   listData.add(_TextMarkdownData(data: str, isBold: i % 2 != 0));
    //   i++;
    // }
    listData = _parseMarkdown(data);
    _TextMarkdownData first = listData.removeAt(0);

    return RichText(
      textAlign: textAlign ?? TextAlign.justify,
      text: TextSpan(
        text: first.data,
        style: regularStyle,
        children: List.generate(
          listData.length,
          (index) {
            _TextMarkdownData tmd = listData[index];
            return TextSpan(
              text: tmd.data,
              style: tmd.isBold
                  ? boldStyle ??
                      TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                  : tmd.isItalic
                      ? TextStyle(fontStyle: FontStyle.italic)
                      : regularStyle,
            );
          },
        ),
      ),
    );
  }
}

class _TextMarkdownData {
  String data;
  bool isBold;
  bool isItalic;
  _TextMarkdownData({
    required this.data,
    this.isBold = false,
    this.isItalic = false,
  });
}

List<_TextMarkdownData> _parseMarkdown(String input) {
  final List<_TextMarkdownData> result = [];

  final RegExp exp = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
  int currentIndex = 0;

  for (final match in exp.allMatches(input)) {
    if (match.start > currentIndex) {
      result.add(
        _TextMarkdownData(
          data: input.substring(currentIndex, match.start),
        ),
      );
    }

    final boldText = match.group(1);
    final italicText = match.group(2);

    if (boldText != null) {
      result.add(
        _TextMarkdownData(
          data: boldText,
          isBold: true,
        ),
      );
    } else if (italicText != null) {
      result.add(
        _TextMarkdownData(
          data: italicText,
          isItalic: true,
        ),
      );
    }

    currentIndex = match.end;
  }

  if (currentIndex < input.length) {
    result.add(
      _TextMarkdownData(
        data: input.substring(currentIndex),
      ),
    );
  }

  return result;
}
