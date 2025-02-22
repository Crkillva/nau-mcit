//
//  AiHelperView.swift
//  cit693
//
//  Created by crkillva on 2025-02-11.
//
// 定义聊天视图，发送消息和接收回复

import Foundation
import SwiftUI

struct ConsultancyChat: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @State private var showHelp: Bool = false
    @State private var showWarn: Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                Text("保险咨询")
                    .font(.title)
                Divider()
                
                Text("投保小助手为您服务")
                    .font(.headline)
                
                ScrollView {
                    Text(consultancyOptions.responseText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(height: geometry.size.height * 0.55)
                
                Spacer()
                
                HStack {
                    Text("发送消息")
                    Label("", systemImage: "info.circle")
                        .font(.headline)
                        .selectionDisabled()
                        .onTapGesture {
                            showHelp = true
                        }
                        .alert("ℹ️提示", isPresented: $showHelp) {
                        } message: {
                            Text("描述保险相关的问题，或者保险需求，以获取投保方案。")
                        }
                }
                VStack(alignment: .trailing, spacing: 10) {
                    TextEditor(text: $consultancyOptions.requestText)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .alert("🔔提醒", isPresented: $showWarn) {
                        } message: {
                            Text("请输入您的问题或需求。")
                        }
                }
           
                HStack {
                    Button(action: {
                        guard checkTextEditor() else {
                            return
                        }
                        Task {
                            await consultancyOptions.getConsultancy()
                        }
                    }) {
                        Text(consultancyOptions.isConsultancyStreaming ? "咨询中..." : "\(Image(systemName: "bubble.left")) 向小助手提问")
                    }
                    .disabled(consultancyOptions.isConsultancyStreaming)
                    
                    Spacer()
                    
                    Button(action: {
                        guard checkTextEditor() else {
                            return
                        }
                        Task {
                            await consultancyOptions.getProposal()
                        }
                        auth.tabSelection = Tab.solutionList
                    }) {
                        Text("\(Image(systemName: "bubble.left")) 获取投保方案")
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    // 检查输入框
    private func checkTextEditor() -> Bool {
        guard consultancyOptions.requestText != "" else {
            showWarn = true
            return false
        }
        return true
    }
    
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    ConsultancyChat()
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
}
