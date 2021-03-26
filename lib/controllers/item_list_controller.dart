import 'package:firebase_todos/controllers/auth_controller.dart';
import 'package:firebase_todos/models/item_model.dart';
import 'package:firebase_todos/repositories/item_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final itemListControllerProvider =
    StateNotifierProvider<ItemListController>((ref) {
  final user = ref.watch(authControllerProvider.state);
  return ItemListController(ref.read, user?.uid);
});

class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  final Reader _read;
  final String? _userId;

  ItemListController(this._read, this._userId) : super(AsyncValue.loading()) {
    if (_userId != null) {
      retrieveItems();
    }
  }

  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = AsyncValue.loading();

    final items =
        await _read(itemRepositoryProvider).retrieveItems(userId: _userId!);

    if (mounted) {
      state = AsyncValue.data(items);
    }
  }

  Future<void> addItem({
    required String name,
    bool obtained = false,
  }) async {
    final item = Item(name: name, obtained: obtained);
    final itemId = await _read(itemRepositoryProvider).createItem(
      userId: _userId!,
      item: item,
    );

    state.whenData((value) =>
        state = AsyncValue.data(value..add(item.copyWith(id: itemId))));
  }

  Future<void> updateItem({
    required Item updateItem,
  }) async {
    await _read(itemRepositoryProvider)
        .updateItem(userId: _userId!, item: updateItem);

    state.whenData((value) => state = AsyncValue.data([
          for (final item in value)
            if (item.id == updateItem.id) updateItem else item
        ]));
  }

  Future<void> deleteItem({required String itemId}) async {
    await _read(itemRepositoryProvider)
        .deleteItem(userId: _userId!, itemId: itemId);
    state.whenData((value) => state =
        AsyncValue.data(value..removeWhere((element) => element.id == itemId)));
  }
}
