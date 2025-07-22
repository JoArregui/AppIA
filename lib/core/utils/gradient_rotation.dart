import 'package:flutter/material.dart';

/// Un GradientTransform que aplica una rotación al gradiente.
class GradientRotation extends GradientTransform {
  final double angle;

  /// Crea un GradientRotation con el ángulo especificado en radianes.
  const GradientRotation(this.angle);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Calcula el centro del rectángulo para rotar alrededor de él
    final double centerX = bounds.left + bounds.width / 2.0;
    final double centerY = bounds.top + bounds.height / 2.0;

    // Crea una matriz de transformación
    // 1. Traslada al origen
    // 2. Rota
    // 3. Traslada de vuelta a la posición original
    return Matrix4.identity()
      ..translate(centerX, centerY)
      ..rotateZ(angle)
      ..translate(-centerX, -centerY);
  }

  @override
  // Es importante implementar la igualdad para que Flutter pueda optimizar las reconstrucciones.
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GradientRotation && other.angle == angle;
  }

  @override
  int get hashCode => angle.hashCode;
}