import SwiftUI

struct CervezaDetailView: View {
    let cerveza: Cerveza
    @Binding var isPresented: Bool
    @State private var image: Image?

    var body: some View {
        NavigationView{
            VStack(alignment: .center, spacing: 20) {
                ZStack {
                    HStack {
                        if cerveza.is_fav {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    
                    Text(cerveza.nombre.uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                
                if let logoURLString = cerveza.logoURL {
                    if let url = URL(string: logoURLString), logoURLString.isValidURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let loadedImage):
                                loadedImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            case .failure:
                                fallbackImage
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else if let base64Data = Data(base64Encoded: logoURLString),
                              let uiImage = UIImage(data: base64Data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else {
                        fallbackImage
                    }
                } else {
                    fallbackImage
                }
                
                Text(cerveza.tipo.capitalized)
                    .font(.headline)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción:")
                        .font(.headline)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    
                    Text(cerveza.descripcion)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Graduación: ")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    
                    Text(String(format: "%.1f", cerveza.grados))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("Kcal: ")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    
                    Text(String(format: cerveza.kcal.truncatingRemainder(dividingBy: 1.0) == 0.0 ? "%.0f" : "%.1f", cerveza.kcal))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                

                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Button("Cancelar") {
                self.isPresented = false
            })
        }
    }

    private var fallbackImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(height: 200)
            .foregroundColor(.gray)
    }
}
