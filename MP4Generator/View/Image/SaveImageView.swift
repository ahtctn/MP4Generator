//
//  SaveImageView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI

struct SaveImageView: View {
    var image: Image
    var body: some View {
        ZStack {
            Image("launchscreenbg")
            image
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.9,
                       height: UIScreen.main.bounds.height * 0.7)
                .shadow(color: .black, radius: 5, x: 0, y: 0)
            VStack {
                Spacer()
                Spacer()
                Image("history")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                Spacer()
            }
            
        }
    }
}

#Preview {
    SaveImageView(image: Image("history"))
}
