//
//  EventsWebView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 12/25/22.
//

import SwiftUI
import WebKit

struct EventsView: View {
    var body: some View {
        CustomEventsWebView()
            .frame(maxHeight: .infinity)
    }
}

struct CustomEventsWebView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //uiView.load(request)
        let localFileURL = Bundle.main.url(forResource: "events", withExtension: "html")!
        uiView.loadFileURL(localFileURL, allowingReadAccessTo: localFileURL)
    }
    

}


struct EventsWebView_Previews : PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}


// https://developer.apple.com/forums/thread/117348
