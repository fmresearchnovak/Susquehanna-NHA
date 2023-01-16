//
//  ContactView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 11/26/22.
//

import SwiftUI

struct ContactView: View {
    var body: some View {
        VStack {
            //Image(systemName: "globe")
            //    .imageScale(.large)
            //    .foregroundColor(.accentColor)
            Image("logo")
                .scaledToFit()
                .frame(width: 500)
           
            Group{
                Text("Columbia Crossing River Trails Center")
                    .font(.custom("Helvetica Neue", size: 20))
                Text("41 Walnut Street")
                Text("Columbia, PA 17512")
                Link("717-449-5607", destination: URL(string: "tel:7174495607")!)
                Spacer()
                    .frame(height: 20)
            }
            
            Group{
                Text("Susquehanna NHA")
                    .font(.custom("Helvetica Neue", size: 20))
                Text("1706 Long Level Road")
                Text("Wrightsville, PA 17512")
                Link("717-252-0229", destination: URL(string: "tel:7172520229")!)
                Spacer()
                    .frame(height: 20)
            }
            
            Group {
                Text("Email us at")
                    .font(.custom("Helvetica Neue", size: 20))
                Link("info@susqnha.org", destination: URL(string: "mailto:info@susqnha.org")!)
                Spacer()
                    .frame(height: 20)
            }
            
            Group {
                // https://stackoverflow.com/questions/59499945/how-to-make-image-clickable-in-swiftui
                Text("Consider Making a Donation")
                    .font(.custom("Helvetica Neue", size: 20))
                //Image("button")
                Link("Donate with PayPal", destination: URL(string: "https://www.paypal.com/donate/?cmd=_s-xclick&hosted_button_id=MEZC4Y4EBNYPA&source=url")!)
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
