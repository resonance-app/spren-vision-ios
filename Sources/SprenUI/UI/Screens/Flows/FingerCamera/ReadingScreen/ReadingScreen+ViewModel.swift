//
//  ReadingScreen+ViewModel.swift
//  SprenUI
//
//  Created by Keith Carolus on 11/11/21.
//

import Foundation
import AVKit
import SprenCapture
import SprenCore

extension ReadingScreen {
    class ViewModel: ObservableObject {
        
        let onReadingStateChange: (Bool) -> Void
        let onError: () -> Void
        let onBackButtonTapNav: () -> Void
        let onFinishNav: () -> Void
        
        @Published var readingState: ReadingState = .preReading
        @Published var progressText = ""
        @Published var progress: Int = 0 {
            didSet {
                updateProgressText()
            }
        }
        @Published var signalPreview: [(x: Double, y: Double)] = []
        @Published var bpm = "--"
        
        @Published var torchMode: AVCaptureDevice.TorchMode?
        
        var brightnessNonComplianceCounter = 0
        var frameDropNonComplianceCounter = 0
        @Published var showAlert = false
        
        // alert config
        var alertTitle: String = ""
        var alertParagraph: String = ""
        var alertPrimaryButtonText: String = ""
        var alertOnPrimaryButtonTap: () -> Void = {}
        var alertSecondaryButtonText: String? = nil
        var alertOnSecondaryButtonTap: (() -> Void)? = nil
        
        var sprenCapture: SprenCapture? = nil
        
        init(onReadingStateChange: @escaping (Bool) -> Void, onError: @escaping () -> Void, onBackButtonTap: @escaping () -> Void, onFinish: @escaping () -> Void) {
            
            self.onReadingStateChange = onReadingStateChange
            self.onError = onError
            self.onBackButtonTapNav = onBackButtonTap
            self.onFinishNav = onFinish
            
            self.onReadingStateChange(true)
            // MARK: - SprenCapture
            
            do {
                sprenCapture = try SprenCapture()
                sprenCapture?.start()
                
                SprenUI.config.logger?.info("SprenCapture started")
            } catch {
                SprenUI.config.logger?.error("SprenCapture failed to start: \(error.localizedDescription)")
                return
            }
            
            // MARK: - Spren config
            
            Spren.setOnStateChange { [weak self] state, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch state {
                    case .started:
                        self.startState()
                    case .finished:
                        self.finishState()
                    case .cancelled:
                        self.cancelState()
                    case .error:
                        if let error = error {
                            SprenUI.config.logger?.info("Spren transitioned to error state: \(error.localizedDescription)")
                        }
                        self.errorState()
                    @unknown default:
                        break
                    }
                }
            }
            
            Spren.setOnPrereadingComplianceCheck { [weak self] name, compliant, action in
                guard let self = self else { return }
                
                if self.readingState == .reading {
                    SprenUI.config.logger?.info(.init(stringLiteral: "received prereading compliance check while VM has reading state, progress \(self.progress)%, showAlert \(self.showAlert), alertTitle \(self.alertTitle)"))
                }
                
                DispatchQueue.main.async {
                    switch name {
                    case .frameDrop:
                        self.handleFrameDropCompliance(name: name, compliant: compliant, action: action)
                    case .brightness:
                        self.handleBrightnessCompliance(name: name, compliant: compliant, action: action)
                    case .lensCoverage:
                        self.handleLensCoverageCompliance(name: name, compliant: compliant, action: action)
                    @unknown default:
                        break
                    }
                }
            }
            
            Spren.setOnProgressUpdate { [weak self] progress in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.progress = progress
                }
            }
                        
            reset()
        }
        
        private func reset() {
            readingState = .preReading
            progress = 0
            progressText = "Place your fingertip over the rear-facing camera lens."
            showAlert = false
            Spren.autoStart = true
            signalPreview = []
        }
        
        // MARK: Spren state transitions
        
        func startState() {
            try? sprenCapture?.lock()
            
            readingState = .reading
            Haptics.softImpact()
        }
        
        func finishState() {
            try? sprenCapture?.unlock()
            sprenCapture?.stop()
            
            progress = 100
            Haptics.successNotification()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.onReadingStateChange(false)
                self.onFinishNav()
            }
            DispatchQueue.global(qos: .background).async {
                UserDefaults.standard.set(true, forKey: SprenUI.config.secondReadingKey)
            }
        }
        
        func cancelState() {
            try? sprenCapture?.unlock()
            sprenCapture?.stop()
            reset()
            self.onReadingStateChange(false)
            onBackButtonTapNav()
        }
        
        func errorState() {
            readingState = .preReading
            try? sprenCapture?.unlock()
            self.onError()
            showErrorAlert() // calls reset
        }
        
        // MARK: - handle compliance checks
        
        func handleFrameDropCompliance(name: ComplianceCheck.Name, compliant: Bool, action: ComplianceCheck.Action?) {
            guard !compliant else { frameDropNonComplianceCounter = 0; return }
            frameDropNonComplianceCounter += 1
            if frameDropNonComplianceCounter == 2 {
                _ = try? sprenCapture?.dropComplexity()
                torchMode = try? sprenCapture?.setTorchMode(to: torchMode ?? .on)
                frameDropNonComplianceCounter = 0
                
                SprenUI.config.logger?.info("drop complexity during state: \(readingState == .reading ? "reading" : "not reading")")                
            }
        }
        
        func handleBrightnessCompliance(name: ComplianceCheck.Name, compliant: Bool, action: ComplianceCheck.Action?) {
            if !compliant && !showAlert {
                brightnessNonComplianceCounter += 1
                if brightnessNonComplianceCounter == 5 {
                    brightnessNonComplianceCounter = 0
                    Spren.autoStart = false
                    showBrightnessAlert()
                }
            }
        }
        
        func handleLensCoverageCompliance(name: ComplianceCheck.Name, compliant: Bool, action: ComplianceCheck.Action?) {
            
        }
        
        func updateProgressText() {
            let pInt = Int(progress)
            switch pInt {
            case 0:
                progressText = "Make sure your finger fully covers the flashlight and the correct camera. Apply enough pressure so that the entire screen stays red."
            case 1:
                progressText = "Detecting your pulse. Keep your hand still and apply firm pressure."
            case 30:
                progressText = "Measuring your heart rate. Please relax and hold still."
            case 50:
                progressText = "Scanning in progress. Please hold still."
            case 70:
                progressText = "Measuring your heart rate. Please hold still."
            case 85:
                progressText = "Almost there."
            case 100:
                progressText = "Measurement complete!"
            default:
                break
            }
        }
        
        // MARK: - user input
        
        func onBackButtonTap() {
            showCancelAlert()
        }
        
        public func turnOnFlash() {
            torchMode = try? sprenCapture?.setTorchMode(to: .on)
        }
        
        public func onTapToggleTorch() {
            guard readingState == .preReading else { return }
            torchMode = try? sprenCapture?.setTorchMode(to: torchMode == .on ? .off : .on)
        }
        
        /// app returns from background
        func onAppActive() {
            Spren.cancelReading()
        }
        
        // MARK: - alerts
        
        func showBrightnessAlert() {
            alertTitle = "There is not enough light for the measurement"
            alertParagraph = "Make sure the flash is on and your finger covers both the flashlight and the camera with enough pressure. "
            alertPrimaryButtonText = "Turn on flash"
            alertOnPrimaryButtonTap = {
                self.turnOnFlash()
                self.onReadingStateChange(true)
                self.reset()
            }
            alertSecondaryButtonText = "Cancel"
            alertOnSecondaryButtonTap = {
                self.onReadingStateChange(true)
                self.reset()
            }
            
            SprenUI.config.logger?.info("show brightness alert")
            self.onReadingStateChange(false)
            showAlert = true
        }
        
        func showErrorAlert() {
            alertTitle = "Oops, something isn't working out yet"
            alertParagraph = "Make sure your finger fully covers the camera and flashlight. Apply enough pressure on both the lens and the flash so that the entire screen stays red and no extra light is leaking into the camera."
            alertPrimaryButtonText = "Try again"
            alertOnPrimaryButtonTap = {
                self.onReadingStateChange(true)
                self.reset()
            }
            alertSecondaryButtonText = nil
            alertOnSecondaryButtonTap = nil
            
            SprenUI.config.logger?.info("show error alert")
            self.onReadingStateChange(false)
            showAlert = true
        }
        
        func showCancelAlert() {
            alertTitle = "Your measurement is not complete"
            alertParagraph = "Continue measurement in order to see your reading results."
            alertPrimaryButtonText = "Stop measurement"
            alertOnPrimaryButtonTap = {
                Spren.cancelReading()
                // cancelled called in callback
            }
            alertSecondaryButtonText = "Continue Measurement"
            alertOnSecondaryButtonTap = {
                self.onReadingStateChange(true)
                self.showAlert = false
            }
            
            SprenUI.config.logger?.info("show cancel alert")
            self.onReadingStateChange(false)
            showAlert = true
        }
        
    }
}
