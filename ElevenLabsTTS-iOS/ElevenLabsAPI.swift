import Foundation

class ElevenLabsAPI: ObservableObject {
    private let baseURL = "https://api.elevenlabs.io/v1"
    private var apiKey: String = ""
    
    @Published var voices: [Voice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func setAPIKey(_ key: String) {
        self.apiKey = key
    }
    
    func loadVoices() async {
        guard !apiKey.isEmpty else {
            await MainActor.run {
                self.errorMessage = "API key is required"
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let url = URL(string: "\(baseURL)/voices")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            await MainActor.run {
                self.isLoading = false
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("API Response Status: \(httpResponse.statusCode)")
                print("API Response Headers: \(httpResponse.allHeaderFields)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("API Response Body: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    do {
                        // Try to decode as VoicesResponse first
                        let voicesResponse = try JSONDecoder().decode(VoicesResponse.self, from: data)
                        await MainActor.run {
                            self.voices = voicesResponse.voices
                            print("Successfully loaded \(self.voices.count) voices")
                        }
                    } catch {
                        print("Failed to decode as VoicesResponse: \(error)")
                        
                        // Try to decode as direct array
                        do {
                            let directVoices = try JSONDecoder().decode([Voice].self, from: data)
                            await MainActor.run {
                                self.voices = directVoices
                                print("Successfully loaded \(self.voices.count) voices (direct array)")
                            }
                        } catch {
                            print("Failed to decode as direct array: \(error)")
                            await MainActor.run {
                                self.errorMessage = "Failed to parse voices: \(error.localizedDescription)"
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "API Error: \(httpResponse.statusCode)"
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func textToSpeech(text: String, voiceId: String, voiceSettings: VoiceSettings?) async -> Data? {
        guard !apiKey.isEmpty else {
            await MainActor.run {
                self.errorMessage = "API key is required"
            }
            return nil
        }
        
        let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let ttsRequest = TTSRequest(
            text: text,
            model_id: "eleven_monolingual_v1",
            voice_settings: voiceSettings
        )
        
        do {
            let jsonData = try JSONEncoder().encode(ttsRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    return data
                } else {
                    if let errorString = String(data: data, encoding: .utf8) {
                        await MainActor.run {
                            self.errorMessage = "TTS Error: \(errorString)"
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = "TTS Error: \(httpResponse.statusCode)"
                        }
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "TTS request failed: \(error.localizedDescription)"
            }
        }
        
        return nil
    }
} 