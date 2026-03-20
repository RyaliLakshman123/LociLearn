//
//  ARAccessibilityManager.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 23/02/26.
//

import UIKit
import AVFoundation

final class ARAccessibilityManager {
    
    static func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
}
