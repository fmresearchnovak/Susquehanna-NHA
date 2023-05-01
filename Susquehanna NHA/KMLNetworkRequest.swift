//
//  KMLNetworkRequest.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 1/3/23.
//


// https://designcode.io/swiftui-advanced-handbook-http-request

import SwiftUI
import MapKit



class KMLNetworkRequest: ObservableObject {
    
    // The placeholder trail is necessary so that the view can be displayed before
    // the trails are downloaded and parsed
    public static let placeHolderTrail: Trail = Trail(idx: 0, name: "Trail...", placemarks: [])
    @Published var trails: [Trail] = [placeHolderTrail] // this is necessary so the view can
    
    func getTrailPlacemarks() {
        let urlS = "https://www.google.com/maps/d/u/0/kml?mid=1ngdc8io_n7CgzEqB03f6eteAVMz0Z0y8&forcekml=1"
        guard let url = URL(string: urlS) else {fatalError("Invalid URL: " + urlS)}
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let errorInstance = error { // this construct means that error (from the previous line) is not nil
                print("Request Error: ", errorInstance)
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
                    
                    let parser = KMLPlacemarkParser(data: dataInstance)
                    if(parser.parse()){
                        
                        // The KMLPlacementParser parses most all of the trails, but this special
                        // "All Trails" trail (that is all the markers from all trails combined)
                        // must be added to the parserTrails list manually, probably this should / could
                        // be done in the KMLPlacemarkParser class.
                        let all = Trail(idx: 0, name: "All Trails", placemarks: parser.allPlacemarks)
                        parser.parserTrails.insert(all, at: 0)
                        
                        self.trails = [] // get rid of the placeholder trail
                        self.trails = parser.parserTrails
                        print("Parsed KML file successfully.")

                        
                    } else {
                        if let error = parser.parserError {
                            print(error)
                        } else {
                            print("Failed to parse for unknown reason")
                        }
                    }
                }
            }
        }
        
        dataTask.resume()
    }
}

// Parsing XML: https://developer.apple.com/forums/thread/670984

struct Trail: Identifiable {
    let id = UUID()
    
    // If theese are not made optional then they must be passed in the constructor
    // when the object is created.  This is not possible since we create the object
    // when encountering a <Placemark> tag, but we then must continue parsing to
    // discover the values of name, description, etc.
    var idx: Int?
    var name: String?
    var placemarks: [Placemark]?
    
}

struct Placemark: Identifiable {
    let id = UUID()
    
    // If theese are not made optional then they must be passed in the constructor
    // when the object is created.  This is not possible since we create the object
    // when encountering a <Placemark> tag, but we then must continue parsing to
    // discover the values of name, description, etc.
    var name: String?
    var coordinate: CLLocationCoordinate2D?
    
    // some of the Placemarks don't have any description, but many do and they're simplistic HTML content
    var desc: String = ""
}

class KMLPlacemarkParser: XMLParser {
    
    @Published var parserTrails: [Trail] = []
    
    public var allPlacemarks: [Placemark] = []
    private var curPlacemarks: [Placemark] = []
    private var curContext: parsingContext? = nil
    private var curidx: Int = 1
    
    private var nextTrail: Trail? = nil
    private var nextPlacemark: Placemark? = nil
    

    private var textBuffer: String = ""
    
    override init(data: Data) { // maybe should be String?
        super.init(data: data)
        self.delegate = self
    }
}

extension KMLPlacemarkParser: XMLParserDelegate {
    
    enum parsingContext {
      case parsingTrail, parsingPlacemark
    }
    
    // function is called when opening tag '<sometag>' is found
    func parser(_ parser: XMLParser, didStartElement sometag: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]){
        
        
        switch sometag {
        case "Folder":
            curContext = parsingContext.parsingTrail
            nextTrail = Trail()
            
        case "Placemark":
            curContext = parsingContext.parsingPlacemark
            nextPlacemark = Placemark()
            
        case "name":
            textBuffer = ""
            
        case "description":
            textBuffer = ""
            
        case "coordinates":
            textBuffer = ""
            
        default:
            // any and all other tags not specified in the switch cases above fall here and are ignored
            break
        }
        
    }
    
    // function is called when a CLOSING tag '</sometag>' is found
    func parser(_ parser: XMLParser, didEndElement sometag: String, namespaceURI: String?, qualifiedName qName: String?){
        switch sometag {
            
        case "Folder":
            if var trl = nextTrail {
                trl.placemarks = self.curPlacemarks
                self.curPlacemarks.removeAll()
                trl.idx = curidx
                curidx += 1
                //print("parsed trail: ", trl.name!) //, "  idx:", trl.idx!)
                self.parserTrails.append(trl)
            }
            
        case "Placemark":
            if let plcmrk = nextPlacemark{
                //print("made a placemark: ", plcmrk)
                self.allPlacemarks.append(plcmrk)
                self.curPlacemarks.append(plcmrk)
            }
            
        case "name":
            if curContext == parsingContext.parsingTrail {
                nextTrail?.name = textBuffer
            } else if curContext == parsingContext.parsingPlacemark {
                nextPlacemark?.name = textBuffer
            } else {
                if(textBuffer != "Susquehanna NHA Master Trail Map"){
                    print("Failed to parse (closing name tag): '", textBuffer, "'")
                }
                return
            }
            
        case "description":
            nextPlacemark?.desc = textBuffer
            
        case "coordinates":
            //print("textBuffer: ", textBuffer)
            var tmp = textBuffer.trimmingCharacters(in: .newlines)
            tmp = tmp.trimmingCharacters(in: .whitespaces)
            //print("textBuffer: ", textBuffer)
            let numbers: [String.SubSequence] = tmp.split(separator: ",")
            let lon = Double(String(numbers[0]))
            let lat = Double(String(numbers[1]))
            nextPlacemark?.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            
        default:
            // any and all other tags not specified in the switch cases above fall here and are ignored
            break
        }
    }
    
    // funtion is called when any character sequence is found
    // usually called multiple times per element
    func parser(_ parser: XMLParser, foundCharacters str: String){
        textBuffer += str
    }
    
    // called when CDATA block is encountered
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data){
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            print("Ignoring CDATA content which could not be encoded as  UTF8 string: ", CDATABlock[...10])
            return
        }
        textBuffer += string
    }
    
    // useful for debugging somehow?
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error){
        print("Error Parsing XML")
        print("\tError:", parseError)
        print("\ton: ", parser.lineNumber, "   at: ", parser.columnNumber)
    }
}
