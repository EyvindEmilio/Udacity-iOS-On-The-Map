//
//  RestClient.swift
//  On the map
//
//  Created by Eyvind on 17/5/22.
//

import Foundation

class RestClient{
    
    struct Auth {
        static var sessionId = ""
        static var accountKey = ""
    }
    
    enum Endpoints {
        case login
        
        var stringValue: String {
            switch self{
                case .login: return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }

    class func login(username: String, password: String, completion: @escaping (Bool, String?, Error?) -> Void){
        
        let body = LoginRequest(udacity: LoginRequest.CredentialsField(username: username, password: password))
          
        taskForPOSTRequest(url: Endpoints.login.url, body: body) { data, error in
            let newData = data?.subdata(in: 5..<data!.count)
            let jsonDecoder = JSONDecoder()
            do {
              let successBody = try jsonDecoder.decode(LoginResponse.self, from: newData!)
                RestClient.Auth.sessionId = successBody.session.id
                RestClient.Auth.accountKey = successBody.account.key
                DispatchQueue.main.async { completion(true, nil, nil) }
            } catch {
                do {
                    let errorBody = try jsonDecoder.decode(LoginErrorResponse.self, from: newData!)
                    DispatchQueue.main.async { completion(false, errorBody.error, nil) }
                } catch {
                    DispatchQueue.main.async { completion(false, nil, error) }
                }
            }
        }
    
    }
    
    
    @discardableResult class func taskForPOSTRequest<RequestType: Encodable>(url: URL, body: RequestType, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! encoder.encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            DispatchQueue.main.async { completion(data, nil) }
        }
        task.resume()
        return task
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) ->  URLSessionDataTask{
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async { completion(responseObject, nil) }
            } catch {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        task.resume()
        return task
    }
}
