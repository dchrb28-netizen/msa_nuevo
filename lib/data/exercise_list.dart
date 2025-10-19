import 'package:flutter/material.dart';
import 'package:myapp/models/exercise.dart';

final List<Exercise> exerciseList = [
  Exercise(
    id: 'e1',
    name: 'Push-ups',
    description: 'A classic bodyweight exercise that works the chest, shoulders, and triceps.',
    type: 'Strength',
    muscleGroup: 'Chest',
    equipment: 'None',
    icon: Icons.fitness_center,
  ),
  Exercise(
    id: 'e2',
    name: 'Squats',
    description: 'A fundamental lower-body exercise that targets the quadriceps, hamstrings, and glutes.',
    type: 'Strength',
    muscleGroup: 'Legs',
    equipment: 'None',
    icon: Icons.fitness_center,
  ),
  Exercise(
    id: 'e3',
    name: 'Pull-ups',
    description: 'A challenging upper-body exercise that primarily works the back and biceps.',
    type: 'Strength',
    muscleGroup: 'Back',
    equipment: 'Pull-up bar',
    icon: Icons.fitness_center,
  ),
  Exercise(
    id: 'e4',
    name: 'Plank',
    description: 'An isometric core exercise that involves maintaining a position similar to a push-up for the maximum possible time.',
    type: 'Strength',
    muscleGroup: 'Core',
    equipment: 'None',
    icon: Icons.fitness_center,
  ),
  Exercise(
    id: 'e5',
    name: 'Running',
    description: 'A cardiovascular exercise that is effective for improving endurance and burning calories.',
    type: 'Cardio',
    muscleGroup: 'Legs',
    equipment: 'None',
    icon: Icons.directions_run,
  ),
];
