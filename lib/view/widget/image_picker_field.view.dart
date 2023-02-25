import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import 'button.view.dart';

class ImagePickerFieldView extends StatefulWidget {
  final EdgeInsets padding, marging;
  final double? width, height, maxWidth, maxHeight;
  final String? label;
  final Function(File image) onPick;
  final Function(File image) onRemove;
  final List<File> images;

  const ImagePickerFieldView({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.marging = const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.label,
    required this.images,
    required this.onPick,
    required this.onRemove,
  });

  @override
  State<ImagePickerFieldView> createState() => _ImagePickerFieldViewState();
}

class _ImagePickerFieldViewState extends State<ImagePickerFieldView> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  pickImage() async {
    List<XFile> images = await ImagePicker().pickMultiImage();
    for (XFile image in images) {
      File imageFile = File(image.path);
      try {
        if ((imageFile.lengthSync() / 2048) > 2) {
          imageFile =
              await FlutterNativeImage.compressImage(image.path, quality: 20);
        }
      } catch (e) {
        print(e);
      }
      widget.onPick(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.marging,
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth ?? double.infinity,
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(5),
          ],
          Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: PageView(
                    controller: pageController,
                    children: [
                      for (File image in widget.images)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 213, 213, 213),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(image),
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: CirclerButton.icon(
                              size: 30,
                              padding: EdgeInsets.zero,
                              margin: const EdgeInsets.only(top: 5, right: 5),
                              icon: Icons.delete_outline_rounded,
                              backgroundColor: Colors.red,
                              iconColor: Colors.white,
                              onPressed: () => widget.onRemove(image),
                            ),
                          ),
                        ),
                      Center(
                        child: CirclerButton.icon(
                          icon: Icons.add_a_photo_outlined,
                          onPressed: pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: () {
                          pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
