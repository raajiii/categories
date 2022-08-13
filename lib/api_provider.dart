import 'package:dio/dio.dart';
import 'package:my_categories/categories_model.dart';

class ApiProvider {
  final String getURL = "https://api.publicapis.org/entries";

  Future<Categories> getProductsData() async {
    try {
      final res = await Dio().get(
        getURL,
      );
      Categories categoriesList = Categories.fromJson(res.data);
        return categoriesList;
    } catch (e) {
      throw Exception('Failed to load Categories');
    }
  }
}
