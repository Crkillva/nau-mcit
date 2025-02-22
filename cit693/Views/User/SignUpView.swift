//
//  SignUpView.swift
//  cit693
//
//  Created by crkillva on 2025-02-13.
//
// 用户注册视图

import SwiftUI
import SwiftData

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var password2 = ""
    @State private var email = ""
    @State private var showWarn: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("新用户注册")
                .font(.title2)
            Divider()
            
            Form {
                HStack {
                    Text("用户名:")
                    TextField("username", text: $username)
                }
                HStack {
                    Text("密码:")
                    SecureField("password", text: $password)
                }
                HStack {
                    Text("确认密码:")
                    SecureField("password again", text: $password2)
                }
                HStack {
                    Text("电子邮箱:")
                    TextField("email", text: $email)
                }
                HStack {
                    Spacer()
                    Button("提交注册") {
                        if checkForm() {
                            return
                        }
                        Task {
                            await auth.signUp(username: username, password: password, email: email)
                        }
                    }
                    .alert("🔔提醒", isPresented: $showWarn) {
                    } message: {
                        Text("请输入您的身份认证信息和有效邮箱。")
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
    
    private func checkForm() -> Bool {
        showWarn = username == "" || password == "" || password2 != password || email == ""
        return showWarn
    }
    
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    SignUpView()
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
}
