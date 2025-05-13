import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/utils/session_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SessionHelper.updateLastActive();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _temas = [
      {
        'titulo': 'Interactivo HTML',
        'tipo': 'INTERACTIVO',
        'icon': Icons.html,
        'ruta':
            'https://uct.tresguerras.com.mx/static/interactive.html?materia=7&unidad=40&tema=90&ruta_recurso=data%2FUC3G_MATERIAS%2Fmateria7%2Funidad40%2Ftema90%2Frecurso_basico',
      },
      {'titulo': 'Video', 'tipo': 'VIDEO', 'icon': Icons.video_library},
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('UCT'),
        actions: [
          IconButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: _temas.length,
        itemBuilder: (context, index) {
          final tema = _temas[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                switch (tema['tipo']) {
                  case 'INTERACTIVO':
                    Navigator.pushNamed(
                      context,
                      AppRoutes.interactive,
                      arguments: tema,
                    );
                    break;
                  case 'VIDEO':
                    Navigator.pushNamed(
                      context,
                      AppRoutes.video,
                      arguments: tema,
                    );
                    break;
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tema['icon'],
                        color: Colors.white70,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tema['titulo'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              tema['tipo'] == 'VIDEO' ? 'Video' : 'Interactivo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.blueGrey.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
