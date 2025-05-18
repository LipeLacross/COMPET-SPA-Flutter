## 🌐 [English Version of README](README_EN.md)

# **GeoMap** - Payment for Environmental Services System

**GeoMap** is a system developed with Flutter, designed to manage beneficiaries, reports, geographical location, and integrations with external services, including Firebase and REST APIs. It offers an intuitive interface to visualize, edit, and register information about environmental areas and beneficiaries' activities, with a focus on features like geolocation, push notifications, and offline storage.

## 🔨 **Project Features**

* **User Authentication**: Implementation of login, registration, password recovery, and authentication with Firebase.
* **Beneficiary Management**: Viewing, editing, and registering beneficiaries, with detailed information such as personal data and geospatial location.
* **Reports**: Creation, editing, and synchronization of reports with data on environmental areas, vegetation types, and other resources.
* **Location and Geolocation**: Obtaining the user’s location and manipulating EXIF data from photos, with GPS coordinates support.
* **Push Notifications**: Sending push notifications to users using Firebase Messaging.
* **Local Storage**: Support for offline data storage, using `SharedPreferences` with automatic synchronization when the network is available.
* **Dashboard**: A control panel with interactive graphs and maps that display information about beneficiaries and their activities.
* **Interactive Maps**: Displaying beneficiaries on the map with geospatial data, using `flutter_map` to create dynamic and interactive maps.

### Visual Example of the Project

<div style="display: flex; flex-wrap: wrap; justify-content: space-between;">
  <img src="https://github.com/user-attachments/assets/fea2d5cc-fc22-44c8-b6dc-c5e00cc0b77e" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/5c7938a9-ef30-4d6d-a23b-d6444df922ad" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/737f4c6d-ba1e-4901-a84f-90476bd5df8f" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/16409d2f-00fa-4243-9dfd-befcf9346556" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/bbdbf443-6f87-462f-bd6d-c3c9853011dc" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/77eb7cda-c25e-4e10-89cc-b01879664990" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/bfd20482-e66f-4c4e-a3e0-6188b7540eee" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/6c465a6e-9147-4688-b9a4-1480d0cc35ce" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/f476f515-9eb7-4a1a-81e1-61753094e2b9" style="width: 30%; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/5caba9f1-6b82-450e-bcb9-5fb849d3cc5b" style="width: 30%; margin-bottom: 10px;">
</div>

## ✔️ **Technologies and Tools Used**

* **Flutter**: Framework used for mobile application development.
* **Firebase**: User authentication and push notification services.
* **Geolocator**: For obtaining the user’s geographic location.
* **Exif**: For manipulating EXIF data in images.
* **SharedPreferences**: For local persistent data storage.
* **http**: For making HTTP requests and interacting with external APIs.
* **Cupertino Icons**: For custom iOS-style icons.
* **flutter\_localizations**: For multi-language support.
* **CSV and PDF**: Handling CSV files and generating PDFs for reports.
* **Webview**: To render web content inside the app.
* **image\_picker**: To pick images or take new photos.
* **permission\_handler**: For managing access permissions.
* **fl\_chart**: For interactive graphs within the app.
* **hive**: Local NoSQL database.
* **path\_provider**: To find the proper directory for storing files.
* **easy\_localization**: For easier translation and internationalization of the app.
* **uuid**: To generate unique identifiers (UUIDs).
* **flutter\_launcher\_icons**: For setting up and generating app icons.
* **flutter\_local\_notifications**: For managing local notifications in the app.
* **csv**: For handling CSV file manipulation.
* **pdf and printing**: For generating and printing PDF documents.
* **webview\_flutter**: To display web content within the app.
* **latlong2**: For handling geographic coordinates in latitude and longitude formats.
* **firebase\_core**: For integrating Firebase into the project.

## 📁 **Project Structure and Description of Each Folder/File**

### **|-- Project 3.txt**

* **Description**: A text file that likely contains project-related information or specifications, such as notes, ideas, or planning details.

### **|-- beneficiary**

* **Description**: Folder containing files related to the beneficiary functionality within the system, such as data and operations.

### **|-- components**

* **Description**: Contains reusable UI components used throughout the app.

    * **custom\_button.dart**: Defines a custom button with specific styling, used across multiple screens.
    * **custom\_input.dart**: A component defining a custom input field, with validation or customized styling.
    * **whatsapp\_button.dart**: A component that creates a styled button for WhatsApp interaction, possibly to facilitate user contact.

### **|-- firebase\_options.dart**

* **Description**: Firebase configuration file that includes Firebase integration options, such as authentication keys and other required configuration details for Firebase.

### **|-- ideias.txt**

* **Description**: A text file that likely contains ideas and proposals for new features or improvements for the system.

### **|-- main.dart**

* **Description**: The main entry file of the app. Here, Flutter initializes the app and defines the primary routes of the system.

### **|-- models**

* **Description**: Contains representations of the app’s data, such as classes that map system entities.

    * **activity.dart**: Representation of an activity carried out by a beneficiary or in an environmental context.
    * **beneficiary.dart**: Representation of a beneficiary, including personal information, location, and other properties.
    * **offline\_record.dart**: Representation of an offline record that will be synchronized with the server when possible.
    * **report.dart**: Representation of a report on activities or environmental data.

### **|-- screens**

* **Description**: Contains the app’s screens, where user interfaces are designed and interact with the data.

    * **admin\_screen.dart**: Main screen for the admin, likely with access control to sensitive resources and information.
    * **beneficiary\_detail\_screen.dart**: Screen displaying details of a beneficiary, including information and activities.
    * **beneficiary\_edit\_screen.dart**: Screen for editing beneficiary information.
    * **beneficiary\_screen.dart**: Screen listing beneficiaries, where users can view or select beneficiaries.
    * **dashboard**

        * **activity\_chart.dart**: Component displaying charts about activities or collected data.
        * **dashboard\_screen.dart**: Dashboard screen that aggregates key data, charts, and information about beneficiaries and their activities.
        * **embedded\_dashboard.dart**: An embedded version of the dashboard, possibly a more compact or simplified version.
        * **map\_view\.dart**: Screen displaying the map with beneficiary locations or areas of interest.
        * **summary\_cards.dart**: Component that displays data summaries in cards, such as the total number of beneficiaries or mapped areas.
    * **forgot\_password\_screen.dart**: Screen where the user can request password recovery.
    * **home\_screen.dart**: Main user screen, providing access to the core app content.
    * **login\_screen.dart**: Login screen where users enter credentials to access the system.
    * **profile\_screen.dart**: Screen where users can view and edit their profile information.
    * **report\_edit\_screen.dart**: Screen for editing an existing report.
    * **signup\_screen.dart**: Registration screen for new users to sign up for the system.

### **|-- services**

* **Description**: Contains services responsible for interacting with external APIs, performing backend operations, or managing internal functionalities.

    * **api\_service.dart**: Service responsible for making HTTP requests to external APIs.
    * **auth\_service.dart**: Authentication service responsible for login, registration, and password recovery.
    * **geolocation\_service.dart**: Service for obtaining and manipulating the user's geographical location.
    * **image\_processing\_service.dart**: Service for processing images, such as AI analysis or manipulating EXIF metadata.
    * **local\_storage\_service.dart**: Service managing local data storage (e.g., `SharedPreferences`).
    * **notification\_service.dart**: Service managing notifications, both push and local, with Firebase.
    * **report\_service.dart**: Service dealing with the creation, editing, and synchronization of reports.
    * **session\_manager.dart**: Service managing user session, including authentication and session data persistence.

### **|-- theme.dart**

* **Description**: File defining the app’s visual theme (colors, fonts, widget styles). It contains light and dark theme configurations for the user interface.

### **|-- utils**

* **Description**: Contains utility helpers for general app functionalities.

    * **date\_helper.dart**: Utility for manipulating and formatting dates in the app, making it easier to display and manipulate dates in the correct format.

## **Installation**

### Step 1: Clone the Repository

Clone the repository to your computer using the command:

```bash
git clone <REPOSITORY_URL>
```

### Step 2: Install Dependencies

Navigate to the project directory and install the project dependencies:

```bash
cd competspa
flutter pub get
```

### Step 3: Run the App

To run the app, use the command below:

```bash
flutter run
```

If you are using an Android or iOS device, the app will be loaded on the emulator or physical device.

## **Firebase Setup**

The project uses Firebase for authentication and push notifications. To configure Firebase:

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Add the **Firebase SDK** to your app for Android and iOS.
3. Configure the authentication keys in the `firebase_options.dart` file.
4. Download the Firebase configuration file (GoogleService-Info.plist for iOS and google-services.json for Android) and add them to the appropriate folders in the project.

## **Project Dependencies**

Here is the list of dependencies the project uses:

* **flutter\_localizations**: Multi-language support.
* **geolocator**: For obtaining the user’s location.
* **google\_maps\_flutter**: For displaying maps in the app.
* **firebase\_messaging**: For sending push notifications.
* **image\_picker**: To take photos or select images.
* **fl\_chart**: For interactive charts.
* **pdf**: To generate PDF reports.
* **csv**: For CSV file manipulation.
* **hive**: Local NoSQL database.
* **permission\_handler**: For managing access permissions.
* **flutter\_map**: For displaying interactive maps.
* **firebase\_core**: For integrating Firebase into the project.

## **Features**

### **Beneficiary Management**

The app allows the user to view, add, and edit information about beneficiaries, including personal data and geospatial area. These details can be saved locally or sent to a server.

### **Activity Reports**

The reporting feature enables the user to record activities, such as creating and sending reports about covered areas, vegetation types, natural and human resources, and more.

### **Interactive Maps**

The app uses the `flutter_map` library to display interactive maps. Beneficiary points are shown on the map with markers. By clicking on a marker, the user can view more details about the beneficiary.

### **Push Notifications**

Firebase is used to send notifications to users. Notifications can be scheduled to alert users about new activities or reports, such as syncing offline data.

## **Internationalization**

The project uses `easy_localization` to support multiple languages. Currently, the app is configured to support Portuguese, but new languages can be easily added by creating translation files in `assets/translations/`.

## **Deploy**

### For iOS

1. Open the project in Xcode (`ios/Runner.xcworkspace`).
2. Connect your device or use the simulator.
3. Select **Product > Archive** to create a distribution file.
4. Upload to the App Store.

### For Android

1. Run the command below to generate the APK:

```bash
flutter build apk --release
```

2. The generated file will be located in `build/app/outputs/flutter-apk/app-release.apk`.
3. Upload the APK to the Google Play Store or install it directly on your device.

## **Contributing**

If you would like to contribute improvements or fixes to the project, feel free to fork the repository and submit a pull request with your changes.
