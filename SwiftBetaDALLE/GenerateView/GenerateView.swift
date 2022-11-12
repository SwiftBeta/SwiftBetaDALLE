//
//  GenerateView.swift
//  SwiftBetaDALLE
//
//  Created by Home on 10/11/22.
//

import SwiftUI

struct GenerateView: View {
    @StateObject var viewModel = ViewModel()
    @State var text = "Two astronauts exploring the dark, cavernous interior of a huge derelict spacecraft, digital art"
    
    var body: some View {
        VStack {
            Text("¡Suscríbete a SwiftBeta para más contenido gratuito! 🚀")
                .multilineTextAlignment(.center)
            Form {
                AsyncImage(url: viewModel.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                viewModel.saveImageGallery()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .shadow(color: .black, radius: 0.2)
                                }
                                .padding(8)
                                .foregroundColor(.green)
                            }

                        }
                    
                } placeholder: {
                    VStack {
                        if !viewModel.isLoading {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                        } else {
                            ProgressView()
                                .padding(.bottom, 12)
                            Text("¡Tu imagen se está generando, espera unos segundos! 🚀")
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 300, height: 300)
                }

                
                TextField("Describe the image that you want to generate",
                          text: $text,
                          axis: .vertical)
                .lineLimit(10)
                .lineSpacing(5)
                
                HStack {
                    Spacer()
                    Button("🪄 Generate Image") {
                        Task {
                            await viewModel.generateImage(withText: text)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                    .padding(.vertical)
                    Spacer()
                }
            }
        }
    }
}

struct GenerateView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateView()
    }
}
