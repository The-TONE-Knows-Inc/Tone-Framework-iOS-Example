//
//  Home.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import SwiftUI

struct Home: View {
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    @StateObject var menuData = MenuViewModel()
    @State var showingDetail = false
    @ObservedObject var model = ContentViewModel()
    @Namespace var animation
    
    var body: some View {
        HStack(spacing:0){
            Drower(animation: animation)
            TabView(selection: $menuData.selectedMenu){
                GeometryReader{ geo in
                    ZStack {
                        Image("ExampleDashboard")
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    }.sheet(isPresented: $showingDetail){
                        SheetDetailView(showingDetail: $showingDetail, url: model.newNotification ?? "")
                    }
                    .onReceive(NotificationCenter.default.publisher(for: model.notificationName), perform: { _ in
                        showingDetail.toggle()
                    })
                }                               
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(x: menuData.showDrawer ? 125: -125) 
        .overlay(
            ZStack {
                if !menuData.showDrawer {
                    DrowerCloseButton(animation: animation)
                        .padding()
                }
            },
            alignment: .topLeading
        )
        .environmentObject(menuData)
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
