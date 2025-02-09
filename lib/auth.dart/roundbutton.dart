import 'package:flutter/material.dart';

class Roundbutton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;

  const Roundbutton({
    super.key,
    required this.title,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap, // Disable the button when loading
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: loading ? Colors.grey : Colors.purple,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: loading
              ? CircularProgressIndicator(
                strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  title,
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
