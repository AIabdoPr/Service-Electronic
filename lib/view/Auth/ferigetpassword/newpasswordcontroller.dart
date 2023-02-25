import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/core/function/handlingData.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storage_database/api/request.dart';

import '../../../link_api.dart';

class NewpasswordControllerInp extends GetxController {
  var NewpasswordFormKey = GlobalKey<FormState>();
  late TextEditingController Password;
  late TextEditingController ConfirmPassword;

  @override
  void onInit() {
    Password = TextEditingController();
    ConfirmPassword = TextEditingController();
    super.onInit();
  }

  StatusRequest? statusRequest;
  String? email;

  newpassword() async {
    if (NewpasswordFormKey.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();

      var _response =
          await Get.find<MainService>().storageDatabase.storageAPI!.request(
        'auth/password_forgot/password_reset',
        RequestType.post,
        headers: Applink.authedHeaders,
        data: {
          'token': Get.arguments['token'],
          'user_id': Get.arguments['user_id'],
          'new_password': ConfirmPassword.text,
        },
      );

      if (_response.success) {
        Get.snackbar(
          margin: const EdgeInsets.all(15),
          icon: const Icon(
            Icons.verified_outlined,
            color: Colors.green,
            size: 30,
          ),
          (""),
          (""),
          backgroundColor: Colors.white70,
          titleText: Text(
            "62".tr,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          messageText: Text(
            "63".tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
        Get.offNamed(AppRoute.login);
      } else {
        Get.defaultDialog(
          title: "Warning",
          middleText: _response.message,
        );
        statusRequest = StatusRequest.failure;
        update();
      }
    }

    @override
    void onDelete() {
      Password.dispose();
      ConfirmPassword.dispose();
      super.dispose();
    }
  }
}
