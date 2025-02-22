//
//  ContentView.swift
//  cit693
//
//  Created by crkillva on 2025-02-11.
//
// app 主视图，提供菜单导航栏， 默认为咨询视图

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    
    var body: some View {
        //  定义App底部tab view菜单。
        TabView(selection: $auth.tabSelection) {
            // 不同role对应不同视图
            if auth.isSignIn {
                switch auth.currentUser?.role {
                case .customer:
                    ConsultancyChat()
                        .tabItem({
                            Label("咨询", systemImage: "questionmark.bubble")
                        })
                        .tag(Tab.consultancyChat)
                    SolutionList()
                        .tabItem({
                            Label("方案", systemImage: "list.bullet.rectangle")
                        })
                        .tag(Tab.solutionList)
                    FormList()
                        .tabItem({
                            Label("保单", systemImage: "list.bullet.circle")
                        })
                        .tag(Tab.formList)
                case .agent:
                    Dashboard()
                        .tabItem({
                            Label("报表", systemImage: "chart.bar.xaxis")
                        })
                        .tag(Tab.dashboard)
                    FormList()
                        .tabItem({
                            Label("审批", systemImage: "list.bullet")
                        })
                        .tag(Tab.reviewList)
                    ProductList()
                        .tabItem({
                            Label("产品", systemImage: "list.bullet.circle")
                        })
                        .tag(Tab.profuctList)
                default:
                    EmptyView()
                }
                // common view for signin user
                UserProfileView()
                    .tabItem({
                        Label("账户", systemImage: "person.crop.circle")
                    })
                    .tag(Tab.userProfile)
                
            } else {
                // common views for anonymous user
                ConsultancyChat()
                    .tabItem({
                        Label("咨询", systemImage: "questionmark.bubble")
                    })
                    .tag(Tab.consultancyChat)
                SolutionList()
                    .tabItem({
                        Label("方案", systemImage: "list.bullet.rectangle")
                    })
                    .tag(Tab.solutionList)
                SignInView()
                    .tabItem({
                        Label("未登录", systemImage: "person.crop.circle")
                    })
                    .tag(Tab.signin)
            }
                
        }
        .onAppear(perform: {
            // 初始化数据
            Task {
                do {
                    auth.checkAutoSignin()
                    try await consultancyOptions.loadProducts()
                    try await formVM.loadForms()
                } catch {
                    auth.showError = true
                    auth.errorMessage = error.localizedDescription
                }
            }
        })
        .alert("🚨错误", isPresented: $auth.showError) {
        } message: {
            Text(auth.errorMessage)
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    ContentView()
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
