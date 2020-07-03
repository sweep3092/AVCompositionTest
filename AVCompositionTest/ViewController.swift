//
//  ViewController.swift
//  AVCompositionTest
//
//  Created by yu.kobayashi on 2020/07/03.
//  Copyright © 2020 yu.kobayashi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var avPlayerPlayButton: UIButton!
    var videoPlayer: AVPlayer!
    var assetA: AVURLAsset!
    var assetB: AVURLAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let composition = AVMutableComposition()
        
        let assetAURL = Bundle.main.url(forResource: "a_downconverted", withExtension: "mp4")!
        assetA = AVURLAsset(url: assetAURL)
        
        guard let audioTrackA = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            debugPrint("Failed to add audio track.")
            return
        }
        
        // 素材Assetの1個目のAudioトラックを使う
        let srcAudioTrackA = assetA.tracks(withMediaType: .audio)[0]
        do {
            // 0秒のタイミングに、映像全体を追加する
            try audioTrackA.insertTimeRange(srcAudioTrackA.timeRange, of: srcAudioTrackA, at: .zero)
        } catch let error {
            debugPrint(error)
        }
        
        let assetBURL = Bundle.main.url(forResource: "matched_b", withExtension: "mp4")!
        assetB = AVURLAsset(url: assetBURL)

        guard let audioTrackB = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            debugPrint("Failed to add audio track.")
            return
        }

        // 素材Assetの1個目のAudioトラックを使う
        let srcAudioTrackB = assetB.tracks(withMediaType: .audio)[0]
        do {
            // 0秒のタイミングに、映像全体を追加する
            try audioTrackB.insertTimeRange(srcAudioTrackB.timeRange, of: srcAudioTrackB, at: .zero)
        } catch let error {
            debugPrint(error)
        }
        
        // AVPlayerで再生
        videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: composition))
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
//        let atHostTime: CMTime = CMClockGetTime(CMClockGetHostTimeClock())
//        let avVideoPlayerA = AVPlayer(playerItem: AVPlayerItem(asset: assetA))
//        let avVideoPlayerB = AVPlayer(playerItem: AVPlayerItem(asset: assetB))
//        avVideoPlayerA.setRate(1, time: CMTime.invalid, atHostTime: atHostTime)
//        avVideoPlayerB.setRate(1, time: CMTime.invalid, atHostTime: atHostTime)
//        avVideoPlayerA.play()
//        avVideoPlayerB.play()
    }
}

