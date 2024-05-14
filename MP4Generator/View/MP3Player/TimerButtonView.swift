//
//  TimerButtonView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI

struct TimerButtonView: View {
    var imageStyle: String
    var body: some View {
        ZStack {
            Image(systemName: imageStyle)
            // Play simgesi
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
                .foregroundColor(.blue) // Play simgesinin rengi
            
            Circle()
                .foregroundStyle(.blue.opacity(0.5))
                .frame(width: 55, height: 55, alignment: .center)
        }
    }
}

#Preview {
    TimerButtonView(imageStyle: "gece")
}

