//
//  AddImageView.swift
//  MP4Generator
//
//  Created by Ahmet Ali ÇETİN on 14.05.2024.
//

import SwiftUI

struct AddImageView: View {
    
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        
        NavigationView {
            Form {
                if selectedImage == nil {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(16)
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        Button {
                            self.showImagePicker = true
                        } label: {
                            Text("Select Image")
                                .fontWeight(.bold)
                        }
                    }
                }
                if let image = selectedImage {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                selectedImage = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 140, height: 140)
                            Spacer()
                        }
                    }
                }
                
            }
            
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage ) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    func loadImage() {
        guard selectedImage != nil else { return }
    }
    
}

#Preview {
    AddImageView(selectedImage: .constant(nil))
}

