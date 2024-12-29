//
//  ContentView.swift
//  UserNotificationOptions
//
//  Created by Đoàn Văn Khoan on 29/12/24.
//


import UserNotifications

class NotificationHelper {
    static let shared = NotificationHelper()
    private init() {}

    private let channelId = "example_channel"

    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: channelId, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

import SwiftUI
import Combine
import UserNotifications

import SwiftUI
import Combine

class NotificationLifecycleViewModel: ObservableObject {
    enum AppState {
        case active, inactive, background
    }
    
    @Published var currentState: AppState = .active
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Check initial state when app launches
        let currentState = UIApplication.shared.applicationState
        
        switch currentState {
        case .active:
            self.currentState = .active
        case .inactive, .background:
            self.currentState = .inactive
        @unknown default:
            self.currentState = .inactive
        }
        
        // Observing lifecycle events
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.currentState = .active
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.currentState = .background
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.currentState = .inactive
            }
            .store(in: &cancellables)
    }
}

import SwiftUI

import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel = NotificationLifecycleViewModel()
    private let notificationHelper = NotificationHelper.shared

    var body: some View {
        VStack {
            Text("App State: \(viewModel.currentState)")
                .padding()
            
            if viewModel.currentState == .active || viewModel.currentState == .inactive {
                Button("Show Notification") {
                    notificationHelper.showNotification(title: "App Resumed", body: "App is now active")
                }
                .padding()

                Button("Cancel Notification") {
                    notificationHelper.cancelNotification()
                }
                .padding()
            }
        }
        .onAppear {
            notificationHelper.requestNotificationAuthorization()
        }
    }
}

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NotificationView()
        }
    }
}
