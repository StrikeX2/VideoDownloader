//
//  whypressbutton.swift
//  VideoDownloader
//
//  Created by home on 10/8/2026.
//
import SwiftUI

struct WhyButton: View{
    @State private var screentext = "why u press button :("
    @State private var buttontext = "dont press this one either pls"
    @State private var buttoncounter = 0
    let buttonMessages = try! String(
        contentsOf: Bundle.main.url(
            forResource: "thebutton",
            withExtension: "txt"
        )!,
        encoding: .utf8
    ).components(separatedBy: .newlines)
    

    let screenMessages = try! String(
        contentsOf: Bundle.main.url(
            forResource: "thetext",
            withExtension: "txt"
        )!,
        encoding: .utf8
    ).components(separatedBy: .newlines)
    
    var body: some View{
        VStack() {
            if buttoncounter != 35 {
                Text(screentext)
                    .padding()
            }else{
                VStack() {
                    Text(screentext)
                        .padding()
                    Link(
                        "www.github.com/StrikeX2/DaSourceCode",
                        destination: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)
                    .padding()
                    .selectionDisabled(false)
                }
            }
            
            HStack(){
                Button(buttontext){
                    buttoncounter += 1
                    if buttoncounter < buttonMessages.count {
                        buttontext = buttonMessages[buttoncounter]
                    }
                    if buttoncounter >= 27 && buttoncounter <= 39 {
                        screentext = screenMessages[buttoncounter - 27]
                    }
                    
                    if buttoncounter == 109 {
                        fatalError("stupid button")
                    }
                }
                .focusable(false)
            }
        }
    }
}
 
#Preview{
    WhyButton()
}
