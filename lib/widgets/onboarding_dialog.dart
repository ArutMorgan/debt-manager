import 'package:flutter/material.dart';

class OnboardingDialog extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onAddDebt;

  const OnboardingDialog({
    super.key,
    required this.onDismiss,
    required this.onAddDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Привет 👋',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  'Добавь свой первый долг и начни выходить из долговой ямы.\n\n'
                  '✕ — закрыть\n+ — добавить ещё долг',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDismiss,
                      child: const Text('Позже'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAddDebt,
                      child: const Text('Добавить долг'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}