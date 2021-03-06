import 'package:flutter_test/flutter_test.dart';

import 'package:base_library/index.dart';

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
    // ToastUtil.show('message');
    await dio.get('banner/json1').then((response) {
      LogUtil.writeLog(response.data.toString());
    });
  });

  test('dart map', () async {
    add({int x, int y = 1, int z = 2}) {
      return x + y + z;
    }

    var gifts = {
      'first': 'partridge',
      'sencond': 'turtledoves',
      'fifth': 'golden rings'
    };

    print(gifts['first']);

    int result = add(x: 10);
    print(result);
  });
}
