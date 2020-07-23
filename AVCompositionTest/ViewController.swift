import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var avPlayerPlayButton: UIButton!
    var videoPlayer: AVPlayer!
    var assetA: AVURLAsset!
    var assetB: AVURLAsset!
    var assetAURL: URL!
    var assetBURL: URL!
    var exportedURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        assetAURL = Bundle.main.url(forResource: "443_original", withExtension: "mp4")!
        assetBURL = Bundle.main.url(forResource: "443_down_converted", withExtension: "mp4")!
        exportedURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(".mp4")
        
        // AVMutableCompositionで、エクスポートし直す
        // 時間がかかるので、ログにメッセージが表示されてから、再生してね
        VideoFileConverter(url: assetBURL).convert(to: exportedURL) { [weak self] in
            self?.load()
        }
    }
    
    private func load() {
        let composition = AVMutableComposition()
        
        assetA = AVURLAsset(url: assetAURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        // assetB = AVURLAsset(url: assetBURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        assetB = AVURLAsset(url: exportedURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        guard let audioTrackA = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        guard let audioTrackB = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        
        
        let srcAudioTrackA = assetA.tracks(withMediaType: .audio)[0]
        do {
            // 0秒のタイミングに、映像全体を追加する
            let timeRange = CMTimeRange(start: CMTime(seconds: 0 / 1000, preferredTimescale: 1000), end: srcAudioTrackA.timeRange.duration)
            try audioTrackA.insertTimeRange(timeRange, of: srcAudioTrackA, at: .zero)
        } catch let error {
            debugPrint(error)
        }

        let srcAudioTrackB = assetB.tracks(withMediaType: .audio)[0]
        do {
            let timeRange = CMTimeRange(start: CMTime(seconds: 0 / 1000, preferredTimescale: 1000), end: srcAudioTrackB.timeRange.duration)
            try audioTrackB.insertTimeRange(timeRange, of: srcAudioTrackB, at: .zero)
        } catch let error {
            debugPrint(error)
        }
        
        // AVPlayerで再生
        videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: composition, automaticallyLoadedAssetKeys: ["playable"]))
    }
    
    @IBAction func playButtonClicked(_ sender: Any) {
        let playerController = AVPlayerViewController()
        playerController.player = videoPlayer
        self.present(playerController, animated: true, completion: {
            self.videoPlayer.play()
        })
    }
    
    @IBAction func avPlayerButtonClicked(_ sender: Any) {
        // FIXME: ここまだ動かない
        let avVideoPlayerA = AVPlayer(playerItem: AVPlayerItem(asset: assetA))
        let avVideoPlayerB = AVPlayer(playerItem: AVPlayerItem(asset: assetB))
        
        avVideoPlayerA.automaticallyWaitsToMinimizeStalling = false
        avVideoPlayerB.automaticallyWaitsToMinimizeStalling = false
        
        func play() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
               // Code you want to be delaye
                
                guard avVideoPlayerA.status == .readyToPlay && avVideoPlayerB.status == .readyToPlay else { return }
                  
                let atHostTime: CMTime = CMClockGetTime(CMClockGetHostTimeClock())
                  avVideoPlayerA.setRate(1, time: CMTime.invalid, atHostTime: atHostTime)
                  avVideoPlayerB.setRate(1, time: CMTime.invalid, atHostTime: atHostTime)
                  // avVideoPlayerA.play()
                  // avVideoPlayerB.play()
            }
            
  
        }
        
        assetA.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            var error: NSError? = nil
            let status = self?.assetA.statusOfValue(forKey: "playable", error: &error)
            
            if status == .loaded {
                play()
            }
        }
        
        assetB.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            var error: NSError? = nil
            let status = self?.assetB.statusOfValue(forKey: "playable", error: &error)
            
            if status == .loaded {
                play()
            }
        }
        
        // avVideoPlayerA.preroll(atRate: <#T##Float#>, completionHandler: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        
        //        avVideoPlayerA.setRate(1, time: CMTime.invalid, atHostTime: atHostTime)
        //        avVideoPlayerB.setRate(1, time: CMTime.invalid, atHostTime: atHostTime)
        //        avVideoPlayerA.play()
        //        avVideoPlayerB.play()
    }
    
//    private func setUpPlayerItem(avplayer: AVPlayer, with asset: AVAsset) {
//        playerItem = AVPlayerItem(asset: asset)
//        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
//
//        DispatchQueue.main.async { [weak self] in
//            self?.player = AVPlayer(playerItem: self?.playerItem!)
//        }
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        // Only handle observations for the playerItemContext
//        guard context == &playerItemContext else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//            return
//        }
//
//        if keyPath == #keyPath(AVPlayerItem.status) {
//            let status: AVPlayerItem.Status
//            if let statusNumber = change?[.newKey] as? NSNumber {
//                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
//            } else {
//                status = .unknown
//            }
//            // Switch over status value
//            switch status {
//            case .readyToPlay:
//                print(".readyToPlay")
//                player?.play()
//            case .failed:
//                print(".failed")
//            case .unknown:
//                print(".unknown")
//            @unknown default:
//                print("@unknown default")
//            }
//        }
//    }
}

