# ElevenLabs TTS iOS App

A SwiftUI-based iOS application that converts text to speech using ElevenLabs AI voices. This app provides a modern, intuitive interface for generating high-quality AI speech from text input.

## Features

- **Text-to-Speech Conversion**: Convert any text to natural-sounding speech
- **Voice Selection**: Choose from a wide variety of AI voices
- **Audio Playback**: Built-in audio player with play, pause, and stop controls
- **Voice Settings**: Adjust stability and similarity boost parameters
- **Modern UI**: Clean, intuitive SwiftUI interface
- **Background Audio**: Continue playing audio when app is in background

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
3. Tap "Settings" in the top-right corner
4. Enter your API key and tap "Save"

### 4. Build and Run

- Select your target device or simulator
- Press `Cmd+R` to build and run the app

## Usage

### Basic Text-to-Speech

1. **Select a Voice**: Tap "Select Voice" and choose from the available voices
2. **Enter Text**: Type or paste the text you want to convert to speech
3. **Generate**: Tap "Generate Speech" to create the audio
4. **Play**: Use the audio controls to play, pause, or stop the generated speech

### Voice Settings

The app uses default voice settings optimized for quality:
- **Stability**: 0.5 (balanced consistency)
- **Similarity Boost**: 0.75 (high similarity to original voice)
- **Style**: 0.0 (neutral style)
- **Speaker Boost**: Enabled

### Audio Controls

- **Play/Pause**: Toggle audio playback
- **Stop**: Stop playback and reset to beginning
- **Seek**: Drag the progress bar to jump to any position
- **Share**: Share the generated audio (coming soon)

## Project Structure

```
ElevenLabsTTS-iOS/
├── ElevenLabsTTS_iOSApp.swift      # Main app entry point
├── ContentView.swift               # Main UI view
├── ConfigurationView.swift         # Settings and API configuration
├── Models.swift                    # Data models and structures
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

### AudioManager
Manages audio playback using AVFoundation:
- Audio session configuration
- Playback controls (play, pause, stop, seek)
- Background audio support
- Progress tracking

### ContentView
Main user interface with:
- Voice selection interface
- Text input area
- Generation controls
- Audio player with progress bar
- Status messages

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

3. **Build Errors**
   - Ensure Xcode 15.0+ is installed
   - Check iOS deployment target (17.0+)
   - Verify all files are included in the project

### Debug Information

The app includes detailed logging for troubleshooting:
- API request/response details
- Audio session configuration status
- Playback state changes
- Error messages and stack traces

## Development

### Adding New Features

1. **Voice Settings UI**: Add sliders for stability and similarity boost
2. **Audio Export**: Save generated audio to files
3. **Voice Cloning**: Add support for custom voice creation
4. **Batch Processing**: Convert multiple text inputs at once

### Code Style

- Follow SwiftUI best practices
- Use `@StateObject` for view models
- Implement proper error handling
- Add comprehensive logging for debugging

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