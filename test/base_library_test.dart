import 'package:flutter_test/flutter_test.dart';

import 'package:base_library/base_library.dart';

void main() async {
  DioUtil.openDebug();
  await LogUtil.init();
  await DioManager.init();

  test('logger init', () async {
    LogUtil.writeLog('message');
  });

  test('dio get', () async {
    await DioUtil().request<List>(Method.get, "banner/json");
  });

  test('dio article', () async {
    await DioUtil.getInstance()
        .request<Map<String, dynamic>>(Method.get, 'article/list/0/json');
  });

  test('dio manager', () async {
    ToastUtil.show('message');
    // await dio.get('banner/json1').then((response) {
    //   LogUtil.writeLog(response.data.toString());
    // });
  });
}
