//
//  ToneValidator.swift
//  ToneKnows
//
//  Created by Anil Kumar on 09/02/24.
//

import SwiftUI
import ToneListen
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: String = "Fetching location..."
    private var locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            currentLocation = "Location access denied. Enable in settings."
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        DispatchQueue.main.async {
            self.currentLocation = "Latitude: \(latitude)\nLongitude: \(longitude)"
        }
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        currentLocation = "Failed to find location: \(error.localizedDescription)"
    }
}

struct ToneValidator: View {
    @StateObject var viewModel = ContentViewModel()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var toneDataViewModel: ToneDataViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.top)
                    HStack {
                        Spacer()
                        Text("Frequencies")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Rectangle())
                            .padding(.top, 30)
                        Spacer()
                    }
                }
                .frame(height: 30)
                ScrollView {
                    if toneDataViewModel.dataResponse.isEmpty {
                        Text("No frequencies added")
                            .foregroundColor(.gray)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(toneDataViewModel.dataResponse, id: \.self) { data in
                            Text(data)
                                .frame(width: geometry.size.width)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }.preferredColorScheme(.dark)
        }
        .onChange(of: viewModel.dataResponse) { newData in
            if !newData.isEmpty {
                toneDataViewModel.dataResponse.append(contentsOf: newData)
                DispatchQueue.main.async {
                    viewModel.dataResponse.removeAll()
                }
            }
        }
    }
}

struct ToneValidator_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
