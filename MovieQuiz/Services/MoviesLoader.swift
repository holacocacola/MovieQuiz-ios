import Foundation

/*  В этом файле сервис для загрузки фильмов.
    Он будет загружать фильмы, используя NetworkClient, и преобразовывать
    их в модель данных MostPopularMovies.
 */

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    enum MoviesLoaderError: Error {
        case apiError(String)
        case emptyMoviesList
    }
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    private let decoder = JSONDecoder()

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            //Означает немедленно остановить приложение с ошибкой. Осознанный краш
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    // реализация загрузки фильмов
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        //получает результат, если data -> парсчит JSON. вызывает handler
        let fetchCompletion: (Result<Data, Error>) -> Void = { result in
            switch result {
            case Result.success(let data):
                do {
                    // декодируем MostPopularMovies
                    let movies = try decoder.decode(MostPopularMovies.self, from: data)
                    
                    // проверили errorMessage: если там не пусто — считаем это ошибкой
                    if !movies.errorMessage.isEmpty {
                        handler(Result.failure(MoviesLoaderError.apiError(movies.errorMessage)))
                    }
                    
                    // если items пустой — тоже считаем это ошибкой
                    if movies.items.isEmpty {
                        handler(Result.failure(MoviesLoaderError.emptyMoviesList))
                    }
                    
                    handler(Result.success(movies))
                } catch {
                    //print(error)
                    handler(Result.failure(error))
                }
            case Result.failure(let error):
                //print(error)
                handler(Result.failure(error))
            }

        }

        // выполнение сетевого запроса
        // берем URL > передаем его в NetworkClient
        // когда скачаете ответ, вызовите fetchCompletion
        networkClient.fetch(url: mostPopularMoviesUrl, handler: fetchCompletion)
    }
}
