import AVFoundation
import Foundation


final class VideoFileConverter {
    private let originalVideoUrl: URL

    /// - Parameter url: URL of the video file that will be converted.
    init(url: URL) {
        originalVideoUrl = url
    }

    /// AVMutableCompositionでエクスポートし直すやつ
    func convert(to targetUrl: URL, fileType: AVFileType = .mp4, completion: (() -> Void)? = nil) {
        let methodStart = NSDate()
        
        let assetUrl = AVURLAsset(url: originalVideoUrl, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let composition = AVMutableComposition()

        guard !assetUrl.tracks(withMediaType: .audio).isEmpty else {
            completion?()
            return
        }

        guard !assetUrl.tracks(withMediaType: .video).isEmpty else {
            completion?()
            return
        }

        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion?()
            return
        }

        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion?()
            return
        }

        let srcAudioTrack = assetUrl.tracks(withMediaType: .audio)[0]
        let srcVideoTrack = assetUrl.tracks(withMediaType: .video)[0]

        do {
            try audioTrack.insertTimeRange(srcAudioTrack.timeRange, of: srcAudioTrack, at: .zero)
            try videoTrack.insertTimeRange(srcVideoTrack.timeRange, of: srcVideoTrack, at: .zero)
        } catch {
            completion?()
            return
        }

        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion?()
            return
        }

        exporter.outputURL = targetUrl
        exporter.outputFileType = fileType

        exporter.exportAsynchronously {
            let methodFinish = NSDate()
            let executionTime = methodFinish.timeIntervalSince(methodStart as Date)
            print("Execution time: \(executionTime)")
            print("エクスポートおわった！！！！！！！！！！！！！！！！！！！！！！！")
            
            completion?()
        }
    }
}
