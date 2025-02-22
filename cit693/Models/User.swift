//
//  User.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 定义用户数据类型，及对应的enum，DTO model

import Foundation
import SwiftData

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case customer, agent, supervisor
    
    var id: String { rawValue }
    
    static let rawValueMap: [String: UserRole] = {
        Dictionary(uniqueKeysWithValues: UserRole.allCases.map { ($0.rawValue, $0) })
    }()
    
    static func fromRawValue(_ value: String) -> UserRole {
        return rawValueMap[value] ?? UserRole.customer
    }
}

@Model
class User {
    var id: String
    var username: String
    var password: String
    var email: String
    var role: UserRole
    var rememberMe: Bool = true
    var isSignIn: Bool = false
    
    init(dict: [String: Any]) {
        let id = dict["Id"] as? Int
        self.id = id?.description ?? UUID().uuidString
        self.username = dict["username"] as? String ?? ""
        self.password = dict["password"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.role = UserRole.fromRawValue(dict["role"] as? String ?? "")
        self.rememberMe = dict["rememberMe"] as? Bool ?? true
        self.isSignIn = dict["isSignIn"] as? Bool ?? false
        
    }
    
    init(userDTO: UserDTO) {
        self.id = userDTO.id.description
        self.username = userDTO.username
        self.password = userDTO.password
        self.email = userDTO.email
        self.role = UserRole.fromRawValue(userDTO.role)
        self.rememberMe = userDTO.rememberMe
        self.isSignIn = userDTO.isSignIn
    }
}

// DTO for http request body
class UserRequestDTO: Codable {
    var username: String
    var password: String
    var email: String
    var role: String
    var rememberMe: Bool = true
    var isSignIn: Bool = false
    
    init(username: String, password: String, email: String, role: UserRole, rememberMe: Bool, isSignIn: Bool) {
        self.username = username
        self.password = password
        self.email = email
        self.role = role.rawValue
        self.rememberMe = rememberMe
        self.isSignIn = isSignIn
    }
    
}

// DTO for http response body
class UserDTO: UserRequestDTO {
    var id: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "Id"
    }

}
