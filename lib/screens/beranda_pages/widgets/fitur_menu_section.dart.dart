import 'package:flutter/material.dart';

class FiturMenuSection extends StatelessWidget {
  final List<dynamic> allFeatures;
  final Function(String) handleFiturClick;

  const FiturMenuSection({
    Key? key,
    required this.allFeatures,
    required this.handleFiturClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      runSpacing: 16,
      children:
          allFeatures.map<Widget>((item) {
            return _iconMenu(
              item['title'],
              iconPath: item['icon'],
              onTap: () => handleFiturClick(item['title']),
            );
          }).toList(),
    );
  }

  Widget _iconMenu(String title, {String? iconPath, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: ClipOval(
              child:
                  iconPath != null && iconPath.isNotEmpty
                      ? Image.asset(
                        iconPath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Icon(Icons.error),
                      )
                      : Container(color: Colors.grey, width: 60, height: 60),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
