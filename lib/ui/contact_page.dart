import 'package:flutter/material.dart';
import 'dart:io';
import 'package:agendatelefonica/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPage createState() => _ContactPage();

}

class _ContactPage extends State<ContactPage> { 


  final _nameController = TextEditingController();
  final _adressController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdit = false;

  Contact _editContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editContact = Contact();
    }else{
      _editContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editContact.name;
      _phoneController.text = _editContact.phone;
      _adressController.text = _editContact.adress; 
    }
  }

  @override 
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editContact.name ?? 'Nuevo Contacto'),
          backgroundColor: Colors.orange[200],
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if (_editContact.name != null && _editContact.name.isNotEmpty) {
              Navigator.pop(context, _editContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }

          },
          child: Icon(Icons.save),
          backgroundColor: Colors.orange[200],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editContact.img != null ? FileImage(File(_editContact.img)) :
                      AssetImage('images/person.png')
                    )
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then(
                    (file){
                    if(file == null) return;
                    setState(() {
                      _editContact.img = file.path;
                    });
                    }
                  );
                } 
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                focusNode: _nameFocus,
                controller: _nameController,
                onChanged: (text){
                  _userEdit = true;
                  setState(() {
                    _editContact.name = text;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Nombre',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _phoneController,
                onChanged: (text){
                  _userEdit = true;
                  setState(() {
                    _editContact.phone = text;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Numero',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _adressController,
                onChanged: (text){
                  _userEdit = true;
                  setState(() {
                    _editContact.adress = text;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Dirección',
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Future<bool>_requestPop(){
    if(_userEdit){
      showDialog(context: context, 
        builder: (contex){
          return AlertDialog(
            title: Text('Deseas elimiar los cambios?'),
            content: Text('Si salís los cambios se perderán.'),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                child: Text('Cancelar')
              ),
              FlatButton(
                onPressed:(){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, 
                child: Text('Salir')
              )
            ],
          );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}