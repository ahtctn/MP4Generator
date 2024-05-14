//
//  MusicDataViewModel.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import Foundation
import AVFAudio
import SwiftUI

class MusicDataViewModel: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?
    @Published var playbackState: PlaybackState = .stopped
    //@Published var fileName: String = "story1"
    @Published var selectedStory: MusicDataModel? = nil
    @Published var selectedTitle: String = ""
    @Published var data = [
        MusicDataModel(name: "Happy Music", soundName: "10_sec_music"),
    ]
    @Published var audioURL: URL?
    
    var selectedIndex: Int = 0
    
    var audioDuration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    var currentPlaybackTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init() {
        if let selectedIndex = UserDefaults.standard.string(forKey: "selectedIndex"),
           let actualIndex = Int(selectedIndex) {
            self.selectedIndex = actualIndex
        } else {
            UserDefaults.standard.set(selectedIndex, forKey: "selectedIndex")
        }
        
        setupTimerAndSelectNextStory()
    }
    
    func selectNextStory() {
        let nextIndex = (selectedIndex + 1) % data.count // Sıradaki indeksi hesapla, dizi sonuna ulaşıldığında başa döner
        let nextStory = data[nextIndex]
        selectedStory = MusicDataModel(name: nextStory.name, soundName: nextStory.soundName)
        
        // Yeni ses dosyasını yükleme
        guard let url = Bundle.main.url(forResource: selectedStory?.soundName, withExtension: "mp3") else {
            print("Dosya bulunamadı.")
            return
        }
        audioURL = url
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            print("🎧 Selected story soundname: \(String(describing: selectedStory?.soundName ?? "Sound not found ❌"))")
            print("📖 Selected story name: \(String(describing: selectedStory?.name ?? "Name not found ❌"))")
        } catch {
            print("AudioPlayer oluşturulamadı: \(error)")
        }
        
        // Seçilen indeksi güncelle
        selectedIndex = nextIndex
        UserDefaults.standard.set(selectedIndex, forKey: "selectedIndex")
    }
    
    func setupTimerAndSelectNextStory() {
        // Uygulama daha önce kapatıldıysa geçen zamanı hesapla
        if let lastTime = UserDefaults.standard.object(forKey: "lastTime") as? Date {
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(lastTime)
            let elapsedTime = Int(timeInterval)
            let elapsedTimeInIndex = elapsedTime / (24 * 60 * 60) // Geçen süreyi günlere çevir
            for _ in 0..<elapsedTimeInIndex {
                selectNextStory()
            }
        }
        
        // Timer'ı başlatarak her 24 saatte bir selectNextStory fonksiyonunu çağıracağız
        Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { _ in
            self.selectNextStory()
        }
        // İlk hikayeyi seç
        self.selectNextStory()
        
        // Şu anki zamanı kaydet
        UserDefaults.standard.set(Date(), forKey: "lastTime")
    }
    
    func resumeAudio() {
        audioPlayer?.play()
    }
    
    // Çalma işlemini durdur
    func stopAudio() {
        
        
        audioPlayer?.stop()
    }
    
    func pauseAudio() {
        
        audioPlayer?.pause()
        
    }
    
    // Belirli bir süreye ileri sarma
    func forward() {
        let forwardTime = 10.0
        guard let currentTime = audioPlayer?.currentTime,
              let duration = audioPlayer?.duration else {
            return
        }
        let newTime = currentTime + forwardTime
        if newTime < duration {
            audioPlayer?.currentTime = newTime
        } else {
            audioPlayer?.currentTime = duration
        }
    }
    
    // Belirli bir süreye geri sarma
    func backward() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        let newTime = currentTime - 10
        if newTime > 0 {
            player.currentTime = newTime
        } else {
            player.currentTime = 0
        }
    }
    
    func togglePlayPause() {
        if playbackState == .playing {
            playbackState = .paused
            pauseAudio()
        } else if playbackState == .resume {
            pauseAudio()
            playbackState = .paused
        } else if playbackState == .paused {
            resumeAudio()
            playbackState = .resume
        } else if playbackState == .stopped {
            resumeAudio()
            playbackState = .playing
        }
    }
    
    @MainActor
    func render(_ savedImage: Image) -> UIImage? {
        let renderer = ImageRenderer(content:
                                        SaveImageView(image: savedImage)
            .frame(width: UIScreen.main.bounds.size.width,
                   height: UIScreen.main.bounds.size.height, alignment: .center)
        )
        renderer.scale = 3
        return renderer.uiImage
    }
    
    
    
}
