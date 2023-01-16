//
//  Test.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 1/5/23.
//

import SwiftUI
import WebKit


struct HardCodedWebView: UIViewRepresentable {

    let markdown: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        let htmlStart = "<HTML><HEAD></HEAD><BODY style=\"padding: 140px; font-size: 120px; font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Oxygen,Ubuntu,Cantarell,Open Sans,Helvetica Neue,sans-serif\">"
        let htmlEnd = "</BODY></HTML>"

        let html = htmlStart + markdown + htmlEnd
        
        

        uiView.loadHTMLString(html, baseURL: nil)
    }

}



struct HardCodedWebView_Previews: PreviewProvider {
    static var previews: some View {
        let markdownExample = "**random markdown text**"
        HardCodedWebView(markdown: markdownExample)
    }
}
