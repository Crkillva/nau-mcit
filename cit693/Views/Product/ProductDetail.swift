//
//  ProductDetail.swift
//  cit693
//
//  Created by crkillva on 2025-02-18.
//
// 保险产品详情视图，用于单独显示使用

import SwiftUI

struct ProductDetail: View {
    //  定义item，绑定到SwiftUI view
    @State var item: InsuranceProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("保险产品详情")
                .font(.title)
            Divider()
            
            ScrollView {
                ProductInfo(item: item)
            }

        }
        .padding()
    }
}

#Preview {
    ProductDetail(item: InsuranceProduct())
}
