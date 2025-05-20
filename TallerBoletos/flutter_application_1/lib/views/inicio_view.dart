import 'package:flutter/material.dart';
import 'resultado_view.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InicioViewState createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final TextEditingController _boletoControllerInput = TextEditingController();

  void _validarBoleto() {
    final numero = int.tryParse(_boletoControllerInput.text);
    if (numero != null && _boletoControllerInput.text.length == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultadoView(numeroBoleto: numero),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Ingrese un número válido de 5 dígitos'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validador de Boletos'),
        centerTitle: true,
        leading: Icon(Icons.confirmation_number),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.event_seat,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Ingrese el número de su boleto para verificar su validez.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  TextField(
                    controller: _boletoControllerInput,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número del boleto',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _validarBoleto,
                      icon: Icon(Icons.check_circle),
                      label: Text('Validar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}