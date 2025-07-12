# Canvas Drawer Plus - Collaborative Drawing App

A powerful collaborative drawing application built with Flutter that supports real-time multi-user drawing rooms with both online and offline capabilities.

## Features

### 🎨 **Drawing Tools**
- **Pen Tool**: Free-form drawing with customizable stroke width and colors
- **Eraser Tool**: Remove unwanted strokes with precision
- **Shape Tools**: Draw perfect circles, rectangles, and squares
- **Color Palette**: 6 predefined colors (black, red, amber, blue, green, brown)
- **Adjustable Brush Size**: 1-20 pixel stroke width

### 🏠 **Room Management**
- **Create Rooms**: Set up drawing rooms with custom names and configurations
- **Join Rooms**: Enter existing rooms using room IDs
- **Password Protection**: Secure rooms with optional passwords
- **Participant Limits**: Control the maximum number of collaborators (2-20)
- **Room Settings**: View participant lists, room details, and management options

### 👥 **Collaborative Features**
- **Real-time Collaboration**: See other users' drawings appear instantly
- **Multi-user Support**: Up to 20 users can draw simultaneously in a room
- **Participant Management**: Track who's in the room and room creator privileges
- **Room Sharing**: Easy room ID sharing to invite collaborators

### 📱 **User Management**
- **Firebase Authentication**: Secure email/password authentication
- **User Profiles**: Personalized profiles with user information
- **Room History**: View and rejoin previous drawing sessions
- **Session Management**: Automatic session handling and user state

### 🔄 **Offline & Sync**
- **Local Storage**: All drawings saved locally using Isar database
- **Offline Mode**: Continue drawing even without internet connection
- **Auto-sync**: Automatically sync offline drawings when connection restored
- **Network Status**: Visual indicator showing connection status

### 🎯 **Advanced Features**
- **Drawing History**: Undo/Redo functionality for all drawing operations
- **Performance Optimized**: Efficient drawing rendering with custom painters
- **Modern UI**: Clean, intuitive interface with Material Design 3
- **Cross-platform**: Works on Android, iOS, Web, and Desktop

## Architecture

### 🏗️ **Project Structure**
```
lib/
├── core/
│   ├── route/              # App routing configuration
│   └── theme/              # App theming and colors
├── feature/
│   ├── auth/               # Authentication system
│   │   ├── model/          # User data models
│   │   ├── service/        # Auth services
│   │   └── presentation/   # Auth UI screens
│   └── drawing_room/       # Drawing room system
│       ├── model/          # Drawing and room models
│       ├── service/        # Room and drawing services
│       └── presentation/   # Drawing UI screens
└── main.dart               # App entry point
```

### 📊 **Data Models**

#### DrawingPoint
- Stores individual drawing strokes with coordinates, color, width, and tool type
- Optimized for real-time collaboration with Firebase integration
- Local storage support for offline capability

#### DrawingRoom
- Manages room metadata including participants, settings, and permissions
- Handles room creation, joining, and participant management
- Synchronized between Firebase and local storage

#### UserModel
- User authentication and profile information
- Session management and user preferences

### 🔧 **Services**

#### AuthService
- Firebase Authentication integration
- User registration, login, and session management
- Profile management and data persistence

#### DrawingRoomService
- Room creation and management
- Real-time drawing synchronization
- Offline/online state handling
- Participant management

### 🎨 **UI Components**

#### RoomListScreen
- Browse and manage user's drawing rooms
- Create new rooms with custom settings
- Join existing rooms with room IDs
- Room filtering and search capabilities

#### DrawingRoomScreen
- Main drawing interface with all tools
- Real-time collaboration display
- Tool selection and customization
- Network status monitoring

#### UserProfileScreen
- User profile management
- Room history and quick access
- Account settings and preferences

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project with Authentication and Firestore enabled
- Android Studio/VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd canvas_drawer_plus
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Download configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Place files in respective platform directories

4. **Generate Isar files**
   ```bash
   dart run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Creating a Room
1. Sign in to your account
2. Tap the "+" button on the room list
3. Enter room name and optional settings
4. Share the room ID with collaborators

### Joining a Room
1. Tap the "Join Room" button
2. Enter the room ID provided by the room creator
3. Enter password if required
4. Start drawing collaboratively

### Drawing
- Select colors from the palette
- Choose drawing tools (pen, eraser, shapes)
- Adjust brush size with the slider
- Use undo/redo for corrections
- All changes sync in real-time

### Offline Mode
- App automatically detects network status
- Drawings saved locally when offline
- Auto-sync when connection restored
- Visual offline indicator shown

## Technical Details

### Real-time Synchronization
- Firebase Firestore for real-time data sync
- Efficient delta updates for drawing strokes
- Optimistic UI updates for smooth experience

### Data Storage
- **Firebase Firestore**: Cloud storage for rooms and drawings
- **Isar Database**: Local storage for offline capability
- **Efficient Sync**: Smart synchronization between cloud and local

### Performance Optimizations
- Custom painters for efficient drawing rendering
- Streaming updates for real-time collaboration
- Memory-efficient stroke storage
- Background sync processing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please create an issue in the repository or contact the development team.

---

**Happy Drawing! 🎨**
