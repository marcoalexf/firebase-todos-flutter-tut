import 'package:firebase_todos/models/item_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../general_providers.dart';

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems({
    required String userId,
  });
  Future<String> createItem({
    required String userId,
    required Item item,
  });
  Future<void> updateItem({
    required String userId,
    required Item item,
  });
  Future<void> deleteItem({
    required String userId,
    required String itemId,
  });
}

final itemRepositoryProvider = Provider((ref) => ItemRepository(ref.read));

class ItemRepository implements BaseItemRepository {
  final Reader _read;

  const ItemRepository(this._read);

  @override
  Future<List<Item>> retrieveItems({required String userId}) async {
    final snap = await _read(frebaseFirestoreProvider)
        .collection('lists')
        .doc(userId)
        .collection('userList')
        .get();
    return snap.docs.map((e) => Item.fromDocument(e)).toList();
  }

  @override
  Future<void> deleteItem(
      {required String userId, required String itemId}) async {
    await _read(frebaseFirestoreProvider)
        .collection('lists')
        .doc(userId)
        .collection('userList')
        .doc(itemId)
        .delete();
  }

  @override
  Future<void> updateItem({required String userId, required Item item}) async {
    await _read(frebaseFirestoreProvider)
        .collection('lists')
        .doc(userId)
        .collection('userList')
        .doc(item.id)
        .update(item.toDocument());
  }

  @override
  Future<String> createItem(
      {required String userId, required Item item}) async {
    final docRef = await _read(frebaseFirestoreProvider)
        .collection('lists')
        .doc(userId)
        .collection('userList')
        .add(item.toDocument());

    return docRef.id;
  }
}
