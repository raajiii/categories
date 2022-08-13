import 'api_provider.dart';
import 'categories_model.dart';

class ApiRepository {
  final _provider = ApiProvider();

  Future<Categories> fetchCartList() async{
    return await _provider.getProductsData();
  }
}