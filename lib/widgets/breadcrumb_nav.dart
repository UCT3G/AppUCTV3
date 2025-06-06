import 'package:flutter/material.dart';

class BreadcrumbNav extends StatelessWidget {
  final List<String> paths;

  const BreadcrumbNav({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(paths.length, (index) {
            final isLast = index == paths.length - 1;
            return Row(
              children: [
                Text(
                  paths[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    color: isLast ? Colors.blueAccent : Colors.black,
                    fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.chevron_right, size: 16),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
