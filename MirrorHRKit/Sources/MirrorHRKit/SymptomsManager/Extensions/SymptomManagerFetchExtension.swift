import Foundation
import CoreData
import SharedPkg
import OSLog

/// Extension for SymptomsManager containing optimized fetch operations
extension SymptomsManager {
    
    /// Fetches symptoms data with pagination support for better performance with large datasets
    /// - Parameters:
    ///   - page: The page number to fetch (0-based)
    ///   - pageSize: Number of items per page
    ///   - sortDescriptor: Optional sort descriptor for the results
    ///   - predicate: Optional predicate to filter results
    ///   - completion: Callback with fetched symptoms or error
    public func fetchPaginated(
        page: Int = 0,
        pageSize: Int = 50,
        sortDescriptor: NSSortDescriptor? = nil,
        predicate: NSPredicate? = nil,
        completion: @escaping (Result<[SymptomsData], Error>) -> Void
    ) {
        let backgroundContext = PersistenceController.shared.createBackgroundContext()
        
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<SymptomsData>(entityName: "SymptomsData")
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = page * pageSize
            
            // Apply sort descriptor or default to start date descending
            if let sortDescriptor = sortDescriptor {
                fetchRequest.sortDescriptors = [sortDescriptor]
            } else {
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            }
            
            // Apply filter if provided
            if let predicate = predicate {
                fetchRequest.predicate = predicate
            }
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                self.logger.debug("Fetched \(results.count) symptoms for page \(page)")
                
                DispatchQueue.main.async {
                    completion(.success(results))
                }
            } catch {
                let nsError = error as NSError
                let msg = "Paginated fetch error: \(nsError), \(nsError.userInfo)"
                self.logger.error("\(msg)")
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetches the total count of symptoms with optional filtering
    /// - Parameters:
    ///   - predicate: Optional predicate to filter the count
    ///   - completion: Callback with count or error
    public func fetchTotalCount(
        predicate: NSPredicate? = nil,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let backgroundContext = PersistenceController.shared.createBackgroundContext()
        
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSNumber>(entityName: "SymptomsData")
            fetchRequest.resultType = .countResultType
            
            if let predicate = predicate {
                fetchRequest.predicate = predicate
            }
            
            do {
                let count = try backgroundContext.count(for: fetchRequest)
                self.logger.debug("Symptom count: \(count)")
                
                DispatchQueue.main.async {
                    completion(.success(count))
                }
            } catch {
                let nsError = error as NSError
                let msg = "Count fetch error: \(nsError), \(nsError.userInfo)"
                self.logger.error("\(msg)")
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Performs a search for symptoms with better performance
    /// - Parameters:
    ///   - searchText: The text to search for
    ///   - limit: Maximum number of results to return
    ///   - completion: Callback with search results
    public func performOptimizedSearch(
        searchText: String,
        limit: Int = 100,
        completion: @escaping (Result<[SymptomsData], Error>) -> Void
    ) {
        guard !searchText.isEmpty else {
            DispatchQueue.main.async {
                completion(.success([]))
            }
            return
        }
        
        let backgroundContext = PersistenceController.shared.createBackgroundContext()
        
        backgroundContext.perform {
            // Create a compound predicate for the search
            let searchPredicates: [NSPredicate] = [
                NSPredicate(format: "symptom CONTAINS[cd] %@", searchText),
                NSPredicate(format: "notes CONTAINS[cd] %@", searchText)
            ]
            
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchPredicates)
            
            let fetchRequest = NSFetchRequest<SymptomsData>(entityName: "SymptomsData")
            fetchRequest.predicate = compoundPredicate
            fetchRequest.fetchLimit = limit
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                self.logger.debug("Search found \(results.count) results for '\(searchText)'")
                
                DispatchQueue.main.async {
                    completion(.success(results))
                }
            } catch {
                self.logger.error("Search error: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetches top logged symptoms efficiently
    /// - Parameter completion: Callback with results
    public func fetchTopLoggedSymptomsOptimized(completion: @escaping ([HandledSymptomsEvents]) -> Void) {
        let backgroundContext = PersistenceController.shared.createBackgroundContext()
        
        backgroundContext.perform {
            let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "SymptomsData")
            request.resultType = .dictionaryResultType
            request.propertiesToGroupBy = ["symptom"]
            
            let countExpression = NSExpression(format: "count:(id)")
            let countED = NSExpressionDescription()
            countED.name = "count"
            countED.expression = countExpression
            countED.expressionResultType = .integer64AttributeType
            
            request.propertiesToFetch = ["symptom", countED]
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
            request.fetchLimit = Self.maxTopLoggedSymptoms
            
            // Filter out system events and non-relevant symptoms
            let excludedSymptoms: [HandledSymptomsEvents] = [
                .realTimeSessionEnded, .realTimeSessionStarted
            ] + HandledSymptomsEvents.quickCommands
              + HandledSymptomsEvents.dailyMoods
              + [.textLog, .error, .none]
            
            let excludedRawValues = excludedSymptoms.map { $0.rawValue }
            request.predicate = NSPredicate(format: "NOT (symptom IN %@)", excludedRawValues)
            
            do {
                let results = try backgroundContext.fetch(request)
                
                let mappedResults = results.compactMap { result -> HandledSymptomsEvents? in
                    if let symptom = result["symptom"] as? String,
                       let sympt = HandledSymptomsEvents(rawValue: symptom) {
                        return sympt
                    }
                    return nil
                }
                
                DispatchQueue.main.async {
                    completion(mappedResults)
                }
            } catch {
                self.logger.error("Failed to fetch top symptoms: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
} 