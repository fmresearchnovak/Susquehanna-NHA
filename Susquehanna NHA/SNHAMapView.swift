//
//  SNHAMapView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 1/3/23.
//

// about generic MapKit: https://kristaps.me/blog/swiftui-mapview/
// about KML: https://stackoverflow.com/questions/35634252/work-with-kml-files-swift-application
// about displaying markers on the map: https://www.appcoda.com/swiftui-map/
// clickable / customizable markers on map: https://stackoverflow.com/questions/63211092/how-do-i-make-a-clickable-pin-in-swiftuis-new-map-view

import SwiftUI
import MapKit

struct SNHAMapView: View {
    @EnvironmentObject var kmlNetReq: KMLNetworkRequest
    
    @State private var curPlacemark: Placemark? // sheet, used when user taps on item
    @State private var curTrailPlacemarks: [Placemark] = [] //MapAnnotation, used when user selects a trail
    @State private var curPickerItemIDX: Int = 0 // picker, used when user picks a different trail
    

    // 40.03056412621596, -76.50826355534342
    @State var coordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.03056412621596, longitude: -76.50826355534342),
        span: MKCoordinateSpan(latitudeDelta: 0.33, longitudeDelta: 0.33))
    
    
    var body: some View {
        
        VStack{

            
            HStack{
                
                Text("Select a Trail: ")
                
                Picker("Trail...", selection: $curPickerItemIDX, content: {
                    ForEach(kmlNetReq.trails) { trl in
                        Text(trl.name!).tag(trl.idx!)
                    }
                })
                .pickerStyle(MenuPickerStyle()) // note, menustyle overrides .font() and some other visual adjustments
                
            }

            
            //Text("Selection: \(curPickerItemIDX)")
            
            
            ZStack {
                
                Button(action: goToGMaps){
                    Text("Go To Google Maps")
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .zIndex(1)
                .offset(x: -20, y: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                // for some reason you have to specify the maxWidth and maxHeight for this to work.
                // https://stackoverflow.com/questions/65135725/how-to-position-my-button-to-the-bottom-of-the-screen-swiftui
                
                
                Map(coordinateRegion: $coordinateRegion, annotationItems: kmlNetReq.trails[curPickerItemIDX].placemarks!) { plcmrk in MapAnnotation(coordinate: plcmrk.coordinate!){
                        VStack{
                            Image(systemName: "mappin.circle.fill").foregroundColor(.red)
                        }.onTapGesture {
                            print(plcmrk.name!, "  ID:", plcmrk.id)
                            curPlacemark = plcmrk
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .onAppear{
                    kmlNetReq.getTrailPlacemarks()
                }
            }.sheet(item: $curPlacemark) {
                plcmrk in PlacemarkDetailView(plcmrk)
            }
        }
    }
    
    func goToGMaps(){
        // https://stackoverflow.com/questions/58643888/swiftui-how-do-i-make-a-button-open-a-url-in-safari
        //print("clicked da button")
        if let url = URL(string: "https://www.google.com/maps/d/u/0/viewer?mid=1ngdc8io_n7CgzEqB03f6eteAVMz0Z0y8&amp;ll=40.076818468575105%2C-76.56685315760316&amp;z=12"){
            UIApplication.shared.open(url)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        SNHAMapView()
            .environmentObject(KMLNetworkRequest())
    }
}
