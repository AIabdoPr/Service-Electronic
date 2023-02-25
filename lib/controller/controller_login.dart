import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/core/class/statusRequest.dart';
import 'package:service_electronic/core/services/auth.service.dart';

import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/link_api.dart';
import 'package:service_electronic/routes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:service_electronic/view/widget/dialogs.view.dart';
import 'package:storage_database/api/request.dart';
import 'package:storage_database/api/response.dart';

class LoginController extends GetxController {
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  MainService myService = Get.find();
  AuthSerivce authSerivce = Get.find();

  StatusRequest? statusRequest;

  late TextEditingController email;
  late TextEditingController password;

  Map<String, String> errors = {};

  login() async {
    if (loginFormKey.currentState!.validate()) {
      DialogsView.loading().show();
      APIResponse loginResponse =
          await myService.storageDatabase.storageAPI!.request(
        Applink.login,
        RequestType.post,
        headers: Applink.headers,
        log: true,
        data: {
          'email': email.text,
          'password': password.text,
        },
      );
      if (loginResponse.success && loginResponse.value != null) {
        await myService.storageDatabase
            .collection('settings')
            .set({"token": loginResponse.value});
        Map userData = loginResponse.value['user'];

        await myService.storageDatabase.collection('settings').set({
          'authed': true,
          'token': loginResponse.value['token'],
          'socket_token': loginResponse.value['socket.token'],
        });
        authSerivce.authed.value = true;
        await (await UserModel.fromMap(userData)).save();
        await Get.find<AuthSerivce>().onAuth();
        Get.offNamed(AppRoute.home);
      } else {
        Get.back();
        if (loginResponse.errors != null) {
          errors = loginResponse.errors!;
          loginFormKey.currentState!.validate();
        } else {
          Get.defaultDialog(
            title: "login error",
            middleText: loginResponse.message,
          );
        }
      }
    }
    update();
  }

  forgietpassword() async {
    await Get.offNamed(AppRoute.forgetpassword);
  }

  singup() {
    Get.offNamed(AppRoute.singuo);
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();

    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
