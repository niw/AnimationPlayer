//
//  MainApp.swift
//  AnimationPlayer
//
//  Created by Yoshimasa Niwa on 11/20/23.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct MainApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MovieDocument.self) { configuration in
            let animationPlayer = AnimationPlayer(url: configuration.fileURL)
            AnimationPlayerView(animationPlayer: animationPlayer)
        }
    }
}
