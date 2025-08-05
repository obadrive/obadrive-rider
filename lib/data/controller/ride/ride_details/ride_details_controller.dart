import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/url_container.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/controller/map/ride_map_controller.dart';
import 'package:ovorideuser/data/model/authorization/authorization_response_model.dart';
import 'package:ovorideuser/data/model/bid/bid_list_response_model.dart';
import 'package:ovorideuser/data/model/global/app/ride_model.dart';
import 'package:ovorideuser/data/model/global/bid/bid_model.dart';
import 'package:ovorideuser/data/model/global/response_model/response_model.dart';
import 'package:ovorideuser/data/model/ride/ride_details_response_model.dart';
import 'package:ovorideuser/data/repo/ride/ride_repo.dart';
import 'package:ovorideuser/presentation/components/snack_bar/show_custom_snackbar.dart';

class RideDetailsController extends GetxController {
  RideRepo repo;
  RideMapController mapController;
  RideDetailsController({required this.repo, required this.mapController});

  RideModel ride = RideModel(id: '-1');
  String currency = '';
  String currencySym = '';
  bool isLoading = true;
  bool isPaymentRequested = false;
  LatLng pickupLatLng = const LatLng(0, 0);
  LatLng destinationLatLng = const LatLng(0, 0);
  String rideId = '-1';
  String serviceImagePath = '';
  String brandImagePath = '';
  String driverImagePath = '';
  String driverTotalCompletedRide = '';

  void updatePaymentRequested({bool isRequested = true}) {
    isPaymentRequested = isRequested;
    update();
  }

  void updateRide(RideModel updatedRide) {
    ride = updatedRide;
    update();
    loggerX('Updated ride: $ride');
  }

  //
  void initialData(String id) async {
    currency = repo.apiClient.getCurrency();
    currencySym = repo.apiClient.getCurrency(isSymbol: true);
    rideId = id;
    totalBids = 0;
    bids = [];
    cancelReasonController.text = '';
    isLoading = true;
    isPaymentRequested = false;
    update();
    await getRideDetails(id);
    await getRideBidList(id);
    isLoading = false;
    update();
  }

  //ride
  Future<void> getRideDetails(String id, {bool shouldLoading = true}) async {
    currency = repo.apiClient.getCurrency();
    currencySym = repo.apiClient.getCurrency(isSymbol: true);
    rideId = id;

    bids = [];
    isLoading = shouldLoading;
    update();

    ResponseModel responseModel = await repo.getRideDetails(id);
    if (responseModel.statusCode == 200) {
      RideDetailsResponseModel model = RideDetailsResponseModel.fromJson((responseModel.responseJson));
      if (model.status == MyStrings.success) {
        RideModel? tempRide = model.data?.ride;
        if (tempRide != null) {
          ride = tempRide;
          driverTotalCompletedRide = model.data?.driverTotalRide ?? '';
          pickupLatLng = LatLng(
            StringConverter.formatDouble(
              tempRide.pickupLatitude.toString(),
              precision: 16,
            ),
            StringConverter.formatDouble(
              tempRide.pickupLongitude.toString(),
              precision: 16,
            ),
          );
          destinationLatLng = LatLng(
            StringConverter.formatDouble(
              tempRide.destinationLatitude.toString(),
              precision: 16,
            ),
            StringConverter.formatDouble(
              tempRide.destinationLongitude.toString(),
              precision: 14,
            ),
          );
        }
        serviceImagePath = '${UrlContainer.domainUrl}/${model.data?.serviceImagePath ?? ''}';
        brandImagePath = '${UrlContainer.domainUrl}/${model.data?.brandImagePath ?? ''}';
        driverImagePath = '${UrlContainer.domainUrl}/${model.data?.driverImagePath}';
        loggerX(
          'pickupLatLng>>> : ${pickupLatLng.latitude}, ${pickupLatLng.longitude} || ${ride.pickupLatitude}, ${ride.pickupLongitude}',
        );
        loggerX(
          'destinationLatLng>>> : ${destinationLatLng.latitude}, ${destinationLatLng.longitude} || ${ride.destinationLatitude}, ${ride.destinationLongitude}',
        );
        update();
        mapController.loadMap(
          pickup: pickupLatLng,
          destination: destinationLatLng,
          isRunning: ride.status == "3",
        );
      } else {
        Get.back();
        CustomSnackBar.error(
          errorList: model.message ?? [MyStrings.somethingWentWrong],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }

  //bid
  List<BidModel> bids = [];
  List<BidModel> tempBids = [];
  int totalBids = 0;
  Future<void> getRideBidList(String id) async {
    isLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.getRideBidList(id: id);
      if (responseModel.statusCode == 200) {
        BidListResponseModel model = BidListResponseModel.fromJson((responseModel.responseJson));
        if (model.status == "success") {
          bids = model.data?.bids ?? [];
          totalBids = bids.length;
          update();
        } else {
          CustomSnackBar.error(errorList: model.message ?? [""]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    }
    isLoading = false;
    update();
  }

  void updateTempBid({required BidModel bid, bool isRemoved = false}) {
    if (isRemoved) {
      tempBids.remove(bid);
    } else {
      tempBids.add(bid);
    }
    update();
  }

  void updateBidCount(bool remove) {
    if (totalBids > 0 && remove) {
      totalBids--;
    } else {
      totalBids++;
    }
    update();
    printX('update total bids $totalBids');
  }

  Future<void> acceptBid(String id) async {
    try {
      ResponseModel responseModel = await repo.acceptBid(bidId: id);
      if (responseModel.statusCode == 200) {
        RideDetailsResponseModel model = RideDetailsResponseModel.fromJson((responseModel.responseJson));
        if (model.status == "success") {
          if (model.data != null && model.data!.ride != null) {
            updateRide(model.data!.ride!);
          }
        } else {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
          );
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    }

    update();
  }

  //sos
  TextEditingController sosMsgController = TextEditingController();
  bool isSosLoading = false;
  Future<void> sos(String id) async {
    isSosLoading = true;

    update();
    Position position = await MyUtils.getCurrentPosition();
    try {
      ResponseModel responseModel = await repo.sos(
        id: ride.id ?? "-1",
        msg: sosMsgController.text,
        latLng: LatLng(position.latitude, position.longitude),
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson((responseModel.responseJson));
        if (model.status == "success") {
          sosMsgController.text = '';
          update();
          CustomSnackBar.success(successList: model.message ?? ["Success"]);
        } else {
          CustomSnackBar.error(errorList: model.message ?? ["Error"]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    }

    isSosLoading = false;
    update();
  }

  //cancel

  bool isCancelLoading = false;
  TextEditingController cancelReasonController = TextEditingController();
  Future<void> cancelRide() async {
    isCancelLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.cancelRide(
        id: ride.id ?? "-1",
        reason: cancelReasonController.text,
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson((responseModel.responseJson));
        if (model.status == "success") {
          Get.offAllNamed(RouteHelper.dashboard);
          CustomSnackBar.success(successList: model.message ?? ["Success"]);
        } else {
          CustomSnackBar.error(errorList: model.message ?? ["Error"]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    }
    isCancelLoading = false;
    update();
  }

  //review
  double rating = 0.0;
  TextEditingController reviewMsgController = TextEditingController();
  bool isReviewLoading = false;
  Future<void> reviewRide(String rideId) async {
    isReviewLoading = true;
    update();

    try {
      ResponseModel responseModel = await repo.reviewRide(
        rideId: rideId,
        rating: rating.toString(),
        review: reviewMsgController.text,
      );
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson((responseModel.responseJson));

        if (model.status == MyStrings.success) {
          printX(model.status);
          reviewMsgController.text = '';
          rating = 0.0;
          update();
          Get.offAllNamed(RouteHelper.dashboard);
          CustomSnackBar.success(successList: model.message ?? []);
        } else {
          CustomSnackBar.error(
            errorList: model.message ?? [MyStrings.somethingWentWrong],
          );
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e);
    }
    isReviewLoading = false;
    update();
  }

  void updateRating(double rate) {
    rating = rate;
    update();
  }

  Future<void> getCurrentPosition() async {}
}
