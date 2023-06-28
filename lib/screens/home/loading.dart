import 'package:flutter/material.dart';

class LoadingEffect extends StatefulWidget {
  final Color? color;
  const LoadingEffect({this.color, Key? key}) : super(key: key);

  @override
  State<LoadingEffect> createState() => _LoadingEffectState();
}

class _LoadingEffectState extends State<LoadingEffect> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (constext, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: double.infinity,
                            height: 18,
                            color: widget.color ?? Colors.grey),
                        const SizedBox(width: 0, height: 8),
                        Container(
                            width: double.infinity,
                            height: 16,
                            color: widget.color ?? Colors.grey),
                        const SizedBox(width: 0, height: 8),
                        Container(
                            width: 100,
                            height: 16,
                            color: widget.color ?? Colors.grey),
                        const SizedBox(width: 0, height: 8),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: widget.color ?? Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 0, height: 16),
            ],
          ),
        );
      },
    );
  }
}
