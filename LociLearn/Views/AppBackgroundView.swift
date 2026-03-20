//
//  AppBackgroundView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 26/02/26.
//


import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            // EXACT AR gradient
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.02, blue: 0.12),
                    Color(red: 0.06, green: 0.02, blue: 0.22),
                    Color(red: 0.10, green: 0.04, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // EXACT same star field (no opacity reduction)
            StarFieldView()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    AppBackgroundView()
}

