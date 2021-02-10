import 'package:agendatelefonica/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/contact_helper.dart';

enum OrderOptions {
  orderaz,
  orderza
}

class HomePage extends StatefulWidget {

  @override
  _HomePage createState() => _HomePage();

}

class _HomePage extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
          },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[200],
      ),
      appBar: AppBar(
        title: Text('Contactos'),
        backgroundColor: Colors.orange[200],
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.orderza,
              )
            ],
            onSelected:_orderList
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return ContactsCard(context, index);
        }
      ),
    ); 
  }

  Widget ContactsCard (BuildContext context, int index){
    return GestureDetector(
      onTap: (){
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ? FileImage(File(contacts[index].img)) :
                    AssetImage('images/person.png')
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacts[index].name ?? "", 
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(contacts[index].adress ?? "", 
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(contacts[index].phone ?? "", 
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ) 
                  ]
                ),
              )
            ],
          ),
        )
      )  
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
      context: context, 
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                      child: FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                        launch('tel: ${contacts[index].phone}');
                      }, 
                      child: Text('Discar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20
                        )
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      }, 
                      child: Text('Editar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20
                        )
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: (){
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      }, 
                      child: Text('Eliminar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20
                        )
                      )
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }


  void _showContactPage({Contact contact}) async {

    final reqContact = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => ContactPage(contact: contact)
      )
    );

    if (reqContact != null) {
      if(contact != null){
        await helper.updateContact(reqContact);
      }else{
        await helper.saveContact(reqContact);
      }
      _getAllContacts();
    } 
  }

  void _getAllContacts(){
    helper.getrAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void  _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {
      
    });
  }
}

