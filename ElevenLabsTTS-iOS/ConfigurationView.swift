import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var api: ElevenLabsAPI
    @Environment(\.dismiss) private var dismiss
    @AppStorage("apiKey") private var apiKey = ""
    @AppStorage("selectedVoiceId") private var storedVoiceId = ""
    @AppStorage("selectedModel") private var storedModel = "eleven_multilingual_v2"
    @AppStorage("selectedOutputFormat") private var storedOutputFormat = "MP3 - 44.1kHz 192kbps"
    @AppStorage("volume") private var storedVolume: Double = 100
    @AppStorage("stability") private var storedStability: Double = 44
    @AppStorage("similarity") private var storedSimilarity: Double = 75
    @AppStorage("style") private var storedStyle: Double = 0
    @AppStorage("speakerBoost") private var storedSpeakerBoost: Bool = true
    @AppStorage("speed") private var storedSpeed: Double = 47
    @State private var tempApiKey = ""
    @State private var selectedVoiceId: String = ""
    @State private var selectedModel: String = "eleven_multilingual_v2"
    @State private var selectedOutputFormat: String = "MP3 - 44.1kHz 192kbps"
    @State private var volume: Double = 100
    @State private var stability: Double = 44
    @State private var similarity: Double = 75
    @State private var style: Double = 0
    @State private var speakerBoost: Bool = true
    @State private var speed: Double = 47
    @State private var errorMessage: String? = nil
    @State private var isPreviewing = false
    @StateObject private var audioManager = AudioManager()
    
    let models = [
        "eleven_multilingual_v2",
        "eleven_flash_v2_5",
        "eleven_turbo_v2_5",
        "eleven_v3",
        "eleven_ttv_v3"
    ]
    let outputFormats = [
        "MP3 - 44.1kHz 192kbps",
        "WAV - 44.1kHz",
        "OGG - 48kHz",
        "PCM - 16bit 44.1kHz"
    ]
    let previewText = "This is a preview of the selected voice."
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Key:")) {
                    SecureField("Enter your API key", text: $tempApiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button("Load Voices") {
                        Task {
                            api.setAPIKey(tempApiKey)
                            await api.loadVoices()
                            if api.voices.isEmpty {
                                errorMessage = api.errorMessage ?? "Error loading voices."
                            } else {
                                errorMessage = nil
                                if selectedVoiceId.isEmpty, let firstVoice = api.voices.first {
                                    selectedVoiceId = firstVoice.voiceId ?? ""
                                }
                            }
                        }
                    }
                    .disabled(tempApiKey.isEmpty)
                    
                    Picker("Voice:", selection: $selectedVoiceId) {
                        Text("").tag("")
                        ForEach(api.voices) { voice in
                            Text(voice.name ?? "Unknown Voice").tag(voice.voiceId ?? "")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    HStack {
                        Button("Preview Voice") {
                            previewVoice()
                        }
                        .disabled(selectedVoiceId.isEmpty || isPreviewing)
                        Button("Stop") {
                            stopPreview()
                        }
                        .disabled(!isPreviewing)
                    }
                }
                
                Section(header: Text("Model:")) {
                    Picker("Model", selection: $selectedModel) {
                        ForEach(models, id: \.self) { model in
                            Text(model)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Output Format:")) {
                    Picker("Output Format", selection: $selectedOutputFormat) {
                        ForEach(outputFormats, id: \.self) { format in
                            Text(format)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Volume:")) {
                    HStack {
                        Slider(value: $volume, in: 0...100)
                        Text("\(Int(volume))")
                            .frame(width: 40, alignment: .trailing)
                    }
                }
                
                Section(header: Text("Voice Boost Parameters")) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Stability:")
                            Slider(value: $stability, in: 0...100)
                            Text("\(Int(stability))")
                                .frame(width: 40, alignment: .trailing)
                        }
                        HStack {
                            Text("Similarity:")
                            Slider(value: $similarity, in: 0...100)
                            Text("\(Int(similarity))")
                                .frame(width: 40, alignment: .trailing)
                        }
                        HStack {
                            Text("Style:")
                            Slider(value: $style, in: 0...100)
                            Text("\(Int(style))%")
                                .frame(width: 40, alignment: .trailing)
                        }
                        Toggle("Speaker Boost:", isOn: $speakerBoost)
                        HStack {
                            Text("Speed:")
                            Slider(value: $speed, in: 0...100)
                            Text("\(Int(speed))")
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveConfiguration()
                    }
                    .disabled(tempApiKey.isEmpty)
                }
            }
            .onAppear {
                tempApiKey = apiKey
                selectedVoiceId = storedVoiceId
                selectedModel = storedModel
                selectedOutputFormat = storedOutputFormat
                volume = storedVolume
                stability = storedStability
                similarity = storedSimilarity
                style = storedStyle
                speakerBoost = storedSpeakerBoost
                speed = storedSpeed
            }
        }
    }
    
    private func saveConfiguration() {
        apiKey = tempApiKey
        storedVoiceId = selectedVoiceId
        storedModel = selectedModel
        storedOutputFormat = selectedOutputFormat
        storedVolume = volume
        storedStability = stability
        storedSimilarity = similarity
        storedStyle = style
        storedSpeakerBoost = speakerBoost
        storedSpeed = speed
        api.setAPIKey(tempApiKey)
        dismiss()
    }
    
    private func previewVoice() {
        guard let voice = api.voices.first(where: { $0.voiceId == selectedVoiceId }) else { return }
        isPreviewing = true
        let voiceSettings = VoiceSettings(
            stability: stability / 100.0,
            similarity_boost: similarity / 100.0,
            style: style / 100.0,
            use_speaker_boost: speakerBoost
        )
        Task {
            let data = await api.textToSpeech(
                text: previewText,
                voiceId: voice.voiceId ?? "",
                voiceSettings: voiceSettings,
                modelId: selectedModel,
                outputFormat: selectedOutputFormat,
                speed: speed / 100.0
            )
            if let data = data {
                await MainActor.run {
                    audioManager.playAudio(data: data)
                }
            }
            isPreviewing = false
        }
    }
    
    private func stopPreview() {
        audioManager.stopAudio()
        isPreviewing = false
    }
}

#Preview {
    ConfigurationView(api: ElevenLabsAPI())
} 