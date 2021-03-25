import 'package:get/get.dart';
import 'package:pc_build_app/app/core/utils/constants/scrapper_constants.dart';
import 'package:pc_build_app/app/data/models/website_model.dart';
import 'package:pc_build_app/app/modules/product/product_controller.dart';

class WebsiteController extends GetxController {
  Rx<WebsiteModel> _site = WebsiteModel.getSample().obs;

  WebsiteController([String? code]) {
    if (code != null) {
      _site.value = WebsiteModel(
        code: code,
        name: ScrapperConstants.WEBSITE_LIST[code]!,
        logo: 'assets/images/site_logo/$code.png',
        categoryList: ScrapperConstants.CATEGORY_LIST[code]!,
      );
    }
  }

  WebsiteModel getWebsite() {
    return _site.value!;
  }

  void setWebsite(WebsiteModel site) {
    _site.value = site;
    Get.find<ProductController>().setSite(
      _site.value!.code.toString(),
    );
    print('Site change to ${_site.value!.name} Successful');
  }

  List<WebsiteModel> getWebSites() {
    List<WebsiteModel> websites = [];

    ScrapperConstants.WEBSITE_LIST.forEach(
      (key, value) {
        websites.add(
          WebsiteModel(
            code: key,
            name: value,
            logo: 'assets/images/site_logo/$key.png',
            categoryList: ScrapperConstants.CATEGORY_LIST[key]!,
          ),
        );
      },
    );
    return websites.obs;
  }
}
