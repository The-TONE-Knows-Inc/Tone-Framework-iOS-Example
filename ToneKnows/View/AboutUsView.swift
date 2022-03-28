//
//  AboutUsView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 28/02/22.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        VStack(alignment: .leading) {
                   Text("About us")
                       .font(.largeTitle)
                       .frame(alignment: .center)
                       .padding(12)
                   Text("TONE Technologies, in its simplest form, is an “audio-QR Code” or audio beacon. The patented technology utilizes inaudible sound fragments called “TONE-Tags” to deliver info, ads, coupons, special offers, or other content to any smartphone, enabling companies to activate and monetize audiences ANYWHERE and ANYTIME, all without the expensive hardware of traditional marketing tech.")
                .frame( alignment: .center)
                .padding(12)
               }
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
