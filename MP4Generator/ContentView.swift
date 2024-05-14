

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct ContentView: View {
    @State private var isPreviewMusicTapped = false
    @State private var isShowingImagePicker = false
    @State private var isShowingAudioPicker = false
    @State private var isShowingVideoPreview = false
    @State private var videoURL: URL?
    @State private var activePopup: ActivePopup?
    @State private var activeAnimation: Bool = false
    
    
    @StateObject var musicDataVM = MusicDataViewModel()
    
    
    @State var selectedImage: UIImage?
    @State var selectedAudioURL: URL?
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                VStack(spacing: 20) {
                    Spacer()
                    if selectedImage == nil {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(16)
                                    .frame(width: 110, height: 110)
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
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 140, height: 140)
                                Spacer()
                            }
                            Button {
                                selectedImage = nil
                            } label: {
                                Text("Deselect Image")
                            }
                        }
                    }
                    if isPreviewMusicTapped {
                        MusicPlayerView()
                            .environmentObject(musicDataVM)
                    }
                    
                    if let videoURL = videoURL {
                        Button {
                            downloadVideo(videoURL: videoURL)
                        } label: {
                            HStack {
                                Text("Your video is ready tap to download.")
                                Image("file")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                .sheet(isPresented: $showImagePicker, onDismiss: loadImage ) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isPreviewMusicTapped.toggle()
                        } label: {
                            Text(isPreviewMusicTapped ? "Dismiss sound" : "Preview sound")
                        }
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if selectedImage != nil {
                            Button {
                                createVideo()
                                activeAnimation = true
                            } label: {
                                HStack {
                                    Text("Create Video")
                                    Image(systemName: "video.fill")
                                }
                            }
                            .opacity(videoURL == nil ? 1 : 0)
                        }
                        
                    }
                }
                
                .navigationTitle("Boby")
                .navigationBarTitleDisplayMode(.inline)
                
                LootieAnimationView(name: "loading", loopMode: .loop)
                    .opacity(activeAnimation ? 1 : 0)
                    .frame(width: 100, height: 100, alignment: .center)
                if activePopup == .imageDownloaded {
                    VStack {
                        Spacer()
                        PopupView(title: "Image Downloaded", subtitle: "Image downloaded successfully. Please check photo library to see your video.")
                            .padding(.bottom, 60)
                    }
                }
            }
            
        }
        
    }
    
    func loadImage() {
        guard selectedImage != nil else { return }
    }
    
    func createVideo() {
        guard let image = selectedImage else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let videoFileName = "video_\(formatter.string(from: Date())).mp4"
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let videoOutputURL = documentsPath.appendingPathComponent(videoFileName)
        
        do {
            if FileManager.default.fileExists(atPath: videoOutputURL.path) {
                try FileManager.default.removeItem(at: videoOutputURL)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        guard let videoWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: .mp4) else { return }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: image.size.width,
            AVVideoHeightKey: image.size.height
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
        
        videoWriter.add(videoWriterInput)
        
        // 2. Start writing session
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        // 3. Add images to video
        let frameDuration = CMTimeMake(value: 5, timescale: 30)
        let frameCount = 60 // Change this according to the duration of your video
        
        for i in 0..<frameCount {
            let imageBuffer = self.pixelBufferFromImage(image: image.cgImage!, size: image.size)!
            while !pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData {
                usleep(100)
            }
            let presentTime = CMTimeMultiply(frameDuration, multiplier: Int32(i))
            pixelBufferAdaptor.append(imageBuffer, withPresentationTime: presentTime)
        }
        
        
        
        // 4. Finish writing
        videoWriterInput.markAsFinished()
        videoWriter.finishWriting {
            DispatchQueue.main.async {
                //self.videoURL = videoOutputURL
                guard let selectedAudioURL = musicDataVM.audioURL else { return }
                addAudioToVideo(videoURL: videoOutputURL, audioURL: selectedAudioURL) { resultURL in
                        if let resultURL = resultURL {
                            DispatchQueue.main.async {
                                self.videoURL = resultURL
                                activeAnimation = false
                            }
                        } else {
                            print("Video oluşturma işlemi başarısız.")
                        }
                    }
            }
        }
        
    }
    
    func downloadVideo(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        } completionHandler: { success, error in
            if success {
                print("Video saved to photo library successfully.")
                activePopup = .imageDownloaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    activePopup = nil
                }
            } else if let error = error {
                print("Error saving video to photo library: \(error.localizedDescription)")
            }
        }
    }
    
    func pixelBufferFromImage(image: CGImage, size: CGSize) -> CVPixelBuffer? {
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }

    func addAudioToVideo(videoURL: URL, audioURL: URL, completion: @escaping (URL?) -> Void) {
        // Video ve ses asset'leri oluştur
        let videoAsset = AVURLAsset(url: videoURL)
        let audioAsset = AVURLAsset(url: audioURL)
        
        // Yeni video dosyasını oluşturacak bileşimi oluştur
        let mixComposition = AVMutableComposition()
        
        // Video track oluştur
        guard let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        
        // Video asset'inden video track'e veri ekle
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                                           of: videoAsset.tracks(withMediaType: .video)[0],
                                           at: .zero)
        } catch {
            completion(nil)
            return
        }
        
        // Ses track oluştur
        guard let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        
        // Ses asset'inden ses track'e veri ekle
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                                           of: audioAsset.tracks(withMediaType: .audio)[0],
                                           at: .zero)
        } catch {
            completion(nil)
            return
        }
        
        // Video çıktı ayarları
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let outputFileName = "final_video_\(formatter.string(from: Date())).mp4"
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        
        let outputURL = documentsPath.appendingPathComponent(outputFileName)
        
        // Videoyu çıkart
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL)
            case .failed, .cancelled:
                completion(nil)
            default:
                completion(nil)
            }
        }
    }

    
}
