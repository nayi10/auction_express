import 'dart:typed_data';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class NewProduct extends StatefulWidget {
  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  List<String> _categories = [
    'Electronics',
    'Fashion & Clothing',
    'Cycling',
    'Home Appliances'
  ];

  late String _category = _categories[0];
  final _formKey = GlobalKey<FormState>();
  final _dropdownFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isProgress = false;
  String? _error;
  List<Asset> images = <Asset>[];
  String title = "New Product";

  List<String> imageUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            if (_isProgress)
              Container(
                margin: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(Colors.blue),
                ),
              ),
            SizedBox(height: 30.0),
            Container(child: _buildForm())
          ]),
        ));
  }

  Widget _buildForm() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_error != null && _error!.isNotEmpty && !_isProgress)
                  Container(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red, fontSize: 17),
                      softWrap: true,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20),
                  ),
                TextFormField(
                  controller: _nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(labelText: "Product name"),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Product name is required";
                    } else if (value.length < 3) {
                      return "Invalid name for product";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: "Product price",
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Price is required";
                    }
                    if (int.parse(value) <= 0) {
                      return "Invalid value for product price";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                DropdownButtonFormField(
                  key: _dropdownFormKey,
                  decoration: InputDecoration(
                    labelText: "Category",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                  validator: (val) {
                    if (_category.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                  items: _categories
                      .map((e) => DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          ))
                      .toList(),
                ),
                Container(
                  height: images.length > 3 ? 270 : 170,
                  child: buildGridView(),
                  margin: EdgeInsets.only(top: 15),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: () => submitForm(),
                  child: Text("Publish"),
                )
              ],
            )));
  }

  submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProgress = true;
      });
      int i = 0;
      images.forEach((element) async {
        i++;
        await saveImage(
            element, _nameController.text.replaceAll(' ', '_') + '_$i');
      });
      final product = Product(
          name: _nameController.text,
          category: _category,
          price: double.tryParse(_priceController.text) ?? 0,
          images: imageUrls,
          dateAdded: Timestamp.now(),
          quantity: 1);
      await FirebaseFirestore.instance
          .collection("products")
          .add(product.toJson())
          .then((value) {
        product.id = value.id;
        value.update(product.toJson());
        setState(() {
          _isProgress = false;
          _priceController.text = '';
          _nameController.text = "";
          images.clear();
          imageUrls.clear();
        });
        CustomSnackBar.snackBar(context,
            text: 'Product has been published', message: Message.success);
      }).onError((error, stackTrace) {
        setState(() {
          _isProgress = false;
          error.toString();
        });
      });
    } else {
      setState(() {
        _isProgress = false;
      });
    }
  }

  Widget buildGridView() {
    return Column(
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 320),
            child: GridView.count(
              crossAxisCount: 3,
              children: uploadedImages(),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => loadAssets(),
          icon: Icon(Icons.add_a_photo),
          label: Text(images.length == 0 ? 'Add images' : 'Add more images'),
        )
      ],
    );
  }

  List<Widget> uploadedImages() {
    var list = List.generate(images.length, (index) {
      Asset asset = images[index];
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Card(
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: AssetThumb(
                asset: asset,
                width: 120,
                height: 120,
              )),
          IconButton(
              onPressed: () {
                images.removeAt(index);
                setState(() {
                  this.images = images;
                });
              },
              icon: Icon(Icons.clear))
        ],
      );
    });
    return list;
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String? _err;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarTitle: "Select images",
          useDetailsView: false,
          selectCircleStrokeColor: "#ffffff",
        ),
      );
    } on Exception catch (e) {
      _err = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = _err;
    });
  }

  Future<void> saveImage(Asset asset, String name) async {
    ByteData byteData =
        await asset.getByteData(); // requestOriginal is being deprecated
    final imageData = byteData.buffer.asUint8List();

    FirebaseStorage storage = FirebaseStorage.instance;
    final folder = _nameController.text;
    Reference ref = storage.ref().child("products/images/$folder/$name");
    UploadTask uploadTask = ref.putData(imageData);
    uploadTask.then((val) async {
      imageUrls.add(await val.ref.getDownloadURL());
      setState(() {
        this.imageUrls = imageUrls;
      });
    });
  }
}
