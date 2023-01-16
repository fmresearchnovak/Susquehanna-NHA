//
//  BridgeStatusView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 12/27/22.
//

// https://medium.com/geekculture/swiftui-view-modifiers-32ed47bef484

import SwiftUI

struct BridgeStatusView: View {
    @EnvironmentObject var bridgeStatNetReq: BridgeStatusNetworkRequest
    
    var body: some View {
        VStack (spacing: 0) {
            Image("sm_bridge")
                .resizable()
                .scaledToFit()

            Text("Information")
                .bold()
                .font(.custom("Helvetica Neue", size: 20))
                .padding()
            
            Text("Near mile marker 8 on the Northwest River Trail is the Shock’s Mill Bridge Underpass. At times, high water prevents passage and there is no detour. The indicator below uses real-time data to predict is the underpass is flooded.")
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            

            Spacer()
            
            Text(bridgeStatNetReq.statusText)
               .padding()
               .frame(maxWidth: .infinity)
               .font(.system(size: 20))
               .modifier(BridgeStatusColorModifier(unloaded: bridgeStatNetReq.unLoaded, precaution: bridgeStatNetReq.precaution, flooded: bridgeStatNetReq.isFlooded))
            
            Text("Current water level: " + String(bridgeStatNetReq.waterLevel) + "ft")
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .modifier(BridgeStatusColorModifier(unloaded: bridgeStatNetReq.unLoaded, precaution: bridgeStatNetReq.precaution, flooded: bridgeStatNetReq.isFlooded))
            
            Spacer().frame(height: 80)
            
        }.frame(maxHeight: .infinity,
            alignment: .top)
        .onAppear{
            bridgeStatNetReq.checkWaterLevel()
        }
    }
}

struct BridgeStatusView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeStatusView()
            .environmentObject(BridgeStatusNetworkRequest())
    }
}

// https://medium.com/geekculture/swiftui-view-modifiers-32ed47bef484
struct BridgeStatusColorModifier: ViewModifier {

    let unloaded: Bool
    let precaution: Bool
    let flooded: Bool

    func body(content: Content) -> some View {
        if(unloaded){
            content.background(Color.gray)
        } else if(precaution){
            content.background(Color.orange)
        } else if (flooded) {
            content.background(Color.red)
        } else {
            content.background(Color.green)
        }
    }
}
