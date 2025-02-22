//
//  FormService.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 提供对Form data的RestAPI 函数

import Foundation

class FormService {
    // NocoDB URL for Form table
    static let baseUrl: String =  "https://app.nocodb.com/api/v2/tables/mzzb3qpsm3idsod/records"
    
    static func fetchForms() async throws -> [InsuranceForm] {
        let urlString: String =  baseUrl + "?viewId=vwsxwzpob661nsuq&limit=200"
        var forms: [InsuranceForm] = []
        
        let jsonData = try await HttpService.getJsonPayload(urlString: urlString)
        if let list = jsonData["list"] as? [[String: Any]] {
            list.forEach { dict in
                forms.append(InsuranceForm(dict: dict))
            }
        }
        return forms
    }
    
    static func fetchFormById(formId: Int) async throws -> InsuranceForm {
        guard let apiUrl = URL(string: baseUrl + "/" + formId.description) else {
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

        guard let insuranceFormDTO = try JSONDecoder().decode(InsuranceFormDTO?.self, from: payload) else {
            throw HttpError.fetchRecordFailed
        }
        return InsuranceForm(dto: insuranceFormDTO)
    }
    
    static func createForm(insuranceFormRequestDTO: InsuranceFormRequestDTO) async throws -> Int {
        guard let apiUrl = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }
        // 创建请求
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue(HttpService.apiKey, forHTTPHeaderField: "xc-token")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(insuranceFormRequestDTO)

        let (payload, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        guard httpResponse?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let jsonData = try JSONSerialization.jsonObject(with: payload, options: []) as? [String: Int]
        guard let formId = jsonData?["Id"] else {
            throw HttpError.createRecordFailed
        }
        
        return formId
    }
    
    static func updateForm(_ requestBody: [String: Any]) async throws {
        guard let apiUrl = URL(string: baseUrl) else {
            throw URLError(.badURL)
        }
        // 创建请求
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "PATCH"
        request.setValue(HttpService.apiKey, forHTTPHeaderField: "xc-token")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 将请求体转换为 JSON 数据
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            throw HttpError.cannotConstructHttpBody
        }
        request.httpBody = httpBody

        let (payload, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let jsonData = try JSONSerialization.jsonObject(with: payload, options: []) as? [String: Int]
        guard jsonData?["Id"] != nil else {
            throw HttpError.createRecordFailed
        }

    }
}
