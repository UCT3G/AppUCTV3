import 'package:flutter/material.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const ConnectionErrorWidget({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/YowiError.png', height: size.height * 0.5,),
            SizedBox(height: 20),
            Text(
              'Problemas de conexión',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message ??
                  'Estimado usuario, no pudimos conectar con el servidor. Revisa tu conexión e intenta de nuevo.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onRetry,
              label: Text(
                'Reintentar',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              icon: Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF574293),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
