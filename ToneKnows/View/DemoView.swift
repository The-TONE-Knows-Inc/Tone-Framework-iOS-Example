//
//  DemoView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 10/02/22.
//

import SwiftUI
import ToneListen

struct DemoView: View {
    @EnvironmentObject var menuData: MenuViewModel
    @State var showingDetail = false
    @ObservedObject var model = ContentViewModel()
    
    var body: some View {
        VStack {
                GeometryReader{ geo in
                    
                    ZStack {
                        if  menuData.clients.count > 0 {
                            ImageViewController(imageUrl: menuData.clients.filter({ client in
                                return client.name == menuData.selectedMenu
                            }).first?.image ?? "")
//                            AsyncImages(
//                                url: URL(string: menuData.clients.filter({ client in
//                                    return client.name == menuData.selectedMenu
//                                }).first?.image ?? "")!,
//                                        placeholder: Text("")
//                            )
                        }
                    }
                    .sheet(isPresented: $showingDetail){
                        SheetDetailView(showingDetail: $showingDetail, url: model.newNotification ?? "")
                    }.onReceive(NotificationCenter.default.publisher(for: model.notificationName), perform: { _ in
                        showingDetail.toggle()
                    })
                }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("get_clients")), perform: { _ in
                print(UserDefaults.standard.string(forKey: "clientID") ?? "0" )
                let toneFramework = ToneFramework(clientID: UserDefaults.standard.string(forKey: "clientID") ?? "0" )
                    toneFramework.stop()
                    toneFramework.start()
                })
        }.tabItem {
            Image(systemName: "house.fill")
            Text("Home")
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

