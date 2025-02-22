//
//  ProductService.swift
//  cit693
//
//  Created by crkillva on 2025-02-17.
//
// 提供对Product data的RestAPI 函数

import Foundation

struct ProductService {
    // NocoDB URL for Product table
    static let baseUrl: String =  "https://app.nocodb.com/api/v2/tables/mjhgt7osp1nnlgy/records"
    
    static func fetchProducts() async throws -> [InsuranceProduct] {
        let urlString: String =  baseUrl + "?viewId=vw61fssjki1agss6"
        var products: [InsuranceProduct] = []
        
        let jsonData = try await HttpService.getJsonPayload(urlString: urlString)
        if let list = jsonData["list"] as? [[String: Any]] {
            list.forEach { dict in
                products.append(InsuranceProduct(dict: dict))
            }
        }
        return products
    }
    
    static func fetchProductById(productId: String) async throws -> InsuranceProduct {
        guard let apiUrl = URL(string: baseUrl + "/" + productId) else {
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

        guard let insuranceProductDTO = try JSONDecoder().decode(InsuranceProductDTO?.self, from: payload) else {
            throw HttpError.fetchRecordFailed
        }
        return InsuranceProduct(dto: insuranceProductDTO)
    }
    
}
