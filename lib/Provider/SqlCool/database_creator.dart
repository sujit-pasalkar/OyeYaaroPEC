import 'package:firebase_database/firebase_database.dart';
import 'package:sqlcool/sqlcool.dart';

Db db = Db();
FirebaseDatabase database;

class DatabaseCreator {
  void initDatabase() {

    database = FirebaseDatabase.instance;
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    String q1 = """CREATE TABLE privateChatTable (
      timestamp TEXT PRIMARY KEY,
      chatId TEXT NOT NULL,
      senderName TEXT NOT NULL,
      msgMedia TEXT,
      senderPhone TEXT NOT NULL,
      msgType TEXT NOT NULL,
      receiverPhone TEXT NOT NULL,
      isUploaded TEXT NOT NULL,
      mediaUrl TEXT,
      thumbPath TEXT,
      thumbUrl TEXT
   )""";

    String q2 = """CREATE TABLE groupChatTable ( 
      timestamp TEXT PRIMARY KEY,
      chatId TEXT NOT NULL,
      senderName TEXT NOT NULL,
      msgMedia TEXT,
      senderPhone TEXT NOT NULL,
      msgType TEXT NOT NULL,
      isUploaded TEXT NOT NULL,
      mediaUrl TEXT,
      thumbPath TEXT,
      thumbUrl TEXT,
      profileImg TEXT NOT NULL
   )""";

    String q3 = """CREATE TABLE groupMembersTable ( 
      chatId TEXT NOT NULL,
      memberPhone TEXT NOT NULL,
      memberName TEXT NOT NULL,
      profileUrl TEXT NOT NULL,
      userType TEXT NOT NULL
   )""";

    String q4 = """CREATE TABLE privateChatListTable ( 
      chatId TEXT PRIMARY KEY,
      chatListLastMsg TEXT NOT NULL,
      chatListSenderPhone TEXT NOT NULL,
      chatListRecPhone TEXT NOT NULL,
      chatListLastMsgTime TEXT NOT NULL,
      chatListMsgCount TEXT NOT NULL,
      chatListProfile TEXT NOT NULL
   )""";

    String q5 = """CREATE TABLE groupChatListTable ( 
      chatId TEXT PRIMARY KEY,
      chatListLastMsg TEXT NOT NULL,
      chatListSenderPhone TEXT NOT NULL,
      chatListLastMsgTime TEXT NOT NULL,
      chatListMsgCount TEXT NOT NULL,
      chatGroupName TEXT NOT NULL
   )""";
    //get logo from chatid.png url

    String q6 = """CREATE TABLE contactsTable ( 
      contactsPhone TEXT PRIMARY KEY,
      contactsName TEXT,
      contactRegistered TEXT NOT NULL,
      profileUrl TEXT
   )""";

    // the path is relative to the documents directory
    String dbpath = "data.sqlite";
    List<String> queries = [q1, q2, q3, q4, q5, q6];
    db.init(path: dbpath, queries: queries, verbose: true).then((onValue) {
      print('SQLCOOL database successfully initialized create queries');
    }, onError: (e) {
      print('SQLCOOL database OnError:$e');
    }).catchError((e) {
      throw ("Error initializing the database: $e");
    });
  }
}
