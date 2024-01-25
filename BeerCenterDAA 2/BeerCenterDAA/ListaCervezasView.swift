import SwiftUI

struct FabricanteDetailView: View {
    var fabricante: Fabricante
    @ObservedObject var viewModel: BeerCenterViewModel
    @State private var showingAddCervezaView = false
    @State private var showingEditCervezaView = false
    @State private var selectedCerveza: Cerveza?
    @State private var sortOption: SortOption = .tipo
    @State private var isFavoritasExpanded = true
    @State private var isNoFavoritasExpanded = true
    @State private var isAscendenteOrder = true
    @State private var searchText = ""
    
    enum SortOption: String, CaseIterable {
        case nombre, graduacion, tipo, kcal
    }

    var body: some View {
        NavigationView {
            VStack{
                if viewModel.isLoading {
                    ProgressView("Cargando cervezas...")
                } else {
                    TextField("Buscar cervezas", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                    List {
                        DisclosureGroup("FAVORITAS", isExpanded: $isFavoritasExpanded) {
                            ForEach(filteredCervezas(isFavorite: true), id: \.id) { cerveza in
                                CervezaRow(cerveza: cerveza) {
                                    selectedCerveza = cerveza
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteCerveza(cerveza)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                    Button {
                                        selectedCerveza = cerveza
                                        showingEditCervezaView = true
                                    } label: {
                                        Label("Editar", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    Button {
                                        toggleFavorite(cerveza)
                                    } label: {
                                        let imageName = cerveza.is_fav ? "heart.slash" : "heart.fill"
                                        Image(systemName: imageName)
                                            .foregroundColor(.yellow)
                                    }.tint(.yellow)
                                }
                            }.font(.system(size: 18))
                        }.font(.system(size: 13))
                        
                        DisclosureGroup("NO FAVORITAS", isExpanded: $isNoFavoritasExpanded) {
                            ForEach(filteredCervezas(isFavorite: false), id: \.id) { cerveza in
                                CervezaRow(cerveza: cerveza) {
                                    selectedCerveza = cerveza
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteCerveza(cerveza)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                    Button {
                                        selectedCerveza = cerveza
                                        showingEditCervezaView = true
                                    } label: {
                                        Label("Editar", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    Button {
                                        toggleFavorite(cerveza)
                                    } label: {
                                        let imageName = cerveza.is_fav ? "heart.slash" : "heart.fill"
                                        Image(systemName: imageName)
                                            .foregroundColor(.yellow)
                                    }.tint(.yellow)
                                }
                            }.font(.system(size: 18))
                        }.font(.system(size: 13))
                    }
                    .onChange(of: selectedCerveza) { _ in
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            addButton
                                .tint(.blue)
                            sortMenu
                                .tint(.blue)
                        }
                    }
                    .fullScreenCover(isPresented: $showingAddCervezaView) {
                        AddCervezaView(isPresented: $showingAddCervezaView, fabricanteId: fabricante.id, viewModel: viewModel)
                    }
                    .fullScreenCover(isPresented: $showingEditCervezaView) {
                        if let selectedCerveza = selectedCerveza {
                            EditCervezaView(isPresented: $showingEditCervezaView, viewModel: viewModel, cerveza: selectedCerveza)
                                .onDisappear {
                                    viewModel.fetchCervezas(for: fabricante.id)
                                }
                        }
                    }
                }
            }
            .navigationTitle(fabricante.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .padding(.bottom, 8)
        }
        .onAppear {
            print("Fetching cervezas for fabricante: \(fabricante.nombre)")
                viewModel.fetchCervezas(for: fabricante.id)
                print("Cervezas loaded: \(viewModel.cervezas?.count ?? 0)")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(.bottom, 8)
    }


    private var addButton: some View {
        Button(action: {
            showingAddCervezaView = true
        }) {
            Image(systemName: "plus")
        }
    }

    private var sortMenu: some View {
            Menu {
                Picker("Ordenar", selection: $isAscendenteOrder) {
                    Text("Ascendente").tag(true)
                    Text("Descendente").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())

                Divider()

                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        if sortOption == option {
                            isAscendenteOrder.toggle()
                        } else {
                            isAscendenteOrder = true
                        }
                        sortOption = option
                    }) {
                        HStack {
                            Text(option.rawValue.capitalized)
                            if sortOption == option {
                                Image(systemName: isAscendenteOrder ? "arrow.up" : "arrow.down")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.blue)
            }
        }
    
    private func sortedCervezas(isFavorite: Bool) -> [Cerveza] {
        guard let cervezas = viewModel.cervezas else {
            return []
        }

        let filteredCervezas = cervezas.filter { $0.is_fav == isFavorite }

        switch sortOption {
        case .nombre:
            return filteredCervezas.sorted(by: { isAscendenteOrder ? $0.nombre < $1.nombre : $0.nombre > $1.nombre })
        case .graduacion:
            return filteredCervezas.sorted(by: { isAscendenteOrder ? $0.grados < $1.grados : $0.grados > $1.grados })
        case .tipo:
            return filteredCervezas.sorted(by: { isAscendenteOrder ? $0.tipo < $1.tipo : $0.tipo > $1.tipo })
        case .kcal:
            return filteredCervezas.sorted(by: { isAscendenteOrder ? $0.kcal < $1.kcal : $0.kcal > $1.kcal })
        }
    }

    private func filteredCervezas(isFavorite: Bool) -> [Cerveza] {
        guard let _ = viewModel.cervezas else {
            print("No cervezas available.")
            return []
        }

        print("Filtering cervezas for \(isFavorite ? "favoritas" : "no favoritas")")

        if searchText.isEmpty {
            return sortedCervezas(isFavorite: isFavorite)
        } else {
            let filtered = sortedCervezas(isFavorite: isFavorite).filter { cerveza in
                return cerveza.nombre.lowercased().contains(searchText.lowercased())
            }
            print("Filtered cervezas count: \(filtered.count)")
            return filtered
        }
    }

    
    private func deleteCerveza(_ cerveza: Cerveza) {
        viewModel.deleteCerveza(cervezaToDelete: cerveza)
    }

    private func toggleFavorite(_ cerveza: Cerveza) {
        viewModel.toggleFavorite(cerveza: cerveza)
    }
}

struct CervezaRow: View {
    let cerveza: Cerveza
    var onTapAction: () -> Void
    @State private var isCervezaDetailViewPresented = false

    var body: some View {
        Button(action: {
            onTapAction()
            isCervezaDetailViewPresented = true
        }) {
            HStack {
                logoView
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.3))

                VStack(alignment: .leading) {
                    Text(cerveza.nombre)
                        .foregroundColor(.black)
                }
            }
        }
        .fullScreenCover(isPresented: $isCervezaDetailViewPresented) {
            CervezaDetailView(cerveza: cerveza, isPresented: $isCervezaDetailViewPresented)
        }
    }

    @ViewBuilder
    private var logoView: some View {
        if let logoURL = cerveza.logoURL {
            if let url = URL(string: logoURL), logoURL.isValidURL {
                ZStack {
                    Color.white
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
                }
            } else if let imageData = Data(base64Encoded: logoURL), let uiImage = UIImage(data: imageData) {
                ZStack {
                    Color.white // Fondo blanco
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                fallbackImage
            }
        } else {
            fallbackImage
        }
    }

    private var fallbackImage: some View {
        ZStack {
            Color.white
            Image(systemName: "photo").foregroundColor(.gray)
        }
    }

}
