import Foundation

struct ApiResponse: Codable {
    var fabricantes: [Fabricante]
    var message: String
}

struct CervezaResponse: Codable {
    let cervezas: [Cerveza]?
    let message: String
}

struct CervezaRequest: Codable {
    let id_fabricante: String
    let nombre: String
    let tipo: String
    let logo: String
    let descripcion: String
    let grados: Float
    let kcal: Float
}

struct UpdateCervezaRequest: Codable {
    let id_cerveza: String
    let nombre: String
    let tipo: String
    let logo: String
    let descripcion: String
    let grados: Float
    let kcal: Float
}

struct FavoriteRequest: Codable {
    let id_cerveza: String
}


class APIService {
    static let shared = APIService()
    private let apiKey = "aa22eeda-2e6d-475b-904c-cf46c49eaa34"
    
    private let baseURL = "http://143.47.45.118:6969/daa-api/v1"
    
    // MARK: - Fabricante Endpoints
    
    func fetchFabricantes(completion: @escaping (Result<[Fabricante], Error>) -> Void) {
        let urlString = "\(baseURL)/fabricante/getFabricantes"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.cannotDecodeContentData)))
                return
            }
            do {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response string: \(responseString)")
                }

                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                completion(.success(decodedResponse.fabricantes))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    
    func addFabricante(name: String, logo: String, tipo: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/fabricante/addFabricante"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "nombre": name,
            "logo": logo, // asumiendo que 'logo' es una cadena base64 o una URL
            "tipo": tipo
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(.failure(APIError.encodingError))
            return
        }

        request.httpBody = bodyData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(APIError.urlError(error as? URLError ?? URLError(.unknown))))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.unknownError))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.decodingError))
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }

    func deleteFabricante(idFabricante: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(baseURL)/fabricante/deleteFabricante"
        var components = URLComponents(string: urlString)
        components?.queryItems = [URLQueryItem(name: "id_fabricante", value: idFabricante)]

        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
            
            // Imprimir la respuesta del servidor
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response from server: \(responseString)")
            }
        }.resume()
    }

    // MARK: - Cerveza Endpoints
    
    func getCervezas(idFabricante: String, completion: @escaping (Result<CervezaResponse, Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)/cerveza/getCervezas")
        components?.queryItems = [URLQueryItem(name: "id_fabricante", value: idFabricante)]
        
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response string: \(responseString)")
            }
            
            guard let responseData = data else {
                completion(.failure(URLError(.cannotDecodeContentData)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CervezaResponse.self, from: responseData)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addCerveza(cerveza: CervezaRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(baseURL)/cerveza/addCerveza"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(cerveza) else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to encode cerveza data"])
            completion(.failure(error))
            return
        }
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON String: \(jsonString)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    completion(.success(true))
                default:
                    let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No response body"
                    print("Response Body: \(responseBody)")
                    let serverError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])
                    completion(.failure(serverError))
                }
            }
        }.resume()
    }
    
    func deleteCerveza(idCerveza: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(baseURL)/cerveza/deleteCerveza"
        var components = URLComponents(string: urlString)
        components?.queryItems = [URLQueryItem(name: "id_cerveza", value: idCerveza)]

        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
        }.resume()
    }
    
    func updateCerveza(cerveza: UpdateCervezaRequest, completion: @escaping (Result<CervezaResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/cerveza/updateCerveza"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(cerveza)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.unknownError))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }

            // Registro de la respuesta
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8)
                print("Respuesta del servidor: \(responseString ?? "")")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(CervezaResponse.self, from: data ?? Data())
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func updateFavoriteCerveza(idCerveza: String, completion: @escaping (Result<[Cerveza], Error>) -> Void) {
        let urlString = "\(baseURL)/cerveza/favCerveza"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let favoriteRequest = FavoriteRequest(id_cerveza: idCerveza)

        do {
            let jsonData = try JSONEncoder().encode(favoriteRequest)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.unknownError))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(CervezaResponse.self, from: data ?? Data())
                completion(.success(decodedResponse.cervezas ?? []))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    enum APIError: Error {
        case urlError(URLError)
        case encodingError
        case decodingError
        case serverError(statusCode: Int)
        case unknownError
    }
}
