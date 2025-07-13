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
    @State private var audioFileURL: URL?
    @State private var showingShareSheet = false
    
    // Access stored configuration
    @AppStorage("selectedVoiceId") private var selectedVoiceId = ""
    @AppStorage("apiKey") private var apiKey = ""
    @AppStorage("selectedOutputFormat") private var selectedOutputFormat = "MP3 - 44.1kHz 192kbps"
    
    var body: some View {
        NavigationStack {
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
                        .disabled(inputText.isEmpty || isGenerating)
                        
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
                        .disabled(inputText.isEmpty || isGenerating)
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
            .navigationTitle("ElevenLabs TTS")
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
            .sheet(isPresented: $showingShareSheet) {
                if let audioFileURL = audioFileURL {
                    ShareSheet(activityItems: [audioFileURL])
                }
            }
            .sheet(isPresented: $showingSaveDialog) {
                if let audioFileURL = audioFileURL {
                    SaveSheet(audioFileURL: audioFileURL)
                }
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
        Task {
            await generateAudioIfNeeded { audioData in
                if let audioData = audioData {
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
                        audioFileURL = tempURL
                        showingSaveDialog = true
                        statusMessage = "Audio saved successfully"
                    } catch {
                        statusMessage = "Failed to save audio: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func shareAudio() {
        Task {
            await generateAudioIfNeeded { audioData in
                if let audioData = audioData {
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
                        audioFileURL = tempURL
                        showingShareSheet = true
                        statusMessage = "Ready to share audio"
                    } catch {
                        statusMessage = "Failed to prepare audio: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func generateAudioIfNeeded(completion: @escaping (Data?) -> Void) async {
        // If we already have audio data, use it
        if let existingAudioData = currentAudioData {
            await MainActor.run {
                completion(existingAudioData)
            }
            return
        }
        
        // Otherwise, generate new audio
        guard !inputText.isEmpty else {
            await MainActor.run {
                statusMessage = "No text to convert to speech"
                completion(nil)
            }
            return
        }
        
        await MainActor.run {
            isGenerating = true
            statusMessage = "Generating speech..."
        }
        
        let voiceSettings = VoiceSettings(
            stability: 0.5,
            similarity_boost: 0.75,
            style: 0.0,
            use_speaker_boost: true
        )
        
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
                    statusMessage = "Audio generated successfully"
                    isGenerating = false
                    completion(audioData)
                }
            } else {
                await MainActor.run {
                    statusMessage = api.errorMessage ?? "Failed to generate speech"
                    isGenerating = false
                    completion(nil)
                }
            }
        } else {
            await MainActor.run {
                statusMessage = "No voices available or selected voice not found"
                isGenerating = false
                completion(nil)
            }
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
}

// ShareSheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// SaveSheet wrapper for UIDocumentPickerViewController
struct SaveSheet: UIViewControllerRepresentable {
    let audioFileURL: URL
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forExporting: [audioFileURL])
        controller.shouldShowFileExtensions = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

#Preview {
    ContentView()
} 