import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import 'bottom_sheet.dart';

enum PickImageType {
  gallery,
  camera,
}

class UploadImageModel {
  final PickedFile imageFile;
  final int imageIndex;

  UploadImageModel(this.imageFile, this.imageIndex);
}

class UploadImageItem extends StatelessWidget {
  final GestureTapCallback onTap;
  final Function callBack;
  final UploadImageModel imageModel;
  final Function deleteFun;
  UploadImageItem({this.onTap, this.callBack, this.imageModel, this.deleteFun});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 115,
        height: 115,
        child: Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Color(0xFFF0F0F0)),
                child: imageModel == null
                    ? InkWell(
                        onTap: onTap ??
                            () {
                              BottomActionSheet.show(context, [
                                '相机',
                                '相册',
                              ], callBack: (i) {
                                callBack(i);

                                return;
                              });
                            },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Icon(Icons.camera_alt),
                            ),
                            Text(
                              '上传',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff999999)),
                            )
                          ],
                        ))
                    :
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeroPhotoViewWrapper(
                          imageProvider: FileImage(File(imageModel.imageFile.path)),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    child: Hero(
                      tag: "someTag",
                      child: Image.file(
                        new File(imageModel.imageFile.path),
                        width: 105,
                        height: 105,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),),

            Offstage(
              offstage: (imageModel == null),
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: const Icon(
                    Icons.close,
                    color: Colors.redAccent
                ),
                onTap: () {
                  print('点击了删除');
                  if (imageModel != null) {
                    deleteFun(this);
                  }
                },
              ),
            ),
          ],
        ));
  }
}

class HeroPhotoViewWrapper extends StatelessWidget {
  const HeroPhotoViewWrapper({
    this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
  });

  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: imageProvider,
        loadingBuilder: loadingBuilder,
        backgroundDecoration: backgroundDecoration,
        minScale: minScale,
        maxScale: maxScale,
        heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
      ),
    );
  }
}

class UcarImagePicker extends StatefulWidget {
  final String title;
  final int maxCount;

  UcarImagePicker({this.title, this.maxCount});
  @override
  _UcarImagePickerState createState() => _UcarImagePickerState();
}

class _UcarImagePickerState extends State<UcarImagePicker> {
  List<UploadImageItem> _images = []; //保存添加的图片
  int currentIndex = 0;
  bool isDelete = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _images.add(UploadImageItem(
      callBack: (int i) {
        if (i == 0) {
          print('打开相机');
          _getImage(PickImageType.camera);
        } else {
          print('打开相册');
          _getImage(PickImageType.gallery);
        }
      },
    ));
  }

  _getImage(PickImageType type) async {
    var image = await ImagePicker().getImage(
        source: type == PickImageType.gallery
            ? ImageSource.gallery
            : ImageSource.camera);
    UploadImageItem();
    setState(() {
      print('add image at $currentIndex');
      _images.insert(
          _images.length - 1,
          UploadImageItem(
            imageModel: UploadImageModel(image, currentIndex),
            deleteFun: (UploadImageItem item) {
              print('remove image at ${item.imageModel.imageIndex}');
              bool result = _images.remove(item);
              print('left is ${_images.length}');
              if (_images.length == widget.maxCount -1 && isDelete == false) {
                isDelete = true;
                _images.add(UploadImageItem(
                  callBack: (int i) {
                    if (i == 0) {
                      print('打开相机');
                      _getImage(PickImageType.camera);
                    } else {
                      print('打开相册');
                      _getImage(PickImageType.gallery);
                    }
                  },
                ));
              }
              print('remove result is $result');
              setState(() {});
            },
          ));
      currentIndex++;
      if (_images.length == widget.maxCount + 1) {
        _images.removeLast();
        isDelete = false;
      }
    });
  }

  /*拍照*/
  _takePhoto() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    UploadImageItem();
    setState(() {
      _images.insert(
          _images.length - 1,
          UploadImageItem(
            imageModel: UploadImageModel(image, currentIndex),
          ));
    });
  }

  /*相册*/
  _openGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    _images.insert(
        _images.length - 1,
        UploadImageItem(
          imageModel: UploadImageModel(image, currentIndex),
        ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(top: 14, left: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 15.0,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(
            height: 22,
          ),
          Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 10,
            spacing: 10,
            children: List.generate(_images.length, (i) {
              return _images[i];
//              return  PhotoView(
//                imageProvider: FileImage(File(_images[i].imageModel.imageFile.path)),
//              );
            }),
          )
        ],
      ),
    );
  }
}
