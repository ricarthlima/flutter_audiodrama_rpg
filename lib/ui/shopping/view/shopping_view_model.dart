import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/repositories/item_repository.dart';

import '../../../domain/models/item.dart';
import '../../../domain/models/item_sheet.dart';
import '../../_core/helpers.dart';
import '../../sheet/view/sheet_view_model.dart';

class ShoppingViewModel extends ChangeNotifier {
  SheetViewModel sheetVM;
  final ItemRepository itemRepo;
  ShoppingViewModel({required this.sheetVM, required this.itemRepo})
      : listSellerItems = itemRepo.listItems;

  List<Item> listSellerItems = [];
  List<ItemSheet> listInventoryItems = [];

  TextEditingController searchInventoryController = TextEditingController();
  TextEditingController searchSellerController = TextEditingController();

  List<String> listFilteredCategories = [];
  List<String> listFilteredCategoriesSeller = [];

  bool _isBuying = false;
  bool get isBuying => _isBuying;
  set isBuying(bool value) {
    _isBuying = value;
    notifyListeners();
  }

  toggleBuying() {
    _isBuying = !_isBuying;
    notifyListeners();
  }

  bool _isFree = false;
  bool get isFree => _isFree;
  set isFree(bool value) {
    _isFree = value;
    notifyListeners();
  }

  List<ItemSheet> _listSheetItems = [];

  final TextEditingController _moneyController = TextEditingController();

  TextEditingController getMoneyTextController(SheetViewModel sheetVM) {
    _moneyController.text = sheetVM.sheet!.money.toString();
    return _moneyController;
  }

  buyItem({required Item item}) {
    double money = double.parse(_moneyController.text);

    if (money >= item.price || isFree) {
      if (_listSheetItems.where((e) => e.itemId == item.id).isNotEmpty) {
        _listSheetItems.where((e) => e.itemId == item.id).first.amount++;
      } else {
        _listSheetItems.add(
          ItemSheet(itemId: item.id, uses: 0, amount: 1),
        );
      }

      if (!isFree) {
        money = money - item.price;
        saveChanges(money: money);
      }

      saveChanges();
    } else {
      _showHaveNoMoneyFeedback();
    }
  }

  bool showingHaveNoMoney = false;

  _showHaveNoMoneyFeedback() async {
    showingHaveNoMoney = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 1750));
    showingHaveNoMoney = false;
    notifyListeners();
  }

  sellItem({required String itemId}) {
    Item item = itemRepo.getItemById(itemId)!;
    _listSheetItems.where((e) => e.itemId == itemId).first.amount--;
    if (_listSheetItems.where((e) => e.itemId == itemId).first.amount <= 0) {
      _listSheetItems.removeWhere((e) => e.itemId == itemId);
    }
    double money = double.parse(_moneyController.text);
    money = money + item.price;
    saveChanges(money: money);
    notifyListeners();
  }

  openInventory(List<ItemSheet> listItems) {
    _listSheetItems = listItems;
    isBuying = false;
    notifyListeners();
  }

  reloadUses({required String itemId}) {
    _listSheetItems
        .firstWhere(
          (ItemSheet itemSheet) => itemSheet.itemId == itemId,
        )
        .uses = 0;

    notifyListeners();
    saveChanges();
  }

  useItem({required String itemId}) {
    Item item = itemRepo.getItemById(itemId)!;

    int index = _listSheetItems.indexWhere(
      (ItemSheet itemSheet) => itemSheet.itemId == itemId,
    );
    if (index != -1) {
      if (item.isFinite) {
        _listSheetItems[index].uses++;
        if (_listSheetItems[index].uses >= item.maxUses!) {
          _listSheetItems[index].amount--;
          _listSheetItems[index].uses = 0;
        }
        if (_listSheetItems[index].amount <= 0) {
          // removeAllFromItem(itemId: itemId, isOver: true);
        }
      }
    }

    notifyListeners();
    saveChanges();
  }

  removeItem({required String itemId}) async {
    _listSheetItems
        .firstWhere((ItemSheet itemSheet) => itemSheet.itemId == itemId)
        .amount--;
    notifyListeners();
    saveChanges();
  }

  removeAllFromItem({required String itemId}) async {
    _listSheetItems.removeWhere(
      (ItemSheet itemSheet) => itemSheet.itemId == itemId,
    );

    notifyListeners();
    saveChanges();
  }

  onEditingMoney() async {
    double? money = double.tryParse(_moneyController.text);
    if (money != null) {
      _showMoneyFeedback(true);
      await saveChanges(money: money);
    } else {
      _moneyController.text = sheetVM.sheet!.money.toString();
      _showMoneyFeedback(false);
      notifyListeners();
    }
  }

  saveChanges({double? money}) async {
    sheetVM.sheet!.listItemSheet = _listSheetItems;

    if (money != null) {
      sheetVM.sheet!.money = money;
    }

    await sheetVM.saveChanges();

    notifyListeners();
  }

  bool? isShowingMoneyFeedback;

  _showMoneyFeedback(bool isSuccess) async {
    isShowingMoneyFeedback = isSuccess;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 1250));
    isShowingMoneyFeedback = null;
    notifyListeners();
  }

  toggleCategory(String category, bool isSeller) {
    if (!isSeller) {
      if (listFilteredCategories.contains(category)) {
        listFilteredCategories.remove(category);
      } else {
        listFilteredCategories.add(category);
      }
      onSearchOnInventory();
    } else {
      if (listFilteredCategoriesSeller.contains(category)) {
        listFilteredCategoriesSeller.remove(category);
      } else {
        listFilteredCategoriesSeller.add(category);
      }
      onSearchOnSeller();
    }
  }

  onSearchOnInventory() {
    String search =
        removeDiacritics(searchInventoryController.text).toLowerCase();

    listInventoryItems = _listSheetItems.map((e) => e).toList();

    if (listFilteredCategories.isNotEmpty || search != "") {
      if (search != "") {
        listInventoryItems = listInventoryItems.where(
          (ItemSheet itemSheet) {
            Item item = itemRepo.getItemById(itemSheet.itemId)!;
            return removeDiacritics(item.name).toLowerCase().contains(search);
          },
        ).toList();
      }

      if (listFilteredCategories.isNotEmpty) {
        listInventoryItems.retainWhere(
          (itemSheet) {
            Item item = itemRepo.getItemById(itemSheet.itemId)!;

            for (String category in item.listCategories) {
              if (listFilteredCategories.contains(category)) {
                return true;
              }
            }
            return false;
          },
        );
      }
    }

    notifyListeners();
  }

  onSearchOnSeller() {
    String search = removeDiacritics(searchSellerController.text).toLowerCase();

    listSellerItems = itemRepo.listItems.map((e) => e).toList();

    if (listFilteredCategoriesSeller.isNotEmpty || search != "") {
      if (search != "") {
        listSellerItems = listSellerItems
            .where((Item item) =>
                removeDiacritics(item.name).toLowerCase().contains(search))
            .toList();
      }

      if (listFilteredCategoriesSeller.isNotEmpty) {
        listSellerItems.retainWhere(
          (item) {
            for (String category in item.listCategories) {
              if (listFilteredCategoriesSeller.contains(category)) {
                return true;
              }
            }
            return false;
          },
        );
      }
    }

    notifyListeners();
  }
}

class requried {}
