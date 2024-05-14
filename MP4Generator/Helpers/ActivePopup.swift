//
//  ActivePopup.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import Foundation

enum ActivePopup: Identifiable {
    case imageDownloaded
        
    
    var id: Int {
        hashValue
    }
}
