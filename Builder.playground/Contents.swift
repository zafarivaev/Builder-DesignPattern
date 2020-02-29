import UIKit
import PlaygroundSupport

enum Method: String {
    case GET
    case POST
}

struct RequestBaseUrls {
    static let gitHub = "https://api.github.com"
}

struct RequestEndpoints {
    static let searchRepositories = "/search/repositories"
}

// MARK: - Builder
class RequestBuilder {
    private(set) var baseURL: URL!
    private(set) var endpoint: String = ""
    private(set) var method: Method = .GET
    private(set) var headers: [String: String] = [:]
    private(set) var parameters: [String: String] = [:]
    
    public func setBaseUrl(_ string: String) {
        baseURL = URL(string: string)!
    }
    public func setEndpoint(_ value: String) {
        endpoint = value
    }
    public func setMethod(_ value: Method) {
        method = value
    }
    public func addHeader(_ key: String, _ value: String) {
        headers[key] = value
    }
    public func addParameter(_ key: String, _ value: String) {
        parameters[key] = value
    }
    
    public func build() -> URLRequest {
        assert(baseURL != nil)
        let url = baseURL.appendingPathComponent(endpoint)
        var components = URLComponents(string: url.absoluteString)
        
        components?.queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        
        var urlRequest = URLRequest(url: components!.url!)
        urlRequest.httpMethod = method.rawValue
        
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return urlRequest
    }
}

class TaskBuilder {
    private(set) var request: URLRequest!
    
    public func setRequest(_ request: URLRequest) {
        self.request = request
    }
    
    public func build() -> URLSessionDataTask {
        assert(request != nil)
        return URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data,
                   let response = response as? HTTPURLResponse,
                   (200 ..< 300) ~= response.statusCode,
                   error == nil else {
                       return
               }
               
            if let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
               print(responseObject)
            }
        }
    }
}

// MARK: - Director
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestBuilder = RequestBuilder()
        requestBuilder.setBaseUrl(RequestBaseUrls.gitHub)
        requestBuilder.setEndpoint(RequestEndpoints.searchRepositories)
        requestBuilder.setMethod(.GET)
        requestBuilder.addHeader("Content-Type", "application/json")
        requestBuilder.addParameter("q", "Builder Design Pattern")
        let request = requestBuilder.build()

        let taskBuilder = TaskBuilder()
        taskBuilder.setRequest(request)
        let task = taskBuilder.build()

        task.resume()
    }
}

let viewController = ViewController()
PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
