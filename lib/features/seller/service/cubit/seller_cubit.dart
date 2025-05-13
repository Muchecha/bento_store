import 'package:bento_store/features/seller/domain/entities/seller.dart';
import 'package:bento_store/features/seller/domain/repositories/seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final SellerRepository _sellerRepository;

  SellerCubit({required SellerRepository repository})
      : _sellerRepository = repository,
        super(SellerInitial()) {
    _loadInitialData();
  }

  Future<void> loadSellers() async {
    try {
      emit(SellerLoading());
      final sellers = await _sellerRepository.getSellers();
      final selectedCachedSeller = await _sellerRepository.getSelectedSeller();
      emit(SellerLoaded(sellers: sellers, selectedSeller: selectedCachedSeller));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> selectSeller(Seller seller) async {
    try {
      if (state is SellerLoaded) {
        final currentState = state as SellerLoaded;
        await _sellerRepository.saveSelectedSeller(seller);
        emit(SellerLoaded(sellers: currentState.sellers, selectedSeller: seller));
      }
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> clearSelectedSeller() async {
    try {
      final currentState = state as SellerLoaded;
      await _sellerRepository.clearSelectedSeller();
      emit(SellerLoaded(sellers: currentState.sellers, selectedSeller: null));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> _loadInitialData() async {
    try {
      emit(SellerLoading());
      final sellers = await _sellerRepository.getSellers();
      emit(SellerLoaded(sellers: sellers, selectedSeller: null));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }
}
