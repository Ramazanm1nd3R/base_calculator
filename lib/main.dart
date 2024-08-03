import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: CalculatorScreen(
        isDarkTheme: _isDarkTheme,
        onThemeChanged: () {
          setState(() {
            _isDarkTheme = !_isDarkTheme;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onThemeChanged;

  CalculatorScreen({required this.isDarkTheme, required this.onThemeChanged});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _expression = "";
  bool _isResultDisplayed = false;
  List<String> _history = [];

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _expression = "";
        _output = "0";
        _isResultDisplayed = false;
      } else if (buttonText == "=") {
        if (_expression.isEmpty) {
          return;
        }
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression.replaceAll('×', '*').replaceAll('÷', '/'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _output = _formatResult(eval);
          _isResultDisplayed = true;
          _history.add("$_expression = $_output");
        } catch (e) {
          _output = "Error";
        }
      } else {
        if (_isResultDisplayed) {
          _expression = buttonText;
          _isResultDisplayed = false;
        } else {
          if (buttonText == '.' && _expression.endsWith('.')) {
            return;
          }
          if (_expression.isEmpty && (buttonText == '0' || buttonText == '.')) {
            return;
          }
          if (_isOperator(buttonText) && (_expression.isEmpty || _isOperator(_expression[_expression.length - 1]))) {
            return;
          }
          _expression += buttonText;
        }
      }
    });
  }

  bool _isOperator(String buttonText) {
    return buttonText == '+' || buttonText == '-' || buttonText == '×' || buttonText == '÷';
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result.toString();
    }
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: OutlinedButton(
          onPressed: () => buttonPressed(buttonText),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ..._history.reversed.map((entry) => ListTile(
                  title: Text(entry),
                )),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  _output,
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(),
          ),
          Column(
            children: [
              Row(
                children: [
                  buildButton("7"),
                  buildButton("8"),
                  buildButton("9"),
                  buildButton("÷"),
                ],
              ),
              Row(
                children: [
                  buildButton("4"),
                  buildButton("5"),
                  buildButton("6"),
                  buildButton("×"),
                ],
              ),
              Row(
                children: [
                  buildButton("1"),
                  buildButton("2"),
                  buildButton("3"),
                  buildButton("-"),
                ],
              ),
              Row(
                children: [
                  buildButton("."),
                  buildButton("0"),
                  buildButton("00"),
                  buildButton("+"),
                ],
              ),
              Row(
                children: [
                  buildButton("("),
                  buildButton(")"),
                  buildButton("C"),
                  buildButton("="),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
