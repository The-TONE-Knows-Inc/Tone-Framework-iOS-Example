//
//  TryItView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 28/02/22.
//

import SwiftUI

struct TryItView: View {
    @StateObject var menuData = MenuViewModel()

    @Namespace var animation
    var body: some View {
        
                  TabView {
                      DemoView()
                          .tabItem {
                              Image(systemName: "house")
                              Text("Dashboard")
                          }
                      
                      ClientsView()
                          .tabItem {
                              Image(systemName: "person.crop.circle")
                              Text("Clients")
                          }
                      
                      ListActionsView()
                          .tabItem {
                              Image(systemName: "message")
                              Text("Inbox")
                          }
                          
                      }
                  .tabViewStyle(PageTabViewStyle())
             // .frame(width: UIScreen.main.bounds.width)
              .environmentObject(menuData)    }
}

struct TryItView_Previews: PreviewProvider {
    static var previews: some View {
        TryItView()
    }
}
