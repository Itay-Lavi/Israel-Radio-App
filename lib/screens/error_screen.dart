import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  final bool internetError;

  const ErrorScreen(this.internetError, {Key? key}) : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/No-Connection.png',
                fit: BoxFit.cover, scale: 3),
            const SizedBox(height: 15),
            Text(widget.internetError ? 'שגיאת רשת' : 'שגיאה כללית',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            Text(
                widget.internetError
                    ? 'נא בדוק שיש למכשיר חיבור אינטרנט תקין'
                    : 'מצטערים, נא נסה מאוחר יותר',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.black, fontSize: 18)),
            _isLoading
                ? const SizedBox(
                    height: 48, width: 48, child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      Future.delayed(const Duration(milliseconds: 300), () {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    },
                    child: const Text(
                      'נסה שוב',
                      style: TextStyle(fontSize: 18),
                    ))
          ],
        ),
      ),
    );
  }
}
