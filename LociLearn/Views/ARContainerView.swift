//
//  ARContainerView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 23/02/26.
//

import SwiftUI

struct ARContainerView: View {
    @StateObject var vm = QuestionViewModel()

    var body: some View {
        ZStack {
            ARPalaceView(viewModel: vm)
                .ignoresSafeArea()

            if !vm.arModeActive {
                VStack {
                    Spacer()
                    Text("Tap to position the Solar System in your space.")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                }
            }
        }
    }
}
