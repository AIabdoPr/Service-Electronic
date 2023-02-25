import 'package:gap/gap.dart';
import 'package:service_electronic/Data/model/product.model.dart';
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:service_electronic/core/services/auth.service.dart';

import '../../../../link_api.dart';
import '../../../widget/network_image.view.dart';
import '../../../widget/vewmodel.dart';

class Profiel extends StatefulWidget {
  const Profiel({Key? key}) : super(key: key);

  @override
  State<Profiel> createState() => _ProfielState();
}

class _ProfielState extends State<Profiel> {
  UserModel get user => Get.find<AuthSerivce>().currentUser.value!;

  bool isLoading = true;

  List<ProductModel> products = [];

  Future getProducts() async {
    isLoading = true;
    setState(() {});
    products = await ProductModel.getMy();
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
            child: Text(
          "93".tr,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        )),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            color: Colors.black,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(50)),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 250,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                bottom: 75,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(148, 0, 0, 0),
                                        blurRadius: 5,
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/drawer.png',
                                    fit: BoxFit.fill, //دير تصويرة للهلفية
                                    width: MediaQuery.of(context).size.width,
                                    height: 250,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                height: 100,
                                width: 100,
                                left:
                                    MediaQuery.of(context).size.width / 2 - 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          0, 173, 173, 173),
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x68000000),
                                        blurRadius: 5,
                                        offset: Offset(1, 2),
                                      )
                                    ],
                                  ),
                                  child: NetworkImageView(
                                    url: user.image!,
                                    headers: Applink.imageHeaders,
                                    backgroundColor: Colors.blue,
                                    fit: BoxFit.cover,
                                    borderRadius: 50,
                                    setItInDecoration: true,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  user.fullname,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 7, 7, 7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              right: 10, left: 10, top: 10),
                          child: Text("${"116".tr} : ${user.firstname}"),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              right: 10, left: 10, top: 10),
                          child: Text("${"153".tr} : ${user.lastname}"),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              right: 10, left: 10, top: 10),
                          child: Text("${"2".tr} : ${user.email}"),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              right: 10, left: 10, top: 10),
                          child: Text("${"15".tr} : ${user.phone}"),
                        ),
                        const Gap(10),
                        const Divider(thickness: 2),
                        RefreshIndicator(
                          onRefresh: getProducts,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: products.length,
                                  physics: const ScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return VewModel(
                                      product: products[index],
                                      onActionEnd: getProducts,
                                      editable: true,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
