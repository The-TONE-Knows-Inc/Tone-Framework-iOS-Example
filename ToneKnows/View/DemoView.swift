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
  //  @State var showingDetail = false
  //  @ObservedObject var model = ContentViewModel()
 
    var body: some View {
        
        VStack {
            GeometryReader{ geo in
                
                ZStack {
                    if  menuData.clients.count > 0 {
                        ImageViewController(imageUrl: menuData.clients.filter({ client in
                            return client.name == menuData.selectedMenu
                        }).first?.image ?? "")
                    }
                }
            }
        }.tabItem {
            Image(systemName: "circle.grid.3x3.circle.fill")
            Text("Dashboard")
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


