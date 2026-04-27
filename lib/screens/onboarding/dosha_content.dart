import 'package:flutter/material.dart';

class DoshaContent extends StatelessWidget {
  const DoshaContent({
    super.key,
    required this.assetPath,
    required this.title,
    required this.titleColor,
    required this.description,
    required this.gradientColors,
  });

  final String assetPath;
  final String title;
  final Color titleColor;
  final List<Color> gradientColors;
  final List<String> description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: const [0.0, 0.58, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 168),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                assetPath,
                height: 118,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                    ),
              ),
              const SizedBox(height: 22),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < description.length; i++) ...[
                        Text(
                          description[i],
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        if (i != description.length - 1)
                          const SizedBox(height: 22),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
