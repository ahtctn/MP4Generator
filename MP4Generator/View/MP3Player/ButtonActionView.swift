//
//  ButtonActionView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI

struct ButtonActionView: View {
    @EnvironmentObject var storyDataVM: MusicDataViewModel
    
    var backwardAction: () -> ()
    var forwardAction: () -> ()
    @Binding var isBackwardTapped: Bool
    @Binding var isForwardTapped: Bool
    var body: some View {
        HStack(spacing: 32) {
            //MARK: BackwardView
            VStack {
                TimerForwardBackwardTextView(isBackwardORForwardTapped: $isBackwardTapped, textSecond: "-10")
                Button {
                    backwardAction()
                    isBackwardTapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                        withAnimation(.easeInOut) {
                            isBackwardTapped = false
                        }
                    }
                } label: {
                    TimerButtonView(imageStyle: Constants.MusicPlayerView.backwardButton)
                }
            }
            
            //MARK: PlayPauseView
            Button {
                storyDataVM.togglePlayPause()
            } label: {
                switch storyDataVM.playbackState {
                case .playing:
                    PlayButtonView(symbolImage: Constants.MusicPlayerView.pauseButton)
                case .paused:
                    PlayButtonView(symbolImage: Constants.MusicPlayerView.playButton)
                case .stopped:
                    PlayButtonView(symbolImage: Constants.MusicPlayerView.playButton)
                case .resume:
                    PlayButtonView(symbolImage: Constants.MusicPlayerView.pauseButton)
                }
            }
            
            //MARK: ForwardView
            VStack {
                TimerForwardBackwardTextView(isBackwardORForwardTapped: $isForwardTapped, textSecond: "+10")
                Button {
                    forwardAction()
                    isForwardTapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                        withAnimation(.easeInOut) {
                            isForwardTapped = false
                        }
                    }
                } label: {
                    TimerButtonView(imageStyle: Constants.MusicPlayerView.forwardButton)
                }
            }
        }
    }
}

#Preview {
    ButtonActionView(backwardAction: {}, forwardAction: {}, isBackwardTapped: .constant(true), isForwardTapped: .constant(true))
        .environmentObject(MusicDataViewModel())
}

