import '../../../../core/dummy_data.dart' show Product;
import '../../../../core/theme.dart';
import '../../domain/entities/product_entity.dart';

const List<String> kDefaultProductSizes = ['One Size'];

const String kFallbackProductImageUrl =
    'https://via.placeholder.com/300x300.png?text=No+Image';

extension ProductDisplayMapper on ProductEntity {
  Product toDisplayProduct() => Product(
    id: id.toString(),
    name: title,
    description: description,
    price: price,
    imageUrl: images.isNotEmpty ? images.first : kFallbackProductImageUrl,
    colors: const [AppTheme.primary],
    sizes: kDefaultProductSizes,
  );
}
