//
//  BridgeStatusNetworkRequest.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 12/27/22.
//


// https://designcode.io/swiftui-advanced-handbook-http-request

import SwiftUI

class BridgeStatusNetworkRequest: ObservableObject {
    
    @Published var unLoaded = true
    @Published var isFlooded = false
    @Published var precaution = false
    @Published var waterLevel = 0.0
    @Published var statusText = "Loading Bridge Status..."
    
    func checkWaterLevel() {
        guard let url = URL(string: "https://waterdata.usgs.gov/nwis/uv?01576000") else {fatalError("Invalid URL: https://waterdata.usgs.gov/nwis/uv?01576000")}
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let errorInstance = error { // this construct means that error (from the previous line) is not nil
                print("Request error: ", errorInstance)
                return
            }
            
            guard let responseInstance = response as? HTTPURLResponse else {
                print("Invalid Response: " + String(response.debugDescription))
                return
            }
            
            if responseInstance.statusCode == 200 {
                guard let dataInstance = data else {
                    print("Failed!  Status Code: " + String(responseInstance.statusCode))
                    return
                }
                
                DispatchQueue.main.async {
                    let encodingParam = String.Encoding(rawValue: NSUTF8StringEncoding)
                    guard let htmlString = String(data: dataInstance, encoding: encodingParam) else {
                        print("Error converting html to a string")
                        return
                    }
                    
                    var index = htmlString.startIndex  // start from the beginning of the string
                    while let range = htmlString[index...].range(of: "Most recent instantaneous value: ") {
                        index = range.upperBound // move to the index after the found occurrence
                    }
                    
                    let startIndex = index
                    let stopIndex = htmlString.index(startIndex, offsetBy: 4)

                    guard let relevantPart = Double(htmlString[startIndex...stopIndex]) else {
                        print("Failed to convert to double: ", htmlString[startIndex...stopIndex])
                        return
                    }
                    
                    self.waterLevel = relevantPart
                    //print("water level: ", self.waterLevel)
                    
                    if(40 <= self.waterLevel && self.waterLevel < 42) { //if the water level is between 40 and 42, it asks for precautions
                        self.isFlooded = false;
                        self.precaution = true;
                        self.statusText = "Shock's Mill Bridge is muddy, please take precautions!"
                    }
                    else if(self.waterLevel >= 42){ //if the water level is above 42, it is flooded and makes the precautions false from before
                        self.isFlooded = true;
                        self.precaution = false;
                        self.statusText = "Shock's Mill Bridge is CLOSED!"
                    }
                    else{
                        self.isFlooded = false;
                        self.precaution = false;
                        self.statusText = "Shock's Mill Bridge is OPEN!"
                    }
                    
                    self.unLoaded = false
                }
            }
        }
        
        dataTask.resume()
    }
}
