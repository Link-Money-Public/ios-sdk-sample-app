//
// ContentView.swift
//
// Copyright (c) 2023-2024 Link Financial Technologies, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
import SwiftUI

struct ContentView: View {
    @StateObject var context: LinkPayContext = LinkPayContext()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color("BackgroundColor").ignoresSafeArea()
                VStack {
                    Rectangle()
                        .frame(height: 0)
                        .background(Color(red: 0.21, green: 0.28, blue: 0.29))
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    self.appTitleAndLogo()
                }
                ScrollView(.vertical, showsIndicators: false) {
                    UserDataView(context)
                    SessionView(context)
                    PaymentView(context)
                }
                .padding(.top, 45)
                .padding(.horizontal, 10)
            }
        }
    }
    
    private func appTitleAndLogo() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Image("linklogowhite")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 25, height: 25, alignment: .leading)
                Text("Link Sample")
                    .fontWeight(.semibold)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
