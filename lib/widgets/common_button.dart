
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  const CommonButton({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height:  MediaQuery.of(context).size.height *0.06,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color:Theme.of(context).primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
