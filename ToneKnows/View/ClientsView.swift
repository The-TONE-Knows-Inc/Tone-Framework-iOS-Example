//
//  ClientsView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 10/02/22.
//

import SwiftUI

struct ClientsView: View {
    @EnvironmentObject var menuData: MenuViewModel

    var filteredClients: [Client] {
        return menuData.clients
    }

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.top)
                HStack {
                    Spacer()
                    Text("Client Names")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .clipShape(Rectangle())
                        .padding()
                    Spacer()
                }
            }
            .frame(height: 30)
            ScrollView {
                ForEach(filteredClients, id: \.clientID) { result in
                    MenuButtons(clientID: result.clientID, name: result.name, image: result.icon, selectedMenu: $menuData.selectedMenu).padding([.leading, .trailing], 20)
                }
            }
        }.preferredColorScheme(.dark)
    }
}
