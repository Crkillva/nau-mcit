//
//  UserProfileView.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 用户账户视图，用户可在此退出登录

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @EnvironmentObject private var auth: AuthViewModel
    
    var body: some View {
        ScrollView {
            //  用不同的合适的组件显示item的各个字段。
            VStack(alignment: .leading, spacing: 10) {
                Text("我的账户")
                    .font(.title)
                Divider()
                
                HStack {
                    
                    Text("\(auth.currentUser?.username ?? "")")
                        .font(.title2)
                    Text("已登录")
                        .foregroundColor(.green)
                }
                .padding()
                
                HStack {
                    Text("电子邮箱:")
                    Text("\(auth.currentUser?.email ?? "")")
                }
                

                Toggle("自动登录:", isOn: Binding(
                    get: { auth.currentUser?.rememberMe ?? false },
                    set: { auth.currentUser?.rememberMe = $0 })
                )
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button("退出登录") {
                        auth.signOut()
                    }
                    .alert("🚨错误", isPresented: $auth.showError) {
                    } message: {
                        Text(auth.errorMessage)
                    }
                    Spacer()
                }
            }
            .padding()
        }

    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    UserProfileView()
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
}
