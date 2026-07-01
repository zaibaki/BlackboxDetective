import Foundation

public class AzureOpenAIService: ObservableObject {
    @Published public var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "azure_openai_key") }
    }
    @Published public var endpoint: String {
        didSet { UserDefaults.standard.set(endpoint, forKey: "azure_openai_endpoint") }
    }
    @Published public var deploymentName: String {
        didSet { UserDefaults.standard.set(deploymentName, forKey: "azure_openai_deployment") }
    }
    
    public static let shared = AzureOpenAIService()
    
    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: "azure_openai_key") ?? ""
        self.endpoint = UserDefaults.standard.string(forKey: "azure_openai_endpoint") ?? ""
        self.deploymentName = UserDefaults.standard.string(forKey: "azure_openai_deployment") ?? ""
    }
    
    public var isConfigured: Bool {
        return !apiKey.isEmpty && !endpoint.isEmpty && !deploymentName.isEmpty
    }
    
    /// Sends the message history to Azure OpenAI, or simulates offline logic if credentials are not configured.
    public func sendInterrogationMessage(
        suspect: Suspect,
        history: [InterrogationLog],
        userMessage: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if !isConfigured {
            completion(.failure(NSError(domain: "AzureOpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Uplink offline. Credentials unconfigured."])))
            return
        }
        
        // Build Azure OpenAI Request
        guard let url = URL(string: "\(endpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=2023-05-15") else {
            completion(.failure(NSError(domain: "AzureOpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Azure Endpoint"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        
        // Construct messages payload
        var messages: [[String: String]] = []
        messages.append(["role": "system", "content": suspect.secretPrompt])
        
        for log in history {
            let role = log.sender == "detective" ? "user" : "assistant"
            messages.append(["role": role, "content": log.message])
        }
        messages.append(["role": "user", "content": userMessage])
        
        let payload: [String: Any] = [
            "messages": messages,
            "max_tokens": 150,
            "temperature": 0.6
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "AzureOpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Parse response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let messageData = firstChoice["message"] as? [String: Any],
                   let responseContent = messageData["content"] as? String {
                    completion(.success(responseContent.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    // Check if error message is embedded
                    if let errorObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorDetails = errorObj["error"] as? [String: Any],
                       let errorMessage = errorDetails["message"] as? String {
                        completion(.failure(NSError(domain: "AzureOpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    } else {
                        completion(.failure(NSError(domain: "AzureOpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response"])))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Local Heuristics Simulation Engine
    
    private func simulateSuspectResponse(suspect: Suspect, message: String) -> String {
        let cleanMsg = message.lowercased()
        
        if suspect.isGuilty {
            // Guilty chemist: Dr. Aris Vance
            if cleanMsg.contains("tape") || cleanMsg.contains("audio") || cleanMsg.contains("recording") || cleanMsg.contains("terminal 4") {
                return "[Stammering] W-what tape? That audio is synthesized, or taken out of context! The customs delay at Terminal 4 was a simple misunderstanding regarding raw glass delivery!"
            } else if cleanMsg.contains("ledger") || cleanMsg.contains("phone") || cleanMsg.contains("burner") || cleanMsg.contains("call") {
                return "[Breaks down, whispering] Okay! Yes, I made the phone calls! But she... Elena Rostova... she threatened my family! I just cooked the formula because I had no choice. She was the one who curated the target!"
            } else if cleanMsg.contains("poison") || cleanMsg.contains("neurotoxin") || cleanMsg.contains("chemist") || cleanMsg.contains("alchemist") {
                return "My research is strictly therapeutic, Detective. Any connection to this 'Alchemist' profile is a baseless smear campaign against my academic reputation."
            } else if cleanMsg.contains("blueprint") || cleanMsg.contains("lab") || cleanMsg.contains("rig") {
                return "A lot of labs use standard distillation setups. That handwritten signature isn't unique to me. Prove that it was me."
            } else {
                return "I am a professional chemist, Detective. If you do not have concrete evidence of a crime, I have nothing to say."
            }
        } else {
            // Innocent broker: Elena Rostova
            if cleanMsg.contains("vance") || cleanMsg.contains("chemist") {
                return "Dr. Vance is a client of mine. I brokers rare ingredients and collectibles. I have no oversight on how he uses his purchases, Detective."
            } else if cleanMsg.contains("poison") || cleanMsg.contains("diplomat") || cleanMsg.contains("murder") || cleanMsg.contains("kill") {
                return "[Laughs softly] As my social itinerary clearly shows, I was speaking to several high-profile patrons during that tragic banquet. You are barking up the wrong tree."
            } else if cleanMsg.contains("burner") || cleanMsg.contains("phone") || cleanMsg.contains("ledger") {
                return "Burn phones? How pedestrian. I conduct my business via licensed secure channels or in person. Do you have a warrant for these accusations?"
            } else {
                return "I am a very busy woman, Detective. If you do not have a formal charge, please stop wasting my gallery's time."
            }
        }
    }
}
