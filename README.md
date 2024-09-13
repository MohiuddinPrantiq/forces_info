# Forces Info

Forces Info is an Android application built using Flutter that provides users with Codeforces profile details, friends list, upcoming contests, and contest notifications. The app is fully online and uses the Codeforces API to fetch the latest data.

## Features
- View Codeforces user profiles.
- Add and manage friends by searching for Codeforces handles manually.
- Stay updated with upcoming contests from Codeforces.
- Receive notifications 30 minutes before any contest starts (requires notification and alarm permissions).
- The email used in the app does not need to match the Codeforces account email. Any valid email will suffice for storing handles and friends.

## Technologies Used
- **Flutter**: For building the user interface.
- **Firebase**: For authentication and storing user data like email, handles, and friends.

## API Integrations
The app utilizes the following Codeforces APIs for fetching data:

1. **Contest Data**:  
   `https://codeforces.com/api/contest.list`

2. **User Profile Information**:  
   `https://codeforces.com/api/user.info?handles={cf_handle_name}`  
   *(Fetches details for one or multiple Codeforces users)*

3. **User's Rated Contest History**:  
   `https://codeforces.com/api/user.rating?handle={cf_handle_name}`

## Permissions
To enable contest notifications, ensure that the following permissions are granted:
- **Notification Permission**
- **Alarm & Reminder Permission**

A sample demo for enabling these permissions on **ONE-UI 6** is provided in the app.

## Getting Started

### Prerequisites
- Flutter SDK installed ([Get Started with Flutter](https://flutter.dev/docs/get-started/install))
- Firebase project setup ([Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup))

### Installation

1. Clone the repository:
   git clone https://github.com/MohiuddinPrantiq/forces_info.git
   
2. Navigate to the project directory:
   cd forces_info

3. Install dependencies:
   flutter pub get

4. Run the app:
   flutter run


