import 'package:flutter/material.dart';

class WrapToggleToggleButtons extends StatefulWidget {
  final List<Widget>? iconList;
  final List<bool>? isSelected;
  final Function? onPressed;

  WrapToggleToggleButtons({
    @required this.iconList,
    @required this.isSelected,
    @required this.onPressed,
  });

  @override
  _WrapToggleToggleButtonsState createState() =>
      _WrapToggleToggleButtonsState();
}

class _WrapToggleToggleButtonsState extends State<WrapToggleToggleButtons> {
  int index= 0;

  @override
  Widget build(BuildContext context) {
    assert(widget.iconList!.length == widget.isSelected!.length);
    index = -1;
    return Wrap(
      children: widget.iconList!.map((Widget icon) {
        index++;
        return ToggleButton(
          active: widget.isSelected![index],
          icon: icon,
          onTap: widget.onPressed!,
          index: index,
        );
      }).toList(),
    );
  }
}

class ToggleButton extends StatelessWidget {
  final bool? active;
  final Widget? icon;
  final Function? onTap;
  final int? width;
  final int? height;
  final int? index;

  ToggleButton({
    @required this.active,
    @required this.icon,
    @required this.onTap,
    @required this.index,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 63,
      height: 98,
      decoration: BoxDecoration(
        border: active! ? Border.all(color: Colors.black, width: 4.0) : null,
        borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
      ),
      child: InkWell(
        child: icon,
        onTap: () => onTap!(index),
      ),
    );
  }
}
