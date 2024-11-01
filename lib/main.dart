import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViaCepApp(),
    );
  }
}

class ViaCepApp extends StatefulWidget {
  const ViaCepApp({super.key});

  @override
  State<ViaCepApp> createState() => _ViaCepAppState();
}

class _ViaCepAppState extends State<ViaCepApp> {
  final TextEditingController _cepController = TextEditingController();

  Map<String, dynamic>? _adressData;
  bool _isLoading = false;
  String? _errorMessage;

  _fetchAddress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String cep = _cepController.text;
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(url);

    if(response.statusCode == 200){
      final data = json.decode(response.body);

      if(data.containsKey('erro')){
        setState(() {
          _errorMessage = data['CEP não encontrado.'];
          _adressData = null;
        });
      }else{
        setState(() {
          _adressData = data;
        });
      }
    }else{
      setState(() {
        _errorMessage = 'Erro ao buscar endereço';
        _adressData = null;
      });
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busca App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Digite o CEP: ',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 01001-00',
                ),
              ),
              FilledButton(
                onPressed: _isLoading? null : _fetchAddress,
                child: _isLoading
                  ? CircularProgressIndicator(color:  Colors.white,)
                  : Text('Buscar Endereço'),
              ),
              SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red),),
              if(_adressData != null)
                Column(
                  children: [
                    Divider(
                      thickness: 0,
                      color: Colors.grey,
                    ),
                    ListTile(
                      leading: Icon(Icons.location_city),
                      title: Text("Cidade: ${_adressData!['localidade']}"),
                    ),
                    Divider(
                      thickness: 0,
                      color: Colors.grey,
                    ),
                    ListTile(
                      leading: Icon(Icons.streetview),
                      title: Text("Logradouro: ${_adressData!['logradouro']}"),
                    ),
                    Divider(
                      thickness: 0,
                      color: Colors.grey,
                    ),
                    ListTile(
                      leading: Icon(Icons.map),
                      title: Text("Bairro: ${_adressData!['bairro']}"),
                    ),
                  ],
                )
            ],
          )
        ),
      ),
    );
  }
}