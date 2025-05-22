import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../seller/domain/entities/seller.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

part 'sale_state.dart';

class SaleCubit extends Cubit<SaleState> {
  final SaleRepository _repository;
  Sale sale = Sale(userId: 0, products: []);
  final Map<int, int> _productQuantities = {};

  static const int maxProducts = 10;
  static const int minProducts = 1;

  SaleCubit({required SaleRepository repository})
    : _repository = repository,
      super(SaleInitial());

  void toggleProduct(Seller seller, Product product, {BuildContext? context}) {
    if (sale.userId == 0) {
      sale = sale.copyWith(userId: seller.id);
    }

    final productId = product.id;
    final currentQuantity = _productQuantities[productId] ?? 0;
    if (currentQuantity >= maxProducts || sale.products.length >= maxProducts) {
      return;
    }

    _productQuantities[productId] = currentQuantity + 1;
    sale.products.add(product);

    emit(SaleLoaded(sale: sale.copyWith(products: List.from(sale.products))));
  }

  void toggleRemoveProduct(
    Seller seller,
    Product product, {
    BuildContext? context,
  }) {
    if (sale.userId == 0) {
      sale = sale.copyWith(userId: seller.id);
    }

    final productId = product.id;
    final currentQuantity = _productQuantities[productId] ?? 0;

    if (currentQuantity <= 0) return;

    _productQuantities.remove(productId);
    sale.products.remove(product);
    _productQuantities[productId] = currentQuantity - 1;

    emit(SaleLoaded(sale: sale.copyWith(products: List.from(sale.products))));
  }

  void removeProduct(Product product) {
    _productQuantities.remove(product.id);
    sale.products.remove(product);
    emit(SaleLoaded(sale: sale.copyWith(products: List.from(sale.products))));
  }

  void clearCart() {
    sale.products.clear();
    _productQuantities.clear();
    sale = sale.copyWith(userId: 0);
    emit(SaleInitial());
  }

  int getProductQuantity(int productId) {
    return _productQuantities[productId] ?? 0;
  }

  void canProceedToPayment() {
    final totalItems = _productQuantities.values.fold(
      0,
      (sum, qty) => sum + qty,
    );

    if (totalItems < minProducts) {
      emit(
        SaleCanNotProceedToPaymentError(
          'Selecione pelo menos $minProducts produto para continuar',
        ),
      );
    } else {
      emit(SaleCanProceedToPayment(sale: sale));
    }

    emit(SaleLoaded(sale: sale.copyWith(products: List.from(sale.products))));
  }

  Future<void> finalizeSale() async {
    if (state is SaleLoaded) {
      try {
        emit(SaleProcessing());

        await _repository.createSale(sale.userId, sale.products);

        clearCart();
        emit(SaleSuccess());
      } catch (e) {
        emit(SaleError(e.toString()));
      }
    }
  }

  bool isProductInCart(int productId) {
    return (_productQuantities[productId] ?? 0) > 0;
  }
}
