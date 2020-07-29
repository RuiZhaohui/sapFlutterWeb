import 'package:flutter/cupertino.dart';
import 'package:gztyre/api/model/Materiel.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';

class SubstituteMaterialCompanyPage extends StatefulWidget {
  SubstituteMaterialCompanyPage({Key key, this.list}) : super(key: key);

  final List<SubstituteMateriel> list;

  @override
  State createState() => _SubstituteMaterialCompanyPageState();
}

class _SubstituteMaterialCompanyPageState extends State<SubstituteMaterialCompanyPage> {
  SubstituteMateriel _selectItem;

  List<Widget> _buildList(List<SubstituteMateriel> substituteMaterielList) {
    List<Widget>  list = new List();
    for (int i = 0; i < substituteMaterielList.length; i++) {
      list.add(
          ListItemSelectWidget(title: Text(substituteMaterielList[i].NAME1), item: substituteMaterielList[i], selectedItem: this._selectItem)
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context, null),
          color: Color.fromRGBO(94, 102, 111, 1),
        ),
        middle: Text(
          "总公司",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
          child: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  ..._buildList(widget.list)
                ],
              ),
              Align(
                child: ButtonBarWidget(
                  color: Color.fromRGBO(0, 0, 0, 0),
                  button: ButtonWidget(
                      color: Color.fromRGBO(163, 6, 6, 1),
                      child: Text("领取", style: TextStyle(color: Color.fromRGBO(163, 6, 6, 1)),),
                      onPressed: () {
                        if (this._selectItem != null) {
                          Navigator.of(context).pop(this._selectItem);
                        }
                      }),
                ),
              )
            ],
          )),
    );
  }
}