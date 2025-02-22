//
//  SecurityFunction.swift
//  cit693
//
//  Created by crkillva on 2025-02-17.
//
// 定义通用的函数

import Foundation
import CryptoKit

enum PasswordHasher {
    static func hash(_ password: String) throws -> String {
        guard let data = password.data(using: .utf8) else {
            throw AuthError.encodingError
        }
        
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func verify(_ password: String, target: String) throws -> Bool {
        let hashedInput = try hash(password)
        return hashedInput == target
    }
}

func formateDateString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func formateDate(_ date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: date) ?? Date()
}

func StringToInt(_ value: String) -> Int {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    return formatter.number(from: value) as! Int
}

func getDoubleFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}
