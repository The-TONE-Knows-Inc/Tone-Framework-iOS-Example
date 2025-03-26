//
//  PermissionManager.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import CoreLocation
import AVFoundation

// MARK: - PermissionManager
class PermissionManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var shouldShowPermissionAlert = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        checkPermissions()
    }
    
    func checkPermissions() {
        checkLocationPermission()
        checkMicrophonePermission()
    }
    
    private func checkLocationPermission() {
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                shouldShowPermissionAlert = true
            default:
                shouldShowPermissionAlert = false
            }
        } else {
            shouldShowPermissionAlert = CLLocationManager.authorizationStatus() == .denied
        }
    }
    
    func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                self?.shouldShowPermissionAlert = !granted
            }
        case .denied:
            shouldShowPermissionAlert = true
        default:
            shouldShowPermissionAlert = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationPermission()
    }
}
