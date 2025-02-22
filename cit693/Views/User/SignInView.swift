//
//  SigninView.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 用户登录视图

import SwiftUI
import SwiftData

struct SignInView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe: Bool = true
    @State private var showWarn: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("用户登录")
                    .font(.title)
                Divider()
                
                HStack {
                    Text("还没账户？")
                    NavigationLink("点这里注册") {
                        SignUpView()
                    }
                    .foregroundColor(.accentColor)
                }
                .padding()
                
                Form {
                    HStack {
                        Text("用户名：")
                        TextField("Username", text: $username)
                    }
                    HStack {
                        Text("密码：")
                        SecureField("Password", text: $password)
                    }
 
                    Toggle("记住我：", isOn: $rememberMe)

                    HStack {
                        Spacer()
                        Button("登录") {
                            if checkCredentials() {
                                return
                            }
                            Task {
                                await auth.signIn(username: username, password: password, rememberMe: rememberMe)
                            }
                        }
                        .alert("🔔提醒", isPresented: $showWarn) {
                        } message: {
                            Text("请输入您的身份认证信息。")
                        }
                        .alert("🚨错误", isPresented: $auth.showError) {
                        } message: {
                            Text(auth.errorMessage)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
 
        }
    }
    
    private func checkCredentials() -> Bool {
        if username == "" || password == "" {
            showWarn = true
        }
        
        return showWarn
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    SignInView()
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
}
