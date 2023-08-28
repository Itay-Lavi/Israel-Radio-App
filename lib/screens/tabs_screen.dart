import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/channels_provider.dart';
import '../widgets/player/channels_bottom_player.dart';
import './channels_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final channelsProv = context.read<ChannelsProvider>();
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary
            ],
          ),
        ),
      ),
      FutureBuilder(
          future: channelsProv.initData(),
          builder: (ctx, chanSnapShot) {
            if (chanSnapShot.hasError) {
              if (chanSnapShot.error.toString().contains('SocketException')) {
                return _errorWidget(
                    true); //Return error screen widget with internet error message
              }
              return _errorWidget(
                  false); //Return error screen widget with general error message
            }
            return chanSnapShot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      const TabBarView(
                        children: [
                          ChannelsList(false), //כל התחנות
                          ChannelsList(true), //מעודפים
                        ],
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: chanSnapShot.connectionState ==
                                  ConnectionState.waiting
                              ? Container()
                              : ChannelsBottomPlayer()),
                    ],
                  );
          })
    ]);
  }

  SizedBox _errorWidget(bool internetError) {
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
            Text(internetError ? 'שגיאת רשת' : 'שגיאה כללית',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            Text(
                internetError
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
