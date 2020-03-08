import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gztyre/commen/Global.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/TextButtonWidget.dart';
import 'package:gztyre/pages/ContainerPage.dart';

class UserMaintenanceGroupSelectionPage extends StatefulWidget {
  UserMaintenanceGroupSelectionPage({Key key, @required this.selectItemList}) : super(key: key);
  @override
  State createState() => _UserMaintenanceGroupSelectionPageState();

  final List<String> selectItemList;
}

class _UserMaintenanceGroupSelectionPageState
    extends State<UserMaintenanceGroupSelectionPage> {

  List<String> _selectItemList;
  final List<String> _managerList = ["A04", "A05", "A06", "A07", "A08"];
  List<String> list = [];


  @override
  void initState() {
    this._selectItemList = widget.selectItemList;
    if (_managerList.contains(Global.userInfo.SORTB)) {
      this.list = ['管理人员'];
    } else this.list = ['跟班维修', '常早班维修', '工装维修'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(94, 102, 111, 1),
        ),
        middle: Text(
          "选择维修分组",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: TextButtonWidget(
          onTap: () async {
            Global.saveMaintenanceGroup(this._selectItemList);
            if (this._selectItemList.length == 0) {
              showCupertinoDialog(
                  context: context,
                  builder: (
                      BuildContext context) {
                    return CupertinoAlertDialog(
                      content: Text(
                        "请选择维修班组",
                        style:
                        TextStyle(fontSize: 18),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(
                                context)
                                .pop();
                          },
                          child: Text("好"),
                        ),
                      ],
                    );
                  });
            } else {
              Navigator.of(context).pop();
            }
          },
          text: "确定",
        ),
      ),
      child: SafeArea(
          child: CupertinoScrollbar(
            child: ListView.custom(
                childrenDelegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
                  if (index % 2 == 0) {
                    return GestureDetector(
                      child: ListItemSelectWidget(
                        title: Text(list[index ~/ 2]),
                        item: list[index ~/ 2],
                        selectedItemList: this._selectItemList,
                      ),
                      onTap: () {
                        if (this._selectItemList.contains(list[index ~/ 2])) {
                          this._selectItemList.remove(list[index ~/ 2]);
                        } else this._selectItemList.add(list[index ~/ 2]);
                        setState(() {

                        });
                      },
                    );
                  } else
                    return Divider(
                      height: 1,
                    );
                }, childCount: list.length * 2 - 1)),
          )),
    );
  }
}
