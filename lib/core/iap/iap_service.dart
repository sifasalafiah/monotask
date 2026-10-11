import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/database/local_storage_service.dart';

const String kProProductId = 'monotask_pro_lifetime';

enum IAPStatus { loading, available, purchased, unavailable, error }

class IAPState {
  final IAPStatus status;
  final ProductDetails? product;
  final bool isPro;
  final String? errorMessage;
  final bool isRestoring;

  const IAPState({
    this.status = IAPStatus.loading,
    this.product,
    this.isPro = false,
    this.errorMessage,
    this.isRestoring = false,
  });

  IAPState copyWith({
    IAPStatus? status,
    ProductDetails? product,
    bool? isPro,
    String? errorMessage,
    bool? isRestoring,
  }) {
    return IAPState(
      status: status ?? this.status,
      product: product ?? this.product,
      isPro: isPro ?? this.isPro,
      errorMessage: errorMessage,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
}

class IAPNotifier extends StateNotifier<IAPState> {
  final LocalStorageService _storage;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  IAPNotifier(this._storage) : super(const IAPState()) {
    _init();
  }

  Future<void> _init() async {
    // Check persisted pro status first (fast path)
    final isPro = _storage.getIsPro();
    if (isPro) {
      state = state.copyWith(isPro: true, status: IAPStatus.purchased);
    }

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      state = state.copyWith(status: isPro ? IAPStatus.purchased : IAPStatus.unavailable);
      return;
    }

    // Listen to purchase updates
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {
        state = state.copyWith(status: IAPStatus.error, errorMessage: 'Purchase stream error');
      },
    );

    // Load product details
    final response = await InAppPurchase.instance.queryProductDetails({kProProductId});
    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      state = state.copyWith(
        status: isPro ? IAPStatus.purchased : IAPStatus.unavailable,
        errorMessage: 'Product not found',
      );
      return;
    }

    final product = response.productDetails.first;
    state = state.copyWith(
      status: isPro ? IAPStatus.purchased : IAPStatus.available,
      product: product,
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != kProProductId) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify + complete
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        await _grantPro();
      } else if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          status: state.isPro ? IAPStatus.purchased : IAPStatus.available,
          errorMessage: purchase.error?.message ?? 'Purchase failed',
          isRestoring: false,
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        state = state.copyWith(
          status: state.isPro ? IAPStatus.purchased : IAPStatus.available,
          isRestoring: false,
        );
      } else if (purchase.status == PurchaseStatus.pending) {
        // pending — do nothing, wait
      }
    }
  }

  Future<void> _grantPro() async {
    await _storage.setIsPro(true);
    state = state.copyWith(
      isPro: true,
      status: IAPStatus.purchased,
      isRestoring: false,
    );
  }

  Future<void> buyPro() async {
    if (state.product == null) return;
    final param = PurchaseParam(productDetails: state.product!);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isRestoring: true);
    await InAppPurchase.instance.restorePurchases();
    // Give it 3 seconds; if nothing comes back, reset flag
    await Future.delayed(const Duration(seconds: 3));
    if (state.isRestoring) {
      state = state.copyWith(isRestoring: false);
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

final iapProvider = StateNotifierProvider<IAPNotifier, IAPState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return IAPNotifier(storage);
});
