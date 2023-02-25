import 'package:flutter/material.dart';
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/core/services/notifiction.service.dart';
import 'package:get/get.dart';
import 'package:service_electronic/link_api.dart';
import 'package:service_electronic/routes.dart';
import 'package:storage_database/api/request.dart';

import '../../view/screen/screen_home/Conditions/conditions.dart';
import '../../view/widget/button.view.dart';
import '../../view/widget/dialogs.view.dart';

class AuthSerivce extends GetxService {
  Rx<UserModel?> currentUser = (null as UserModel?).obs;
  MainService mainService = Get.find();

  RxBool authed = false.obs;

  Future onAuth({bool refresh = false}) async {
    currentUser = (await UserModel.currentUser).obs;
    NotificationService notificationService = Get.find<NotificationService>();
    await notificationService.init();
  }

  Future clearData() async {
    Get.find<NotificationService>().disconnect();
    await Get.delete<NotificationService>();
    await mainService.storageDatabase.clear();
    await mainService.initCollections();
    await mainService.storageDatabase
        .collection('settings')
        .set({'token': '', 'authed': false, 'language': 'en'});

    authed.value = false;
    currentUser.value = null;
  }

  Future checkPoliciesStatus() async {
    if (currentUser.value!.policiesAccepted == false) {
      await const DialogsView(
        isDismissible: false,
        child: PoliciesView(),
      ).show();
    }
  }

  Future signout({bool sendRequest = true}) async {
    await clearData();
    if (sendRequest) {
      await mainService.storageDatabase.storageAPI!.request(
        'auth/logout',
        RequestType.get,
        headers: Applink.authedHeaders,
      );
    }
    Get.offAllNamed(AppRoute.login);
  }
}

class PoliciesView extends StatefulWidget {
  const PoliciesView({super.key});

  @override
  State<PoliciesView> createState() => _PoliciesViewState();
}

class _PoliciesViewState extends State<PoliciesView> {
  bool policiesAccepted = false;
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Image.asset(
                "assets/images/logo3.png",
                width: 50,
                height: 50,
              ),
              Text(
                '45'.tr,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color.fromARGB(255, 20, 20, 20),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 500,
          child: SingleChildScrollView(
            child: Flex(
              direction: Axis.vertical,
              children: [
                Conditions.texts,
                Row(
                  children: [
                    Checkbox(
                      value: policiesAccepted,
                      onChanged: (value) {
                        setState(() {
                          policiesAccepted = value ?? false;
                        });
                      },
                    ),
                    Text('Accept'.tr),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 3, right: 3),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (DialogAction action in (DialogAction.ok))
                ButtonView.text(
                  borderRaduis: 10,
                  onPressed: policiesAccepted
                      ? () async {
                          await Get.find<MainService>()
                              .storageDatabase
                              .storageAPI!
                              .request(
                                'auth/accept_policies',
                                RequestType.get,
                                headers: {
                                  ...Applink.headers,
                                  'Authorization':
                                      'Bearer ${Get.find<AuthSerivce>().currentUser.value?.token}'
                                },
                                log: true,
                              );
                          Get.back();
                        }
                      : null,
                  text: action.text,
                  backgroundColor: action.actionColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
