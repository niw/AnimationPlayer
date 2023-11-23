//
//  ObserverToken.swift
//  AnimationPlayer
//
//  Created by Yoshimasa Niwa on 11/23/23.
//

import Foundation

final class ObserverToken<Token> {
    private let removeObserverBlock: (Token) -> Void

    private let token: Token

    init(token: Token, removeObserverBlock: @escaping (Token) -> Void) {
        self.token = token
        self.removeObserverBlock = removeObserverBlock
    }

    deinit {
        removeObserverBlock(token)
    }
}
