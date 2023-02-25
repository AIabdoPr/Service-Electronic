import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:service_electronic/Data/model/offer_request.dart';
import 'package:service_electronic/view/widget/button.view.dart';
import 'package:service_electronic/view/widget/network_image.view.dart';

import '../../../../core/localization/localiztioncontroller.dart';

class OffersCart extends StatelessWidget {
  const OffersCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 251, 83, 83),
        title: Center(
          child: Text(
            "123".tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: StreamBuilder<List<OfferRequestModel>>(
        stream: OfferRequestModel.stream(),
        builder: (context, snapshot) {
          List<OfferRequestModel> offerRequests =
              snapshot.data?.reversed.toList() ?? [];
          return ListView.builder(
            itemCount: offerRequests.length,
            itemBuilder: (context, index) {
              OfferRequestModel offerRequest = offerRequests[index];
              return OfferRequestItem(offerRequest);
            },
          );
        },
      ),
    );
  }
}

class OfferRequestItem extends StatefulWidget {
  final OfferRequestModel offerRequest;
  const OfferRequestItem(this.offerRequest, {super.key});

  @override
  State<OfferRequestItem> createState() => _OfferRequestItemState();
}

class _OfferRequestItemState extends State<OfferRequestItem> {
  bool showMore = false;

  String? moreData;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    String lang = Get.find<LocaleController>().language.languageCode;
    return InkWell(
      onTap: widget.offerRequest.data != null &&
              widget.offerRequest.data!.isNotEmpty
          ? () {
              if (widget.offerRequest.data != null) {
                showMore = !showMore;
                setState(() {});
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10)
            .copyWith(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(255, 228, 228, 228),
          boxShadow: const [
            BoxShadow(
              blurRadius: 1,
              spreadRadius: 1,
              color: Colors.black38,
              offset: Offset(0.2, 0.2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkImageView(
                  width: w * 0.23,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  url: widget.offerRequest.offer.image,
                  fit: BoxFit.fill,
                  setItInDecoration: true,
                ),
                const Gap(10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.offerRequest.offer.title[lang]!,
                      ),
                      Text(
                        widget.offerRequest.offer.subOffers[
                            widget.offerRequest.subOffer]!["title_$lang"]!,
                      ),
                      Text('Price: ${widget.offerRequest.totalPrice} DZD'),
                      Row(
                        children: [
                          Text(widget.offerRequest.status.tr),
                          const Gap(5),
                          Icon(
                            widget.offerRequest.status.icon,
                            color: widget.offerRequest.status.color,
                          )
                        ],
                      ),
                      Text(
                        'Sended at: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.offerRequest.sendedAt)}',
                      ),
                      if (showMore &&
                          widget.offerRequest.data != null &&
                          widget.offerRequest.data!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5)
                              .copyWith(left: 10),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 240, 240),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 0.5,
                              color: const Color.fromARGB(255, 47, 47, 47),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Flex(
                                  direction: Axis.vertical,
                                  children: [
                                    for (String name
                                        in widget.offerRequest.data!.keys)
                                      Text(
                                        '${widget.offerRequest.offer.data[name]!['title_$lang']}: ${widget.offerRequest.data![name]}',
                                      )
                                  ],
                                ),
                              ),
                              const Spacer(),
                              ButtonView(
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.zero,
                                borderRaduis: 50,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  String data = '';
                                  for (String name
                                      in widget.offerRequest.data!.keys) {
                                    data +=
                                        '${widget.offerRequest.offer.data[name]!['title_$lang']}: ${widget.offerRequest.data![name]}\n';
                                  }
                                  Clipboard.setData(
                                    ClipboardData(text: data),
                                  );
                                },
                                child: const Icon(Icons.copy, size: 15),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
            if (widget.offerRequest.data != null &&
                widget.offerRequest.data!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 20,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Icon(
                  !showMore ? Icons.expand_more : Icons.expand_less,
                  color: Colors.grey,
                ),
              )
          ],
        ),
      ),
    );
  }
}
