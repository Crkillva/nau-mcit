//
//  ProductList.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 保险产品清单， 数据源于Product table

import SwiftUI

struct ProductList: View {
    //  用于查询所有Item。
    @State private var items: [InsuranceProduct] = []
    //  用于记录选择的SuperType选择器的值，默认为ALL。
    @State private var filterSuperType: String = ConstantValue.all
    //  用于记录选择的SubType选择器的值，默认为ALL。
    @State private var filterSubType: String = ConstantValue.all
    
    //  用于显示item list中的数据，使用选择器的值对所有item进行匹配过滤。
    var filteredItems: [InsuranceProduct] {
        items.filter { item in
            funcFilterItem(item: item)
        }
    }

    var body: some View {
        //  使用NvagationSplitView结合使用NavigationLink使得列表view和item view之间可相互导航。
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("保险产品清单")
                    .font(.title)
                Divider()
                
                //  显示item总数，过滤选择器和列表的编辑按钮。
                HStack {
                    Image(systemName: "sum")
                    Text("\(filteredItems.count)")
                    
                    Divider().frame(height: 20)
                    
                    //  过滤importance的选择器。
                    Label("类别", systemImage: "ev.plug.ac.type.1")
                    Picker("Type", selection: $filterSuperType) {
                        Text(ConstantValue.all).tag(ConstantValue.all)
                        ForEach(InsuranceType.SuperType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Divider().frame(height: 20)
                    
                    //  过滤status的选择器。
                    Label("险种", systemImage: "ev.plug.ac.type.2")
                    Picker("SubType", selection: $filterSubType) {
                        Text(ConstantValue.all).tag(ConstantValue.all)
                        ForEach(InsuranceType.SubType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                List {
                    if items.isEmpty {
                        Text("Loading data...")
                            .foregroundColor(.secondary)
                    } else {
                        //  每个item可导航到item的主控视图，可查看item和执行编辑操作。
                        ForEach(filteredItems) {item in
                            NavigationLink {
                                ProductDetail(item: item)
                            } label: {
                                //  设计item在列表中的显示信息
                                HStack {
                                    Text("#\(item.id)")
                                    Divider()
                                    Text(item.type.rawValue)
                                    Divider()
                                    Text(item.subType.rawValue)
                                    Spacer()
                                }

                            }
                        }
                    }
                }
                //  添加对数据执行过滤和删除数据时的动画效果。
                .animation(.default, value: filteredItems)
                
            }
            .padding()
//        } detail: {
//            Text("选择一个项目")
        }.onAppear(perform: {
            Task {
                items = try await ProductService.fetchProducts()
            }
        })
    }
    
    //  定义item过滤方法，返回Bool类型判断结果。
    private func funcFilterItem(item: InsuranceProduct) -> Bool {
        var filteredSuperType: Bool
        var filteredSubType: Bool
        
        //  使用选择器的值匹配item的importance。
        if filterSuperType == ConstantValue.all {
            filteredSuperType = InsuranceType.SuperType.allCases.contains(item.type)
        } else {
            filteredSuperType = item.type.rawValue == filterSuperType
        }
        //  使用选择器的值匹配item的status。
        if filterSubType == ConstantValue.all {
            filteredSubType = InsuranceType.SubType.allCases.contains(item.subType)
        } else {
            filteredSubType = item.subType.rawValue == filterSubType
        }
        return filteredSuperType && filteredSubType
    }

}

#Preview {
    ProductList()
}
