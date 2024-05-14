//
//  MusicPlayerView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    @State var audioPlayer: AVAudioPlayer!
    @State private var progress: Double = 0.0
    
    @State private var isBackwardTapped: Bool = false
    @State private var isForwardTapped: Bool = false
    
    @EnvironmentObject var musicDataVM: MusicDataViewModel
    
    var body: some View {
        VStack {
            Text("\(musicDataVM.selectedTitle)")
            ZStack {
                CircularProgressView(circleWidth: 130, circleHeight: 130, progress: $progress)
                ButtonActionView(
                    backwardAction: {
                        
                        musicDataVM.backward()
                        isBackwardTapped = true
                        
                    },
                    forwardAction: {
                        
                        musicDataVM.forward()
                        isForwardTapped = true
                    },
                    isBackwardTapped: $isBackwardTapped,
                    isForwardTapped: $isForwardTapped
                )
            }
            .onReceive(musicDataVM.timer) { _ in
                
                if let duration = musicDataVM.audioPlayer?.duration,
                   let currentTime = musicDataVM.audioPlayer?.currentTime,
                       duration > 0 {
                    progress = min(1.0, max(0.0, currentTime / duration))
                } else {
                    progress = 0.0
                }
            }
        }
    }
        
}

#Preview {
    MusicPlayerView()
        .environmentObject(MusicDataViewModel())
}



