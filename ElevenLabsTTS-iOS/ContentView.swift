import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var api = ElevenLabsAPI()
    @StateObject private var audioManager = AudioManager()
    @State private var inputText = ""
    @State private var selectedVoice: Voice?
    @State private var showingConfiguration = false
    @State private var statusMessage = "Ready"
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("ElevenLabs TTS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Text-to-Speech with AI Voices")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Voice Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Voice")
                        .font(.headline)
                    
                    if api.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading voices...")
                                .foregroundColor(.secondary)
                        }
                    } else if let selectedVoice = selectedVoice {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedVoice.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if let category = selectedVoice.category {
                                    Text(category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button("Change") {
                                self.selectedVoice = nil
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(api.voices) { voice in
                                    Button(action: {
                                        selectedVoice = voice
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(voice.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                if let category = voice.category {
                                                    Text(category)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text to Convert")
                        .font(.headline)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Generate Button
                Button(action: generateSpeech) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "play.circle.fill")
                        }
                        Text(isGenerating ? "Generating..." : "Generate Speech")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedVoice != nil && !inputText.isEmpty ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(selectedVoice == nil || inputText.isEmpty || isGenerating)
                
                // Audio Controls
                if audioManager.duration > 0 {
                    VStack(spacing: 12) {
                        // Progress Bar
                        VStack(spacing: 4) {
                            Slider(
                                value: Binding(
                                    get: { audioManager.currentTime },
                                    set: { audioManager.seek(to: $0) }
                                ),
                                in: 0...audioManager.duration
                            )
                            
                            HStack {
                                Text(formatTime(audioManager.currentTime))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatTime(audioManager.duration))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Playback Controls
                        HStack(spacing: 20) {
                            Button(action: {
                                if audioManager.isPlaying {
                                    audioManager.pauseAudio()
                                } else {
                                    audioManager.resumeAudio()
                                }
                            }) {
                                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: {
                                audioManager.stopAudio()
                            }) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                            
                            Button(action: shareAudio) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                // Status Message
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingConfiguration = true
                    }
                }
            }
            .sheet(isPresented: $showingConfiguration) {
                ConfigurationView(api: api)
            }
            .onAppear {
                if api.voices.isEmpty {
                    Task {
                        await api.loadVoices()
                    }
                }
            }
            .onChange(of: audioManager.isPlaying) { _, isPlaying in
                if !isPlaying && statusMessage == "Playing audio..." {
                    statusMessage = "Ready"
                }
            }
        }
    }
    
    private func generateSpeech() {
        guard let voice = selectedVoice, !inputText.isEmpty else { return }
        
        isGenerating = true
        statusMessage = "Generating speech..."
        
        let voiceSettings = VoiceSettings(
            stability: 0.5,
            similarity_boost: 0.75,
            style: 0.0,
            use_speaker_boost: true
        )
        
        Task {
            if let audioData = await api.textToSpeech(
                text: inputText,
                voiceId: voice.id,
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
        }
    }
    
    private func shareAudio() {
        // This would need to be implemented to save and share the audio file
        // For now, just show a placeholder
        statusMessage = "Share functionality coming soon"
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
} 