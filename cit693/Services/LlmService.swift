//
//  AiFunctions.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 定义Deepseek基本的API call function

import Foundation

func prepareHttpRequest(_ requestBody: [String: Any]) throws -> URLRequest {
    // DeepSeek API的URL和API密钥 api token will expired, and don't use in anywhere else!
    let apiUrl = URL(string: "https://api.deepseek.com/chat/completions")!
    let apiKey = "sk-40b20b88b8054edbb3295aed25e2790c"

    // 创建请求
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    // 将请求体转换为 JSON 数据
    guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
        throw HttpError.cannotConstructHttpBody
    }
    request.httpBody = httpBody
    
    return request
}

// 返回 URLSession.AsyncBytes 数据类型
func chatWithDeepseekBytes(requestBody: [String: Any]) async throws -> URLSession.AsyncBytes {
    let (payload, response) = try await URLSession.shared.bytes(for: prepareHttpRequest(requestBody))
    let httpResponse = response as? HTTPURLResponse
    guard httpResponse?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    return payload
}

// 返回 Data 数据类型
func chatWithDeepseekData(requestBody: [String: Any]) async throws -> Data {
    let (payload, response) = try await URLSession.shared.data(for: prepareHttpRequest(requestBody))
    let httpResponse = response as? HTTPURLResponse
    guard httpResponse?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    return payload
}
