import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;

  const CustomListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: GoogleFonts.getFont(
          'Fira Sans',
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subTitle,
        style: GoogleFonts.getFont(
          'Fira Sans',
          fontSize: 15.0,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }
}
