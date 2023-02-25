import 'package:flutter/cupertino.dart';
import 'package:service_electronic/Data/model/currency.model.dart';
import 'package:service_electronic/Data/model/transfer.model.dart';
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/core/services/auth.service.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/routes.dart';

import 'package:get/get.dart';

import '../Data/model/notification.model.dart';
import '../core/class/statusRequest.dart';
import '../core/services/notifiction.service.dart';
import 'controller_solide.dart';

class HomeController extends GetxController {
  MainService myService = Get.find();
  AuthSerivce authSerivce = Get.find();
  StatusRequest statusRequest = StatusRequest.success;
  Rx<UserModel?> get user => authSerivce.currentUser;

  // int notifictionCount = 0;

  @override
  void onReady() {
    super.onReady();
    authSerivce.checkPoliciesStatus();
  }

  Future refreshPage() async {
    await TransferModel.loadAllTargets();
    await CurrencyModel.loadAll();
  }

  GlobalKey floatingButtonKey = GlobalKey(debugLabel: 'floating-button');

  RenderBox? get floatingButtonRenderBox =>
      floatingButtonKey.currentContext?.findRenderObject() as RenderBox?;

  RxBool showNotifications = false.obs;
  openNotifications() {
    showNotifications.value = !showNotifications.value;
    update();
    if (showNotifications.isTrue) loadNotifications();
  }

  RxBool loadingNotifictions = true.obs;
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  loadNotifications() async {
    loadingNotifictions.value = true;
    update();
    notifications.value = await NotificationModel.loadAll();

    loadingNotifictions.value = false;
    Get.find<NotificationService>().newsAdminMessages.value = 0;
    update();
  }

  singOut() async {
    statusRequest = StatusRequest.loading;
    update();
    await Get.find<AuthSerivce>().signout();
  }

  echonge() {
    Get.toNamed(AppRoute.myechonge);
    Get.delete<MyEchongeController>();
  }

  service() {
    Get.toNamed(AppRoute.myservice);
  }

  myStore() {
    Get.toNamed(AppRoute.productModel);
    update(); // هادي ماعدهاش علاقة هادي تاع اصفحة هادي الهوم
  }

  @override
  void onInit() {
    Get.find<NotificationService>().newsAdminMessages.listen((count) {
      update();
    });
    Get.find<NotificationService>().newsTransfers.listen((count) {
      update();
    });
    super.onInit();
  }
}
