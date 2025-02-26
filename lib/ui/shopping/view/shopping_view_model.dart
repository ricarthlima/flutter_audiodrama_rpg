import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/data/daos/item_dao.dart';
import 'package:flutter_rpg_audiodrama/domain/models/item_sheet.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/components/remove_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/helpers.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/view/sheet_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/item.dart';

class ShoppingViewModel extends ChangeNotifier {
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

  TextEditingController getMoneyTextController(BuildContext context) {
    final sheetViewModel = Provider.of<SheetViewModel>(context);
    _moneyController.text = sheetViewModel.money.toString();
    return _moneyController;
  }

  buyItem({required BuildContext context, required Item item}) {
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
        saveChanges(context, money: money);
      }

      saveChanges(context);
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

  sellItem({required BuildContext context, required String itemId}) {
    Item item = ItemDAO.instance.getItemById(itemId)!;
    _listSheetItems.where((e) => e.itemId == itemId).first.amount--;
    if (_listSheetItems.where((e) => e.itemId == itemId).first.amount <= 0) {
      _listSheetItems.removeWhere((e) => e.itemId == itemId);
    }
    double money = double.parse(_moneyController.text);
    money = money + item.price;
    saveChanges(context, money: money);
    notifyListeners();
  }

  openInventory(List<ItemSheet> listItems) {
    _listSheetItems = listItems;
    isBuying = false;
    notifyListeners();
  }

  reloadUses({required BuildContext context, required String itemId}) {
    _listSheetItems
        .firstWhere(
          (ItemSheet itemSheet) => itemSheet.itemId == itemId,
        )
        .uses = 0;

    notifyListeners();
    saveChanges(context);
  }

  useItem({required BuildContext context, required String itemId}) {
    Item item = ItemDAO.instance.getItemById(itemId)!;

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
          removeAllFromItem(context: context, itemId: itemId, isOver: true);
        }
      }
    }

    notifyListeners();
    saveChanges(context);
  }

  removeItem({
    required BuildContext context,
    required String itemId,
    bool isOver = false,
  }) async {
    Item item = ItemDAO.instance.getItemById(itemId)!;

    bool? result = await showRemoveItemDialog(
      context: context,
      name: item.name,
    );

    if (result != null && result) {
      _listSheetItems
          .firstWhere(
            (ItemSheet itemSheet) => itemSheet.itemId == itemId,
          )
          .amount--;
    }

    notifyListeners();

    if (!context.mounted) return;
    saveChanges(context);
  }

  removeAllFromItem({
    required BuildContext context,
    required String itemId,
    bool isOver = false,
  }) async {
    Item item = ItemDAO.instance.getItemById(itemId)!;

    bool? result = await showRemoveItemDialog(
      context: context,
      name: item.name,
      isOver: isOver,
    );

    if (result != null && result) {
      _listSheetItems.removeWhere(
        (ItemSheet itemSheet) => itemSheet.itemId == itemId,
      );
    }

    notifyListeners();

    if (!context.mounted) return;
    saveChanges(context);
  }

  onEditingMoney(BuildContext context) async {
    double? money = double.tryParse(_moneyController.text);
    if (money != null) {
      _showMoneyFeedback(true);
      await saveChanges(context, money: money);
    } else {
      final sheetViewModel = context.read<SheetViewModel>();
      _moneyController.text = sheetViewModel.money.toString();
      _showMoneyFeedback(false);
      notifyListeners();
    }
  }

  saveChanges(BuildContext context, {double? money}) async {
    final sheetViewModel = context.read<SheetViewModel>();
    sheetViewModel.listSheetItems = _listSheetItems;

    if (money != null) {
      sheetViewModel.money = money;
    }

    await sheetViewModel.saveChanges();

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

  List<Item> listSellerItems = ItemDAO.instance.getItems;
  List<ItemSheet> listInventoryItems = [];

  TextEditingController searchInventoryController = TextEditingController();
  TextEditingController searchSellerController = TextEditingController();

  onSearchItem(bool isSeller) {
    String search = searchInventoryController.text;

    if (isSeller) {
      search = searchSellerController.text;
    }

    if (search == "") {
      resetSearch(isSeller);
      return;
    }

    search = removeDiacritics(search).toLowerCase();

    if (isSeller) {
      listSellerItems = listSellerItems
          .where((Item item) =>
              removeDiacritics(item.name).toLowerCase().contains(search))
          .toList();
    } else {
      listInventoryItems = _listSheetItems.where(
        (ItemSheet itemSheet) {
          Item item = ItemDAO.instance.getItemById(itemSheet.itemId)!;
          return removeDiacritics(item.name).toLowerCase().contains(search);
        },
      ).toList();
    }

    notifyListeners();
  }

  resetSearch(bool isSeller) {
    if (isSeller) {
      listSellerItems = ItemDAO.instance.getItems;
    } else {
      listInventoryItems = _listSheetItems;
    }

    searchInventoryController.text = "";
    searchSellerController.text = "";

    notifyListeners();
  }
}
