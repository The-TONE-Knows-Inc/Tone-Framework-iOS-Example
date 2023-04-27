//
//  ClientsView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 10/02/22.
//

import SwiftUI

struct ClientsView: View {
    @EnvironmentObject var menuData: MenuViewModel
    var body: some View {
        ScrollView {
            VStack(spacing:18) {
                ForEach(menuData.clients, id: \.clientID) { result in
                    MenuButtons(clientID: result.clientID, name: result.name, image: result.icon, selectedMenu: $menuData.selectedMenu).padding([.leading, .trailing], 20)
                }
            }.preferredColorScheme(.dark)
        }
    
        .tabItem {
            Image(systemName: "list.dash.header.rectangle")
            Text("Try it")
        }
    }
}

struct ClientsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientsView()
    }
}
