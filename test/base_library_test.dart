import 'package:flutter_test/flutter_test.dart';

import 'package:base_library/base_library.dart';

void main() {
  DioUtil.openDebug();

  test('logger init', () {
    LogUtil.init();
    LogUtil.getInstance().d('message');
  });

  test('dio get', () async {
    await DioUtil().request<List>(Method.get, "banner/json");
  });

  test('dio article', () async {
    await DioUtil.getInstance()
        .request<Map<String, dynamic>>(Method.get, 'article/list/0/json');
  });
}

class BannerModel {
  String title;
  int id;
  String url;
  String imagePath;

  BannerModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        id = json['id'],
        url = json['url'],
        imagePath = json['imagePath'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'id': id,
        'url': url,
        'imagePath': imagePath,
      };

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"title\":\"$title\"");
    sb.write(",\"id\":$id");
    sb.write(",\"url\":\"$url\"");
    sb.write(",\"imagePath\":\"$imagePath\"");
    sb.write('}');
    return sb.toString();
  }
}
