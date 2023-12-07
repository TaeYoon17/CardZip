//
//  TTS_Service.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/19.
//

import Foundation
import AVFoundation


final class TTS{
    static let shared = TTS()
    private init(){}
    var synthesizer = AVSpeechSynthesizer()
    enum LanguageType:String,CaseIterable{
        case ko = "ko-KR"
        case en_usa = "en-US"
        case en_uk = "en-UK"
        case fr = "fr-FR"
        case ja = "ja-JP"
        case ch = "zh-CN"
        case de = "de-DE"
        case es = "es-ES"
        private var _name:String{
            switch self{
            case .ch: return "TTS Simplified Chinese"
            case .en_uk: return  "TTS English (United Kingdom)"
            case .en_usa: return "TTS English (United States)"
            case .fr: return "TTS French (Standard)"
            case .de: return "TTS German (Standard)"
            case .ja: return "TTS Japanese"
            case .ko: return "TTS Korean"
            case .es: return "TTS Spanish (Spain)"
            }
        }
        var name:String{_name.localized}
    }
    func textToSpeech(text:String,language: LanguageType){
        // 무음 모드에서도 음성을 작동하는 코드
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,mode: .default)
        } catch let error {
            print("This error message from SpeechSynthesizer \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        utterance.rate = 0.4
        synthesizer.speak(utterance)
        Task.detached {
            try await Task.sleep(for:.seconds(2))
            self.synthesizer = AVSpeechSynthesizer()
        }
    }
}
