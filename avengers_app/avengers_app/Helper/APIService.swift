//
//  APIService.swift
//  avengers_app
//
//  Created by Mospeng Research Lab Philippines on 8/12/20.
//  Copyright © 2020 Mospeng Research Lab Philippines. All rights reserved.
//

import Foundation
import UIKit

class APIService: NSObject {
    static let shared = APIService()
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func fetchHeroes(completion: @escaping (Result<[Hero], Error>) -> ()) {
        let urlStr = Constant.API_BASE_URL + Constant.HEROES_API_KEY
        guard let url = URL(string: urlStr) else { return }
        
        getData(from: url) { data, _, err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to fetch heroes: ", err)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let posts = try JSONDecoder().decode([Hero].self, from: data)
                    completion(.success(posts))
                }
                catch {
                    completion(.failure(error))
                }
                print(String(data: data, encoding: .utf8) ?? "")
            }
        }
    }
    
    func downloadImage(using imageStr: String, completion: @escaping (_ image: UIImage?) -> ()) {
        print("Download Started")
        guard let url = URL(string: imageStr) else { return }
           
        getData(from: url) { data, res, err in
             DispatchQueue.main.async {
                if let err = err {
                    print("Failed to download image: ", err)
                    return
                }

                if let data = data {
                    completion(UIImage(data: data as Data))
                }
                else {
                    completion(nil)
                }
                print(res?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                
            }
        }
    }
    
    func createHero(name: String, specialSkill: String, imageFileName: String, image: UIImage?, completion: @escaping (Error?) -> ()) {
        let urlStr = Constant.API_BASE_URL + Constant.HERO_CREATE_API_KEY
        guard let url = URL(string: urlStr) else { return }
        
        guard let image = image else { return  }
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        // post request data
        let fieldName1 = "create_name",
            fieldValue1 = name,
            fieldName2 = "create_special_skill",
            fieldValue2 = specialSkill,
            fieldName3 = "uploaded_image",
            fieldValue3 = imageFileName
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the name field and its value to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName1)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue1)".data(using: .utf8)!)

        // Add the special skill field and its value to the raw http reqyest data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue2)".data(using: .utf8)!)

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName3)\"; filename=\"\(fieldValue3)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        URLSession.shared.uploadTask(with: urlRequest, from: data, completionHandler: { data, res, err in
            DispatchQueue.main.async {
                if let err = err {
                    print("failed to create hero: ", err)
                    completion(err)
                    return
                }
                guard let responseData = data else {
                    print("no response data")
                    return
                }
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("uploaded to: \(responseString)")
                }
                
                completion(nil)
            }
        }).resume()
    }
    
    func deletePost(id: Int, completion: @escaping (Error?) -> ()) {
        let urlStr = "\(Constant.API_BASE_URL)\(Constant.HERO_API_KEY)\(id)"
        guard let url = URL(string: urlStr) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
         URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(err)
                    return
                }
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                    completion(NSError(domain: "", code: resp.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                    return
                }
                completion(nil)
//                print(String(data: data, encoding: .utf8) ?? "")
            }
        }.resume()
    }
    
}
