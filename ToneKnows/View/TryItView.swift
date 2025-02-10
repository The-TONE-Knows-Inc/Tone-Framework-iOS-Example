//
//  TryItView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 28/02/22.
//

import SwiftUI
import Accelerate
import AudioKit
import AVFoundation
import Combine
import CoreLocation
import ToneListen
import FirebaseFirestore

struct TryItView: View {
    @StateObject private var locationViewModel = LocationManager()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var menuData = MenuViewModel()
    var body: some View {
        ZStack {
            VStack {
//                Spacer()
                HeaderView(locationViewModel: locationViewModel)
                ContentViews()
                Spacer()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                permissionManager.checkMicrophonePermission()
            }

            if permissionManager.shouldShowPermissionAlert {
                PermissionAlertView(onOpenSettings: openSettings)
            }
        }
        .environmentObject(menuData)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

class ToneDataViewModel: ObservableObject {
    @Published var dataResponse: [String] = []
}

struct MainTabView: View {
    @State var showingDetail = false
    @State var showingDetailForOffline = false
    @ObservedObject var model = ContentViewModel()
    @State private var refreshView = false
    @StateObject private var audioProcessor = AudioProcessor()
    @State private var isToneFrameworkRunning = false
    @State private var imageURL = ""
    @State private var imageData = Data()
    let toneFramework = ToneFramework.shared
    @StateObject var toneDataViewModel = ToneDataViewModel()
    
    var body: some View {
        TabView {
            ClientsView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Clients")
                }.onAppear{
                    print("<<<<toneFramework.stop()>>>>")
                    toneFramework.perform(action: .stop)
                    isToneFrameworkRunning = false
                }
            DemoView()
                .tabItem {
                    Image(systemName: "list.dash.header.rectangle")
                    Text("Try it")
                }.onAppear{
                    if !isToneFrameworkRunning {
                        print("<<<<toneFramework.start()>>>>")
                        isToneFrameworkRunning = true
                        toneFramework.perform(action: .start)
                        toneFramework.setFeature(.bluetoothDetection(true))
                        toneFramework.setFeature(.carrierDetection(true))
                        toneFramework.setFeature(.wifiDetection(true))
                        getClientId() { result in
                            if result {
                                toneFramework.setFeature(.offlineMode(isClientId: UserDefaults.standard.string(forKey: "clientID") ?? "", result))
                            } else {
                                toneFramework.perform(action: .deleteOfflineData)
                            }
                        }
                    }
                }
            ToneValidator()
                .tabItem {
                    Image(systemName: "music.quarternote.3")
                    Text("Frequency")
                }
                .environmentObject(toneDataViewModel)
        }.sheet(isPresented: $showingDetail){
            SheetDetailView(showingDetail: $showingDetail, url: imageURL)
        }
        .sheet(isPresented: $showingDetailForOffline) {
            SheetDetailDataView(showingDetail: $showingDetailForOffline, imageData: $imageData)
        }
        .onAppear {
            toneFramework.setClientId(clientID: UserDefaults.standard.string(forKey: "clientID") ?? "")
        }.onDisappear {
            if isToneFrameworkRunning {
                print("<<<<toneFramework.stop()>>>>")
                toneFramework.perform(action: .stop)
                isToneFrameworkRunning = false
            }
        }.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("get_clients")), perform: { _ in
            toneFramework.setClientId(clientID: UserDefaults.standard.string(forKey: "clientID") ?? "")
        })
        .onReceive(NotificationCenter.default.publisher(for: model.notificationName)) { notification in
            showingDetailForOffline = false
            imageURL = (notification.object ?? "") as? String ?? ""
            if let userInfo = notification.userInfo, let tone = userInfo["tone"] as? String {
                print("Received tone: \(tone)")
            }
            if showingDetail {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showingDetail = true
                }
                showingDetail.toggle()
            }else{
                showingDetail.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: model.notificationImageData)) { notification in
            showingDetail = false
            if let imageData = notification.object as? Data {
                self.imageData = imageData
            } else {
                print(" NO DATA AVAILABLE :: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< $$$$$$")
            }
            if let userInfo = notification.userInfo, let tone = userInfo["tone"] as? String {
                print("Received tone: \(tone)")
            }
            if showingDetailForOffline {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showingDetailForOffline = true
                }
                showingDetailForOffline.toggle()
            } else {
                showingDetailForOffline.toggle()
            }
        }
        .onChange(of: audioProcessor.routeChanged, perform: { _ in
            refreshView.toggle()
        })
    }
    
    private func getClientId(completion: @escaping (Bool) -> Void) {
        let databaseAuth = Firestore.firestore()
        var result: Bool = false
        let documentReference = databaseAuth.collection("onlineClients").document("Z0bSkI7ywrXgSRJW5TrN")
        
        documentReference.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                DispatchQueue.main.async {
                    print("Client:::::::\(dataDescription?["client"] as? String ?? "")")
                    let dataDes = dataDescription?["client"] as? String ?? ""
                    let dataClient = dataDes.data(using: .utf8) ?? Data()
                    let dataJson = try? JSONSerialization.jsonObject(with: dataClient, options: []) as? [String: Any]
                    
                    if let onlineClientId = dataJson?["onlineClientId"] as? [String] {
                        // Store it in a variable
                        let onlineClientIds: [String] = onlineClientId
                        print("The overall Client ids are ------------------------------->", onlineClientIds)
                        
                        let enteredClientId = UserDefaults.standard.string(forKey: "clientID") ?? ""
                        result = onlineClientIds.contains(enteredClientId)
                        print("The result for client id is ----------------------------------------------->", result)
                    }
                    
                    // Return the result via the completion handler
                    completion(result)
                }
            } else {
                print("Document does not exist")
                completion(false)
            }
        }
    }
}
struct ContentViews: View {
    @StateObject private var audioProcessor = AudioProcessor()
    @StateObject private var featureFlagManager = FeatureFlagManager()
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    VStack {
                        Text("Frequency: \(audioProcessor.maxFrequency, specifier: "%.2f") Hz")
                            .foregroundColor(.white)
                        Spacer()
                        SpectrumView(magnitudes: audioProcessor.frequencyMagnitudes)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.9, alignment: .center)
                    }
                    .background(Color.clear)
                    if  featureFlagManager.featureEnabled {
                        NavigationLink(destination: MainTabView()) {
                            Image(systemName: "gear")
                                .font(.title)
                                .foregroundColor(.black)
                                .background(Circle()
                                                .fill(Color.cyan)
                                                .frame(width: 44, height: 44))
                        }
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
}


struct SpectrumView: View {
    var magnitudes: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 0.0000001) {
                    ForEach(magnitudes.indices, id: \.self) { index in
                        Rectangle()
                            .fill(Color.cyan)
                            .frame(width: max((geometry.size.width - CGFloat(magnitudes.count * 2)) / CGFloat(magnitudes.count), 1),
                                   height: min(CGFloat(magnitudes[index]) * 10, geometry.size.height))
                    }
                }
                .frame(width: 2000, height: geometry.size.height, alignment: .bottom)
                .clipped()
            }
        }
        .background(
            Image("BackgroundGraph")
                .resizable()
                .scaledToFill()
        )
        .background(Color(.clear))
    }
}

class FeatureFlagManager: ObservableObject {
    @Published var featureEnabled: Bool = false

    private var db = Firestore.firestore()

    init() {
        fetchFeatureFlag()
    }

    func fetchFeatureFlag() {
        let docRef = db.collection("settings").document("2mFXFqDjUCBlJnaTDP8z")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                DispatchQueue.main.async {
                    self.featureEnabled = dataDescription?["featureEnabled"] as? Bool ?? false
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

class AudioProcessor: NSObject, ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var fftSetup: FFTSetup?
    private let fftSize = vDSP_Length(4096)
    @Published var maxFrequency: Float = 0.0
    @Published var frequencyMagnitudes: [Float] = []
    @Published var permissionMessage: String?
    @Published var routeChanged = false
    
    private var debounceTimer: AnyCancellable?
    
    override init() {
        super.init()
        setupNotifications()
        setupAudio()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }

    private func setupAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetooth, .duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }

        guard audioSession.isInputAvailable else {
            print("Audio input not available.")
            return
        }

        configureAudioEngine()
    }

    private func configureAudioEngine() {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        if inputFormat.sampleRate == 0 || inputFormat.channelCount == 0 {
            print("Invalid or unsupported audio format.")
            return
        }

        fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Double(fftSize))), FFTRadix(kFFTRadix2))

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(fftSize), format: inputFormat) { [weak self] (buffer, _) in
            self?.processAudio(buffer: buffer, frameCount: buffer.frameLength, inputFormat: inputFormat)
        }

        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error)")
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioSessionInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            pauseAudioProcessing()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        configureAudioEngine()
                    } catch {
                        print("Failed to reactivate audio session: \(error)")
                    }
                }
            }
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        if reason == .newDeviceAvailable || reason == .oldDeviceUnavailable {
            print("Route change detected: reconfiguring audio session\n\t\tReason: \(reason)")
            debounceTimer?.cancel() // Cancel any previous debounce timer
            debounceTimer = Just(()).delay(for: .seconds(0.5), scheduler: RunLoop.main).sink { [weak self] _ in
                guard let self = self else { return }
                self.reconfigureAudioSession()
            }
        }
    }
    
    private func reconfigureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            configureAudioEngine()
            routeChanged = true
        } catch {
            print("Failed to reactivate audio session: \(error)")
        }
    }
    
    func pauseAudioProcessing() {
        audioEngine.stop()
        audioEngine.reset()
    }

    func processAudio(buffer: AVAudioPCMBuffer, frameCount: AVAudioFrameCount, inputFormat: AVAudioFormat) {
        var realp = [Float](repeating: 0, count: Int(frameCount / 2))
        var imagp = [Float](repeating: 0, count: Int(frameCount / 2))
        var splitComplex = DSPSplitComplex(realp: &realp, imagp: &imagp)

        let floatChannelData = buffer.floatChannelData![0]
        floatChannelData.withMemoryRebound(to: DSPComplex.self, capacity: Int(frameCount / 2)) { complexData in
            vDSP_ctoz(complexData, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
        }

        vDSP_fft_zrip(self.fftSetup!, &splitComplex, 1, vDSP_Length(log2(Float(frameCount))), FFTDirection(FFT_FORWARD))
        vDSP_zvmags(&splitComplex, 1, &realp, 1, vDSP_Length(frameCount / 2))

        let magnitudes = realp.map { sqrt($0) }
        var maxMagnitude: Float = 0
        var maxIndex: vDSP_Length = 0
        vDSP_maxvi(magnitudes, 1, &maxMagnitude, &maxIndex, vDSP_Length(frameCount / 2))

        let frequencyPerBin = inputFormat.sampleRate / Double(fftSize)
        let maxFrequency = Float(maxIndex) * Float(frequencyPerBin)

        DispatchQueue.main.async {
            self.maxFrequency = maxFrequency
            self.frequencyMagnitudes = magnitudes
        }
    }
}

struct HeaderView: View {
    @ObservedObject var locationViewModel: LocationManager

    var body: some View {
        Text(locationViewModel.currentLocation)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.black)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
    }
}

class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var shouldShowPermissionAlert = false

    private let locationManager = CLLocationManager()

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
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.shouldShowPermissionAlert = false
            }
        case .authorizedAlways, .authorizedWhenInUse:
            DispatchQueue.main.async {
                self.updateAlertVisibility()
            }
        @unknown default:
            break
        }
    }
    
    func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.updateAlertVisibility()
                }
            }
        case .denied:
            DispatchQueue.main.async {
                self.shouldShowPermissionAlert = true
            }
        case .granted:
            DispatchQueue.main.async {
                print("PROVIDED ACCESS::::::::")
                self.updateAlertVisibility()
            }
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateAlertVisibility()
    }

    private func updateAlertVisibility() {
        shouldShowPermissionAlert = AVAudioSession.sharedInstance().recordPermission == .denied
    }
}

struct PermissionAlertView: View {
    var onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("AUDIO FEED BLOCKED")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("TONE Telegenics is not receiving audio from the microphone. This may be caused by other apps using the microphone. Please exit any others app that are using the microphone and restart TONE Telegenics.")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button("Open Settings", action: onOpenSettings)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(8)
        }
        .padding()
        .frame(width: 300, height: 350)
        .background(Color.black)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan, lineWidth: 1)
        )
    }
}

struct TryItView_Previews: PreviewProvider {
    static var previews: some View {
        TryItView()
    }
}
