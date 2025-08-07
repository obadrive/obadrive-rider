import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/data/controller/account/profile_complete_controller.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/custom_bottom_sheet.dart';

class CityBottomSheet {
  static void bottomSheet(BuildContext context, ProfileCompleteController controller) {
    CustomBottomSheet(
      child: Container(
        height: MediaQuery.of(context).size.height * .4,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: MyColor.getCardBgColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHeaderRow(
              header: MyStrings.city,
              bottomSpace: 15,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: ListView.builder(
                itemCount: controller.cityList.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  String cityItem = controller.cityList[index];
                  bool isSelected = controller.selectedCity == cityItem;

                  return GestureDetector(
                    onTap: () {
                      controller.selectCity(cityItem);
                      Navigator.pop(context);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space15,
                        vertical: Dimensions.space12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MyColor.primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                        border: Border.all(
                          color: isSelected
                              ? MyColor.primaryColor
                              : MyColor.borderColor,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cityItem,
                            style: regularMediumLarge.copyWith(
                              color: isSelected
                                  ? MyColor.primaryColor
                                  : MyColor.getTextColor(),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: MyColor.primaryColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).customBottomSheet(context);
  }
}
