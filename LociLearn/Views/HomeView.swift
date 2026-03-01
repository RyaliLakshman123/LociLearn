////
////  HomeView.swift
////  LociLearn
////
////  Created by Sameer Nikhil on 21/02/26.
////
//
//import SwiftUI
//
//struct HomeView: View {
//    
//    @StateObject private var viewModel = QuestionViewModel()
//    @State private var navigateToAR = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(.systemBackground)
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 30) {
//                    
//                    Spacer()
//                    
//                    Text("LociLearn")
//                        .font(.largeTitle)
//                        .bold()
//                    
//                    Text("Place knowledge. Remember naturally.")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                    
//                    Spacer()
//                    
//                    if viewModel.isLoading {
//                        ProgressView("Loading Questions...")
//                            .progressViewStyle(.circular)
//                    }
//                    
//                    if let error = viewModel.errorMessage {
//                        Text(error)
//                            .foregroundColor(.red)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                    }
//                    
//                    Button {
//                        viewModel.fetchQuestions()
//                    } label: {
//                        Text("Load Questions")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(.ultraThinMaterial)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//                    }
//                    
//                    Button {
//                        navigateToAR = true
//                    } label: {
//                        Text("Start Palace")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.primary)
//                            .foregroundColor(.black)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//                    }
//                    .disabled(viewModel.questions.isEmpty)
//                    
//                }
//                .padding()
//            }
//            .navigationDestination(isPresented: $navigateToAR) {
//                ARPalaceView(viewModel: viewModel)
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//}
