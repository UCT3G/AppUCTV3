import 'package:flutter/material.dart';

class InputUndefinedWidget extends StatelessWidget {
  const InputUndefinedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Este input no esta definido, avisar al equipo de desarrollo",
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
      ),
    );
  }
}
