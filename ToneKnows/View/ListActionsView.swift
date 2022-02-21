//
//  ListActionsView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 17/02/22.
//

import SwiftUI

struct ListActionsView: View {
    @ObservedObject var model = ContentViewModel()
    @State var showingDetail = false
    var body: some View {
        VStack(spacing:3) {
            List(model.tones) { tone in
                Button {
                    handleContent(actionType: tone.actionType, actionUrl: tone.actionURL)                    
                } label: {
                    VStack(alignment: .leading) {
                        Text(tone.actionDesc)
                            .bold()
                        Text("Type: \(tone.actionType)")
                        Text(tone.actionURL)
                            .font(.subheadline)
                    }
                }.sheet(isPresented: $showingDetail){
                    SheetDetailView(showingDetail: $showingDetail, url: tone.actionURL )
                }
            }
        }.preferredColorScheme(.dark)
        
        .onReceive(NotificationCenter.default.publisher(for: model.responseObjectNotificationName), perform: { _ in
            print("ListActionsView")
            print(model.responseContent)
            guard let data = model.responseContent else {return}
            model.saveResponse(content: data)
            
            
        })
        .tabItem {
            Image(systemName: "message")
            Text("Inbox")
        }
    }
    
    func handleContent(actionType:String, actionUrl: String){
        if(actionType.contains("image")){
            showingDetail.toggle()            
        }
        if(actionType.contains("url")){
            if(actionUrl.starts(with: "sms:")){
                if let url = URL(string: "sms://" + String(actionUrl.dropFirst(5))) {
                    print("sms")
                    UIApplication.shared.open(url)
                }else{
                    print("forbidden")
                }
            }else {
                if let url = URL(string: "tel://" + String(actionUrl.dropFirst(4))) {
                    print("Call")
                    UIApplication.shared.open(url)
                }
            }
            
        }
        if(actionType.contains("webpage")){
            if let url = URL(string: actionUrl) {
                UIApplication.shared.open(url)
            }
        }
        if(actionType.contains("email")){
            if let url = URL(string: actionUrl) {
                UIApplication.shared.open(url)
            }
        }
        if(actionType.contains("sms")){
            if let url = URL(string: actionUrl) {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct ListActionsView_Previews: PreviewProvider {
    static var previews: some View {
        ListActionsView()
    }
}

