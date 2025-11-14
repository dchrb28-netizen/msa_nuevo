# Blueprint: Habit Tracker App - Intermittent Fasting Module

## Overview

This document outlines the features and design of the Intermittent Fasting module within the Habit Tracker application. The goal is to provide a comprehensive, motivating, and visually engaging experience for users tracking their fasting habits.

## Implemented Features & Design

This is a summary of the features implemented in the current version of the Intermittent Fasting screen.

### Core Functionality
- **Fasting Timer**: Tracks the duration of the current fast or the time within the feeding window.
- **Start/Stop Control**: Users can manually start and stop their fasting periods.
- **Plan Selection**: Users can choose from a list of predefined fasting plans (e.g., 16:8, 18:6).
- **History Tracking**: All completed fasts are saved locally, displaying start time, end time, and total duration.
- **Statistics**: The app calculates and displays key stats like the longest fast and the average fast duration.

### Advanced Features (Newly Implemented)
1.  **Custom Fasting Plans**:
    - Users can create their own fasting plans by specifying the fasting duration.
    - Custom plans can be edited or deleted with a long-press gesture.
2.  **Educational Fasting Timeline**:
    - The timeline now displays enriched, motivational descriptions for each phase of the fast (Anabolic, Catabolic, Fat Burning, Autophagy, etc.).
    - Users can tap on a phase to learn about the benefits their body is experiencing at that moment.
3.  **Fasting Journal**:
    - Users can add, edit, and view personal notes for each completed fast in their history.
    - This allows for tracking feelings, energy levels, or any other relevant information.
4.  **Smart Notifications**:
    - Users receive notifications at the start and successful completion of a fast.
    - **Phase Change Alerts**: A key feature that sends a notification each time the user enters a new fasting phase, keeping them informed and motivated.

### Visual & UX Design (Newly Implemented)
1.  **Interactive Sun & Moon Timer**:
    - The standard circular progress bar has been replaced with a custom-painted, animated timer.
    - A sun icon (☀️) travels along an arc during the feeding window, set against a bright, daytime sky gradient.
    - A moon icon (🌙) travels along the arc during the fasting period, set against a dark, nighttime sky gradient.
    - This provides an intuitive and visually delightful representation of the user's progress.
2.  **Dynamic Background**:
    - The entire background of the fasting tab animates smoothly between two states:
        - A light, energetic gradient during the feeding window.
        - A dark, calm gradient during the fasting period.
    - This creates an immersive experience that complements the Sun & Moon timer.
3.  **Modern UI Components**:
    - `ChoiceChip` for plan selection provides clear visual feedback.
    - `Card`, `ListTile`, and `TimelineTile` are used for a clean, organized, and modern layout.
    - Dialogs and bottom sheets are used for intuitive user interactions like adding plans or notes.

## Plan for Current Request: Upload to GitHub

1.  **Create `blueprint.md`**: Document all the newly implemented features and design changes in this file. (✓ Done)
2.  **Initialize Git Repository**: Use `git init` to prepare the project for version control.
3.  **Stage All Files**: Use `git add .` to include all project files in the first commit.
4.  **Create Initial Commit**: Use `git commit -m "feat: Implement enhanced intermittent fasting tracker"` to save the current state.
5.  **Provide User Instructions**: Explain to the user how to create a new, empty repository on GitHub.com.
6.  **Request Repository URL**: Ask the user to provide the URL for the newly created GitHub repository.
7.  **Push to GitHub**: Once the URL is provided, add it as a remote origin (`git remote add origin <URL>`) and push the `main` branch (`git push -u origin main`).
