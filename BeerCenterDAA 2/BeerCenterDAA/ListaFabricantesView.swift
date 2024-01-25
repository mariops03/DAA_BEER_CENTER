import SwiftUI

struct FabricantesListView: View {
    @StateObject var viewModel = BeerCenterViewModel()
    @State private var isNacionalesExpanded = true
    @State private var isImportadosExpanded = true
    @State private var showingAddFabricanteView = false
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView("Cargando...")
            } else {
                List {
                    DisclosureGroup("NACIONALES", isExpanded: $isNacionalesExpanded) {
                        ForEach(viewModel.fabricantesNacionales) { fabricante in
                            NavigationLink(destination: FabricanteDetailView(fabricante: fabricante, viewModel: viewModel)) {
                                FabricanteRow(fabricante: fabricante)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteFabricante(fabricanteToDelete: fabricante)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                            .font(.system(size: 13))
                        }
                    }
                    
                    DisclosureGroup("IMPORTADOS", isExpanded: $isImportadosExpanded) {
                        ForEach(viewModel.fabricantesImportados) { fabricante in
                            NavigationLink(destination: FabricanteDetailView(fabricante: fabricante, viewModel: viewModel)) {
                                FabricanteRow(fabricante: fabricante)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteFabricante(fabricanteToDelete: fabricante)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                            .font(.system(size: 13))
                        }
                    }
                }
                
                .navigationBarItems(trailing: Button(action: {
                    showingAddFabricanteView = true
                }) {
                    Image(systemName: "plus")
                })
                .fullScreenCover(isPresented: $showingAddFabricanteView) {
                    AddFabricanteView(isPresented: $showingAddFabricanteView, viewModel: viewModel)
                }
            }
            
        }.navigationTitle("Fabricantes")
    }
    
    struct FabricanteRow: View {
        let fabricante: Fabricante
        
        var body: some View {
            HStack {
                logoView
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(fabricante.nombre)
                }
            }
        }
        
        @ViewBuilder
        private var logoView: some View {
            ZStack {
                Color.white
                
                if let logoURL = fabricante.logoURL {
                    if logoURL.isValidURL {
                        
                        if let url = URL(string: logoURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fit)
                                case .failure:
                                    fallbackImage
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            fallbackImage
                        }
                    } else {
                        if let imageData = Data(base64Encoded: logoURL), let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                        } else {
                            fallbackImage
                        }
                    }
                } else {
                    fallbackImage
                }
            }
        }
        
        private var fallbackImage: some View {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray)
        }
        
    }
    
    struct FabricantesListView_Previews: PreviewProvider {
        static var previews: some View {
            FabricantesListView()
        }
    }
}
