import 'package:flutter/material.dart';

import 'package:mysql8_on_my_phone/format.dart';
import 'package:mysql_client/mysql_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MySQL8 Quick',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.light,
      ),
      home: const MyHomePage(title: 'MySQL8 Quick'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) :super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //文字列を受け取る
  var myHost = '';
  var myUserName = '';
  var myPassword = '';
  var myDatabase = '';
  var myPort = 3306;

  var myQuery = '';

  List<Map<String, String>> displayList = [];


  Future<void> _operate() async {
    debugPrint("connecting");
    //接続する
    final conn = await MySQLConnection.createConnection(
        host: myHost,
        port: myPort,
        userName: myUserName,
        password: myPassword,
        databaseName: myDatabase,
    );

    await conn.connect();
    debugPrint("connected");

    //クエリ実行
    var result = await conn.execute(myQuery);
    debugPrint("query done");

    //結果を返す
    List<Map<String, String>> list = [];
    for (final row in result.rows) {
      final data = {
        'field0': row.colAt(0)?? "",
        'field1': row.colAt(1)?? "",
        'field2': row.colAt(2)?? "",
        'field3': row.colAt(3)?? "",
      };
      list.add(data);
    }
    debugPrint("result return");

    setState(() {
      displayList = list;
      debugPrint("well done");
    });

    //切断
    await conn.close();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
          flex: 2,
            child: Column(
              children: [
                Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.brown),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(13.0),
                              child: Text(
                                'Your account & query:',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Format(
                              hintText: 'host',
                              onChanged: (text) {
                                myHost = text;
                              }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Format(
                              hintText: 'user name',
                              onChanged: (text) {
                                myUserName = text;
                              }
                          ),
                        ),]),
                  ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Obscure(
                                  hintText: 'password',
                                  onChanged: (text) {
                                    myPassword = text;
                                  }
                              ),
                            ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Format(
                              hintText: 'database',
                              onChanged: (text) {
                                myDatabase = text;
                              }
                          ),
                        ),
                          Padding(
                          padding: const EdgeInsets.all(5.0),
                            child: Format(
                              hintText: 'port',
                              onChanged: (text) {
                                myPort = text as int;
                              }
                            ),
                          ),
                        ]),
                      ),
                ]),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Format(
                        hintText: 'ex: SELECT * FROM myTable',
                        onChanged: (text) {
                          myQuery = text;
                        }
                    ),
                ),
          ]),
          ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child:
                Column(children: displayList.map<Widget>((data) {
                  return Card(
                    child: ListTile(
                      leading: Text(data['field0']?? ""),
                      title: Text(data['field1']?? ""),
                      subtitle: Text(data['field2']?? ""),
                      trailing: Text(data['field3']?? ""),
                    )
                  );
                }).toList()
                ),
              ))
          ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _operate,
        tooltip: 'Go!',
        label: const Text("Go!"),
      ),
    );
  }
}
