import 'package:flutter/material.dart';

class CPIElevatedButton extends StatelessWidget {
  const CPIElevatedButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 16,
      width: 16,
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}

class CenterCPI extends StatelessWidget {
  const CenterCPI({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ScaffoldCenterCPI extends StatelessWidget {
  const ScaffoldCenterCPI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CenterCPI(),
    );
  }
}
