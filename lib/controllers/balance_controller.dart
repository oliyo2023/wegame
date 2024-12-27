import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../utils/euum.dart';
import '../utils/network_utils.dart';

class BalanceController extends GetxController {
  var balance = ''.obs;
  var isLoading = false.obs;

  Future<void> fetchBalance(BuildContext context) async {
    if (!await NetworkUtils.checkNetworkConnection()) {
      NetworkUtils.showNetworkError(context);
      return;
    }

    isLoading.value = true;
    try {
      final dio = Dio();
      final response = await dio.get(
        Configure.DEEPSEEK_API_URL,
        options: Options(headers: {
          'Authorization': 'Bearer ${Configure.DEEPSEEK_API_KEY}',
        }),
      );

      if (response.statusCode == 200) {
        final balanceInfos = response.data['balance_infos'] as List;
        if (balanceInfos.isNotEmpty) {
          final cnyBalance = balanceInfos.firstWhere(
            (info) => info['currency'] == 'CNY',
            orElse: () => balanceInfos.first,
          );
          balance.value = cnyBalance['total_balance']?.toString() ?? '未知';
        } else {
          balance.value = '未知';
        }
      } else {
        Get.snackbar(
          '错误',
          '获取余额失败，请稍后重试',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '网络请求异常：${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}