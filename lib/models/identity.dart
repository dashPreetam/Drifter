import 'package:flutter/material.dart';

enum Identity {
  googleEngineer,
  corporateCricketer,
  edmProducer,
  healthyAdult;

  String get label {
    switch (this) {
      case Identity.googleEngineer:
        return 'Google Engineer';
      case Identity.corporateCricketer:
        return 'Corporate Cricketer';
      case Identity.edmProducer:
        return 'EDM Producer';
      case Identity.healthyAdult:
        return 'Healthy Adult';
    }
  }

  IconData get icon {
    switch (this) {
      case Identity.googleEngineer:
        return Icons.terminal;
      case Identity.corporateCricketer:
        return Icons.sports_cricket;
      case Identity.edmProducer:
        return Icons.graphic_eq;
      case Identity.healthyAdult:
        return Icons.favorite;
    }
  }

  static Identity? fromName(String? name) {
    if (name == null) return null;
    for (final value in Identity.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
