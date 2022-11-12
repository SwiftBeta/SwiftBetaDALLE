//
//  EditView.swift
//  SwiftBetaDALLE
//
//  Created by Home on 11/11/22.
//

import SwiftUI
import HelpersTutorialDALLE2

struct EditView: View {
    @StateObject var viewModel = ViewModel()
    @State var text = ""
    @State var selectedImage: Image?
    @State var emptyImage: Image = Image(systemName: "photo.on.rectangle.angled")
    
    @State var showCamera: Bool = false
    @State var showGallery: Bool = false
    
    @State var lines: [Line] = []
    
    @FocusState var isFocused: Bool
    
    var currentImage: some View {
        if let selectedImage {
            return selectedImage
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
        } else {
            return emptyImage
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
        }
    }
    
    var body: some View {
        Form {
            Text("Create a mask")
                .font(.headline)
            .padding(.vertical, 12)
            
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
                        ZStack {
                            currentImage
                            SwiftBetaCanvas(lines: $lines, currentLineWidth: 30)
                        }
                    } else {
                        ProgressView()
                            .padding(.bottom, 12)
                        Text("¡Tu imagen se está generando, espera unos segundos! 🚀")
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: 300, height: 300)
            }
            
            HStack {
                Button {
                    showCamera.toggle()
                } label: {
                    Text("📷 Take a photo!")
                }
                .tint(.orange)
                .buttonStyle(.borderedProminent)
                .fullScreenCover(isPresented: $showCamera) {
                    CameraView(selectedImage: $selectedImage)
                }
                .padding(.vertical, 12)
                
                Spacer()
                
                Button {
                    showGallery.toggle()
                } label: {
                    Text("Open Gallery")
                }
                .tint(.purple)
                .buttonStyle(.borderedProminent)
                .fullScreenCover(isPresented: $showGallery) {
                    GalleryView(selectedImage: $selectedImage)
                }
                .padding(.vertical, 12)
            }
            
            TextField("Añade un texto la IA generá una imagen",
                      text: $text,
                      axis: .vertical)
            .lineLimit(10)
            .lineSpacing(5)
            .focused($isFocused)
            
            HStack {
                Spacer()
                
                Button("🪄 Generate Image") {
                    isFocused = false
                    
                    let selectedImageRenderer = ImageRenderer(content: currentImage)
                    let maskRenderer = ImageRenderer(content: currentImage.reverseMask {
                        SwiftBetaCanvas(lines: $lines, currentLineWidth: 30)
                    })
                    
                    Task {
                        guard let selecteduiImage = selectedImageRenderer.uiImage,
                              let selectedPNGData = selecteduiImage.pngData(),
                              let maskuiImage = maskRenderer.uiImage,
                              let maskPNG = maskuiImage.pngData() else {
                            return
                        }
                        
                        self.viewModel.generateEdit(withText: text,
                                                    imageData: selectedPNGData,
                                                    maskData: maskPNG)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                Button("Reset") {
                    viewModel.imageURL = nil
                    selectedImage = nil
                    lines.removeAll()
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
            .padding(.vertical, 12)
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
