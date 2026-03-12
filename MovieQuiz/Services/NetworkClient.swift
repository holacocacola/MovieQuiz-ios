import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    // загружает что-то по заданному URL. работает асинхронно
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        //print("fetch стартанул с url = \(request)")
        // data     -> данные ответа
        // response -> HTTP ответ
        // error    -> ошибка сети
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //print("data = \(data), \nresponse = \(response), \nerror = \(error)")
            
            // Проверяем пришло ли вообще что-то(или ошибка сети, таймаут и тп)
            if let error = error {
                handler(Result.failure(error))
                return
            }
            
            // Ответ получен. Проверяем что он там прислал. Если ошибку, то отдаем ошибку
            if let http = response as? HTTPURLResponse {
                //print("http.statusCode: \(http.statusCode)")
                if http.statusCode < 200 || http.statusCode >= 300 {
                    handler(Result.failure(NetworkError.codeError))
                    return
                }
            }
            

            // Проверяем пришли ли сами данные. Если сервер не прислал тело ответа - просто выходим.
            guard let data = data else { return }
            // если все норм, то отдаем успех
            handler(Result.success(data))
            
        }
        
        // запуск задачи
        task.resume()
    }
}
