import Foundation
import UIKit

struct Fabricante: Identifiable, Codable {
    var id: String
    var nombre: String
    var tipo: String
    var logoURL: String?
    var cervezas: [Cerveza]?

    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, cervezas
        case logoURL = "logo"
    }
}

struct Cerveza: Identifiable, Codable, Equatable {
    var id: String
    var nombre: String
    var tipo: String
    var logoURL: String?
    var descripcion: String
    var grados: Float
    var is_fav: Bool
    var kcal: Float

    enum CodingKeys: String, CodingKey {
        case id, nombre, tipo, descripcion, grados, is_fav, kcal
        case logoURL = "logo"
    }
}

