import SwiftUI

struct EditCervezaView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: BeerCenterViewModel
    @Environment(\.presentationMode) var presentationMode
    var cerveza: Cerveza

    @State private var nombre: String
    @State private var tipo: String
    @State private var logo: String
    @State private var descripcion: String
    @State private var grados: String
    @State private var kcal: String
    @State private var logoOption: LogoOption = .url
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false

    let beerTypes = ["Pilsen", "Amber", "IPA", "Porter", "Lager"]

    enum LogoOption {
        case url, upload
    }

    init(isPresented: Binding<Bool>, viewModel: BeerCenterViewModel, cerveza: Cerveza) {
        self._isPresented = isPresented
        self._viewModel = ObservedObject(initialValue: viewModel)
        self.cerveza = cerveza
        self._nombre = State(initialValue: cerveza.nombre)
        self._tipo = State(initialValue: cerveza.tipo.lowercased())
        self._logo = State(initialValue: cerveza.logoURL ?? "")
        self._descripcion = State(initialValue: cerveza.descripcion)
        self._grados = State(initialValue: "\(cerveza.grados)")
        self._kcal = State(initialValue: "\(cerveza.kcal)")
        
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Cerveza")) {
                    TextField("Nombre", text: $nombre)
                    Picker("Tipo", selection: $tipo) {
                        ForEach(beerTypes, id: \.self) { type in
                            Text(type.capitalized)
                                .tag(type.lowercased())
                        }
                    }
                    .onChange(of: tipo) { newValue in
                        tipo = newValue.lowercased()
                    }

                    TextField("Descripción", text: $descripcion)
                    TextField("Grados Alcohólicos", text: $grados)
                        .keyboardType(.decimalPad)
                    TextField("kcal", text: $kcal)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Logo de la Cerveza")) {
                    Picker("Añadir logo desde:", selection: $logoOption) {
                        Text("URL").tag(LogoOption.url)
                        Text("Subir Imagen").tag(LogoOption.upload)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if logoOption == .url {
                        TextField("URL del logo", text: $logo)
                    } else {
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            Text(selectedImage != nil ? "Cambiar Imagen" : "Seleccionar Imagen")
                        }

                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }

                Button("Actualizar") {
                    guard let gradosInt = Float(grados), let kcalInt = Float(kcal) else {
                        print("Error: Los grados y kcal deben ser números.")
                        return
                    }

                    var logoFinal = logo
                    if logoOption == .upload, let selectedImage = selectedImage {
                        logoFinal = convertImageToBase64String(img: selectedImage)
                    }

                    let cervezaActualizada = UpdateCervezaRequest(
                        id_cerveza: cerveza.id,
                        nombre: nombre,
                        tipo: tipo,
                        logo: logoFinal,
                        descripcion: descripcion,
                        grados: gradosInt,
                        kcal: kcalInt
                    )

                    viewModel.updateCerveza(updateRequest: cervezaActualizada)
                    presentationMode.wrappedValue.dismiss()
                }

            }
            .navigationBarTitle("Editar Cerveza", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancelar") {
                self.isPresented = false
            })
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
            }
        }
    }

    private func convertImageToBase64String(img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.1)?.base64EncodedString() ?? ""
    }
}
