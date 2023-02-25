import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_electronic/Data/model/currency.model.dart';
import 'package:http/http.dart' as http;
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/link_api.dart';
import 'package:service_electronic/view/widget/dialogs.view.dart';
import 'package:storage_database/api/request.dart';
import 'package:storage_database/api/response.dart';

import '../../../../Data/model/transfer.model.dart';
import '../../../../core/class/statusRequest.dart';
import '../../../../core/services/auth.service.dart';
import '../../../../core/services/main.service.dart';

class Exchone2Controller extends GetxController {
  MainService mainSerivice = Get.find();

  late CurrencyModel sendedCurrency;
  late CurrencyModel receivedCurrency;
  late double sendedBalance;
  late double receivedBalance;
  Map<String, TextEditingController> dataControllers = {};
  Map<String, String> errors = {};

  UserModel get user => Get.find<AuthSerivce>().currentUser.value!;

  // late TextEditingController userWallet;
  GlobalKey<FormState> confirm = GlobalKey<FormState>();
  @override
  void onInit() {
    super.onInit();
    // userWallet = TextEditingController();
    sendedCurrency = Get.arguments['sended_currency'];
    receivedCurrency = Get.arguments['received_currency'];
    sendedBalance = Get.arguments['sended_balance'];
    receivedBalance = Get.arguments['received_balance'];
    for (String name in receivedCurrency.data.keys) {
      dataControllers[name] = TextEditingController();
    }
  }

//=========== متغيرات الصور =======================================
  File? imageproof;

  // ============ فنكشن الصورة الاثبات ==========================
  Future<void> ublodimage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: sendedCurrency.pickType.source,
      imageQuality: 50,
    );
    if (pickedImage != null) {
      imageproof =
          await FlutterNativeImage.compressImage(pickedImage.path, quality: 15);
    } else {}
    update();
  }

//=========== فنكشن خاص بصفحة الدفع ===================================
  confirme() async {
    if (confirm.currentState!.validate() && !sendedCurrency.proofIsRequired ||
        confirm.currentState!.validate() &&
            sendedCurrency.proofIsRequired &&
            imageproof != null) {
      DialogsView.loading().show();
      APIResponse response =
          await Get.find<MainService>().storageDatabase.storageAPI!.request(
        '${Applink.transfers}/${sendedCurrency.id == user.platformSettings.platformCurrency.id ? 'withdraw' : 'create'}',
        RequestType.post,
        headers: Applink.authedHeaders,
        data: {
          'received_balance': sendedBalance.toString(),
          'sended_currency_id': sendedCurrency.id.toString(),
          'received_currency_id': receivedCurrency.id.toString(),
          'data': jsonEncode({
            for (String name in dataControllers.keys)
              name: dataControllers[name]!.text,
          }),
        },
        files: [
          if (sendedCurrency.proofIsRequired)
            await http.MultipartFile.fromPath("proof", imageproof!.path)
        ],
      );
      if (response.success) {
        await TransferModel.loadAll(TransferTarget.transfers);
        Get.back();
        Get.back();
      } else {
        Get.back();
        if (response.errors != null) {
          errors = response.errors!;
          confirm.currentState!.validate();
        } else {
          Get.defaultDialog(
            title: 'Transfer error',
            middleText: response.message,
          );
        }
      }
    } else {
      Get.defaultDialog(
        title: 'Transfer error',
        middleText: 'Please fill all data',
      );
    }
  }
}
