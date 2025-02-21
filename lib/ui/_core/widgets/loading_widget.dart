import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
      // child: Lottie.asset(
      //   "assets/lotties/loading.json",
      //   width: 256,
      //   height: 256,
      // ),
    );
  }
}
