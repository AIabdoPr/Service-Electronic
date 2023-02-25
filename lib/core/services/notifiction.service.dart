import 'dart:io';

import 'package:service_electronic/Data/model/notification.model.dart';
import 'package:service_electronic/Data/model/transfer.model.dart';
import 'package:service_electronic/Data/model/user.mode.dart';
import 'package:service_electronic/core/services/auth.service.dart';
import 'package:service_electronic/link_api.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../Data/model/offer_request.dart';
import '../../Data/model/purchase.model.dart';
import 'main.service.dart';

class NotificationService extends GetxService {
  MainService mainService = Get.find();
  AuthSerivce authService = Get.find();

  RxInt newsTransfers = 0.obs;
  RxInt newsServices = 0.obs;
  RxInt newsSellerPurchases = 0.obs;
  RxInt newsClientPurchases = 0.obs;
  RxInt newsAdminMessages = 0.obs;

  IO.Socket? socket;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  messaingConfiure() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    //   messaging.setForegroundNotificationPresentationOptions(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   );

    print('User granted permission: ${settings.authorizationStatus}');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  bool connectionError = false;
  bool? connected;

  init() async {
    if (!Platform.isWindows) {
      authService.currentUser.value?.checkMessagingToken(
        (await messaging.getToken())!,
      );
      await messaingConfiure();
    }

    String? token = Get.find<AuthSerivce>().currentUser.value!.socketToken;
    print('auth token: $token');
    socket = IO.io(Applink.socketUrl, {
      'autoConnect': false,
      'transports': ['websocket'],
      'path': '/api/'
    });
    socket!.onConnect((_) {
      socket!.emit('auth', token);
      if (!connectionError) return;
      connectionError = false;
      // ScaffoldMessenger.of(Get.context!).showSnackBar(
      //   SnackBar(
      //     content: Flex(
      //       direction: Axis.horizontal,
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Flexible(
      //           child: Text('143'.tr),
      //         ),
      //         const Icon(
      //           Icons.wifi,
      //           color: Color.fromARGB(255, 40, 248, 50),
      //         )
      //       ],
      //     ),
      //   ),
      // );
    });
    socket!.onDisconnect((_) {
      connectionError = true;
      print('onDisconnect: disconnect');
    });
    socket!.onConnectError((data) {
      print(data.toString());
      if (connectionError) return;
      connectionError = true;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('144'.tr),
              ),
              const Icon(
                Icons.wifi_off,
                color: Colors.redAccent,
              )
            ],
          ),
        ),
      );
    });
    socket!.onError((data) {
      connectionError = true;
      print(data);
    });
    socket!.on('auth-resualt', (data) async {
      connected = data['success'];
      if (connected == false) Get.find<AuthSerivce>().signout();
      socket!.emit('listenUser');
    });
    socket!.on('user-update', (args) async {
      if (args.containsKey('user')) {
        UserModel user = (await UserModel.fromMap(args['user']));
        user.save();
      }
    });
    socket!.on('notifications', (args) {
      NotificationModel notification = NotificationModel.fromMap(args);

      if (notification.name == 'admin-message') {
        newsAdminMessages += 1;
      } else if (notification.name == 'balance-received' ||
          notification.name == 'transfer-answer') {
        newsTransfers += 1;
        TransferModel.loadAll(TransferTarget.transfers);
      } else if (notification.name == 'offer-request-answred') {
        newsServices += 1;
        OfferRequestModel.loadAll();
      } else if ([
        'new-product-solded',
        'purchase-seller-answer',
        'purchase-seller-repport',
        'purchase-client-answer',
        'purchase-request-readed',
        'purchase-step-updated',
      ].contains(notification.name)) {
        PurchaseModel.userLoadAll();
        PurchaseModel.sellerLoadAll();
      }
      Get.snackbar(
        notification.title,
        notification.message,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.notifications),
      );
    });
    socket!.connect();
  }

  disconnect() {
    socket?.disconnect();
    socket?.clearListeners();
    socket?.close();
    socket?.dispose();
    socket = null;
  }
}
