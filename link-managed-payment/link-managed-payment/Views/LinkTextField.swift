//
// LinkTextField.swift
//
// Copyright (c) 2024 Link Financial Technologies, Inc.
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
import Foundation
import SwiftUI

@available(iOS 15.0, *)
struct LinkTextField: View {
    private var title: String
    private var placeHolder: String
    private var isDisabled: Bool = false
    private var keyboardType: UIKeyboardType
    private var text: Binding<String>
    private var textFieldBackgroundColor: Color
    private var textFieldBorderColor: Color
    private var onCopyPressed: (() -> Void)?

    init(title: String,
         place: String = "",
         text: Binding<String>,
         textSize: CGFloat? = nil,
         isDisabled: Bool = false,
         keyboardType: UIKeyboardType = .default,
         textFieldBackgroundColor: Color = Color("FormFieldBackgroundColor"),
         textFieldBorderColor: Color = Color("FormFieldBorderColor"),
         onCopyPressed: (() -> Void)? = nil
    ) {
        self.title = title
        self.placeHolder = place
        self.text = text
        self.isDisabled = isDisabled
        self.keyboardType = keyboardType
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textFieldBorderColor = textFieldBorderColor
        self.onCopyPressed = onCopyPressed
    }

    // border color
    var body: some View {
        Text(title).font(.callout).bold()
        HStack {
            TextField(placeHolder, text: text)
                .padding([.bottom, .top, .leading], 5)
                .background(textFieldBackgroundColor)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(textFieldBorderColor, lineWidth: 2)
                })
                .disabled(isDisabled)
                .keyboardType(keyboardType)
            if self.onCopyPressed != nil {
                Image(systemName: "doc.on.clipboard").onTapGesture {
                    if let onCopyPressed = onCopyPressed {
                        onCopyPressed()
                    }
                }
            }
        }
    }
}
