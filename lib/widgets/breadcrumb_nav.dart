import 'package:flutter/material.dart';

class BreadcrumbNav extends StatelessWidget {
  final List<String> paths;

  const BreadcrumbNav({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(paths.length, (index) {
            final isLast = index == paths.length - 1;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isLast
                              ? [Color(0xFF575398), Color(0xFFA29ECE)]
                              : [Color(0xFFF0F3F8), Color(0xFFF0F3F8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paths[index],
                    style: TextStyle(
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                      color: isLast ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
