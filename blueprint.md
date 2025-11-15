# Blueprint: My Health and Fitness App

## Overview

This document outlines the features and design of the "My Health and Fitness App". The application helps users track various aspects of their health, including diet, exercise, and body measurements.

## Implemented Features & Design

### **User Profile Management**

*   **User Profiles**: Users can create multiple profiles to track their health and fitness data separately.
*   **Guest Mode**: A guest mode is available for users who want to try the app without creating a profile.
*   **Profile Switching**: Users can easily switch between different profiles.
*   **Delete User Profiles**:
    *   Users can delete their profiles from the profile selection screen.
    *   A confirmation dialog is displayed to prevent accidental deletion.
    *   If the currently active profile is deleted, the user is logged out.

### **Core Functionality**

*   **Dashboard**: A central dashboard provides an overview of the user's daily progress.
*   **Food Tracking**: Users can log their daily food intake.
*   **Water Tracking**: Users can track their daily water consumption.
*   **Exercise Tracking**: Users can log their workouts and exercises.
*   **Body Measurements**: Users can track their body measurements, such as weight and height.
*   **History**: Users can view their historical data for all tracked metrics.

### **Exercise Library**

*   **Predefined Exercises**: The app now includes a default library of exercises.
*   **Categorization**: Exercises are categorized by muscle group (e.g., Legs, Arms, Glutes, Chest, Back, Core).
*   **Visual Grouping**: The exercise library screen displays exercises grouped by muscle group in expandable cards (`ExpansionTile`).
*   **Icons**: Each muscle group is represented by a unique icon for quick visual identification.
*   **Search Functionality**: A search bar allows users to easily filter and find specific exercises by name, muscle group, or equipment.
*   **CRUD Operations**: Users can still add, edit, and delete their own custom exercises.
*   **Initial Data Loading**: The `ExerciseProvider` now preloads the default exercise list into the local database on the first launch.
*   **Loading Indicator**: A `CircularProgressIndicator` is displayed while the initial exercises are being loaded.

## Plan for Current Request: Fix Empty Exercise Library

1.  **Initialize `ExerciseProvider` with Default Data**: (✓ Done)
    *   Modified `lib/providers/exercise_provider.dart` to check if the exercise database is empty upon initialization.
    *   If empty, it now populates the database with the predefined `exerciseList`.
2.  **Add Loading Indicator**: (✓ Done)
    *   Updated `lib/screens/training/exercise_library_screen.dart` to show a `CircularProgressIndicator` while the provider is loading the initial data.
3.  **Fix Grouping Logic**: (✓ Done)
    *   Corrected a minor bug in `lib/screens/training/exercise_library_screen.dart` to ensure exercises are correctly grouped by muscle group after filtering.
4.  **Update `blueprint.md`**: Document the bug fixes and improvements. (✓ Done)
