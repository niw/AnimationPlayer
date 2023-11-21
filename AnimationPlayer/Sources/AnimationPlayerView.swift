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

    var body: some View {
        VStack {
            VideoPlayerView(player: animationPlayer.player)
            HStack {
                Button {
                    animationPlayer.back()
                } label: {
                    Text("Back")
                }

                Spacer()

                Button {
                    if animationPlayer.rate > .zero {
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

                Spacer()

                Button {
                    animationPlayer.forward()
                } label: {
                    Text("Forward")
                }
            }
            .padding(EdgeInsets(top: 0.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
        }
    }
}

#Preview {
    AnimationPlayerView(animationPlayer: AnimationPlayer(url: nil))
}
