import Foundation

class BeerCenterViewModel: ObservableObject {
    @Published var fabricantes: [Fabricante] = []
    @Published var cervezas: [Cerveza]? = []
    @Published var isLoading: Bool = false
    
    var fabricantesNacionales: [Fabricante] {
        fabricantes.filter { $0.tipo == "nacionales" }
    }
    
    var fabricantesImportados: [Fabricante] {
        fabricantes.filter { $0.tipo == "importadas" }
    }
    
    
    init() {
        fetchFabricantes()
    }
    
    func fetchFabricantes() {
        isLoading = true

        APIService.shared.fetchFabricantes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fabricantes):
                    self?.fabricantes = fabricantes
                case .failure(let error):
                    print("Error fetching fabricantes: \(error)")
                }
                self?.isLoading = false
            }
        }
    }

    func addManufacturer(_ fabricante: Fabricante) {
        APIService.shared.addFabricante(name: fabricante.nombre, logo: fabricante.logoURL ?? "", tipo: fabricante.tipo) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.fabricantes.append(fabricante)
                    print("Fabricante añadido con éxito: \(response.message)")
                case .failure(let error):
                    // Manejar el error
                    print("Error al añadir fabricante: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchCervezas(for idFabricante: String) {
        isLoading = true
        APIService.shared.getCervezas(idFabricante: idFabricante) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cervezaResponse):
                    self?.cervezas = cervezaResponse.cervezas
                    print("Cervezas assigned: \(self?.cervezas?.count ?? 0)")
                case .failure(let error):
                    print("Error fetching cervezas: \(error)")
                }
                self?.isLoading = false
            }
        }
    }
    
    func addCerveza(cerveza: CervezaRequest) {
        APIService.shared.addCerveza(cerveza: cerveza) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let idFabricante = cerveza.id_fabricante
                    self?.fetchCervezas(for: idFabricante)
                case .failure(let error):
                    print("Error adding cerveza: \(error)")
                }
            }
        }
    }
    
    func deleteFabricante(fabricanteToDelete: Fabricante) {
        APIService.shared.deleteFabricante(idFabricante: fabricanteToDelete.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.fabricantes.firstIndex(where: { $0.id == fabricanteToDelete.id }) {
                        self.fabricantes.remove(at: index)
                        print("Fabricante eliminado con éxito.")
                    }
                case .failure(let error):
                    print("Error al eliminar fabricante: \(error)")
                }
            }
        }
    }


    func updateCerveza(updateRequest: UpdateCervezaRequest) {
        isLoading = true
        APIService.shared.updateCerveza(cerveza: updateRequest) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cervezaResponse):
                    print("Cerveza actualizada con éxito. Mensaje: \(cervezaResponse.message)")
                case .failure(let error):
                    print("Error al actualizar cerveza: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }

    
    func deleteCerveza(cervezaToDelete: Cerveza) {
        APIService.shared.deleteCerveza(idCerveza: cervezaToDelete.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Cerveza eliminada con éxito.")
                case .failure(let error):
                    print("Error al eliminar cerveza: \(error)")
                }
            }
        }
    }
    
    func toggleFavorite(cerveza: Cerveza) {
        let idCerveza = cerveza.id

        APIService.shared.updateFavoriteCerveza(idCerveza: idCerveza) { result in
            switch result {
            case .success(let updatedCervezas):
                print("Estado de favorito actualizado con éxito.")
                self.cervezas = updatedCervezas

            case .failure(let error):
                print("Error al actualizar el estado de favorito: \(error)")
            }
        }
    }
}

