//
//  EyezonWebViewPresenter.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 05.08.2021.
//

import Foundation
import AVFoundation
@_implementationOnly import  SwiftyJSON

/// View protocol
protocol EyezonWebViewProtocol: AnyObject {
    /// Calling if timer was ended and needed events wasn't received
    func showError(with message: String)
}

/// Presenter protocol
protocol EyezonWebViewPresenter: AnyObject {
    init(with view: EyezonWebViewProtocol)
    
    /// Firing timer with 5 sec interval for
    func webViewLoaded()
    
    /// Map console events
    func mapConsoleEvent(_ value: Any) -> (eventName: String, eventData: [String: Any])
    
    /// Connect to sockets because we leaving webview
    func webViewClose()
}

final class EyezonWebViewPresenterImpl: EyezonWebViewPresenter {
    
    /// Nested type
    private enum NeededEvents: String {
        case buttonClicked = "BUTTON_CLICKED"
        case chatJoined = "CHAT_JOINED"
    }
    
    // MARK: - Private properties
    private let emptyTuple = ("", [String: Any]())
    private var timer: Timer?
    private var buttonClickedReceived = false
    private var chatJoinedReceived = false
    private let socketService = SocketServiceProvider().getInstance()
    private var isWebViewLoaded = false
    
    // MARK: - Public properties
    weak var view: EyezonWebViewProtocol?

    // MARK: - Lifecycle
    init(with view: EyezonWebViewProtocol) {
        self.view = view
    }
    
    // MARK: - Public methods
    func webViewLoaded() {
        if !isWebViewLoaded {
            isWebViewLoaded = true
            socketService.disconnect()
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] timer in
                self?.view?.showError(with: "")
                timer.invalidate()
            })
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch { }
        }
    }
    
    func mapConsoleEvent(_ value: Any) -> (eventName: String, eventData: [String : Any]) {
        guard let bodyString = value as? String else {
            return emptyTuple
        }
        let json = JSON(parseJSON: bodyString)
        guard let eventName = json.array?[safe: 0]?.string,
              let eventDictionary = json.array?[safe: 1]?.dictionaryObject else {
            return emptyTuple
        }
        if eventName == NeededEvents.buttonClicked.rawValue {
            buttonClickedReceived = true
        } else if eventName == NeededEvents.chatJoined.rawValue {
            chatJoinedReceived = true
        }
        if let data = try? json.array?[safe: 1]?.rawData(),
            let knownClient = try? JSONDecoder().decode(KnownClient.self, from: data) {
            Storage.shared.setClientId(knownClient.eyezonClientId)
        }
        if buttonClickedReceived && chatJoinedReceived && timer != nil {
            /// Needed events received then we need stop timer
            eyezonDidLoad()
        }
        return (eventName, eventDictionary)
    }
    
    func webViewClose() {
        socketService.connect()
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch { }
    }
    
    // MARK: - Private methods
    private func eyezonDidLoad() {
        timer?.invalidate()
        timer = nil
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: // The user has previously granted access to the camera.
            break
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                print(granted)
            }
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        @unknown default:
            return
        }
    }
}
