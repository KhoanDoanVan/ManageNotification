//
//  ContentView.swift
//  UserNotificationOptions
//
//  Created by Đoàn Văn Khoan on 29/12/24.
//


import SwiftUI
import UserNotifications

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NotificationSettingsView()
        }
    }
}


struct NotificationSettingsView: View {
    @State private var isNotificationEnabled: Bool = false
    @State private var showSettingsAlert: Bool = false

    var body: some View {
        VStack {
            Toggle("Enable Notifications", isOn: $isNotificationEnabled)
                .onChange(of: isNotificationEnabled) { oldValue, newValue in
                    handleNotificationToggle(isOn: newValue)
                }
                .padding()

            Spacer()
        }
        .alert(isPresented: $showSettingsAlert) {
            Alert(
                title: Text("Notification Permission Required"),
                message: Text("To enable notifications, please allow permissions in Settings."),
                primaryButton: .default(Text("Open Settings"), action: openDeviceSettings),
                secondaryButton: .cancel {
                    // Reset the toggle to off if the user declines.
                    isNotificationEnabled = false
                }
            )
        }
        .onAppear {
            checkNotificationStatus()
        }
    }

    // Check the current notification status
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }

    // Handle toggle changes
    private func handleNotificationToggle(isOn: Bool) {
        if isOn {
            requestNotificationPermission()
        } else {
            disableNotifications()
        }
    }

    // Request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    isNotificationEnabled = true
                } else {
                    showSettingsAlert = true
                }
            }
        }
    }

    // Disable notifications
    private func disableNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
        isNotificationEnabled = false
    }

    // Open device settings
    private func openDeviceSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
