import 'package:flutter/material.dart';
import 'package:nostalgia/features/places/presentation/widgets/image_viewer.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageGrid(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewer(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          PageView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                imageUrls[index],
                height: MediaQuery.sizeOf(context).height * 0.444,
                fit: BoxFit.cover,
              );
            },
            controller: PageController(
              initialPage: initialIndex,
              viewportFraction: 1,
            ),
          ),
          if (imageUrls.length > 1)
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${imageUrls.length - 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
