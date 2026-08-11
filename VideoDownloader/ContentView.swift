//
//  ContentView.swift
//  YTdownloader NotAScam
//
//  Created by home on 4/8/2026.
//

// ADD A MENU HELP BUTTON OR SMTH

import SwiftUI
import Foundation
import AppKit

struct ContentView: View {
    @State private var url = ""
    @State private var downloadstatus = " "
    @State private var progressdots = "."
    @State private var currentprocess: Process?
    @State private var isdownloading = false
    @AppStorage("savedoutpath") private var outpath: String = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? ""
    

    
    
    var body: some View {
        VStack() {
            TextField("Insert URL... ", text: $url)
            
            HStack(){
                Text("Output path: \(outpath)")
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Button("Browse..."){
                    selectfolder()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                // Add a progress bar?
            }
            .padding()
            HStack{
                if isdownloading{
                    Button("Cancel"){
                        currentprocess?.terminate()
                    }
                    .tint(.red)
                }else{
                    Button("Download .mp3") {
                        download(downloadtype: "mp3")
                    }
                    //.buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    Button("Download .mp4") {
                        download(downloadtype: "mp4")
                    }
                    //.buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
            }
            Text(downloadstatus)
                .textSelection(.enabled)
        }
        .padding()
    }
    
    
    func selectfolder(){
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Choose"
        // Show the panel and wait for the user to click OK
        if panel.runModal() == .OK {
            if let path = panel.url?.path{
                outpath = path
            }
        }
    }
    
    
    
    func download(downloadtype: String){
        guard let ffmpegurl = Bundle.main.url(forResource: "ffmpeg", withExtension: nil),
              let ytdlpurl = Bundle.main.url(forResource: "yt-dlp", withExtension: nil) else{
            print("Error - binaries not found!")
            return}

        guard !url.isEmpty else{
            downloadstatus = "Error - Empty URL"
            return}
        
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            // Kill any previous processes and restarts
            DispatchQueue.main.async {
                currentprocess?.terminate()
                currentprocess = nil
                currentprocess = process
                isdownloading = true
                downloadstatus = "Downloading."
            }
            
            // Downloading timer
            downloadstatus = "Downloading\(progressdots)"
            let dottimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                DispatchQueue.main.async {
                    progressdots+="."
                    if (progressdots.count > 3){
                        progressdots = "."
                    }
                    downloadstatus = "Downloading\(progressdots)"
                }
            }
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            process.executableURL = ytdlpurl
            if downloadtype == "mp3" {
                
                // ADD THING FOR CUSTOM SETTINGS, ESPECIALLY VIDEO DOWNLOADING
                process.arguments = [
                    "-x",
                    "--audio-format", "mp3",
                    "--ffmpeg-location", ffmpegurl.path,
                    "--print", "after_move:filepath",
                    "-o", "\(outpath)/%(title)s.%(ext)s",
                    url
                ]
            }
            else if downloadtype == "mp4"{
                process.arguments = [
                    "-f", "bv[vcodec^=avc1]+ba[acodec^=mp4a]/b",
                    "--merge-output-format", "mp4",
                    "--ffmpeg-location", ffmpegurl.path,
                    "--print", "after_move:filepath",
                    "-o", "\(outpath)/%(title)s.%(ext)s",
                    url
                ]
            }

            // Ending process
            process.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                DispatchQueue.main.async {
                    if currentprocess === process {
                        currentprocess = nil
                        isdownloading = false
                    }

                    dottimer.invalidate()
                    
                    if process.terminationStatus == 0 {
                        let filepath = output
                            .split(separator: "\n")
                            .last?
                            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                        downloadstatus = "File saved to \(filepath))"
                    } else{
                        if process.terminationReason == .uncaughtSignal {
                            downloadstatus = "Download cancelled"
                        }else{
                            // ADD AN OPTION LIKE DROP DOWN OR SMTH TO VIEW YT DLP OUTPUT
                            downloadstatus = "\(output)"//"Download failed - probably an invalid URL."
                        }
                    }
                }
            }
            do{
                try process.run()
                process.waitUntilExit()
            }catch{
                DispatchQueue.main.async {
                    dottimer.invalidate()
                    downloadstatus = "Error: \(error.localizedDescription)"
                    isdownloading = false
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
