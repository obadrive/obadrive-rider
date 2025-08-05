import 'package:ovorideuser/core/helper/shared_preference_helper.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'dart:convert';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/data/model/global/pusher/pusher_event_response_model.dart';
import 'package:ovorideuser/data/services/pusher_service.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/data/services/api_client.dart';

class GlobalPusherController extends GetxController {
  ApiClient apiClient;
  GlobalPusherController({required this.apiClient});

  @override
  void onInit() {
    super.onInit();

    PusherManager().addListener(onEvent);
  }

  List<String> activeEventList = [
    "NEW_RIDE_CREATED",
    "RIDE_END",
    "PICK_UP",
    "CASH_PAYMENT_RECEIVED",
    "NEW_BID",
  ];

  void onEvent(PusherEvent event) {
    try {
      printE("global pusher event ${event.eventName}");
      printE("global pusher event ${event.data}");
      PusherResponseModel model = PusherResponseModel.fromJson(jsonDecode(event.data));
      final modify = PusherResponseModel(
        eventName: event.eventName,
        channelName: event.channelName,
        data: model.data,
      );
      if (event.data == null) return;
      if (activeEventList.contains(event.eventName.toLowerCase()) && !isRidePage()) {
        Get.toNamed(
          RouteHelper.rideDetailsScreen,
          arguments: model.data?.ride?.id,
        );
      }
      updateEvent(modify);
    } catch (e) {
      printX(e.toString());
    }
  }

  void updateEvent(PusherResponseModel event) {
    loggerX('global pusher ${event.eventName}');
    if (activeEventList.contains(event.eventName) && !isRidePage()) {
      loggerI("event.data?.ride?.id | ${event.data?.bid?.id}");
      if (event.eventName.toString().toLowerCase() == "NEW_BID".toLowerCase()) {
        Get.toNamed(
          RouteHelper.rideDetailsScreen,
          arguments: event.data?.bid?.rideId,
        );
      } else {
        Get.toNamed(
          RouteHelper.rideDetailsScreen,
          arguments: event.data?.ride?.id,
        );
      }
    }
  }

  bool isRidePage() {
    return Get.currentRoute == RouteHelper.rideDetailsScreen;
  }

  @override
  void onClose() {
    PusherManager().removeListener(onEvent);
    super.onClose();
  }

  Future<void> ensureConnection({String? channelName}) async {
    try {
      var userId = apiClient.sharedPreferences.getString(SharedPreferenceHelper.userIdKey) ?? '';
      await PusherManager().checkAndInitIfNeeded(channelName ?? "private-rider-user-$userId");
    } catch (e) {
      printX("Error ensuring connection: $e");
    }
  }
}
