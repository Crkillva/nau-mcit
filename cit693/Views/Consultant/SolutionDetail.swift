//
//  SolutionDetaail.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 推荐方案详情视图，客户登录后可据此生成保单

import SwiftUI

struct SolutionDetail: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    @State var solutionItem: SolutionItem
    @State private var showForm: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("方案详情")
                    .font(.title)
                Divider()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10)  {
                    Text("基本信息")
                        .font(.headline)
                    
                    HStack {
                        Text("推荐度:")
                        Spacer()
                        Text(solutionItem.matchScore.description)
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("推荐说明:")
                        Spacer()
                        Text(solutionItem.reason)
                    }
                    Divider()
                }

                ProductInfo(item: consultancyOptions.getProductById(id: solutionItem.productId) ?? InsuranceProduct())
            }

        }
        .alert("🚨错误", isPresented: $formVM.showError) {
        } message: {
            Text(formVM.errorMessage)
        }
        .toolbar {
            // 在导航栏右侧添加按钮
            if auth.isSignIn {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            showForm = await formVM.createForm(productId: solutionItem.productId, user: auth.currentUser)
                            print("form creation: \(showForm)")
                        }
                    }) {
                        Text("\(Image(systemName: "document.badge.plus"))生成保单")
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SignInView()
                    } label: {
                        Text("\(Image(systemName: "person.badge.key"))登录生成保单")
                    }
                }
            }
            
        }
        .navigationDestination(isPresented: $showForm, destination: {
            FormHost(insuranceForm: $formVM.insuranceForm)
        })
        .padding()
    }
    
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    SolutionDetail(solutionItem: SolutionItem(productId: "1", matchScore: 0, reason: ""))
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
