import '../../core/network/api_client.dart';
import '../home/api/home_api_service.dart';
import '../home/data/datasources/home_remote_data_source.dart';
import '../home/data/repositories/home_repository_impl.dart';
import '../home/domain/usecases/get_product_by_id_use_case.dart';
import 'presentation/cubit/product_details_cubit.dart';

class DetailsDependencies {
  DetailsDependencies._();

  static ProductDetailsCubit buildProductDetailsCubit() {
    final apiService = HomeApiService(ApiClient());
    final remoteDataSource = HomeRemoteDataSourceImpl(apiService);
    final repository = HomeRepositoryImpl(remoteDataSource);
    return ProductDetailsCubit(
      getProductByIdUseCase: GetProductByIdUseCase(repository),
    );
  }
}
