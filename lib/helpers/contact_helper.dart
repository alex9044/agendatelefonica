import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';


final String contactTable = 'contactTable';
final String idColum = 'idColum';
final String nameColum = 'nameColum';
final String phoneColum = 'phoneColum';
final String adressColum = 'adressColum';
final String imgColum = 'imgColum'; 

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper () => _instance;

  ContactHelper.internal();

  Database _database;

  Future<Database> get db async {
    if(_database != null){
      return _database;
    }else{
      _database = await initDb();
      return _database;
    }
  } 

  
  
  Future<Database> initDb() async {

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");
    return await openDatabase(path,version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColum INTEGER PRIMARY KEY, $nameColum TEXT, $phoneColum TEXT, $adressColum TEXT, $imgColum TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable, 
      columns: [idColum, nameColum, adressColum, phoneColum, imgColum],
      where: "$idColum = ? ",
      whereArgs: [id]
    );
    if(maps.isNotEmpty){
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable, 
      where: "$idColum = ?",
      whereArgs: [id]  
    );
  }

  Future<int> updateContact (Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable, 
      contact.toMap(),
      where: "$idColum = ?",
      whereArgs: [contact.id]
    );
  }

  Future <List>  getrAllContacts () async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in  listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    return await dbContact.close();
  }

}

class Contact {
  int id;
  String name;
  String phone;
  String img;
  String adress;

  Contact();

  Contact.fromMap(Map map){
    id = map[idColum];
    name = map[nameColum];
    phone = map[phoneColum];
    img = map[imgColum];
    adress = map[adressColum];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColum: name,
      phoneColum: phone,
      adressColum: adress,
      imgColum: img
    };

    if(id != null){
      map[idColum] = id;
    }
    return map;
  }

  @override 
  String toString() {
    return "Contact(id: $id,name: $name, phone: $phone, adress: $adress, img: $img)";
  }
}