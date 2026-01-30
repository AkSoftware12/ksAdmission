import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color kPrimaryDark = Color(0xFF010071);
const Color kPrimaryBlue = Color(0xFF0A1AFF);

Future<void> showSubscriptionPremiumPopup(
    BuildContext context, {
      VoidCallback? onSubscribe,
      String title = "Subscription Required",
      String message = "To access this content, you need to purchase a subscription.",
      String priceText = "Unlock Premium Access",
    }) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔥 Gradient Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [kPrimaryDark, kPrimaryBlue],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 46.sp,
                              width: 46.sp,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 26.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(50.r),
                                    ),
                                    child: Text(
                                      priceText,
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // Body
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                        child: Column(
                          children: [
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            _benefitTile("Unlock all premium content"),
                            _benefitTile("Unlimited access & faster usage"),
                            _benefitTile("Priority customer support"),

                            SizedBox(height: 18.h),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      side: const BorderSide(color: kPrimaryDark),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                    ),
                                    child: Text(
                                      "Not Now",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimaryDark,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      onSubscribe?.call();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryDark,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.workspace_premium_rounded,
                                            size: 18.sp, color: Colors.white),
                                        SizedBox(width: 6.w),
                                        Text(
                                          "Get Subscription",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // ❌ Close Button
            Positioned(
              top: -14.h,
              right: 12.w,
              child: InkWell(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  height: 34.sp,
                  width: 34.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(Icons.close_rounded, size: 18.sp),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _benefitTile(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: kPrimaryBlue.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18.sp, color: kPrimaryDark),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
                color: kPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
