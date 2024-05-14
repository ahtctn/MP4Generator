//
//  TimerForwardBackwardTextView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//


import SwiftUI

struct TimerForwardBackwardTextView: View {
    
    @Binding var isBackwardORForwardTapped: Bool
    var textSecond: String
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 45, height: 45, alignment: .center)
                .foregroundStyle(.blue.opacity(0.4))
            
            
            Text(textSecond)
                .font(.title3)
                .foregroundStyle(.blue)
                .bold()
        }
        .opacity(isBackwardORForwardTapped ? 1 : 0)
        
    }
}

#Preview {
    TimerForwardBackwardTextView(isBackwardORForwardTapped: .constant(true), textSecond: "10")
}
