//
//  MovieDocument.swift
//  AnimationPlayer
//
//  Created by Yoshimasa Niwa on 11/20/23.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

final class MovieDocument: FileDocument {
    static var readableContentTypes = [
        UTType.movie
    ]

    required init(configuration: ReadConfiguration) throws {
        // Do nothing.
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Should not reach here.
        FileWrapper()
    }
}
