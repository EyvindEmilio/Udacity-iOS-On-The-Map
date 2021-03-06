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
        static var objectId = ""
        static var lastLocationString = ""
        static var lastWeb = ""
    }

    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"

        case login
        case studentLocation
        case findStudentLocation(String)
        case postStudentLocation
        case putStudentLocation(String)
        case logout
        case user(String)

        var stringValue: String {
            switch self{
                case .login: return "\(Endpoints.base)/session"
                case .studentLocation: return "\(Endpoints.base)/StudentLocation?order=-updatedAt&limit=100"
                case .findStudentLocation(let uniqueKey): return "\(Endpoints.base)/StudentLocation?uniqueKey=\(uniqueKey)"
                case .postStudentLocation: return "\(Endpoints.base)/StudentLocation"
                case .putStudentLocation(let objectId): return "\(Endpoints.base)/StudentLocation/\(objectId)"
                case .logout: return "\(Endpoints.base)/session"
                case .user(let userId): return "\(Endpoints.base)/users/\(userId)"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    class func login(username: String, password: String, completion: @escaping (Bool, String?, Error?) -> Void){

        let body = LoginRequest(udacity: LoginRequest.CredentialsField(username: username, password: password))

        taskForPOSTRequest(url: Endpoints.login.url, body: body) { data, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(false, nil, error) }
                return
            }

            let newData = data.subdata(in: 5..<data.count)
            let jsonDecoder = JSONDecoder()
            do {
              let successBody = try jsonDecoder.decode(LoginResponse.self, from: newData)
                RestClient.Auth.sessionId = successBody.session.id
                RestClient.Auth.accountKey = successBody.account.key
                DispatchQueue.main.async { completion(true, nil, nil) }
            } catch {
                do {
                    let errorBody = try jsonDecoder.decode(ErrorResponse.self, from: newData)
                    DispatchQueue.main.async { completion(false, errorBody.error, nil) }
                } catch {
                    DispatchQueue.main.async { completion(false, nil, error) }
                }
            }
        }
    }

    class func loadStudentLocations(completion: @escaping ([StudentLocation], Error?) -> Void) -> URLSessionDataTask {
        debugPrint(Endpoints.studentLocation.url)
       return taskForGETRequest(url: Endpoints.studentLocation.url, responseType: StudemtLocationResponse.self) { studentLocations, error in
            if let studentLocations = studentLocations {
                DispatchQueue.main.async { completion(studentLocations.results,nil) }
            } else {
                DispatchQueue.main.async { completion([], error) }
            }
        }
    }

    class func checkStudentLocation(uniqueKey:String, completion: @escaping (Bool, Error?) -> Void) -> URLSessionDataTask {

       return taskForGETRequest(url: Endpoints.findStudentLocation(uniqueKey).url, responseType: StudemtLocationResponse.self) { studentLocations, error in

            if let studentLocations = studentLocations {
                if studentLocations.results.count > 0 {
                    Auth.objectId = studentLocations.results[0].objectId
                    Auth.lastLocationString = studentLocations.results[0].mapString
                    Auth.lastWeb = studentLocations.results[0].mediaURL
                }
                DispatchQueue.main.async { completion(studentLocations.results.count != 0, nil) }
            } else {
                DispatchQueue.main.async { completion(false, error) }
            }
        }
    }

    class func loadUserInfo(userId: String, completion: @escaping (UserResponse?, Error?) -> Void){
        taskForGETRequest(url: Endpoints.user(userId).url, responseType: UserResponse.self) { userInfo, error in
            if let userInfo = userInfo {
                DispatchQueue.main.async { completion(userInfo, nil) }
            } else {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
    }


    class func postLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void) {
        let body = PostLocationRequest(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)

        taskForPOSTRequest(url: Endpoints.postStudentLocation.url, body: body) { data, error in
            guard let _ = data else {
                DispatchQueue.main.async { completion(false, error) }
                return
            }

            let jsonDecoder = JSONDecoder()
            do {
              let successBody = try jsonDecoder.decode(PostLocationResponse.self, from: data!)
                Auth.objectId = successBody.objectId
                Auth.lastLocationString = mapString
                Auth.lastWeb = mediaURL
                DispatchQueue.main.async { completion(true, nil) }
            } catch {
                do {
                    let errorBody = try jsonDecoder.decode(ErrorResponse.self, from: data!)
                    DispatchQueue.main.async { completion(false, MessageError(errorBody.error)) }
                } catch {
                    DispatchQueue.main.async { completion(false, error) }
                }
            }
        }
    }

    class func putLocation(objectId: String, uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void) {
        let body = PostLocationRequest(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)

        taskForPUTRequest(url: Endpoints.putStudentLocation(objectId).url, body: body) { data, error in
            guard let _ = data else {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            Auth.lastLocationString = mapString
            Auth.lastWeb = mediaURL
            DispatchQueue.main.async { completion(true, nil) }
        }
    }

    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            let newData = data?.subdata(in: 5..<data!.count)
            debugPrint(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async { completion(true, nil) }
        }
        task.resume()
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

    @discardableResult class func taskForPUTRequest<RequestType: Encodable>(url: URL, body: RequestType, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {

        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
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
