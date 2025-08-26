import 'package:flutter/material.dart';

class ParkingNoTimer extends StatelessWidget {
  const ParkingNoTimer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone sugestivo
          Icon(
            Icons.timer_off,
            color: Colors.red.withValues(alpha: 0.6),
            size: 24,
          ),
          const SizedBox(height: 6),
          // Mensagem com fonte maior e quebra de linha
          Text(
            'Não há estacionamento ativo\npara este veículo.',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
