//
//  AnimationPlayer.swift
//  AnimationPlayer
//
//  Created by Yoshimasa Niwa on 11/20/23.
//

import AVFoundation
import Foundation
import SwiftUI

@Observable
final class AnimationPlayer {
    let player: AVPlayer

    init(url: URL?) {
        if let url {
            player = AVPlayer(url: url)
        } else {
            player = AVPlayer()
        }
        rate = player.rate
    }

    var rate: Float {
        didSet {
            player.rate = rate
        }
    }

    func forward() {
        rate = .zero
        player.currentItem?.step(byCount: 1)
    }

    func back() {
        rate = .zero
        player.currentItem?.step(byCount: -1)
    }
}
