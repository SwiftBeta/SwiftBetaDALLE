//
//  ViewModel.swift
//  SwiftBetaDALLE
//
//  Created by Home on 10/11/22.
//

import Foundation
import UIKit
import Alamofire

final class ViewModel: ObservableObject {
    private let urlSession: URLSession
    @Published var imageURL: URL?
    @Published var isLoading = false
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func generateImage(withText text: String) async {
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        let dictionary: [String: Any] = [
            "n": 1,
            "size": "1024x1024",
            "prompt": text
        ]
        
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            let (data, _) = try await urlSession.data(for: urlRequest)
            let model = try JSONDecoder().decode(ModelResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.isLoading = false
                guard let firstModel = model.data.first else {
                    return
                }
                self.imageURL = URL(string: firstModel.url)
                print(self.imageURL ?? "No imageURL")
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveImageGallery() {
        guard let imageURL = imageURL else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let data = try! Data(contentsOf: imageURL)
            DispatchQueue.main.async {
                let image = UIImage(data: data)!
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    func generateEdit(withText text: String, imageData: Data, maskData: Data) {
        let url = URL(string: "https://api.openai.com/v1/images/edits")!
        
        let headers = HTTPHeaders(["Authorization" : "Bearer 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"])
        
        let dictionary = [
            "n": "1",
            "size": "1024x1024",
            "prompt": text
        ]
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in dictionary {
                if let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
            
            multipartFormData.append(imageData, withName: "image", fileName: "image.png", mimeType: "image/png")
            multipartFormData.append(maskData, withName: "mask", fileName: "mask.png", mimeType: "image/png")
            
        }, to: url, headers: headers)
        .responseDecodable(of: ModelResponse.self) { dataResponse in
            let model = try! JSONDecoder().decode(ModelResponse.self, from: dataResponse.data!)
            
            DispatchQueue.main.async {
                self.isLoading = false
                guard let firstModel = model.data.first else {
                    return
                }
                self.imageURL = URL(string: firstModel.url)
                print(self.imageURL ?? "No imageURL")
            }
        }
        
    }
}
