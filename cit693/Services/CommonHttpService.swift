//
//  CommonHttpService.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 定义通用的NocoDB Rest API调用函数

import Foundation

class HttpService {
    // api token will expired, and don't use in anywhere else!
    static let apiKey = "ELiu7gF1avZFjJj5P2CR0b-oIdlLUhSttLofC9So"
    
    static func getJsonPayload(urlString: String, httpMethod: String = "GET") async throws -> [String: Any] {
        guard let apiUrl = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        // 创建请求
        var request = URLRequest(url: apiUrl)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(apiKey, forHTTPHeaderField: "xc-token")

        let (payload, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        guard httpResponse?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let jsonData = try JSONSerialization.jsonObject(with: payload, options: []) as? [String: Any]
        
        return jsonData ?? [:]
    }
}
