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
@MainActor
final class AnimationPlayer {
    let player: AVPlayer

    private var playerRateDidChangeObserverToken: ObserverToken<any NSObjectProtocol>?

    private var playerPeriodicTimeObserverToken: ObserverToken<Any>?

    init(url: URL?) {
        if let url {
            player = AVPlayer(url: url)
        } else {
            player = AVPlayer()
        }
        rate = player.rate
        playerRateDidChangeObserverToken = ObserverToken(token: NotificationCenter.default.addObserver(forName: AVPlayer.rateDidChangeNotification, object: player, queue: nil) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.playerRateDidChange()
            }
        }) { token in
            NotificationCenter.default.removeObserver(token)
        }
    }

    private func playerRateDidChange() {
        rate = player.rate
    }

    var rate: Float {
        didSet {
            guard player.rate != rate else {
                return
            }
            player.rate = rate
            rateDidChange(from: oldValue)
        }
    }

    private func rateDidChange(from oldValue: Float) {
        if oldValue != .zero && rate != .zero {
            return
        }

        self.playerPeriodicTimeObserverToken = nil

        if rate != .zero {
            let currentRate = rate
            Task {
                do {
                    let interval = try await frameDuration
                    // Rentrant
                    guard currentRate == rate else {
                        return
                    }
                    let player = player
                    playerPeriodicTimeObserverToken = ObserverToken(token: player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
                        Task { @MainActor [weak self] in
                            self?.updateCurrentFrame()
                        }
                    }) { token in
                        // Do not retain `self` here.
                        player.removeTimeObserver(token)
                    }
                } catch {
                }
            }
        }
    }

    private func updateCurrentFrame() {
        Task {
            let currentTime = player.currentTime()
            let currentFrame = try await Int(currentTime.seconds / frameDuration.seconds)
            self.currentFrame = currentFrame
        }
    }

    var currentFrame: Int = 0

    private var firstVideoTrack: AVAssetTrack? {
        get async throws {
            guard let currentItem = player.currentItem else {
                return nil
            }
            let tracks = try await currentItem.asset.load(.tracks)
            for track in tracks {
                if try await track.load(.isEnabled) && track.mediaType == .video {
                    return track
                }
            }
            return nil
        }
    }

    private var duration: CMTime {
        get async throws {
            guard let firstVideoTrack = try await firstVideoTrack else {
                return .zero
            }
            let range = try await firstVideoTrack.load(.timeRange)
            return range.duration
        }
    }

    private var frameDuration: CMTime {
        get async throws {
            guard let firstVideoTrack = try await firstVideoTrack else {
                return .zero
            }
            return try await firstVideoTrack.load(.minFrameDuration)
        }
    }

    var framesPerSecond: Double {
        get async throws {
            try await 1.0 / frameDuration.seconds
        }
    }

    var frames: Int {
        get async throws {
            try await Int(duration.seconds / frameDuration.seconds)
        }
    }

    func seekToBegin() {
        rate = .zero
        player.seek(to: .zero)
        updateCurrentFrame()
    }

    func seekToEnd() {
        rate = .zero
        guard let currentItem = player.currentItem else {
            return
        }
        player.seek(to: currentItem.duration, toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
        updateCurrentFrame()
    }

    func stepForward() async {
        do {
            rate = .zero
            guard let currentItem = player.currentItem else {
                return
            }
            let frameDuration = try await frameDuration
            let time = CMTimeAdd(currentItem.currentTime(), frameDuration)
            await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: frameDuration)
            updateCurrentFrame()
        } catch {
        }
    }

    func stepBack() async {
        do {
            rate = .zero
            guard let currentItem = player.currentItem else {
                return
            }
            let frameDuration = try await frameDuration
            let time = CMTimeSubtract(currentItem.currentTime(), frameDuration)
            await player.seek(to: time, toleranceBefore: frameDuration, toleranceAfter: .zero)
            updateCurrentFrame()
        } catch {
        }
    }
}
