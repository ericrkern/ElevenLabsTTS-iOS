import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var api: ElevenLabsAPI
    @Environment(\.dismiss) private var dismiss
    @AppStorage("apiKey") private var apiKey = ""
    @State private var tempApiKey = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ElevenLabs API Key")
                            .font(.headline)
                        
                        SecureField("Enter your API key", text: $tempApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Get your API key from [ElevenLabs Console](https://elevenlabs.io/account)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Voice Settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Default Voice Settings")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stability: Controls voice consistency")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Slider(value: .constant(0.5), in: 0...1)
                                    .disabled(true)
                                Text("High")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Similarity Boost: Controls voice similarity to original")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Slider(value: .constant(0.75), in: 0...1)
                                    .disabled(true)
                                Text("High")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ElevenLabs TTS iOS")
                            .font(.headline)
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Convert text to speech using ElevenLabs AI voices")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
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
            }
        }
    }
    
    private func saveConfiguration() {
        apiKey = tempApiKey
        api.setAPIKey(tempApiKey)
        dismiss()
    }
}

#Preview {
    ConfigurationView(api: ElevenLabsAPI())
} 