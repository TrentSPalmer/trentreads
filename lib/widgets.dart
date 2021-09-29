import 'package:flutter/material.dart';
import 'constants.dart';

Padding functionTile(String textContent, VoidCallback _onTap) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 6.0,
      vertical: 3.0,
    ),
    child: Container(
      decoration: myBoxDecoration(appColors.ivory),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTap,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    textContent,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Padding homeButton(BuildContext context, int _numPops) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 48.0,
      vertical: 48.0,
    ),
    child: Container(
      decoration: myBoxDecoration(appColors.ivory),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('home_button_ink_well'),
          onTap: () async {
            if (_numPops == 1) {
              Navigator.of(context).pop();
            } else if (_numPops == 2) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              Icons.home,
              size: 48,
            ),
          ),
        ),
      ),
    ),
  );
}

Padding okButton(BuildContext context, int _numPops) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 48.0,
      vertical: 48.0,
    ),
    child: Container(
      decoration: myBoxDecoration(appColors.ivory),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('ok_button_ink_well'),
          onTap: () async {
            if (_numPops == 1) {
              Navigator.of(context).pop();
            } else if (_numPops == 2) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Padding switchTile(
    String textContent, bool _currentVal, Function(bool) _onChanged) {
  return Padding(
    key: Key('switch_tile_for_$textContent'),
    padding: EdgeInsets.symmetric(
      horizontal: 6.0,
      vertical: 3.0,
    ),
    child: Container(
      decoration: myBoxDecoration(appColors.ivory),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                textContent,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Transform.scale(
              scale: 1.5,
              child: Switch(
                value: _currentVal,
                onChanged: (bool _newVal) {
                  _onChanged(_newVal);
                },
                activeTrackColor: appColors.peacockBlue,
                activeColor: appColors.navy,
                inactiveThumbColor: appColors.candyApple,
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Row infoTile(String textContent) {
  return Row(
    key: Key('info_tile_for_$textContent'),
    children: [
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 3.0,
          ),
          child: Container(
            decoration: myBoxDecoration(appColors.ivory),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                textContent,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Row navTile(BuildContext context, Widget destination, String textContent) {
  return Row(
    key: Key('nav_tile_for_$textContent'),
    children: [
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 3.0,
          ),
          child: Container(
            decoration: myBoxDecoration(appColors.ivory),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => destination,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    textContent,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
