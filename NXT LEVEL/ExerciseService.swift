import Foundation

struct APIExercise: Codable {
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String
}

enum ExerciseServiceError: Error {
    case missingAPIKey
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
}

class ExerciseService: ObservableObject {
    private let apiKey = "2qCf4A5+6sr1N5hJBHqfzA==0Naa8Jfocqh0rWsm"  // Replace with your actual API Ninjas key
    private let baseURL = "https://api.api-ninjas.com/v1/exercises"
    
    @Published var exercises: [APIExercise] = []
    
    init() {
        // Initialize with API key from environment or configuration
        print("ExerciseService initialized with API key: \(apiKey.isEmpty ? "MISSING" : "PRESENT")")
    }
    
    func fetchExercises(for muscle: String) async throws -> [APIExercise] {
        print("Fetching exercises for muscle: \(muscle)")
        
        guard !apiKey.isEmpty else {
            print("Error: API key is missing")
            throw ExerciseServiceError.missingAPIKey
        }
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            print("Error: Invalid base URL")
            throw ExerciseServiceError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "muscle", value: muscle)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Could not construct URL with components")
            throw ExerciseServiceError.invalidURL
        }
        
        print("Making request to URL: \(url)")
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response type")
                throw ExerciseServiceError.invalidResponse
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("Error: Server returned status code \(httpResponse.statusCode)")
                if let errorMessage = String(data: data, encoding: .utf8) {
                    print("Server response: \(errorMessage)")
                }
                throw ExerciseServiceError.invalidResponse
            }
            
            do {
                let exercises = try JSONDecoder().decode([APIExercise].self, from: data)
                print("Successfully decoded \(exercises.count) exercises")
                return exercises
            } catch {
                print("Error decoding response: \(error)")
                throw ExerciseServiceError.decodingError(error)
            }
        } catch {
            print("Network error: \(error)")
            throw ExerciseServiceError.networkError(error)
        }
    }
    
    // Helper method to get exercises for specific workout types
    func getExercisesForPushDay() async throws -> [APIExercise] {
        print("Getting exercises for Push day")
        var pushExercises: [APIExercise] = []
        
        do {
            // Fetch exercises for each muscle group
            let chestExercises = try await fetchExercises(for: "chest")
            let shoulderExercises = try await fetchExercises(for: "shoulders")
            let tricepsExercises = try await fetchExercises(for: "triceps")
            
            pushExercises.append(contentsOf: chestExercises)
            pushExercises.append(contentsOf: shoulderExercises)
            pushExercises.append(contentsOf: tricepsExercises)
            
            print("Total Push exercises found: \(pushExercises.count)")
            return pushExercises
        } catch {
            print("Error getting Push day exercises: \(error)")
            throw error
        }
    }
    
    func getExercisesForPullDay() async throws -> [APIExercise] {
        print("Getting exercises for Pull day")
        var pullExercises: [APIExercise] = []
        
        do {
            let backExercises = try await fetchExercises(for: "lats")
            let bicepsExercises = try await fetchExercises(for: "biceps")
            
            pullExercises.append(contentsOf: backExercises)
            pullExercises.append(contentsOf: bicepsExercises)
            
            print("Total Pull exercises found: \(pullExercises.count)")
            return pullExercises
        } catch {
            print("Error getting Pull day exercises: \(error)")
            throw error
        }
    }
    
    func getExercisesForLegDay() async throws -> [APIExercise] {
        print("Getting exercises for Leg day")
        var legExercises: [APIExercise] = []
        
        do {
            let quadsExercises = try await fetchExercises(for: "quadriceps")
            let hamstringsExercises = try await fetchExercises(for: "hamstrings")
            let calvesExercises = try await fetchExercises(for: "calves")
            
            legExercises.append(contentsOf: quadsExercises)
            legExercises.append(contentsOf: hamstringsExercises)
            legExercises.append(contentsOf: calvesExercises)
            
            print("Total Leg exercises found: \(legExercises.count)")
            return legExercises
        } catch {
            print("Error getting Leg day exercises: \(error)")
            throw error
        }
    }
} 