//
//  PlacemarkDetailView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 1/5/23.
//

// Scaling the WebView: https://developer.apple.com/documentation/swiftui/section/scaleeffect(x:y:anchor:)

import SwiftUI
import CoreLocation
import WebKit

struct PlacemarkDetailView: View {
    
    var plcmrk: Placemark
    
    init(_ placemark: Placemark){
        self.plcmrk = placemark
    }
    
    var body: some View {
        VStack {
            Text(self.plcmrk.name!)
                .bold()
                .font(.system(size: 30))
                .frame(alignment: .top)
                .padding()
            
            PlacemarkDescriptionWebView(descriptionHTML: plcmrk.desc)
                .border(Color.black)
                .padding()
            
            Spacer()
        }
    }
}

struct PlacemarkDescriptionWebView: UIViewRepresentable {
    
    let descriptionHTML: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let wrappedDescriptionHTML = "<body style='font-size: 40;text-align: center;width: 900px;'>" + descriptionHTML + "</body>"
        uiView.loadHTMLString(wrappedDescriptionHTML, baseURL: nil)
    }

}



struct PlacemarkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let tmpPlacemark = Placemark(name: "Example Trail POI",
                                     coordinate:CLLocationCoordinate2D(latitude: 40.1192158, longitude: -76.7091846), desc: "<h1> Parking </h1> Parking near boat launch is reserved for boaters.  This is a long description that stretches across multiple lines.")
        PlacemarkDetailView(tmpPlacemark)
    }
}
