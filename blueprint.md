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

## Plan for Current Request: Add Profile Deletion

1.  **Modify `lib/screens/profile_selection_screen.dart`**: (✓ Done)
    *   Add a delete button to each profile in the list.
    *   Implement a confirmation dialog to prevent accidental deletion.
2.  **Modify `lib/providers/user_provider.dart`**: (✓ Done)
    *   Implement a `deleteUser` method to remove the user from the database.
    *   Handle the case where the active user is deleted.
3.  **Update `blueprint.md`**: Document the new profile deletion feature. (✓ Done)