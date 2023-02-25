import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/core/function/handlingData.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:storage_database/api/request.dart';

import '../../../../link_api.dart';

class VerficodesingupController extends GetxController {
  StatusRequest statusRequest = StatusRequest.success;
  String token = Get.arguments['token'];

  resendEmail() async {
    statusRequest = StatusRequest.loading;
    update();

    var response =
        await Get.find<MainService>().storageDatabase.storageAPI!.request(
      'auth/resend_verifiy_email',
      RequestType.post,
      headers: Applink.authedHeaders,
      data: {
        'user_id': Get.arguments['user_id'],
        'token': token,
      },
    );

    if (response.success) token = response.value;

    Get.defaultDialog(
      title: response.success ? "Success" : "Error",
      middleText: response.message,
    );
    statusRequest = StatusRequest.failure;
    update();
  }

  verifaycodesingup(verfycodesingup) async {
    statusRequest = StatusRequest.loading;
    update();
    var response =
        await Get.find<MainService>().storageDatabase.storageAPI!.request(
      'auth/email_verify',
      RequestType.post,
      headers: Applink.authedHeaders,
      data: {
        'user_id': Get.arguments['user_id'],
        'token': token,
        "code": verfycodesingup,
      },
    );
    if (response.success) {
      Get.offNamed(AppRoute.login);
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
            "60".tr,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          messageText: FittedBox(
              child: Text(
            "61".tr,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          )));
    } else {
      Get.defaultDialog(
        title: "Warning",
        middleText: response.message,
      );
      statusRequest = StatusRequest.failure;
      update();
    }
  }
}
