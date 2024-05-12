//
//  HomeView.swift
//  photoEditor
//
//  Created by Вадим on 11.05.2024.
//

import SwiftUI

typealias CGOffset = CGSize

class HomeViewModel: ObservableObject {
    @Published var imagePicker = false
    @Published var imageData = Data(count: 0)
}

struct HomeView: View {
    
    @StateObject var homeData = HomeViewModel()
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGSize = .zero
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGSize = .zero
    
    var body: some View {
        VStack {
            Spacer()
            if let imageFile = UIImage(data: homeData.imageData) {
                Image(uiImage: imageFile)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
                    .gesture(panGesture.simultaneously(with: zoomGesture))
            } else {
                Text("Pick Image")
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    homeData.imagePicker.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $homeData.imagePicker) {
            ImagePicker(
                showPicker: $homeData.imagePicker,
                imageData: $homeData.imageData
            )
        }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { value in
                zoom *= value
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
}

#Preview {
    HomeView()
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var showPicker: Bool
    @Binding var imageData: Data
    
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let imageData = (info[.originalImage] as? UIImage)?.pngData() {
                Task {
                    parent.imageData = imageData
                    parent.showPicker.toggle()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.showPicker.toggle()
        }
    }
}

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func +=(lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
}
