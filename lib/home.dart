import 'package:brasil_fields/brasil_fields.dart';
import 'package:credit_card_scanner/credit_card_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name, cardNumber, validityNumber, cvv;
  String initialCardNumber = "0";
  bool cvvBool = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  final cvvFormatter =
      MaskTextInputFormatter(mask: "###", filter: {"#": RegExp(r'[0-9]')});

  CardDetails? _cardDetails;
  CardScanOptions scanOptions = const CardScanOptions(
    scanCardHolderName: true,
    // enableDebugLogs: true,
    validCardsToScanBeforeFinishingScan: 5,
    possibleCardHolderNamePositions: [
      CardHolderNameScanPosition.aboveCardNumber,
    ],
  );

  Future<void> scanCard() async {
    final CardDetails? cardDetails =
        await CardScanner.scanCard(scanOptions: scanOptions);
    if (!mounted || cardDetails == null) return;
    setState(() {
      _cardDetails = cardDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Novo Cartão"),
          centerTitle: true,
          backgroundColor: Colors.teal[800],
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.done))],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CreditCardWidget(
                    cardNumber: cardNumber == null ? "" : cardNumber!,
                    expiryDate: validityNumber == null ? "" : validityNumber!,
                    cardHolderName: name == null ? "" : name!,
                    cvvCode: cvv == null ? "" : cvv!,
                    showBackView: cvvBool,
                    isHolderNameVisible: true,
                    labelCardHolder: "NOME IMPRESSO NO CARTÃO",
                    onCreditCardWidgetChange: (CreditCardBrand) {}, //
                    cardBgColor: Colors.teal,
                    //backgroundImage: "images/diobra_icon.png",
                    cardType: initialCardNumber == "3"
                        ? CardType.americanExpress
                        : initialCardNumber == "4"
                            ? CardType.visa
                            : initialCardNumber == "5"
                                ? CardType.mastercard
                                : initialCardNumber == "6"
                                    ? CardType.discover
                                    : initialCardNumber == null
                                        ? null
                                        : null),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    onChanged: (c) {
                      setState(() {
                        name = nameController.text;
                      });
                    },
                    textCapitalization: TextCapitalization.characters,
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Nome impresso no cartão",
                      fillColor: Colors.black,
                      prefixIcon: const Icon(
                        Icons.credit_card,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          //color: Colors.yellow,
                          width: 2.5,
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    onChanged: (c) {
                      setState(() {
                        cardNumber = cardNumberController.text;
                        if (cardNumber == null) {
                          setState(() {
                            initialCardNumber = "0";
                          });
                        } else if (cardNumber!.length >= 1) {
                          setState(() {
                            initialCardNumber = cardNumber!.substring(0, 1);
                          });
                        }
                      });
                    },
                    onSubmitted: (s) {},
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CartaoBancarioInputFormatter()
                    ],
                    decoration: InputDecoration(
                      labelText: "Número do cartão",
                      fillColor: Colors.black,
                      prefixIcon: const Icon(
                        Icons.credit_card,
                      ),
                      suffixIcon: IconButton(
                          onPressed: () async {
                            scanCard();
                            print(_cardDetails);
                            setState(() {
                              cardNumber = _cardDetails!.cardNumber;
                              cardNumberController.text =
                                  _cardDetails!.cardNumber;
                              validityNumber = _cardDetails!.expiryDate;
                              validityController.text =
                                  _cardDetails!.expiryDate;
                            });
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.black54,
                          )),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          //color: Colors.yellow,
                          width: 2.5,
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 50,
                      child: TextField(
                          onChanged: (c) {
                            setState(() {
                              validityNumber = validityController.text;
                            });
                          },
                          controller: validityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ValidadeCartaoInputFormatter(maxLength: 6)
                          ],
                          decoration: InputDecoration(
                            labelText: "Validade",
                            fillColor: Colors.black,
                            prefixIcon: const Icon(
                              Icons.date_range,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                //color: Colors.yellow,
                                width: 2.5,
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 50,
                      child: TextField(
                          onTap: () {
                            setState(() {
                              cvvBool = true;
                            });
                          },
                          onChanged: (c) {
                            setState(() {
                              cvv = cvvController.text;
                            });
                          },
                          onSubmitted: (s) {
                            setState(() {
                              cvvBool = false;
                            });
                          },
                          controller: cvvController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [cvvFormatter],
                          decoration: InputDecoration(
                            labelText: "CVV",
                            fillColor: Colors.black,
                            prefixIcon: const Icon(
                              Icons.numbers,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                //color: Colors.yellow,
                                width: 2.5,
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void flushBarWidget(String title, String message, IconData icon,
      Color iconColor, Color backgroundColor) {
    Flushbar(
        title: "$title",
        message: "$message",
        icon: Icon(
          icon,
          color: iconColor,
        ),
        duration: Duration(seconds: 4),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: backgroundColor,
        mainButton: TextButton(
          onPressed: () {},
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white),
          ),
        )).show(context);
  }
}
