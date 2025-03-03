//
//  MenuViewModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import ToneListen
import Alamofire
import AlamofireImage
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ClientEntityModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error)")
            }
        }
    }
}

class MenuViewModel {
    
    var clients: [Client] = []
    static let shared = MenuViewModel()
    
    private var imageLoader: ImageLoaderProtocol {
        return ImageLoader()
    }
    
    func fetchClients(completion: @escaping () -> Void) {
        NetworkRequests.fetchClientData { result in
            switch result {
                case .success(let clients):
                    DispatchQueue.main.async {
                        self.clients = clients.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
                        self.setSelectedClientDefaults()
                        completion()
                    }
                    
                    self.downloadAllImages(clients: clients) { updatedClients in
                        DispatchQueue.main.async {
                            self.saveClientsToCoreData(clients: updatedClients)
                        }
                    }
                    
                case .failure(let error):
                    print("API Fetch Failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.loadClientsFromLocalDB()
                        completion()
                    }
            }
        }
    }
    
    func downloadAllImages(clients: [Client], completion: @escaping ([Client]) -> Void) {
        var updatedClients: [Client] = []
        let dispatchGroup = DispatchGroup()
        
        for client in clients {
            var modifiedClient = client
            
            dispatchGroup.enter()
            downloadImage(url: .azureImageURL(basePath: .LOGO, fileName: client.logo ?? "")) { localPath in
                modifiedClient.logoData = localPath
                print("Logo Data Path >> \(localPath)")
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            downloadImage(url: .azureImageURL(basePath: .CLIENTS, fileName: client.background ?? "")) { localPath in
                modifiedClient.demoImage = localPath
                print("Demo Image Path >> \(localPath)")
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                updatedClients.append(modifiedClient)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished downloading images. Updated clients count: \(updatedClients.count)")
            completion(updatedClients)
        }
    }
    
    func downloadImage(url: String, completion: @escaping (String) -> Void) {
        guard let validURL = imageLoader.getValidURL(from: url) else {
            completion("")
            return
        }
        
        imageLoader.fetchImageData(url: validURL) { data in
            if let data = data {
                if let localPath = self.saveImageToFileManager(image: data, imageName: validURL.lastPathComponent) {
                    completion(localPath)
                } else {
                    print("Failed to save image: \(validURL.lastPathComponent)")
                    completion("")
                }
            } else {
                print("Image download failed for URL: \(url)")
                completion("")
            }
        }
    }
    
    func saveImageToFileManager(image: UIImage, imageName: String) -> String? {
        let fileManager = FileManager.default
        guard let imageData = image.pngData() else { return nil }
        
        if let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let directory = cachesDirectory.appendingPathComponent("ClientImages")
            
            if !fileManager.fileExists(atPath: directory.path) {
                try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            let filePath = directory.appendingPathComponent(imageName)
            
            do {
                try imageData.write(to: filePath)
                return filePath.path
            } catch {
                debugPrint("Error saving image to disk: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    func saveClientsToCoreData(clients: [Client]) {
        let context = CoreDataStack.shared.context
        
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ClientEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            
            for client in clients {
                let entity = ClientEntity(context: context)
                entity.clientID = client.clientId ?? ""
                entity.icon = client.logo
                entity.image = client.background
                entity.name = client.name ?? ""
                entity.isActive = client.status ?? false
                entity.logoData = client.logoData
                entity.demoImage = client.demoImage
            }
            
            try context.save()
            print("Core Data Save Successful")
            loadClientsFromLocalDB()
        } catch {
            print("Core Data Save Error: \(error)")
        }
    }
    
    func loadClientsFromLocalDB() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let savedClients = try context.fetch(fetchRequest)
            
            self.clients = savedClients.map { clientEntity in
                Client(
                    name: clientEntity.name,
                    logo: clientEntity.icon,
                    background: clientEntity.image,
                    clientId: clientEntity.clientID,
                    logoData: clientEntity.logoData,
                    demoImage: clientEntity.demoImage
                )
            }
        } catch {
            print("Core Data Fetch Error: \(error)")
        }
    }
    
    func loadLocalImagePath(clientID: String) -> String? {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "clientID == %@", clientID)
        
        do {
            let clients = try context.fetch(fetchRequest)
            return clients.first?.demoImage
        } catch {
            print("Failed to fetch local image path: \(error)")
            return nil
        }
    }
    
    private func setSelectedClientDefaults() {
        guard let firstClient = clients.first?.clientId else { return }
        
        let storedClientID = UserDefaults.isSelectedClientID
        
        if storedClientID == nil || storedClientID == "" || !clients.contains(where: { $0.clientId == storedClientID }) {
            UserDefaults.isSelectedClientID = firstClient
            UserDefaults.isSelectedImageURL = clients.first?.background
            UserDefaults.isHeaderTitle = clients.first?.name
        } else {
            UserDefaults.isSelectedImageURL = clients.first(where: { $0.clientId == storedClientID })?.background ?? ""
            UserDefaults.isHeaderTitle = clients.first(where: { $0.clientId == storedClientID })?.name ?? "Tone Demo"
        }
    }
}
