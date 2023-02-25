import 'dart:io';

import 'package:service_electronic/Data/model/currency.model.dart';
import 'package:service_electronic/Data/model/seller.model.dart';
import 'package:service_electronic/core/services/auth.service.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/link_api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storage_database/api/request.dart';
import 'package:storage_database/api/response.dart';
import 'package:storage_database/storage_collection.dart';

class UserModel {
  String firstname, lastname, email, phone;
  double balance, checkingBalance;
  bool emailIsVerifited;
  IdentityVerifyStatus identityVerifyStatus;
  String? token, socketToken, messagingToken, imageUrl;
  int? sellerId;
  SellerStatus? sellerStatus;
  PlatformSettings platformSettings;
  bool? policiesAccepted;

  UserModel(
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.balance,
    this.checkingBalance,
    this.emailIsVerifited,
    this.identityVerifyStatus,
    this.imageUrl,
    this.token,
    this.socketToken,
    this.messagingToken,
    this.sellerId,
    this.sellerStatus,
    this.platformSettings,
    this.policiesAccepted,
  );

  String get fullname => '$firstname $lastname';

  static StorageCollection get document =>
      Get.find<MainService>().storageDatabase.collection('user');

  static Future<UserModel> fromMap(Map data) async {
    Map setting = await Get.find<MainService>()
        .storageDatabase
        .collection('settings')
        .get();
    return UserModel(
      data['firstname'],
      data['lastname'],
      data['email'],
      data['phone'],
      double.parse(data['balance'].toString()),
      double.tryParse(data['checking_balance'].toString()) ?? 0,
      data['email_verified'],
      IdentityVerifyStatus.fromString(data['identity_status']) ??
          IdentityVerifyStatus.notVerifted,
      data['profile_image_id'],
      setting['token'],
      setting['socket_token'],
      data['messaging_token'],
      data['seller']?['id'],
      data['seller'] != null
          ? SellerStatus.fromString(data['seller']['status'])
          : null,
      await PlatformSettings.fromMap(data['platform_settings']),
      data['settings']?['policies_accepted'],
    );
  }

  Future save() async {
    await document.set(map, keepData: false);
    Get.find<AuthSerivce>().currentUser.value = await UserModel.currentUser;
  }

  static Future<UserModel?> get currentUser async {
    Map? userData = await document.get();
    return userData != null ? fromMap(userData) : null;
  }

  String? get image =>
      imageUrl != null ? '${Applink.filesUrl}/${imageUrl!}' : null;

  Future<APIResponse> updateImageProfile(File imageProfile) async =>
      await Get.find<MainService>().storageDatabase.storageAPI!.request(
        Applink.editProfile,
        RequestType.post,
        headers: Applink.authedHeaders,
        files: [
          await http.MultipartFile.fromPath("profile_image", imageProfile.path),
        ],
      );

  Future checkMessagingToken(String token) async {
    if (token != messagingToken) {
      return await Get.find<MainService>().storageDatabase.storageAPI!.request(
        'auth/update_messaging_token',
        RequestType.post,
        headers: Applink.authedHeaders,
        data: {'token': token},
      );
    }
  }

  Map get map => {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'phone': phone,
        'balance': balance,
        'messaging_token': messagingToken,
        'checking_balance': checkingBalance,
        'email_verified': emailIsVerifited,
        'identity_status': '$identityVerifyStatus',
        'profile_image_id': imageUrl,
        'seller': sellerId != null
            ? {
                'id': sellerId,
                'status': '$sellerStatus',
              }
            : null,
        'platform_settings': platformSettings.map,
        'settings': {'policies_accepted': policiesAccepted},
      };
}

class IdentityVerifyStatus {
  final String status, name;

  final Color color, secendColor;

  const IdentityVerifyStatus(
    this.status,
    this.name,
    this.color,
    this.secendColor,
  );

  static const IdentityVerifyStatus notVerifted = IdentityVerifyStatus(
    'not_verifted',
    'Not Verifted',
    Colors.red,
    Color.fromARGB(255, 247, 157, 157),
  );
  static const IdentityVerifyStatus checking = IdentityVerifyStatus(
    'checking',
    'Checking',
    Color.fromARGB(255, 197, 165, 3),
    Color.fromARGB(255, 251, 252, 159),
  );
  static const IdentityVerifyStatus verfited = IdentityVerifyStatus(
    'verifited',
    'Verifited',
    Color.fromARGB(255, 1, 141, 6),
    Color.fromARGB(255, 152, 248, 156),
  );

  bool get isNotVerifted => status == notVerifted.status;
  bool get isChecking => status == checking.status;
  bool get isVerfited => status == verfited.status;

  static Map<String, IdentityVerifyStatus> values = {
    notVerifted.status: notVerifted,
    checking.status: checking,
    verfited.status: verfited,
  };

  static IdentityVerifyStatus? fromString(String status) => values[status];

  @override
  String toString() => status;
}

class PlatformSettings {
  CurrencyModel platformCurrency, displayCurrency;
  double commisstion;
  Map servicesStatus;

  PlatformSettings(this.platformCurrency, this.displayCurrency,
      this.commisstion, this.servicesStatus);

  static Future<PlatformSettings> fromMap(Map data) async => PlatformSettings(
        data['platform_currency'] != null
            ? await CurrencyModel.fromMap(data['platform_currency'])
            : CurrencyModel(
                0,
                '--',
                '--',
                'logo',
                [],
                '',
                0,
                {},
                {},
                {},
                true,
                CurrencyProofPickType.gallery,
              ),
        data['display_currency'] != null
            ? await CurrencyModel.fromMap(data['display_currency'])
            : CurrencyModel(
                0,
                '--',
                '--',
                'logo',
                [],
                '',
                0,
                {},
                {},
                {},
                true,
                CurrencyProofPickType.gallery,
              ),
        double.tryParse(data['commission'].toString()) ?? 0,
        data['services_status'],
      );

  Map get map => {
        'platform_currency': platformCurrency.map,
        'display_currency': displayCurrency.map,
        'commission': commisstion,
        'services_status': servicesStatus,
      };
}
