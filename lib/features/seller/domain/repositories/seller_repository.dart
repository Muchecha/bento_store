import 'package:bento_store/core/repositories/base_repository.dart';

import '../entities/seller.dart';

abstract class SellerRepository extends BaseRepository {
  SellerRepository(super.cacheService);

  Future<List<Seller>> getSellers();
  Future<void> saveSelectedSeller(Seller seller);
  Future<Seller?> getSelectedSeller();
  Future<void> clearSelectedSeller();
}
