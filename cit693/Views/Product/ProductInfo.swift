//
//  ProductInfo.swift
//  cit693
//
//  Created by crkillva on 2025-02-20.
//
// 保险产品详细信息视图，用于被其他视图嵌套使用。

import SwiftUI

struct ProductInfo: View {
    @State var item: InsuranceProduct
    
    var body: some View {
        //  用不同的合适的组件显示item的各个字段。
        VStack(alignment: .leading, spacing: 10) {
            Text("产品信息")
                .font(.headline)
            
            HStack {
                Text("编号:")
                Spacer()
                Text("#\(item.id)")
            }
            HStack {
                Text("保险名称:")
                Spacer()
                Text(item.name.rawValue)
            }
            HStack {
                Text("类别:")
                Spacer()
                Text(item.type.rawValue)
            }
            HStack {
                Text("险种:")
                Spacer()
                Text(item.subType.rawValue)
            }
            HStack {
                Text("定义说明:")
                Spacer()
                Text(item.definition)
            }
            HStack {
                Text("赔付额:")
                Spacer()
                Text("(\(item.coverageAmountMin.description) 至 \(item.coverageAmountMin.description))")
            }
            HStack {
                Text("保费:")
                Spacer()
                Text("(\(item.premiumMin.description) 至 \(item.premiumMax.description))")
            }
            HStack {
                Text("限制年龄:")
                Spacer()
                Text("(\(item.eligibleAgeMin.description) 至 \(item.eligibleAgeMax.description))")
            }
            HStack {
                Text("风险系数:")
                Spacer()
                Text(item.riskCoefficient.description)
            }

            
            HStack {
                Text("适用情况:")
                Spacer()
                Text(item.characterization)
            }
            
        }
    }
}

#Preview {
    ProductInfo(item: InsuranceProduct())
}
