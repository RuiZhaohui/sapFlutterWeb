import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/api/HttpRequest.dart';
import 'package:gztyre/api/model/ProblemDescription.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/ProgressDialog.dart';
import 'package:gztyre/components/TextButtonWidget.dart';

class ProblemDescriptionPage extends StatefulWidget {
  ProblemDescriptionPage({Key key, @required this.type})
      : super(key: key);

//  final Map<String, String> selectItem;
  final String type;

  @override
  State createState() => _ProblemDescriptionPageState();
}

class _ProblemDescriptionPageState extends State<ProblemDescriptionPage> {
  Map<String, String> _selectItem;
  ProblemDescription _currentProblemDescription;
  bool _loading = false;
  var _listProblemDescriptionFuture;

  List<ProblemDescription> _list = [];

  TextEditingController _searchController = new TextEditingController();

  List<Widget> createWidgetList(List<ProblemDescription> list) {
    List<Widget> itemList = [];
//    itemList.add(ListTitleWidget(
//      title: position,
//    ));
    for (int i = 0; i < list.length; i++) {
      itemList.add(Material(
        child: ExpansionTile(
          title: Text(list[i].title),
          children: <Widget>[
            ...list[i].content.map((item) {
              return
                Padding(padding: EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    child: ListItemSelectWidget(
                        title: Text(
                          item["text"],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        item: item,
                        selectedItem: this._selectItem),
                    onTap: () {
                      if (this._selectItem == item) {
                        this._selectItem = null;
                        this._currentProblemDescription = null;
                      } else
                        this._selectItem = item;
                      this._currentProblemDescription = list[i];
                      setState(() {});
                    },
                  ),
                );
            }).toList()
          ],
        ),
      ));
//      if (i == 0) {
//        itemList.add(new GestureDetector(
//          child: ListItemSelectWidget(
//              title: Text(
//                list[i].KURZTEXT_CODE,
//                overflow: TextOverflow.ellipsis,
//                maxLines: 1,
//              ),
//              item: list[i],
//              selectedItem: this._selectItem),
//          onTap: () {
//            if (this._selectItem == list[i]) {
//              this._selectItem = null;
//            } else
//              this._selectItem = list[i];
//            setState(() {});
//          },
//        ));
//      } else {
//        itemList.add(Divider(
//          height: 1,
//        ));
//        itemList.add(new GestureDetector(
//          child: ListItemSelectWidget(
//              title: Text(
//                list[i].KURZTEXT_CODE,
//                overflow: TextOverflow.ellipsis,
//                maxLines: 1,
//              ),
//              item: list[i],
//              selectedItem: this._selectItem),
//          onTap: () {
//            if (this._selectItem == list[i]) {
//              this._selectItem = null;
//            } else
//              this._selectItem = list[i];
//            setState(() {});
//          },
//        ));
//      }
    }
    return itemList;
  }

  _listProblemDescription() {
    this._loading = true;
    HttpRequest.listProblemDescription(widget.type,
            (List<ProblemDescription> list) {
          this._list = list;
//      this._currentProblemDescription = this._selectItem == null ? null : list.firstWhere((item) {
//        return item.content.any((item2) {
//          if (item2 != null) {
//            return item2["code"] == this._selectItem["code"];
//          } else return false;
//        });
//      });
          setState(() {
            this._loading = false;
          });
        }, (err) {
          print(err);
          setState(() {
            this._loading = false;
          });
        });
  }

  @override
  void initState() {
//    this._selectItem = widget.selectItem;
    this._searchController.addListener(() {
      if (this._searchController.text == 'a') {
        print(this._selectItem);
        print('a');
      }
    });
    this._listProblemDescriptionFuture = this._listProblemDescription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: FutureBuilder(
          future: this._listProblemDescriptionFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return ProgressDialog(
              loading: this._loading,
              child: CupertinoPageScaffold(
                navigationBar: new CupertinoNavigationBar(
                  leading: CupertinoNavigationBarBackButton(
                    onPressed: () =>
                        Navigator.of(context).pop({"selectItem": null, "problemDesc": this._currentProblemDescription}),
                    color: Color.fromRGBO(94, 102, 111, 1),
                  ),
                  middle: Text(
                    widget.type == "5" ? "维修动作" : "故障描述",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: TextButtonWidget(
                    onTap: () {
                      Navigator.of(context).pop({"selectItem": this._selectItem, "problemDesc": this._currentProblemDescription});
                    },
                    text: "确定",
                  ),
                ),
                child: SafeArea(
                    child: CupertinoScrollbar(
                        child: ListView(
                          children: <Widget>[
//                  SearchBar(controller: this._shiftController),
                            ...createWidgetList(this._list),
                          ],
                        ))),
              ),
            );
          },
        ),
        onWillPop: () async {
          Navigator.of(context).pop({this._selectItem, this._currentProblemDescription});
          return false;
        });
  }
}
