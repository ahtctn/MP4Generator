//
//  PopupView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI

struct PopupView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                Text(title)
                    .font(.title3).bold()
            }
            Text(subtitle)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .multilineTextAlignment(.center)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color("appBackgroundColorLightAndDark").opacity(0.9))
                .padding(.leading, 10)
                .padding(.trailing, 10)
        )
    }
}

#Preview {
    PopupView(title: "Popup", subtitle: "Popup subtitle.")
        .previewLayout(.sizeThatFits)
}

