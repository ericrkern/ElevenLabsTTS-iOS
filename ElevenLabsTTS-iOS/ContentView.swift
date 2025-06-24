import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var api = ElevenLabsAPI()
    @StateObject private var audioManager = AudioManager()
    @State private var inputText = ""
    @State private var showingConfiguration = false
    @State private var statusMessage = "Ready"
    @State private var isGenerating = false
    @State private var currentAudioData: Data?
    @State private var showingSaveDialog = false
    
    // Access stored configuration
    @AppStorage("selectedVoiceId") private var selectedVoiceId = ""
    @AppStorage("apiKey") private var apiKey = ""
    @AppStorage("selectedOutputFormat") private var selectedOutputFormat = "MP3 - 44.1kHz 192kbps"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("ElevenLabs TTS")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.top, 8)
                    Text("Text to Speech")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Text Input
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 4)
                        .background(Color.white)
                    TextEditor(text: $inputText)
                        .padding(8)
                        .font(.title2)
                        .frame(minHeight: 250, maxHeight: 250)
                        .background(Color.clear)
                }
                .frame(maxWidth: .infinity, maxHeight: 250)
                .padding(.horizontal, 4)
                
                // 2x2 Button Grid
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: generateSpeech) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Speak")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.title3.bold())
                        }
                        .disabled(inputText.isEmpty || isGenerating)
                        
                        Button(action: {
                            audioManager.stopAudio()
                            currentAudioData = nil
                        }) {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                Text("Stop")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.title3.bold())
                        }
                        .disabled(audioManager.duration == 0)
                    }
                    HStack(spacing: 16) {
                        Button(action: saveAudio) {
                            HStack {
                                Image(systemName: "arrow.down.to.line.alt")
                                Text("Save")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.title3.bold())
                        }
                        .disabled(currentAudioData == nil)
                        
                        Button(action: shareAudio) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.title3.bold())
                        }
                        .disabled(currentAudioData == nil)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 4)
                
                Spacer()
                
                // Status Message
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingConfiguration = true }) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingConfiguration) {
                ConfigurationView(api: api)
            }
            .onAppear {
                // Set the API key from stored configuration
                if !apiKey.isEmpty {
                    api.setAPIKey(apiKey)
                }
            }
        }
    }
    
    private func generateSpeech() {
        guard !inputText.isEmpty else { return }
        isGenerating = true
        statusMessage = "Generating speech..."
        let voiceSettings = VoiceSettings(
            stability: 0.5,
            similarity_boost: 0.75,
            style: 0.0,
            use_speaker_boost: true
        )
        Task {
            let voices = await api.loadVoicesIfNeeded()
            
            // Use the selected voice ID if available, otherwise use the first voice
            let targetVoiceId = selectedVoiceId.isEmpty ? voices.first?.voiceId : selectedVoiceId
            let voice = voices.first { $0.voiceId == targetVoiceId }
            
            if let voice = voice {
                if let audioData = await api.textToSpeech(
                    text: inputText,
                    voiceId: voice.voiceId ?? "",
                    voiceSettings: voiceSettings,
                    outputFormat: selectedOutputFormat
                ) {
                    await MainActor.run {
                        currentAudioData = audioData
                        audioManager.playAudio(data: audioData)
                        statusMessage = "Playing audio..."
                        isGenerating = false
                    }
                } else {
                    await MainActor.run {
                        statusMessage = api.errorMessage ?? "Failed to generate speech"
                        isGenerating = false
                    }
                }
            } else {
                await MainActor.run {
                    statusMessage = "No voices available or selected voice not found"
                    isGenerating = false
                }
            }
        }
    }
    
    private func saveAudio() {
        guard let audioData = currentAudioData else {
            statusMessage = "No audio to save"
            return
        }
        
        // Generate filename with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        // Get file extension based on selected format
        let fileExtension = getFileExtension(for: selectedOutputFormat)
        let filename = "ElevenLabs_TTS_\(timestamp).\(fileExtension)"
        
        // Create temporary file URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try audioData.write(to: tempURL)
            
            // Show document picker for save location
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true) {
                    statusMessage = "Audio saved successfully"
                }
            }
        } catch {
            statusMessage = "Failed to save audio: \(error.localizedDescription)"
        }
    }
    
    private func getFileExtension(for format: String) -> String {
        switch format {
        case "MP3 - 44.1kHz 192kbps":
            return "mp3"
        case "WAV - 44.1kHz":
            return "wav"
        case "OGG - 48kHz":
            return "ogg"
        case "PCM - 16bit 44.1kHz":
            return "pcm"
        default:
            return "mp3"
        }
    }
    
    private func shareAudio() {
        guard let audioData = currentAudioData else {
            statusMessage = "No audio to share"
            return
        }
        
        // Generate filename with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        // Get file extension based on selected format
        let fileExtension = getFileExtension(for: selectedOutputFormat)
        let filename = "ElevenLabs_TTS_\(timestamp).\(fileExtension)"
        
        // Create temporary file URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try audioData.write(to: tempURL)
            
            // Show share sheet
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true) {
                    statusMessage = "Audio shared successfully"
                }
            }
        } catch {
            statusMessage = "Failed to share audio: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
} 