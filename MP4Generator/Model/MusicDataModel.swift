//
//  MusicDataModel.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import Foundation
import SwiftUI

struct MusicDataModel: Identifiable {
    var id = UUID().uuidString
    var name: String
    var soundName: String
}
