import 'dart:convert';
import 'dart:io';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:service_electronic/Data/model/currency.model.dart';
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/core/services/auth.service.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/link_api.dart';
import 'package:service_electronic/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:service_electronic/view/widget/dialogs.view.dart';
import 'package:storage_database/api/request.dart';
import 'package:storage_database/api/response.dart';

import '../../../Data/model/transfer.model.dart';

class PayController extends GetxController {
  GlobalKey<FormState> protfolio = GlobalKey<FormState>();
  AuthSerivce authSerivce = Get.find();

  UserModel get user => authSerivce.currentUser.value!;

  RxMap<String, CurrencyModel> platofromCurrencies =
      <String, CurrencyModel>{}.obs;

  Map<String, TextEditingController> dataControllers = {};
  Map<String, String> errors = {};

  int display = 1;

  String currenctCurrencyId = '-1';
  late TextEditingController dibosit;
  late TextEditingController transfier;
  late TextEditingController blanci;
  File? imageproof;

  double sellBalance = 0;
  double rechargeBalance = 0;

  Future refreshPage() async {
    sellBalance = 0;
    rechargeBalance = 0;
    display = 1;
    currenctCurrencyId = '-1';
    dibosit.clear();
    transfier.clear();
    blanci.clear();
    imageproof = null;

    platofromCurrencies.value =
        user.platformSettings.platformCurrency.avaliableCurrencies;

    update();
  }

  dibosi() async {
    if (protfolio.currentState!.validate() && imageproof != null) {
      DialogsView.loading().show();
      CurrencyModel platformCurrency =
          authSerivce.currentUser.value!.platformSettings.platformCurrency;

      APIResponse response =
          await Get.find<MainService>().storageDatabase.storageAPI!.request(
        '${Applink.transfers}/recharge',
        RequestType.post,
        headers: Applink.authedHeaders,
        data: {
          'sended_balance': dibosit.text,
          'sended_currency_id': currenctCurrencyId,
          'received_currency_id': platformCurrency.id.toString(),
        },
        files: [
          await http.MultipartFile.fromPath("proof", imageproof!.path),
        ],
      );
      if (response.success) {
        await TransferModel.loadAll(TransferTarget.recharges);
        Get.back();
        Get.back();
      } else {
        Get.back();
        Get.defaultDialog(
          title: 'Transfer error',
          middleText: response.message,
        );
      }
    }
  }

  calculateRechareBalance(String text) {
    if (text.isEmpty || currenctCurrencyId == '-1') {
      rechargeBalance = 0;
    } else {
      double value = double.tryParse(text) ?? 0;
      rechargeBalance = value *
          platofromCurrencies[currenctCurrencyId]!
              .dPrices["${user.platformSettings.platformCurrency.id}"]['sell'];
    }
    update();
  }

  calculateBalance(String text) {
    if (text.isEmpty || currenctCurrencyId == '-1') {
      sellBalance = 0;
    } else {
      double value = double.tryParse(text) ?? 0;
      sellBalance = value *
          platofromCurrencies[currenctCurrencyId]!
              .dPrices["${user.platformSettings.platformCurrency.id}"]['buy'];
    }
    update();
  }

  Withdraw() async {
    if (protfolio.currentState!.validate()) {
      DialogsView.loading().show();
      APIResponse response =
          await Get.find<MainService>().storageDatabase.storageAPI!.request(
        '${Applink.transfers}/withdraw',
        RequestType.post,
        log: true,
        headers: Applink.authedHeaders,
        data: {
          'received_balance': blanci.text,
          'sended_currency_id':
              user.platformSettings.platformCurrency.id.toString(),
          'received_currency_id': currenctCurrencyId,
          'data': jsonEncode({
            for (String name in dataControllers.keys)
              name: dataControllers[name]!.text,
          }),
          'for_what': 'withdraw'
        },
      );
      if (response.success) {
        // statusRequest = StatusRequest.success;
        await TransferModel.loadAll(TransferTarget.withdraws);
        // await UserModel.refreshUser();
        Get.back();
        Get.back();
      } else {
        Get.back();
        if (response.errors != null) {
          errors = response.errors!;
          protfolio.currentState!.validate();
        } else {
          Get.defaultDialog(
            title: 'Transfer error',
            middleText: response.message,
          );
        }
        // statusRequest = StatusRequest.failure;
        // update();
      }
    }
  }

  transfer() async {
    if (protfolio.currentState!.validate()) {
      DialogsView.loading().show();
      APIResponse response =
          await Get.find<MainService>().storageDatabase.storageAPI!.request(
        'send_mony',
        RequestType.post,
        headers: Applink.authedHeaders,
        data: {
          'email': transfier.text,
          'balance': blanci.text,
        },
      );
      Get.back();
      if (response.success) {
        Get.back();
      } else {
        if (response.errors != null) {
          errors = response.errors!;
          protfolio.currentState!.validate();
        } else {
          Get.defaultDialog(
            title: 'Balance Transfer',
            middleText: response.message,
          );
        }
      }
    }
  }

  @override
  void onInit() {
    // withdraw = TextEditingController();
    blanci = TextEditingController();
    transfier = TextEditingController();
    dibosit = TextEditingController();

    platofromCurrencies.value =
        user.platformSettings.platformCurrency.avaliableCurrencies;
    // statusRequest = StatusRequest.success;
    // update();

    super.onInit();
  }

  @override
  void dispose() {
    blanci.dispose();
    transfier.dispose();
    dibosit.dispose();
    super.dispose();
  }

//================ فنكشن رفع الصور ======================================
  Future<void> ublodimage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: platofromCurrencies[currenctCurrencyId]!.pickType.source,
      imageQuality: 50,
    );
    if (pickedImage != null) {
      imageproof =
          await FlutterNativeImage.compressImage(pickedImage.path, quality: 15);
      update();
    } else {}
    update();
  }

  historque() {
    Get.toNamed(AppRoute.homeCart);
    update();
  }
}
