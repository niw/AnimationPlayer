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

    @State
    var scrollPosition: Int?

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

            ScrollView(.horizontal) {
                LazyHGrid(rows: [
                    GridItem(.fixed(30.0), spacing: 0.0),
                    GridItem(.fixed(30.0), spacing: 0.0),
                    GridItem(.fixed(30.0), spacing: 0.0),
                    GridItem(.fixed(10.0), spacing: 0.0)
                ], spacing: 0.0) {
                    ForEach(0..<frames, id: \.self) { frame in
                        if framesPerSecond != .zero && frame % Int(framesPerSecond) == .zero {
                            let seconds = Int(Double(frame + 1) / framesPerSecond)
                            Text("\(seconds)")
                                .frame(width: 30.0)
                        } else {
                            Spacer()
                                .frame(width: 30.0)
                        }
                        Text("\(frame)")
                            .frame(width: 30.0)
                        Rectangle()
                            .stroke(lineWidth: 1.0)
                            .frame(width: 30.0)
                        if frame == animationPlayer.currentFrame {
                            Rectangle()
                                .fill(.blue)
                                .frame(width: 30.0)
                        } else {
                            Spacer()
                                .frame(width: 30.0)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scaledToFit()
            .scrollPosition(id: $scrollPosition, anchor: .center)
        }
        .task {
            do {
                frames = try await animationPlayer.frames
                framesPerSecond = try await animationPlayer.framesPerSecond
            } catch {
            }
        }
        .onChange(of: animationPlayer.currentFrame) {
            scrollPosition = animationPlayer.currentFrame
        }
    }
}

#Preview {
    AnimationPlayerView(animationPlayer: AnimationPlayer(url: nil))
}
