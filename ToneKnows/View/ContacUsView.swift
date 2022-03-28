//
//  ContacUsView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 28/02/22.
//

import SwiftUI

struct ContacUsView: View {
    var body: some View {
        VStack(alignment: .leading) {
                    Text("Contact us")
                       .font(.largeTitle)
                       .frame(alignment: .center)
                       .padding(12)
                    Text("Sales@thetoneknows.com")
                    .frame( alignment: .center)
                    .padding(12)
                    Text("Info@thetoneknows.com")
                     .frame( alignment: .center)
                     .padding(12)
                    Text("Tel: 702-805-5600")
                     .frame( alignment: .center)
                     .padding(12)
       }
    }
}

struct ContacUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContacUsView()
    }
}
