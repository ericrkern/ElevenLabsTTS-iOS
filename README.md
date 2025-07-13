# ElevenLabs TTS iOS App

**Version 1.0.3 Build 3**

A SwiftUI-based iOS application that converts text to speech using ElevenLabs AI voices. This app provides a modern, intuitive interface for generating high-quality AI speech from text input.

## Features

- **Text-to-Speech Conversion**: Convert any text to natural-sounding speech
- **Voice Selection**: Choose from a wide variety of AI voices in settings
- **Audio Playback**: Built-in audio player with play, stop, save, and share controls
- **Voice Settings**: Adjust stability, similarity boost, style, and speaker boost parameters
- **Modern UI**: Clean, intuitive SwiftUI interface with simplified controls
- **Background Audio**: Continue playing audio when app is in background
- **Configuration Persistence**: Settings are saved and restored between app launches

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- ElevenLabs API key

## Setup

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd ElevenLabsTTS-iOS
```

### 2. Open in Xcode

```bash
open ElevenLabsTTS-iOS.xcodeproj
```

### 3. Configure Your API Key

1. Get your API key from [ElevenLabs Console](https://elevenlabs.io/account)
2. Run the app on your device or simulator
3. Tap the gear icon (⚙️) in the top-right corner to open Settings
4. Enter your API key and tap "Load Voices" to verify
5. Select your preferred voice from the dropdown
6. Tap "Save" to store your configuration

### 4. Build and Run

- Select your target device or simulator
- Press `Cmd+R` to build and run the app

## Usage

### Basic Text-to-Speech

1. **Configure Voice**: First, set up your preferred voice in Settings
2. **Enter Text**: Type or paste the text you want to convert to speech in the text area
3. **Generate**: Tap "Speak" to generate and play the audio
4. **Control**: Use the audio controls to stop, save, or share the generated speech

### Voice Settings

Access voice settings through the gear icon (⚙️) in the top-right corner:

- **Voice Selection**: Choose from available ElevenLabs voices
- **Model Selection**: Select the AI model (eleven_multilingual_v2, etc.)
- **Output Format**: Choose audio format (MP3, WAV, OGG, PCM)
- **Volume Control**: Adjust playback volume
- **Voice Parameters**:
  - **Stability**: 0-100 (consistency of voice)
  - **Similarity**: 0-100 (similarity to original voice)
  - **Style**: 0-100 (style variation)
  - **Speaker Boost**: Enable/disable speaker enhancement
  - **Speed**: 0-100 (playback speed)

### Audio Controls

- **Speak**: Generate and play speech from entered text
- **Stop**: Stop current playback
- **Save**: Save the generated audio to device storage (works independently)
- **Share**: Share the generated audio via iOS share sheet (works independently)

## Project Structure

```
ElevenLabsTTS-iOS/
├── ElevenLabsTTS_iOSApp.swift      # Main app entry point
├── ContentView.swift               # Main UI view with simplified controls
├── ConfigurationView.swift         # Settings and API configuration
├── Models.swift                    # Data models and API response structures
├── ElevenLabsAPI.swift            # API client for ElevenLabs
├── AudioManager.swift             # Audio playback management
├── Assets.xcassets/               # App icons and colors
├── Preview Content/               # SwiftUI preview assets
└── Info.plist                     # App configuration and permissions
```

## Key Components

### ElevenLabsAPI
Handles all communication with the ElevenLabs API:
- Voice listing and selection
- Text-to-speech conversion
- Error handling and status updates
- Configuration persistence

### AudioManager
Manages audio playback using AVFoundation:
- Audio session configuration
- Playback controls (play, stop)
- Background audio support
- Progress tracking

### ContentView
Main user interface with simplified design:
- Large text input area
- 2x2 button grid (Speak, Stop, Save, Share)
- Status messages
- Settings access via gear icon

### ConfigurationView
Settings interface with:
- API key configuration
- Voice selection dropdown
- Voice parameter controls
- Model and format selection
- Preview functionality

## API Integration

The app integrates with ElevenLabs API endpoints:

- `GET /v1/voices` - Retrieve available voices
- `POST /v1/text-to-speech/{voice_id}` - Convert text to speech

### Authentication
Uses API key authentication via the `xi-api-key` header.

### Error Handling
Comprehensive error handling for:
- Network connectivity issues
- API authentication errors
- Invalid voice selections
- Audio playback problems
- JSON decoding errors

## Permissions

The app requires the following permissions:
- **Audio Playback**: For playing generated speech
- **Background Audio**: To continue playback when app is backgrounded

## Troubleshooting

### Common Issues

1. **No Audio Output**
   - Check device volume
   - Ensure audio session is properly configured
   - Verify API key is valid

2. **Voice Loading Fails**
   - Check internet connection
   - Verify API key is correct
   - Check ElevenLabs service status
   - Ensure API key has proper permissions

3. **Build Errors**
   - Ensure Xcode 15.0+ is installed
   - Check iOS deployment target (17.0+)
   - Verify all files are included in the project

4. **Decoding Errors**
   - The app now handles null values in API responses
   - Voice verification fields are properly optional
   - All model fields are nullable to prevent crashes

### Debug Information

The app includes detailed logging for troubleshooting:
- API request/response details
- Audio session configuration status
- Playback state changes
- Error messages and stack traces
- JSON decoding errors with context

## Recent Updates (v1.0.3 Build 3)

- **Enhanced Save and Share Functionality**: Save and Share buttons now work independently without requiring the Speak button to be pressed first
- **Automatic Audio Generation**: When Save or Share is pressed, the app automatically generates audio if it doesn't exist
- **Improved User Workflow**: Users can now save or share audio files directly without the extra step of pressing Speak
- **Smart Audio Management**: The app intelligently reuses existing audio data or generates new audio as needed
- **Better Button States**: Save and Share buttons are now properly enabled when there's text input, regardless of audio state

## Recent Updates (v1.0.3 Build 2)

- **Fixed iPad Layout Issues**: Replaced deprecated NavigationView with NavigationStack for proper iPad display
- **Fixed iPad Share/Save Crashes**: Implemented SwiftUI-native sharing with proper UIActivityViewController wrapper
- **Improved Device Compatibility**: Better support for both iPhone and iPad interfaces
- **Enhanced User Experience**: Share and Save buttons now work reliably on all devices

## Recent Updates (v1.0.3 Build 1)

- **Fixed API Decoding Issues**: Resolved JSON decoding errors with null values
- **Improved Voice Selection**: App now uses selected voice instead of first available
- **Enhanced Error Handling**: Better error messages and recovery
- **Configuration Persistence**: Settings are properly saved and restored
- **Simplified UI**: Streamlined interface focusing on core functionality

## Development

### Adding New Features

1. **Audio Export**: Save generated audio to files
2. **Voice Cloning**: Add support for custom voice creation
3. **Batch Processing**: Convert multiple text inputs at once
4. **Voice Preview**: Preview voices before selection
5. **History**: Save and replay previous generations

### Code Style

- Follow SwiftUI best practices
- Use `@StateObject` for view models
- Implement proper error handling
- Add comprehensive logging for debugging
- Use `@AppStorage` for configuration persistence

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review ElevenLabs API documentation
3. Open an issue in the repository

## Acknowledgments

- ElevenLabs for providing the AI voice API
- Apple for SwiftUI and AVFoundation frameworks
- The open source community for inspiration and tools 