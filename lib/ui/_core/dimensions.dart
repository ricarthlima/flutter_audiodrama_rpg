import 'package:flutter/material.dart';

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

bool isVertical(BuildContext context) {
  return width(context) < height(context);
}

double getZoomFactor(BuildContext context, double valueAtDefault) {
  return (width(context) / 1920) * valueAtDefault;
}

double getZoomFactorVertical(BuildContext context, double valueAtDefault) {
  return (height(context) / 1000) * valueAtDefault;
}

double getZoomValue(BuildContext context) {
  return width(context) / 1920;
}

double getLimiarZoom() {
  return 0.75;
}
