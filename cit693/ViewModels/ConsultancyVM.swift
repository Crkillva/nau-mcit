//
//  ConsultancyModel.swift
//  cit693
//
//  Created by crkillva on 2025-02-13.
//
// viewmodel 用于与智能顾问GenAI的互动场景

import Foundation

enum DefaultPlaceHolder: String, Codable, Identifiable {
    case noSolutionYet = "暂无推荐方案，说说您的需求吧"
    case thinking = "思考中..."
    
    var id: String { rawValue }
}

@MainActor
class ConsultancyOptions: ObservableObject {
    @Published var requestText: String = ""
    @Published var responseText: String = ""
    @Published var isConsultancyStreaming: Bool = false
    @Published var products: [InsuranceProduct] = []
    @Published var solutions: [SolutionItem] = []
    @Published var solutionText: String = DefaultPlaceHolder.noSolutionYet.rawValue
    @Published var isSolutionStreaming: Bool = false
    
    // 与智能顾问聊天
    func getConsultancy() async {
        responseText = DefaultPlaceHolder.thinking.rawValue
        // 请求体
        let requestBody: [String: Any] = [
            "messages": [
                [
                    "role" : "system",
                    "content": "你是一位保险领域的专家，为用户解答保险领域相关的问题。 要求：1. 仅回答保险领域相关的内容，不扩展其他领域 2. 每次回答控制在200字以内 3. 保持中立客观，不作假设"
                    
                ],
                [
                    "role" : "user",
                    "content" : requestText
                ]
            ],
            "model": "deepseek-chat",
            "temperature": 1.3,
            "stream": true // 启用流式响应
        ]
        // 清空提问区
        requestText = ""
        isConsultancyStreaming = true
        defer {
            // 结束流式处理通知UI显示
            isConsultancyStreaming = false
        }
        
        // 发送请求并处理流式响应
        do {
            let stream = try await chatWithDeepseekBytes(requestBody: requestBody)
            // 清空回复区
            responseText = ""
            
            // 逐行读取流式数据
            for try await line in stream.lines {
                // print("received: \(line)")
                if let data = line.dropFirst(5).data(using: .utf8),
                   let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonData["choices"] as? [[String: Any]],
                   let message = choices.first?["delta"] as? [String: Any],
                   let content = message["content"] as? String {
                        // 更新 UI
                    responseText += content
                    }
            }
        } catch {
            let content = "请求出错！ \(error.localizedDescription)"
            print(content)
            responseText = content
        }
        
    }
    
    // 请求投保方案
    func getProposal() async {
        solutionText = DefaultPlaceHolder.thinking.rawValue
        do {
            // 获取产品清单并转换成String，用于promt message
            try await loadProducts()
            var productListString: String = ""
            products.forEach { product in
                productListString += product.toString() + ","
            }
            // 请求体
            let requestBody: [String: Any] = [
                "messages": [
                    [
                        "role" : "system",
                        "content": """
                        你是一位保险领域的专家，为用户推荐投保方案，根据用户描述的需求在保险产品清单中分析匹配适合的保险产品作为推荐方案，并根据匹配逻辑计算匹配分数。 
                        要求：
                        1. 仅讨论保险推荐方案，不扩展其他领域，如果用户需求不清晰，则提示用户描述更多需求细节。
                        2. 保持中立客观，不作假设。
                        3. 推荐方案的产品仅在以下保险产品清单中匹配, 如果用户有提出具体的保险类型或名称，但不在此产品清单内无法成功匹配到推荐方案的话，则提示用户暂不支持该保险类型。
                        保险产品清单：
                        \(productListString)
                        4. 匹逻辑至少还需要验证用户描述的需求是否含有关键信息如赔付额，保费，年龄等，是否在保险产品的适用范围.
                        例如，赔付额是否在(coverageAmountMin,coverageAmountMax)范围，保费是否在(premiumMin,premiumMax)范围，年龄是否在(eligibleAgeMin,eligibleAgeMax)范围。
                        5. 每有一个合适的推荐方案，则解析"productId","matchScore"和"reason"并且严格使用JSON格式输出，每个方案将添加到数组。
                        6. 最终输出为JSON数组类型，此JSON数组外不额外增加任何内容。
                        其中"productId"为所推荐的产品在产品清单中的id，"matchScore"为计算得出的匹配分数（值范围为0到1，使用Double类型），"reason"为匹配逻辑或推荐理由概述。
                        
                        EXAMPLE INPUT: 
                        我想了解一下人寿保险，保费低一些的

                        EXAMPLE JSON OUTPUT:
                        [
                            {
                                "productId": "1",
                                "matchScore": 0.9,
                                "reason": "保费低至200每年，非常适合您的需求"
                            }，
                            {
                                "productId": "2",
                                "matchScore": 0.7,
                                "reason": "保费较高，但赔付额也较高，且使用年龄较宽松，亦可考虑"
                            }
                        ]
                        """
                    ],
                    [
                        "role" : "user",
                        "content" : requestText
                    ]
                ],
                "model": "deepseek-chat",
                "temperature": 1.0,
                "type": "json_object",
                "stream": true // 启用流式响应
            ]
            // 清空提问区
            requestText = ""
            isSolutionStreaming = true
            defer {
                // 结束流式处理通知UI显示
                isSolutionStreaming = false
            }

            // 发送请求并处理流式响应
            let stream = try await chatWithDeepseekBytes(requestBody: requestBody)
            // 清空回复区
            solutionText = ""
            
            // 逐行读取流式数据
            for try await line in stream.lines {
                // print("received: \(line)")
                if let data = line.dropFirst(5).data(using: .utf8),
                   let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonData["choices"] as? [[String: Any]],
                   let message = choices.first?["delta"] as? [String: Any],
                   let content = message["content"] as? String {
                        // 更新 UI
                    solutionText += content
//                    print(solutionText)
                    }
            }
            guard let solutionData = solutionText.data(using: .utf8) else {
                throw HttpError.cannotDecodeJsonResponse
            }
            guard let dtoList = try JSONDecoder().decode([SolutionItemDTO]?.self, from: solutionData) else {
                throw HttpError.registerUserFailed
            }
            dtoList.forEach { dto in
                if getProductById(id: dto.productId) != nil {
                    solutions.append(SolutionItem(dto: dto))
                }
            }
            solutionText = DefaultPlaceHolder.noSolutionYet.rawValue
        } catch {
            let content = "请求出错！ \(error.localizedDescription)"
            print(content)
            solutionText = content
        }
        
    }
    
    // 获取产品清单
    func loadProducts() async throws {
        if products.isEmpty {
            products = try await ProductService.fetchProducts()
        }
    }
    
    // 获取单一产品信息
    func getProductById(id: String) -> InsuranceProduct? {
        return products.first(where:{$0.id == id})
    }
}
