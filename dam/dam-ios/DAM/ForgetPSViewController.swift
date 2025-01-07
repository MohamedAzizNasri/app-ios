//
//  ForgetPSViewController.swift
//  DAM
//
//  Created by Apple Esprit on 7/11/2024.
//

import UIKit

class ForgetPSViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var otpMail: UITextField!
    
    
    var email : String!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set the text field delegates
        otpMail.delegate = self
        otpMail.keyboardType = .emailAddress

    }

    

    
    
    // Continue button action to validate fields
    @IBAction func continueAction(_ sender: Any) {
   
        guard let emailText = otpMail.text, !emailText.isEmpty else {
                    showAlert(message: "Please enter a valid email.")
                    return
                }
                
                if isValidEmail(emailText) {
                    email = emailText
                    let parameters: [String: Any] = ["email": emailText]
                    sendForgotPasswordRequest(parameters: parameters)
                } else {
                    showAlert(message: "Please enter a valid email.")
                }
            }
            
            // Fonction pour afficher une alerte
            private func showAlert(message: String) {
                DispatchQueue.main.async {
                    guard self.isViewLoaded && self.view.window != nil else { return }
                    let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // Fonction pour valider le format de l'email
            private func isValidEmail(_ email: String) -> Bool {
                let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailPattern)
                return emailPred.evaluate(with: email)
            }
            
            // Fonction pour envoyer la requête de mot de passe oublié
            private func sendForgotPasswordRequest(parameters: [String: Any]) {
                guard let url = URL(string: "http://172.18.1.47:3001/auth/forget-password") else { return }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("Request error:", error)
                            return
                        }
                        
                        guard let data = data, !data.isEmpty else {
                            print("Response data is missing.")
                            return
                        }
                        
                        // Imprimer les données de réponse pour débogage
                        print("Response data:", String(data: data, encoding: .utf8) ?? "No readable data")
                        
                        // Gérer la réponse du serveur
                        self.handleResponse(data: data, response: response)
                    }
                    
                    // Démarrer la tâche de la requête
                    task.resume()
                    
                } catch {
                    print("Error serializing JSON:", error.localizedDescription)
                }
            }
            
            // Fonction pour traiter la réponse du serveur
            private func handleResponse(data: Data, response: URLResponse?) {
                // Vérification du statut HTTP
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode > 200 {
                        // La requête a réussi, extraire l'email de la réponse
                        do {
                            // Nous supposons que la réponse contient juste un email et un statut
                            let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            if let email = responseDict?["email"] as? String {
                                DispatchQueue.main.async {
                                    // Passe l'email à la vue suivante
                                    self.performSegue(withIdentifier: "otp", sender: email)
                                }
                            } else {
                                self.showAlert(message: "Failed to retrieve email from response.")
                            }
                        } catch {
                            print("Error decoding response:", error)
                        }
                    } else {
                        // Affichez un message d'erreur si le statut HTTP n'est pas 200
                        self.showAlert(message: "Error: \(httpResponse.statusCode). Please try again.")
                    }
                }
            }
            
            // Préparer le segue pour passer les données à la prochaine vue
            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "otp", let email = sender as? String {
                    let destination = segue.destination as! RecupCodeViewController
                    destination.email = email // Passer uniquement l'email à la vue suivante
                }
            }
        }
