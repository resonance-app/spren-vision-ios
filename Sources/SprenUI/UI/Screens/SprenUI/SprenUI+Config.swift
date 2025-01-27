//
//  SprenUI+Config.swift
//  SprenUI
//
//  Created by Keith Carolus on 8/18/22.
//

import Foundation
import SwiftUI
import Logging

extension SprenUI {
    public struct Config {
        // API config
        public let baseURL: String
        public let apiKey: String
        
        // user config
        public let userID: String
        public var userGender: BiologicalSex?
        public var userBirthdate: Date?
        
        // UI config
        public let project: SprenProject
        public let primaryColor: Color?
        public let secondaryColor: Color?
        
        public var bundle: Bundle = .module
        public var graphics: [Graphic: String] = [
            .greeting1: "GreetingScreen1",
            .greeting2: "GreetingScreen2",
            .fingerOnCamera: "FingerOnCamera",
            .noCamera: "NoCamera",
            .serverError: "Server",

            .greetings: "GreetingsImage",
            .cameraAccessDenied: "cameraAccessDenied",
            .incorrectBodyPosition: "IncorrectBodyPosition",
            .privacy: "Privacy",
            .bodyPosition: "Position",
//            .serverError: "ServerError",
            .setupGuide: "SetupGuide"
        ]
        public let onReadingStateChange: ((Bool) -> Void)
        public let onError: (() -> Void)
        public let onCancel: (() -> Void)?
        public let onFinish: ((_ results: Results) -> Void)
        
        // only relevant to demo app
        public let logger: Logger?
        
        // keys for UserDefaults
        public let secondReadingKey = "com.spren.ui.second-reading"
        
        public enum Graphic {
            case greeting1
            case greeting2
            case fingerOnCamera
            case noCamera
            case serverError

            case greetings
            case cameraAccessDenied
            case incorrectBodyPosition
            case privacy
            case bodyPosition
//            case serverError
            case setupGuide
        }
        
        public enum SprenProject {
            case fingerCamera
            case bodyComp
        }
        
        public init(baseURL: String,
                    apiKey: String,
                    userID: String,
                    userGender: BiologicalSex? = nil,
                    userBirthdate: Date? = nil,
                    primaryColor: Color? = nil,
                    secondaryColor: Color? = nil,
                    project: SprenProject,
                    graphics: [Graphic: String]? = nil,
                    onReadingStateChange: @escaping ((Bool) -> Void),
                    onError: @escaping (() -> Void),
                    onCancel: (() -> Void)? = nil,
                    onFinish: @escaping ((Results) -> Void),
                    logger: Logger? = nil) {
            self.baseURL = baseURL
            self.apiKey = apiKey
            
            self.userID = userID
            self.userGender = userGender
            self.userBirthdate = userBirthdate
            
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.project = project
            if let graphics = graphics {
                self.graphics = graphics
                self.bundle = .main
            }
            self.onReadingStateChange = onReadingStateChange
            self.onError = onError
            self.onCancel = onCancel
            self.onFinish = onFinish
            
            self.logger = logger
        }
    }
}
