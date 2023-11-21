//
//  VideoPlayerView.swift
//  AnimationPlayer
//
//  Created by Yoshimasa Niwa on 11/20/23.
//

import AVKit
import Foundation
import SwiftUI

struct VideoPlayerView: NSViewRepresentable {
    var player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.controlsStyle = .none
        return playerView
    }

    func updateNSView(_ playerView: AVPlayerView, context: Context) {
        playerView.player = player
    }
}
