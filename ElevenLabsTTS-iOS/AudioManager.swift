import Foundation
import AVFoundation
import UIKit

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func playAudio(data: Data) {
        do {
            // Stop any currently playing audio
            stopAudio()
            
            // Create audio player
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            
            // Update duration
            duration = audioPlayer?.duration ?? 0
            print("Audio duration: \(duration) seconds")
            
            // Start playing
            let success = audioPlayer?.play() ?? false
            if success {
                isPlaying = true
                print("Audio playback started successfully")
                
                // Start timer to update current time
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                    guard let self = self, let player = self.audioPlayer else {
                        timer.invalidate()
                        return
                    }
                    
                    if player.isPlaying {
                        self.currentTime = player.currentTime
                    } else {
                        timer.invalidate()
                        self.isPlaying = false
                    }
                }
            } else {
                print("Failed to start audio playback")
            }
        } catch {
            print("Error creating audio player: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        print("Audio playback stopped")
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        print("Audio playback paused")
    }
    
    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
        print("Audio playback resumed")
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0
            print("Audio playback finished successfully: \(flag)")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
} 