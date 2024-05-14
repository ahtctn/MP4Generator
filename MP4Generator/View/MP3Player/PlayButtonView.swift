//
//  PlayButtonView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI

struct PlayButtonView: View {
    var symbolImage: String
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 130, height: 130)
                .foregroundColor(Color.blue.opacity(0.5))
            
            Image(systemName: symbolImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
        }
    }
}
#Preview {
    PlayButtonView(symbolImage: "person.fill")
}

