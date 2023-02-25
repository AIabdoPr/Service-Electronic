import 'dart:convert';

import 'package:service_electronic/Data/model/category.model.dart';
import 'package:service_electronic/Data/model/product.model.dart';
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/controller/controller_add_product.dart';
import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/core/services/auth.service.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/link_api.dart';

import 'package:service_electronic/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storage_database/api/request.dart';
import 'package:storage_database/api/response.dart';

import '../Data/model/purchase.model.dart';

class StoreController extends GetxController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  Map countries = {};
  late TextEditingController serch;
  int sella = 0;
  List data = [];
  bool showNavigationButton = false;

// ============== سطر خاص حفظ البيانات شرد برفرنس =================
  MainService myService = Get.find();
  Rx<UserModel?> get user => Get.find<AuthSerivce>().currentUser;

  List<PurchaseModel> clientPurchases = [];
  List<PurchaseModel> sellerPurchases = [];

  StatusRequest productsStatusRequest = StatusRequest.loading;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxList<ProductModel> products = <ProductModel>[].obs;

  AccontSelle() {
    Get.toNamed(AppRoute.addProduct);
    update();
  }

  bool recting = false;
  react(ProductModel product) async {
    recting = true;
    update();
    if (product.isLiked) {
      await product.unLike();
    } else {
      await product.like();
    }
    recting = false;
    update();
  }

  bool rating = false;
  rate(ProductModel product, double value) async {
    rating = true;
    update();
    value = value / 5;
    await product.rate(value);
    rating = false;
    update();
  }

  Sella() {
    sella++;
    update();
  }

  onSearch(String value) {
    String text = serch.text.toLowerCase().trim();
    if (text.isEmpty) {
      products.value = allProducts
          .where((product) =>
              currenctCategory != -1 &&
                  product.category.id == currenctCategory ||
              currenctCategory == -1)
          .toList();
    } else {
      products.value = allProducts
          .where(
            (product) =>
                (currenctCategory != -1 &&
                        product.category.id == currenctCategory ||
                    currenctCategory == -1) &&
                (product.name.toLowerCase().contains(text) ||
                    product.price.toString().contains(text) ||
                    product.sellerFullName.toLowerCase().contains(text)),
          )
          .toList();
    }
    update();
  }

  int currenctCategory = -1;
  changeCategory(int category) {
    if (category == currenctCategory) category = -1;
    currenctCategory = category;
    products.value = allProducts
        .where((product) =>
            currenctCategory != -1 && product.category.id == currenctCategory ||
            currenctCategory == -1)
        .toList();
    update();
  }

  Future refreshProducts() async {
    productsStatusRequest = StatusRequest.loading;
    update();
    CategoryModel.loadAll().then((items) {
      categories.value = items;
      update();
    });
    var items = await ProductModel.loadAll();
    allProducts.value = items;
    products.value = items;
    currenctCategory = -1;
    productsStatusRequest = StatusRequest.success;
    update();
  }

  @override
  void onInit() {
    user.listen((user) => update());
    DefaultAssetBundle.of(Get.context!)
        .loadString("assets/countries.json")
        .then((data) {
      countries = jsonDecode(data);
      update();
    });

    PurchaseModel.userLoadAll();
    PurchaseModel.userStream().listen((items) {
      clientPurchases = items;
      update();
    });
    PurchaseModel.sellerLoadAll();
    PurchaseModel.sellerStream().listen((items) {
      sellerPurchases = items;
      update();
    });

    serch = TextEditingController();
    fullname = TextEditingController(text: user.value?.fullname);
    phone = TextEditingController(text: user.value?.phone);
    street = TextEditingController();
    count = TextEditingController();

    refreshProducts();
    super.onInit();
  }

  @override
  void dispose() {
    serch.dispose();
    fullname.dispose();
    phone.dispose();
    street.dispose();
    count.dispose();
    super.dispose();
  }

  GlobalKey<FormState> formstore2 = GlobalKey<FormState>();
  late TextEditingController fullname;
  late TextEditingController phone;
  late TextEditingController street;
  late TextEditingController count;

  ProductModel? currenctProduct;
  double get delveryPrice => slectedState.value == '-1'
      ? 0
      : deliveryType == 'office'
          ? double.parse(currenctProduct!
              .seller.deliveryPrices[slectedState.value]['office']
              .toString())
          : deliveryType == 'home'
              ? double.parse(currenctProduct!
                  .seller.deliveryPrices[slectedState.value]['home']
                  .toString())
              : 0;
  String deliveryType = '-1';

  buy(ProductModel product) {
    currenctProduct = product;
    balanceInvalid = false;
    fullname.clear();
    phone.clear();
    street.clear();
    count.clear();
    deliveryType = '-1';
    update();
    Get.toNamed(AppRoute.store2);
  }

  void changeDeliveryType(String value) {
    deliveryType = value;
    update();
  }

  RxString slectedState = '-1'.obs;
  void changeState(String value) {
    slectedState.value = value;
    update();
  }

  double get totalPrice =>
      currenctProduct!.price * (int.tryParse(count.text) ?? 1) + delveryPrice;
  bool balanceInvalid = false;

  StatusRequest statusRequest = StatusRequest.success;

  buyProduct() async {
    statusRequest = StatusRequest.loading;
    update();
    balanceInvalid = totalPrice > user.value!.balance;
    if (formstore2.currentState!.validate() && !balanceInvalid) {
      APIResponse response =
          await myService.storageDatabase.storageAPI!.request(
        'purchase/${currenctProduct!.id}/create',
        RequestType.post,
        headers: Applink.authedHeaders,
        data: {
          'fullname': fullname.text,
          'phone': phone.text,
          'count': int.parse(count.text),
          'state': slectedState.value,
          'delivery_type': deliveryType,
          'address': street.text.isNotEmpty ? street.text : null,
        },
      );
      if (response.success) {
        statusRequest = StatusRequest.success;
        PurchaseModel.userLoadAll();
        Get.back();
      }
    }
    statusRequest = StatusRequest.success;
    update();
  }
}
