//
//  UserService.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 提供对User data的RestAPI 函数

import Foundation
import SwiftData

struct UserService {
    // NocoDB URL for user table
    static let baseUrl: String =  "https://app.nocodb.com/api/v2/tables/m3a7q9zxnam4tey/records"
    
    // get user by id
    static func fetchUserById(userId: Int) async throws -> User {
        guard let apiUrl = URL(string: baseUrl+"/"+userId.description) else {
            throw URLError(.badURL)
        }
        // 创建请求
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(HttpService.apiKey, forHTTPHeaderField: "xc-token")

        let (payload, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        guard httpResponse?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let userDTO = try JSONDecoder().decode(UserDTO?.self, from: payload) else {
            throw HttpError.registerUserFailed
        }
        return User(userDTO: userDTO)
    }
    
    // register new user
    static func registerUser(userRequestDTO: UserRequestDTO) async throws -> Int {
        guard let apiUrl = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }
        // 创建请求
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue(HttpService.apiKey, forHTTPHeaderField: "xc-token")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(userRequestDTO)

        let (payload, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        guard httpResponse?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let jsonData = try JSONSerialization.jsonObject(with: payload, options: []) as? [String: Int]
        guard let userId = jsonData?["Id"] else {
            throw HttpError.registerUserFailed
        }
        
        return userId
    }
    
    // check user is already exist
    static func matchUserForSignUp(username: String, email: String) async throws -> Bool {
        let urlString = "\(baseUrl)?viewId=vw35pann8wsjsztc&where=(username,eq,\(username))~and(email,eq,\(email))"
        let jsonData = try await HttpService.getJsonPayload(urlString: urlString)
        if let list = jsonData["list"] as? [[String: Any]], !list.isEmpty {
            return true
        }
        return false
    }
    
    // get user by username for user signin
    static func matchUserForSignIn(username: String) async throws -> User? {
        let urlString = "\(baseUrl)?viewId=vw35pann8wsjsztc&where=(username,eq,\(username))"
        let jsonData = try await HttpService.getJsonPayload(urlString: urlString)
        if let list = jsonData["list"] as? [[String: Any]], let userDict = list.first {
            return User(dict: userDict)
        }
        return nil
    }
    
    
}
