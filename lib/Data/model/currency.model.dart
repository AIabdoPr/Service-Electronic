import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:service_electronic/core/services/main.service.dart';
import 'package:service_electronic/link_api.dart';
import 'package:get/get.dart';
import 'package:storage_database/api/request.dart';
import 'package:storage_database/storage_collection.dart';
import 'package:storage_database/storage_document.dart';

import '../../core/services/auth.service.dart';

class CurrencyModel {
  int id;
  String name, char, imageId;
  List<String> wallet;
  String? strWallet;
  double maxReceive;
  Map dPrices, data;
  Map<String, CurrencyModel> avaliableCurrencies;
  bool proofIsRequired;
  CurrencyProofPickType pickType;

  CurrencyModel(
    this.id,
    this.name,
    this.char,
    this.imageId,
    this.wallet,
    this.strWallet,
    this.maxReceive,
    this.dPrices,
    this.avaliableCurrencies,
    this.data,
    this.proofIsRequired,
    this.pickType,
  );

  static StorageCollection document =
      Get.find<MainService>().storageDatabase.collection('currencies');

  String get image {
    return '${Applink.filesUrl}/$imageId';
  }

  static Future<List<CurrencyModel>> loadAll() async {
    // try {
    var response =
        await Get.find<MainService>().storageDatabase.storageAPI!.request(
              'currency',
              RequestType.get,
              headers: Applink.authedHeaders,
            );
    if (response.success && response.value != null) {
      await document.set(
        response.value.isNotEmpty ? response.value : {},
        keepData: false,
      );
    }
    // } catch (e) {}
    return getAll();
  }

  static Future<List<CurrencyModel>> getAll() async {
    Map items = (await document.get()) as Map? ?? {};
    return await allFromMap(items);
  }

  static Future<CurrencyModel> fromMap(Map data) async {
    if (data['prices'].isEmpty) data['prices'] = {};
    if (data['avaliable_currencies'] == null ||
        data['avaliable_currencies'].isEmpty) {
      data['avaliable_currencies'] = {};
    }
    return CurrencyModel(
      data['id'],
      data['name'],
      data['char'],
      data['image_id'],
      data['wallet']?.toString().split(', ') ?? [],
      data['wallet']?.toString().replaceAll(', ', '\n'),
      double.parse((data['platform_wallet']?['balance'] ?? '0').toString()),
      // {
      //   for (String currencyId in (data['prices'] ?? {}).keys)
      //     currencyId: await CurrencyModel.fromId(currencyId),
      // },
      data['prices'],
      {
        for (String id in data['avaliable_currencies'].keys)
          id: await CurrencyModel.fromMap(data['avaliable_currencies'][id]),
      },
      data['data']?.isNotEmpty == true ? data['data'] : {},
      data['proof_is_required'],
      CurrencyProofPickType.fromString(data['image_pick_type']),
    );
  }

  static Future<List<CurrencyModel>> allFromMap(Map items) async =>
      [for (String id in items.keys) await fromMap(items[id])];

  Map get map => {
        'id': id,
        'name': name,
        'char': char,
        'image_id': imageId,
        'wallet': wallet.join(', '),
        'platform_wallet': {'balance': maxReceive},
        'prices': dPrices,
        'avaliable_currencies': {
          for (String id in avaliableCurrencies.keys)
            id: avaliableCurrencies[id]!.map
        },
        'data': data,
        'proof_is_required': proofIsRequired,
        'image_pick_type': '$pickType',
      };

  static Future<CurrencyModel> fromId(String id) async {
    Map data = (await document.document(id).get()) as Map;
    return fromMap(data);
  }
}

class CurrencyProofPickType {
  final String type;
  final ImageSource source;

  const CurrencyProofPickType(this.type, this.source);

  static const CurrencyProofPickType gallery =
      CurrencyProofPickType('gallery', ImageSource.gallery);
  static const CurrencyProofPickType camera =
      CurrencyProofPickType('camera', ImageSource.camera);

  bool get isGallery => type == gallery.type;
  bool get isCamera => type == camera.type;

  static Map<String, CurrencyProofPickType> values = {
    gallery.type: gallery,
    camera.type: camera
  };

  static CurrencyProofPickType fromString(String type) => values[type]!;

  @override
  String toString() => type;
}
