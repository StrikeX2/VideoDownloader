//
//  YTdownloader_NotAScamApp.swift
//  YTdownloader NotAScam
//
//  Created by home on 4/8/2026.
//

import SwiftUI
import Sparkle
@main
struct VideoDownloader: App {
    private let updaterController: SPUStandardUpdaterController
    init(){
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
            )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .frame(minWidth: 200, minHeight:150) // Minimum window width
        }
        .defaultSize(width: 400, height: 250)
        Window("why u press button :(", id: "WhyButton") {
            WhyButton()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates..."){
                    updaterController.updater.checkForUpdates()}
                Divider()
            }
            VideoDownloaderCommands()
        }
    }
}



struct VideoDownloaderCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(after: .appInfo) {

            Divider()

            Button("dont press this button") {
                openWindow(id: "WhyButton")
            }
        }
    }
}
