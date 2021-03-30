import 'package:get/get.dart';
import 'package:pc_build_app/app/core/utils/constants/scrapper_constants.dart';
import 'package:pc_build_app/app/data/models/brand_model.dart';
import 'package:pc_build_app/app/data/models/product_info_model.dart';
import 'package:pc_build_app/app/data/models/product_page_model.dart';
import 'package:pc_build_app/app/data/providers/scrapping_provider_mixin.dart';
import 'package:pc_build_app/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';
import 'package:web_scraper/web_scraper.dart';

class StartechScrapper with Scrapper {
  StartechScrapper() {
    siteUrl = ScrapperConstants.STARTECH_BASE_URL;
    categoryUrls = ScrapperConstants.STARTECH_CATEGORY_LIST;
    localUrl = ScrapperConstants.STARTECH_PRODUCT_INDEX_URL;
  }

  @override
  getProducts({
    required category,
    required page,
  }) async {
    WebScraper webScraper = WebScraper(siteUrl);

    final titleList = [];
    final urlList = [];
    final thumbnailList = [];
    final priceList = [];
    final labelList = [];
    List<ProductInfoModel> productList = [];
    List<BrandModel> brandList = [];
    ProductPageModel productPage = ProductPageModel.sampleModel();

    var uuid = Uuid();

    try {
      var url = localUrl
          .replaceAll('[1]', '${categoryUrls[category]}')
          .replaceAll('[2]', '$page');

      if (await webScraper.loadWebPage(url)) {
        // Scrapping Title, Url
        webScraper.getElement(
          'h4.product-name > a',
          ['href'],
        ).forEach(
          (element) {
            final title = element['title'];
            final url = element['attributes']['href'];
            titleList.add(title);
            urlList.add(url);
          },
        );

        // Scrapping Thumbnail
        webScraper.getElement(
          'div.product-thumb > div.img-holder > a > img',
          ['src'],
        ).forEach(
          (element) {
            final thumbnail = element['attributes']['src'];
            thumbnailList.add(thumbnail);
          },
        );

        // Scrapping Price
        webScraper
            .getElement(
              'div.price > span',
              [],
            )
            .asMap()
            .forEach(
              (index, element) {
                if (index % 2 == 0) {
                  final price = int.parse(
                    element['title'].replaceAll(RegExp('[^0-9]'), ''),
                  );
                  priceList.add(price);
                }
              },
            );

        // // Product Label
        webScraper.getElement(
          'div.product-info > div.actions > div.cart-btn > span',
          [],
        ).forEach(
          (element) {
            final temp = element.toString().toLowerCase();
            var label = '';
            if (temp.contains('out of stock')) {
              label = 'Out of Stock';
            } else if (temp.contains('up coming')) {
              label = 'Upcoming';
            } else if (temp.contains('call for price')) {
              label = 'Call for Price';
            } else {
              label = '';
            }

            labelList.add(label);
          },
        );

        // Populating Brand Model
        webScraper.getElement(
          'div.product-listing > div.child-list > a',
          ['href'],
        ).forEach(
          (element) {
            final brand = BrandModel(
              name: element['title'],
              url: element['attributes']['href'].toString().replaceAll(
                    this.siteUrl,
                    '',
                  ),
            );
            brandList.add(brand);
          },
        );

        // checking previous page
        bool prevCheck = !webScraper.getElement(
          'li > span.disabled',
          [],
        ).any((element) => element['title'] == 'PREV');

        // checking next page
        bool nextCheck = !webScraper.getElement(
          'li > span.disabled',
          [],
        ).any((element) => element['title'] == 'NEXT');

        // Populating ProductInfo List
        for (var i = 0; i < titleList.length; i++) {
          productList.add(
            ProductInfoModel(
              id: uuid.v5(
                Uuid.NAMESPACE_URL,
                '$siteUrl$localUrl/item$i',
              ),
              title: titleList[i].trim(),
              url: urlList[i].toString().replaceFirst(siteUrl, ''),
              thumb: thumbnailList[i],
              price: priceList[i],
              spacialNote: labelList[i].trim(),
            ),
          );
        }

        productPage = ProductPageModel(
          page: page,
          nextPageAvailable: nextCheck,
          previousPageAvailable: prevCheck,
          category: category,
          website: 'startech',
          productList: productList,
          brandList: brandList,
        );

        // For Debugging
        // productList.forEach((element) {
        //   print(element);
        // });
        // print(productPage);
        print('Scrapping Succesful');
      } else {
        print('Scrapping Unsuccesful');
        throw Exception('Api Connection Failed');
      }
    } catch (e) {
      print(e);
      Get.toNamed(
        Routes.ERROR,
        parameters: {
          'error': e.toString(),
        },
      );
    }

    // Returning ProductInfo List
    return productPage;
  }
}
