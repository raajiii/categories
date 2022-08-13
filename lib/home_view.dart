import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_categories/repository.dart';

import 'categories_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Categories? categoryList;
  Categories? searchList;
  bool isExpand = false;
  int? current;
  TextEditingController searchController = TextEditingController();
  final box = GetStorage();
  List<dynamic> localList = [];
  List<dynamic> myList = [];
  @override
  void initState() {
    super.initState();
    Future(() async {
      listAdd();
       await Future.delayed(const Duration(milliseconds: 1));
      categoryList = await ApiRepository().fetchCartList();
      searchList = categoryList;
      await Future.delayed(const Duration(milliseconds: 2));
      listAdd();
      localListRemove();
      print("localList    $localList");

      setState(() {});
    });
  }

  localListRemove() {
    if (localList.isNotEmpty) {
      for (int i = 0; i < localList.length; i++) {
        searchList?.entries!.removeWhere((element) {
          return element.api == localList[i];
        });
        setState(() {});
      }
    }
  }

  List listAdd() {
    if (box.read("categoryList") is List) {
      localList = box.read("categoryList");
    } else {
      localList.add(box.read("categoryList"));
    }
    return localList;
  }

  searchListShowing(query) async {
    categoryList = await ApiRepository().fetchCartList();
    for (int i = 0; i < categoryList!.entries!.length; i++) {
      if (categoryList!.entries![i].api!.contains(query)) {
        searchList?.entries?.clear();
        searchList?.entries?.add(categoryList!.entries![i]);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green,
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: searchController,
                decoration: buildTextFieldInputDecoration(),
                onChanged: (change) async {
                  if (change.length > 1) {
                    searchListShowing(change);
                  } else {
                    categoryList = await ApiRepository().fetchCartList();
                    searchList = categoryList;
                    listAdd();
                    localListRemove();
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchList?.entries?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: InkWell(
                    onTap: () async {
                      current = index;
                      setState(() {
                        current = index;
                        isExpand = !isExpand;
                      });
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _alert(context, index);
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(searchList?.entries?[index].api ?? ""),
                          isExpand && current == index
                              ? Column(
                                  children: [
                                    Text(searchList
                                            ?.entries?[index].description ??
                                        ""),
                                    Text(
                                        searchList?.entries?[index].link ?? ""),
                                    Text(searchList?.entries?[index].category ??
                                        ""),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration buildTextFieldInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      hintText: 'Search',
      contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  AlertDialog _alert(BuildContext context, int index) {
    return AlertDialog(
      title: const Text("Delete Item"),
      content: const Text("Are you sure you want to Delete this item?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            TextButton(
                onPressed: () {
                   listAdd();
                   if(localList.isNotEmpty){
                     myList = localList;
                   }
                  myList.add(searchList?.entries?[index].api ?? " ");
                  box.write("categoryList", myList);
                  searchList?.entries?.removeAt(index);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Yes")),
          ],
        )
      ],
    );
  }
}
