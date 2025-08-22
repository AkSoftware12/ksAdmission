import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Utils/app_colors.dart';

class DoubtFullImage extends StatefulWidget {
  final String image ;
  const DoubtFullImage({super.key, required this.image});

  @override
  State<DoubtFullImage> createState() => _DoubtFullImageState();
}

class _DoubtFullImageState extends State<DoubtFullImage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: primaryColor,
        body:  Center(
          child: InteractiveViewer(
            panEnabled: true, // Allow panning
            minScale: 0.5,    // Minimum zoom scale
            maxScale: 4.0,
            child:Image.network(
              widget.image ?? '',
              fit: BoxFit.fill,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Image.asset('assets/no_image.jpg', fit: BoxFit.fill);
              },
            )

          ),
        ),

    );
  }
}
