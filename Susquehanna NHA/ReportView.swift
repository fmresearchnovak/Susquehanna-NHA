//
//  ReportView.swift
//  Susquehanna NHA
//
//  Created by Ed Novak on 1/6/23.
//

// https://thinkdiff.net/how-to-send-email-in-swiftui-5a9047e3442f
// Better Link: https://github.com/egesucu/SendMailApp/tree/main/SendMailApp/Views


import SwiftUI
import Foundation
import MessageUI

struct ReportView: View {
    
    @State private var emailTimeBaby = false
    @State private var alertTime = false
    
    var body: some View {
        
        
        VStack{
            Text("Maintenance Report")
                .bold()
                .font(.custom("Helvetica Neue", size: 20))
                .padding()
            
            Text("Maintenance reports for specific trails can be sent via email to info@susqnha.org  Please include the trail, nearby mile-marker, and a description.  Please also attach a photo of the relevant area.")
                .padding()
            
            // missing the "choose image from camera roll viewˇ
            
            Spacer().frame(height: 100)
            
            Button(action: tryEmail){
                Text("Send Report")
            }
            .padding(5)
            .background(Color.red)
            .foregroundColor(Color.white)
            .cornerRadius(8)
            
        } // https://serialcoder.dev/text-tutorials/swiftui/presenting-sheets-in-swiftui/
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $emailTimeBaby, content: {
            EmailView().onDisappear{
                emailTimeBaby = false
            }
        })
        .alert(isPresented: $alertTime) {
            Alert(
                title: Text("Email Not Setup"),
                message: Text("There does not appear to by any Email account(s) setup on this device.")
            )
        }.onDisappear{
            alertTime = false
        }
    }
    
    func tryEmail(){
        // make this boolean true to activate the sheet
        if(MFMailComposeViewController.canSendMail()){
            emailTimeBaby = true
        } else {
            alertTime = true
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}


struct EmailView : UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context){
    
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        if(MFMailComposeViewController.canSendMail()){
            let view = MFMailComposeViewController()
            view.mailComposeDelegate = context.coordinator
            
            let addr = "info@columbiacrossing.org"
            let subj = "Susquehanna Trail Report"
            let bodyPlacehldr = "Replace this text with a description of the necessary maintenance / problem..."
            
            view.setToRecipients([addr])
            view.setSubject(subj)
            view.setMessageBody(bodyPlacehldr, isHTML: false) // maybe should be true?
            
            return view
            
        } else {
            return MFMailComposeViewController()
        }
    }
    
    func makeCoordinator() -> Coordinator {
         return Coordinator(self)
    }
    
    class Coordinator : NSObject, MFMailComposeViewControllerDelegate {
        
        var parent: EmailView
        
        init(_ parent: EmailView){
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error? ){
            controller.dismiss(animated: true)
        }
    }
    
}
