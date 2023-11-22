//
//  AnimationPlayerView.swift
//  AnimationPlayer
//
//  Created by Yoshimasa Niwa on 11/20/23.
//

import AVKit
import SwiftUI

struct AnimationPlayerView: View {
    @State
    var animationPlayer: AnimationPlayer

    @State
    var frames: Int = 0

    @State
    var framesPerSecond: Double = 0

    var body: some View {
        VStack(spacing: 0.0) {
            VideoPlayerView(player: animationPlayer.player)

            HStack {
                Button {
                    animationPlayer.seekToBegin()
                } label: {
                    Text("Begin")
                }
                Button {
                    Task {
                        await animationPlayer.stepBack()
                    }
                } label: {
                    Text("Back")
                }

                Spacer()

                Button {
                    if animationPlayer.rate != .zero {
                        animationPlayer.rate = .zero
                    } else {
                        animationPlayer.rate = 1.0
                    }
                } label: {
                    if animationPlayer.rate > .zero {
                        Text("Pause")
                    } else {
                        Text("Play")
                    }
                }

                Text("\(animationPlayer.currentFrame)/\(frames) (\(framesPerSecond) fps)")

                Spacer()

                Button {
                    Task {
                        await animationPlayer.stepForward()
                    }
                } label: {
                    Text("Forward")
                }
                Button {
                    animationPlayer.seekToEnd()
                } label: {
                    Text("End")
                }
            }
            .padding(8.0)
        }
        .task {
            do {
                frames = try await animationPlayer.frames
                framesPerSecond = try await animationPlayer.framesPerSecond
            } catch {
            }
        }
    }
}

#Preview {
    AnimationPlayerView(animationPlayer: AnimationPlayer(url: nil))
}
