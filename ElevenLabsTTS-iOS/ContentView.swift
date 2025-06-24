import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var api = ElevenLabsAPI()
    @StateObject private var audioManager = AudioManager()
    @State private var inputText = ""
    @State private var showingConfiguration = false
    @State private var statusMessage = "Ready"
    @State private var isGenerating = false
    
    // Access stored configuration
    @AppStorage("selectedVoiceId") private var selectedVoiceId = ""
    @AppStorage("apiKey") private var apiKey = ""
    
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
                        .disabled(audioManager.duration == 0)
                        
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
                        .disabled(audioManager.duration == 0)
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
                    voiceSettings: voiceSettings
                ) {
                    await MainActor.run {
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
        // Placeholder for save functionality
        statusMessage = "Save functionality coming soon"
    }
    
    private func shareAudio() {
        // Placeholder for share functionality
        statusMessage = "Share functionality coming soon"
    }
}

#Preview {
    ContentView()
} 