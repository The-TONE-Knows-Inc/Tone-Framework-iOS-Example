//
//  ToneProtocols.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

// MARK: - LocationManager
protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ Latitude: String, _ Longitude: String)
    func didFailWithError(_ error: String)
}

protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(_ tab: ViewControllers)
}

protocol ClientsViewControllerDelegate: AnyObject {
    func didSelectClientImage(_ imageName: String, _ clientID: String)
}

protocol HeaderViewDelegate: AnyObject {
    func didSelectClient(_ clientName: String)
}

protocol BackButtonDelegate: AnyObject {
    func backButtonAction()
}

protocol NotificationViewModelDelegate: AnyObject {
    func didReceiveNewNotification(_ notification: String)
    func didReceiveOfflineNotification(_ notification: Data)
    func didUpdateClients(_ hasClients: Bool)
    func didUpdateResponseContent(_ content: [String: Any])
    func didUpdateToneSequences(_ toneSequences: [String])
}

protocol ImageLoaderProtocol {
    func getValidURL(from urlString: String) -> URL?
    func fetchImage(url: URL, urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask
    func getImageFromSDWebImage(from url: URL?, completion: ((UIImage?) -> Void)?)
    func convertAVIFToPNGOrJPEG(from data: Data, completion: ((UIImage?) -> Void)?)
    func fetchImageData(url: URL, completion: @escaping (UIImage?) -> Void)
}
