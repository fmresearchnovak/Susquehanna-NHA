//
//  Susquehanna_NHAApp.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 11/26/22.
//

import SwiftUI

@main
struct Susquehanna_NHAApp: App {
    
    var bridgeStatNetReq = BridgeStatusNetworkRequest()
    var kmlNetReq = KMLNetworkRequest()
    var notiNetReq = NotificationNetworkRequest()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                
                SNHAMapView()
                    .tabItem {
                        Label("Trails", systemImage: "mappin.and.ellipse")
                    }
                    .environmentObject(kmlNetReq)
                
                
                BridgeStatusView()
                    .tabItem{
                        // alternatives that are not available on test iPhone
                        // water.waves.and.arrow.down.trianglebadge.exclamationmark
                        // water.waves
                        Label("Bridge", systemImage: "figure.walk.diamond")
                    }
                    .environmentObject(bridgeStatNetReq)
                
                
                ReportView()
                    .tabItem{
                        Label("Report", systemImage: "exclamationmark.octagon")
                    }
                
                
                EventsView()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                
                    
                ContactView()
                    .tabItem {
                        Label("Contact", systemImage: "i.circle.fill")
                    }
                
                
                NotificationListView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell")
                    }
                    .environmentObject(notiNetReq)
                    
                
            }.background(Color.purple)
        }
    }
}


// https://developer.apple.com/documentation/swiftui/tabview
