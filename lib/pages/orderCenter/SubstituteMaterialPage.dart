import 'package:flutter/cupertino.dart';
import 'package:gztyre/api/model/Materiel.dart';
import 'package:gztyre/components/ListItemShopChartWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/components/SearchBar.dart';
import 'package:gztyre/pages/orderCenter/MaterielDetailPage.dart';
import 'package:gztyre/pages/orderCenter/SubstituteMaterialDetailPage.dart';

class SubstituteMaterialPage extends StatefulWidget {

  SubstituteMaterialPage({Key key, this.list}) : super(key: key);
  final List<SubstituteMateriel> list;

  @override
  State createState() => _SubstituteMaterialPageState();
}

class _SubstituteMaterialPageState extends State<SubstituteMaterialPage> {

  List<Widget> _buildList(List<SubstituteMateriel> list) {
    List<Widget> widgetList = new List();
    if (list.length == 0) {
      return widgetList;
    }
    list.forEach((item) {
      Widget listItem = ListItemWidget(title: Text(item.REMAKTX), onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
          return SubstituteMaterielDetailPage(materielList: list, materiel: item);
        })).then((val) {
          if (val != null && ModalRoute.of(context).settings.name != "materielPage") {
            Navigator.of(context).pop(val);
          }
        });
      },);
      widgetList.add(listItem);
    });
    return widgetList;
  }

//  @override
//  void initState() {
//    this._loading = true;
//    setState(() {});
//    this._listMaterielFuture = new Future.delayed(Duration(seconds: 1), () {
//      for (int i = 0; i < 10; i++) {
//        Materiel temp = new Materiel();
//        temp.MATNR = (i * 999).toString();
//        temp.MAKTX = 'aaaaa$i';
//        temp.LABST = 10;
//        temp.SUMLABST = 20;
//        temp.MATYP = 'comp$i';
//        temp.MATYT = '公司$i';
//        for (int j = 0; j < 10; j++) {
//          SubstituteMateriel temp2 = new SubstituteMateriel();
//          temp2.REMATNR = (j * 888).toString();
//          temp2.REMAKTX = 'bbbbb$j';
//          temp.LABST = 10;
//          temp.SUMLABST = 20;
//          temp2.MATYP = 'comp$j';
//          temp2.MATYT = '公司$j';
//        }
//        _materielList.add(temp);
//      }
//      this._loading = false;
//      setState(() {});
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context, null),
          color: Color.fromRGBO(94, 102, 111, 1),
        ),
        middle: Text(
          "替代料",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
//        child: BottomDragWidget(
//          body: CupertinoScrollbar(
          child: ListView(
            children: <Widget>[
              ...this._buildList(widget.list)
            ],
          )
//          ),
//        ),
      ),
    );
  }
}