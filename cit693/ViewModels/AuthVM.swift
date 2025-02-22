//
//  AuthModel.swift
//  cit693
//
//  Created by crkillva on 2025-02-13.
//
// viewmodel 用于实现用户注册，登录，访问控制等场景

import Foundation
import SwiftData
import Combine

//  定义“All”的默认选项，用于ItemList view过滤数据。
final class ConstantValue {
    static let `all`: String = "ALL"
}

enum Tab {
    case consultancyChat, solutionList, formList
    case dashboard, reviewList, profuctList
    case signin, signup, userProfile
}


@MainActor
class AuthViewModel: Observable, ObservableObject {
    @Published var tabSelection: Tab = .consultancyChat
    @Published var currentUser: User? = nil
    @Published var isSignIn: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    var modelContext: ModelContext? = nil
    
    func setupModelContext(modelContext: ModelContext) -> AuthViewModel {
        self.modelContext = modelContext
        
        return self
    }
    
    // 注册 只对客户开放注册，而agent和supervisor则从内部员工渠道注册，不在此App功能范围
    @MainActor
    func signUp(username: String, password: String, email: String) async {
        do {
            guard try await !UserService.matchUserForSignUp(username: username, email: email) else {
                showError = true
                errorMessage = "\(AuthError.userExists)"
                return
            }
            
            let userRequestDTO = UserRequestDTO(
                username: username,
                password: try PasswordHasher.hash(password), // 使用hash加密存储
                email: email,
                role: UserRole.customer,
                rememberMe: false,
                isSignIn: true
            )
            let userId = try await UserService.registerUser(userRequestDTO: userRequestDTO)
            let user = try await UserService.fetchUserById(userId: userId)
            modelContext?.insert(user)
            try modelContext?.save()
            
            currentUser = user
            isSignIn = true
            tabSelection = Tab.userProfile
        } catch {
            showError = true
            errorMessage = "\(error)"
        }
        
    }
    
    // 登录
    @MainActor
    func signIn(username: String, password: String, rememberMe: Bool) async {
        do {
            let hasedPassword = try PasswordHasher.hash(password)
            guard let user = try await UserService.matchUserForSignIn(username: username) else {
                showError = true
                errorMessage = "\(AuthError.invalidCredentials)"
                return
            }
            
            guard hasedPassword == user.password else {
                throw AuthError.invalidCredentials
            }
     
            user.rememberMe = rememberMe
            user.isSignIn = true
            try modelContext?.save()
            
            currentUser = user
            isSignIn = true
            tabSelection = Tab.userProfile
        } catch {
            showError = true
            errorMessage = "\(error)"
        }
        
    }
    
    // 登出
    func signOut() {
        do {
            currentUser?.isSignIn = false
            try modelContext?.save()
            currentUser = nil
            isSignIn = false
            tabSelection = Tab.signin
        } catch {
            showError = true
            errorMessage = "\(error)"
        }
        
    }
    
    // 自动登录检查
    func checkAutoSignin() {
        do {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.isSignIn })
            if let user = try modelContext?.fetch(descriptor).first, user.rememberMe {
                currentUser = user
                isSignIn = true
            }
        } catch {
            showError = true
            errorMessage = "\(error)"
        }
    }
    
}


