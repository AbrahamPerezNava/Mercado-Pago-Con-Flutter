import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mercadopago_prueba/utils/globals.dart' as globals;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() {
    const channelMercadoPagoRespuesta =
        const MethodChannel("mercadopago.com/pagarRespuesta");

    channelMercadoPagoRespuesta.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'mercadopagook':
          var idPago = call.arguments[0];
          var status = call.arguments[1];
          var statusDetails = call.arguments[2];

          return mercadoPagoOk(idPago, status, statusDetails);

        case 'mercadopagoerror':
          var error = call.arguments[0];
          return mercadoPagoError(error);
      }
    });

    super.initState();
  }

  void mercadoPagoOk(idPago, status, statusDetails) {
    print('ID Pago: ' + idPago);
    print('Status: ' + status);
    print('Detalles: ' + statusDetails);
  }

  void mercadoPagoError(error) {
    print('Error: ' + error);
  }

  Future<Map<String, dynamic>> armarPreferncia() async {
    var mp = MP(globals.clientID, globals.clientSecret);

    var preference = {
      "items": [
        {
          "title": "Venta de calzado deportivo",
          "quantity": 1,
          "currency_id": "MXN",
          "unit_price": 2500
        }
      ],
      "payer": {"name": "Juan Hernandez", "email": "juan_hernan@outlook.com"},
      "payment_methods": {
        "excluded_payment_types": [
          {"id": "atm"}
        ]
      }
    };

    var result = await mp.createPreference(preference);

    return result;
  }

  void ejecutarMercadoPago() {
    armarPreferncia().then((result) {
      if (result != null) {
        var idPreference = result['response']['id'];

        try {
          const channelMercadoPago =
              const MethodChannel("mercadopago.com/pagar");

          final result = channelMercadoPago.invokeMethod(
              "mercadopago", <String, dynamic>{
            "publicKey": globals.publicKeyTEST,
            "preferenceID": idPreference
          });

          print(result.toString());
        } on PlatformException catch (e) {
          print(e.message);
        }

        print('resultado: ' + idPreference.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del producto'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Image(
                image: NetworkImage(
                    'https://ss203.liverpool.com.mx/xl/1102217876.jpg'),
                height: 300.0,
                width: 300.0,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              child: Column(
                children: [
                  Text(
                    'Tenis Jordan Rojos',
                    style: TextStyle(fontSize: 28.0),
                  ),
                  Text('\$2 500 MXN', style: TextStyle(fontSize: 22.0))
                ],
              ),
            ),
            SizedBox(
              height: 145.0,
            ),
            Container(
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        ejecutarMercadoPago();
                      },
                      child: Text('Comprar'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
