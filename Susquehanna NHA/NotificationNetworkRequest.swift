//
//  KMLNetworkRequest.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 1/3/23.
//


// network: https://designcode.io/swiftui-advanced-handbook-http-request
// json parsing: https://developer.apple.com/documentation/foundation/jsondecoder
// UserDefaults: https://developer.apple.com/documentation/foundation/userdefaults
// UserDeftauls: https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swiftui/
//
// Notifications: https://developer.apple.com/documentation/usernotifications
// Notifications: https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications <-- best one!
// Notifications: https://stackoverflow.com/questions/74567769/implement-swiftui-notifications

import SwiftUI

class NotificationNetworkRequest: ObservableObject {
    
    @Published var notis: [SNHANotification] = []
    //@Published var newNotis: [SNHANotification] = []
    
    func getRecentNotifications() {
        let urlStr = "https://www.ednovak.net/snha/notifications/recent"
        guard let url = URL(string: urlStr) else {fatalError("Invalid URL: " + urlStr)}
        
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
                    
                    // Maybe don't do this
                    //let encodingParam = String.Encoding(rawValue: NSUTF8StringEncoding)
                    //guard let jsonString = String(data: dataInstance, encoding: encodingParam) else {
                    //    print("Error converting html to a string")
                    //    return
                    //}
                    //print(jsonString)
                    // Maybe don't do this
                    
                    let decoder = JSONDecoder()
                    
                    do{
                        
                        // 1 get notifications from server
                        let notis:[SNHANotification] = try decoder.decode([SNHANotification].self, from: dataInstance)
                        //print(notis)
                        
                        // 2 sort them
                        self.notis = notis.sorted(by: { $0.created_on_ts > $1.created_on_ts })
                        
                        // 3 identify the new ones
                        let newNotis = self.identifyNewNotifications()
                        
                        // 4 display notifications to user
                        // actually make the notifications for display to the user
                        self.displayNotificationsToUser(SNHAnotifications: newNotis)
                        
                        
                        // 5 store the notifications
                        self.storeNotifications(SNHAnotifications: newNotis)
                        
                        print("Notifications successfully acquired from server.")
                        
                    } catch {
                        print(error)
                    }
                    
                }
            }
        }
        
        dataTask.resume()
    }
    
    func identifyNewNotifications() -> [SNHANotification] {
        // https://developer.apple.com/documentation/foundation/userdefaults
        // https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swiftui/
        var results: [SNHANotification] = []
        for i in 0..<self.notis.count {
            let cur = self.notis[i]
            let isAlreadyStored = UserDefaults.standard.bool(forKey: String(cur.id))
            if(!isAlreadyStored){
                results.append(cur)
            }
        }
        return results
    }
    
    func storeNotifications(SNHAnotifications: [SNHANotification]){
        // https://developer.apple.com/documentation/foundation/userdefaults
        // https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swiftui/
        for i in 0..<SNHAnotifications.count {
            UserDefaults.standard.setValue(true, forKey: String(SNHAnotifications[i].id))
        }
    }
    
    func displayNotificationsToUser(SNHAnotifications: [SNHANotification]){
        // https://stackoverflow.com/questions/74567769/implement-swiftui-notifications
        for i in 0..<SNHAnotifications.count {
            let curSNHANotification = SNHAnotifications[i]
            let content = UNMutableNotificationContent()
            //print("building notification: ", curSNHANotification.title)
            content.title = "Susquehanna Nat. Heritage Area Alert"
            content.subtitle = curSNHANotification.title
            content.body = curSNHANotification.description
            content.sound = UNNotificationSound.default

            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
        }
    }
        
        
    struct SNHANotification: Codable {
        let id: Int
        var title: String
        var description: String
        var created_on_ts: UInt
        var created_on: String
        var debug_flag: Bool
    }
}



