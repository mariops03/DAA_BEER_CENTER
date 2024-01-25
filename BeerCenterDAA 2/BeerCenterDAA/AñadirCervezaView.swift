import SwiftUI
import PhotosUI

struct AddCervezaView: View {
    @Binding var isPresented: Bool
    var fabricanteId: String
    @ObservedObject var viewModel: BeerCenterViewModel
    @State private var nombre: String = ""
    @State private var tipo: String = ""
    @State private var logo: String = ""
    @State private var descripcion: String = ""
    @State private var grados: String = ""
    @State private var kcal: String = ""
    @State private var logoOption: LogoOption = .url
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false

    let beerTypes = ["pilsen", "amber", "ipa", "porter", "lager"]

    enum LogoOption {
        case url, upload
    }

    var body: some View {
            NavigationView {
                Form {
                    TextField("Nombre", text: $nombre)
                    Picker("Tipo", selection: $tipo) {
                        Text("Selecciona un tipo").tag("")
                        ForEach(beerTypes, id: \.self) { type in
                            Text(type.capitalized)
                        }
                    }
                    Section {
                        Picker("Añadir logo desde:", selection: $logoOption) {
                            Text("URL").tag(LogoOption.url)
                            Text("Galería").tag(LogoOption.upload)
                        }
                    
                    if logoOption == .url {
                        TextField("URL del logo", text: $logo)
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
                TextField("Descripción", text: $descripcion)
                TextField("Grados", text: $grados)
                    .keyboardType(.decimalPad)
                TextField("Kcal", text: $kcal)

                Button("Guardar") {
                    guard let gradosInt = Float(grados), let kcalInt = Float(kcal), !nombre.isEmpty, !tipo.isEmpty, !descripcion.isEmpty else {
                        print("Por favor, rellena todos los campos correctamente.")
                        return
                    }

                    let logoRepresentation: String
                    if logoOption == .upload, let selectedImage = selectedImage {
                        logoRepresentation = selectedImage.jpegData(compressionQuality: 0.0)?.base64EncodedString() ?? ""
                    } else {
                        logoRepresentation = logo
                    }

                    let nuevaCerveza = CervezaRequest(
                        id_fabricante: fabricanteId,
                        nombre: nombre,
                        tipo: tipo,
                        logo: logoRepresentation,
                        descripcion: descripcion,
                        grados: gradosInt,
                        kcal: kcalInt
                    )
                    
                    viewModel.addCerveza(cerveza: nuevaCerveza)
                    self.isPresented = false
                }
            }
            .navigationBarTitle("Añadir Cerveza", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancelar") {
                self.isPresented = false
            })
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}
