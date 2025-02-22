//
//  SolutionList.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 推荐方案列表视图，客户可自行管理推荐的方案，推荐方案只在本地缓存，无需保存到服务器。

import SwiftUI

struct SolutionList: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("投保建议方案列表")
                    .font(.title)
                Divider()
                
                //  显示item总数，过滤选择器和列表的编辑按钮。
                HStack {
                    Image(systemName: "sum")
                    Text("\(consultancyOptions.solutions.count)")
                    Spacer()
                    
                    Button("More", systemImage: "plus.circle") {
                        auth.tabSelection = Tab.consultancyChat
                    }
                    Divider().frame(height: 20)
                    //  列表编辑按钮。
                    EditButton()
                }
                if consultancyOptions.solutions.isEmpty {
                    ScrollView {
                        Text(consultancyOptions.solutionText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                } else {
                    List {
                    //  每个item可导航到item的主控视图，可查看item和执行编辑操作。
                        ForEach(consultancyOptions.solutions) {item in
                            NavigationLink {
                                SolutionDetail(solutionItem: item)
                            } label: {
                                //  设计item在列表中的显示信息
                                VStack {
                                    HStack {
                                        Text("\(displayProduct(id: item.productId))")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("推荐度:")
                                        Spacer()
                                        Text(item.matchScore.description)
                                            .foregroundColor(.green)
                                    }
                                    
                                    HStack {
                                        Text("推荐说明:")
                                        Spacer()
                                        Text(item.reason)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    //  添加对数据执行过滤和删除数据时的动画效果。
                    .animation(.default, value: consultancyOptions.solutions)
                }
            }
            .padding()
        }
    }
    
    func displayProduct(id: String) -> String {
        let product = consultancyOptions.getProductById(id: id)
        return "#\(id) - \(product?.type.rawValue ?? "") - \(product?.subType.rawValue ?? "")"
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            consultancyOptions.solutions.remove(atOffsets: offsets)
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    SolutionList()
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
