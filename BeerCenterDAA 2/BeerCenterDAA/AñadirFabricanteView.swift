import SwiftUI
import PhotosUI

struct AddFabricanteView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: BeerCenterViewModel
    @State private var logoOption: LogoOption = .url
    @State private var logoURL: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var manufacturerName: String = ""
    @State private var manufacturerType: ManufacturerType = .national
    
    enum LogoOption {
        case url, upload
    }
    
    enum ManufacturerType: String, CaseIterable {
        case imported = "Importadas"
        case national = "Nacionales"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nombre del fabricante", text: $manufacturerName)
                    
                    Picker("Tipo de fabricante", selection: $manufacturerType) {
                        ForEach(ManufacturerType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                }
                
                Section {
                    Picker("Añadir logo desde:", selection: $logoOption) {
                        Text("URL").tag(LogoOption.url)
                        Text("Galería").tag(LogoOption.upload)
                    }
                    
                    if logoOption == .url {
                        TextField("URL del logo", text: $logoURL)
                    } else {
                        Button("Selecciona una imagen") {
                            isImagePickerPresented = true
                        }
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                
                Button("Añadir fabricante") {
                    addManufacturer()
                }
            }
            .navigationBarTitle("Añadir Fabricante", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancelar") {
                self.isPresented = false
            })
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func addManufacturer() {
        guard !manufacturerName.isEmpty else {
            return
        }

        let logoRepresentation: String
        if logoOption == .upload, let selectedImage = selectedImage {
            logoRepresentation = selectedImage.jpegData(compressionQuality: 0.0)?.base64EncodedString() ?? ""
        } else {
            logoRepresentation = logoURL
        }

        let newManufacturer = Fabricante(
            id: UUID().uuidString,
            nombre: manufacturerName,
            tipo: manufacturerType.rawValue.lowercased(),
            logoURL: logoRepresentation,
            cervezas: nil
        )

        viewModel.addManufacturer(newManufacturer)

        self.isPresented = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

struct AddFabricanteView_Previews: PreviewProvider {
    static var previews: some View {
        AddFabricanteView(isPresented: .constant(true), viewModel: BeerCenterViewModel())
    }
}
