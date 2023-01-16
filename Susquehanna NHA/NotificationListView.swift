//
//  NotificationListView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 12/27/22.
//

// https://stackoverflow.com/questions/56645647/how-to-have-a-dynamic-list-of-views-using-swiftui

// Notifications tutorial: https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications

import SwiftUI
//import UserNotifications

struct NotificationListView: View {
    @EnvironmentObject var notiNetReq: NotificationNetworkRequest
    @State var recentNotisFromServer: [NotificationNetworkRequest.SNHANotification]?
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permissions acquired.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack (spacing: 2) {
            
            Text("Recent Notifications")
                .bold()
                .font(.custom("Helvetica Neue", size: 20))
                .padding()
            

            List {
                ForEach(notiNetReq.notis, id: \.id) { cur in
                    VStack{
                        
                        Text(cur.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 18))
                        Text("Notification #:" + String(cur.id))
                            .italic()
                            .font(.system(size: 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(cur.created_on)
                            .italic()
                            .font(.system(size: 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer(minLength: 2)
                        Text(cur.description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.padding(.bottom)

                }
            }
            
        }.frame(maxHeight: .infinity,
            alignment: .top)
        .onAppear{
            notiNetReq.getRecentNotifications()
        }
    }
    
    func buildView(types: [NotificationNetworkRequest.SNHANotification], index: Int) -> some View {
        let cur = types[index]
        let v = VStack{
            Text("Notification #:" + String(cur.id))
            Text(cur.title)
                .italic()
                .font(.system(size: 2))
            Text(cur.created_on)
            Text(cur.description)

        }
        print("created view to display: ", cur.id)
        return v
    }
}

struct NotificationsListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
            .environmentObject(NotificationNetworkRequest())
    }
}


