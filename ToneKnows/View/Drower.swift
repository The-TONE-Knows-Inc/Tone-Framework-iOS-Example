//
//  Drower.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import SwiftUI

struct Drower: View {
    @EnvironmentObject var menuData: MenuViewModel
    var animation: Namespace.ID
    var body: some View {
        VStack {
            HStack {
                Image("KrakenApp")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                Spacer()
                if menuData.showDrawer {
                    DrowerCloseButton(animation: animation)
                }
                
            }
            .padding()
            VStack(alignment: .leading, spacing: 10, content: {
                Text("Tone Knows.")
                    .font(.title2)
                
                Text("Select demo:")
                    .font(.title)
                    .fontWeight(.heavy)
            })
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 5)
            VStack(spacing:18) {
                ForEach(menuData.clients, id: \.clientID) { result in
                    MenuButtons(clientID: result.clientID, name: result.name, image: result.icon, selectedMenu: $menuData.selectedMenu)
                }
            }
            .padding(.leading)
            .frame(width: 250, alignment: .leading)
            .padding(.top, 30)
            
            Divider()
                .background(Color.white)
                .padding(.top,30)
                .padding(.horizontal, 25)
            
            Spacer()
            
            
        }
        .frame(width: 250)
        .background(Color("DrowerColor")
                        .ignoresSafeArea(.all, edges: .vertical))
        
    }
}

struct Drower_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
       // Home()
    }
}

struct DrowerCloseButton: View {
    @EnvironmentObject var menuData: MenuViewModel
    var animation: Namespace.ID
    var body: some View {
        Button(action:{
            withAnimation(.easeInOut){
                menuData.showDrawer.toggle()
                
            }
        },label:{
            VStack(spacing: 5){
                Capsule()
                    .fill(menuData.showDrawer ? .white : Color.primary)
                   .frame(width: 35, height: 3)
                   .rotationEffect(.init(degrees: menuData.showDrawer ? -50 : 0))
                   .offset(x: menuData.showDrawer ? 2 : 0, y: menuData.showDrawer ? 9 : 0)
                VStack(spacing: 5) {
                    Capsule()
                        .fill(menuData.showDrawer ? .white : Color.primary)
                       .frame(width: 35, height: 3)
                    Capsule()
                        .fill(menuData.showDrawer ? .white : Color.primary)
                       .frame(width: 35, height: 3)
                       .offset(y: menuData.showDrawer ? -8 : 0)
                }
                .rotationEffect(.init(degrees: menuData.showDrawer ? 50 : 0))
            }
             
        })
            
        
        .matchedGeometryEffect(id: "MENU_BUTTON", in: animation)
    }
}
