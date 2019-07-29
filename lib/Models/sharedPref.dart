// remove profileUrl var
import 'package:oye_yaaro_pec/Provider/SqlCool/database_creator.dart';
import 'package:shared_preferences/shared_preferences.dart';

final SharedPref pref = new SharedPref();

class SharedPref {
  int phone, pin;
  String name, profileUrl, groupId, collegeName; //email, address,
  int currentIndex = 0;
  bool connectionListener, hideMedia, getPrivateChatHistory;

  Future<String> getValues() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    name = (_prefs.getString('userName') ?? null);
    phone = (_prefs.getInt('userPhone') ?? null);
    pin = (_prefs.getInt('pin') ?? null);
    // email = (_prefs.getString('userEmail') ?? null);
    // address = (_prefs.getString('userAddress') ?? null);
    // profileUrl = (_prefs.getString('profileUrl') ?? null);
    hideMedia = (_prefs.getBool('hideMedia') ?? null);
    getPrivateChatHistory = (_prefs.getBool('getPrivateChatHistory') ?? null);
    groupId = (_prefs.getString('collegeName') ?? null);
    collegeName = (_prefs.getString('collegeName') ?? null);

    return 'ok';
  }

  setName(String name) async {
    print('name:$name');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('userName', name);
    this.name = name;
  }

  setPhone(int phone) async {
    print('Phone:$phone');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setInt('userPhone', phone);
    this.phone = phone;
    // print(_prefs.getInt('userPhone'));
  }

  setPin(int pin) async {
    print('pin:$pin');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setInt('pin', pin);
    this.pin = pin;
    // print(_prefs.getInt('userPhone'));
  }

  // setEmail(String email) async {
  //   print('email:$email');
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   _prefs.setString('userEmail', email);
  //   this.email = email;
  // }

  // setAddr(String addr) async {
  //   print('addr:$addr');
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   _prefs.setString('userAddr', addr);
  //   address = addr;
  // }

  setProfile(String url) async {
    print('name:$url');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('profileUrl', url);
    profileUrl = url;
    // print("----------------------------------------" + profileUrl);
  }

  setHideMedia(bool val) async {
    print('hide media:$val');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool('hideMedia', val);
    hideMedia = val;
  }

  setPrivateChatHistory(bool val) async {
    print('setPrivateChatHistory: $val');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool('getPrivateChatHistory', val);
    getPrivateChatHistory = val;
  }

  setGroupId(String gid) async {
    print('groupId:$gid');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('groupId', gid);
    groupId = gid;
  }

  setCollege(String cnm) async {
    print('college:$cnm');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('collegeName', cnm);
    collegeName = cnm;
  }

  clearUser() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
    name = null;
    phone = null;
    profileUrl = null;
    hideMedia = false;
    pin = null;
    groupId = null;
    collegeName = null;
    // db.database.close();
    db.database.delete('privateChatTable');
    db.database.delete('groupChatTable');
    db.database.delete('groupMembersTable');
    db.database.delete('privateChatListTable');
    db.database.delete('groupChatListTable');
  }
}
