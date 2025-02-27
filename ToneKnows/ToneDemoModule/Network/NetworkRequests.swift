//
//  NetworkRequests.swift
//  ToneKnows
//
//  Created by Balan iOS on 26/02/25.
//

import Foundation

class NetworkRequests {
    
    static func fetchClientData(completion: @escaping (Result<[Client], Error>) -> Void) {
        
        let urlString = "https://dev-dashboard-api.tonetrackr.com/companies/get/offline"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "GET"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("WaOIgO4Ccea1wk55mDZVVRBdmyh2HweXGHdOlrx2OYseIdwFcDLHmRcZiPAWegjvuytuytuy", forHTTPHeaderField: "x-api-key")
        
        print("Sending GET request to: \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                print("Invalid response received")
                completion(.failure(NSError(domain: "HTTP Error", code: statusCode, userInfo: nil)))
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("No data received from server")
                completion(.failure(NSError(domain: "No Data", code: 204, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ToneClientsResponse.self, from: data)
                print("Successfully fetched tone data")
                completion(.success(decodedResponse.data))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
