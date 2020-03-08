import 'package:flutter/cupertino.dart';
import 'package:gztyre/api/model/Materiel.dart';
import 'package:gztyre/components/ButtonBarWidget.dart';
import 'package:gztyre/components/ButtonWidget.dart';
import 'package:gztyre/components/ListItemSelectWidget.dart';
import 'package:gztyre/components/ListItemWidget.dart';
import 'package:gztyre/pages/orderCenter/noPlanOrder/MaterielCompanyPage.dart';
import 'package:gztyre/pages/orderCenter/noPlanOrder/SubstituteMaterialPage.dart';

class MaterielDetailPage extends StatelessWidget {
  MaterielDetailPage({Key key, @required this.materiel, @required this.materielList}) : super(key: key);
  final Materiel materiel;
  final List<Materiel> materielList;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(94, 102, 111, 1),
        ),
        middle: Text(
          materiel.MAKTX,
          style: TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: SafeArea(
          child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              ListItemSelectWidget(title: Text("本公司"), selectedItem: null, item: materiel, count: materiel.LABST,),
              ListItemWidget(title: Text("总公司"), count: materiel.SUMLABST, onTap: () {
                List list = materielList.where((item) {
                  return item.MATNR == materiel.MATNR && item.MATYP != materiel.MATYP;
                }).toList();
                if (materiel.SUMLABST - materiel.LABST == 0 || list.length == 0) {
                  showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          content: Text(
                            "无其他公司信息",
                            style: TextStyle(fontSize: 18),
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("好"),
                            ),
                          ],
                        );
                      });
                } else {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                    return MaterielCompanyPage(list: list,);
                  })).then((val) {
                    if (val != null && ModalRoute.of(context).settings.name != "materiealPage") {
                      Navigator.of(context).pop(val);
                    }
                  });
                }
              },),
              ListItemWidget(title: Text("替代料"), onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
                  return SubstituteMaterialPage(list: this.materiel.list,);
                })).then((val) {
                  if (val != null && ModalRoute.of(context).settings.name != "materiealPage") {
                    Navigator.of(context).pop(val);
                  }
                });
              }),
            ],
          ),
          Align(
            child: ButtonBarWidget(
              color: Color.fromRGBO(0, 0, 0, 0),
              button: ButtonWidget(
                  color: Color.fromRGBO(76, 129, 235, 1),
                  child: Text("领取", style: TextStyle(color: Color.fromRGBO(76, 129, 235, 1)),),
                  onPressed: () {
                      Navigator.of(context).pop(this.materiel);
                  }),
            ),
          )
        ],
      )),
    );
  }
}
