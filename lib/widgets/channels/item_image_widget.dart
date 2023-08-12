import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/channel.dart';

const placeholderPath = 'assets/images/Radio-Placeholder.png';

class ItemImageWidget extends StatelessWidget {
  const ItemImageWidget({
    Key? key,
    required this.channelData,
  }) : super(key: key);

  final Channel channelData;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: FadeInImage(
      fadeInDuration: const Duration(milliseconds: 1000),
      fadeInCurve: Curves.easeIn,
      image: CachedNetworkImageProvider(
        channelData.imageUrl,
      ),
      placeholder: const AssetImage(placeholderPath),
      imageErrorBuilder: (_, __, ___) {
        return const Image(image: AssetImage(placeholderPath));
      },
      fit: BoxFit.cover,
    ));
  }
}
