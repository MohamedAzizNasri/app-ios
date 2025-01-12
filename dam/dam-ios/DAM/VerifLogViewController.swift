//
//  VerifLogViewController.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

import UIKit

class VerifLogViewController: UIViewController {
    var email: String?
    
    @IBOutlet weak var verif: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storedEmail = UserDefaults.standard.string(forKey: "email") {
                  self.email = storedEmail
                  // Passer directement à l'étape suivante si l'email est trouvé
                  print("Utilisateur déjà connecté avec email: \(storedEmail)")
              }
        
        
    }
    
    @IBAction func continueAction(_ sender: Any) {
        /*   // Vérifier si le champ du code de vérification n'est pas vide
         guard let verificationCode = verif.text, !verificationCode.isEmpty else {
         showAlert(title: "Erreur", message: "Veuillez entrer le code de vérification.")
         return
         }
         
         // Vérifier si l'email est présent
         guard let email = email else {
         showAlert(title: "Erreur", message: "Email manquant.")
         return
         }
         
         // Préparer les paramètres pour la requête API
         let parameters: [String: Any] = [
         "email": email,
         "recoveryCode": verificationCode
         ]
         
         // Envoyer la requête au backend pour vérifier le code
         verifyCode(parameters: parameters)
         }
         
         // Fonction pour afficher une alerte
         private func showAlert(title: String, message: String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
         }
         
         // Fonction pour envoyer la requête API de vérification
         private func verifyCode(parameters: [String: Any]) {
         guard let url = URL(string: "http://192.168.196.54:3001/auth/verify-login") else { return }
         
         do {
         let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.httpBody = jsonData
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
         print("Erreur: \(error.localizedDescription)")
         return
         }
         
         guard let data = data else {
         print("Pas de données reçues")
         return
         }
         
         self.handleVerificationResponse(data: data)
         }
         
         task.resume()
         } catch {
         print("Erreur lors de la sérialisation JSON: \(error.localizedDescription)")
         }
         }
         
         // Gérer la réponse de l'API après la vérification du code
         private func handleVerificationResponse(data: Data) {
         if let responseString = String(data: data, encoding: .utf8) {
         print("Réponse brute : \(responseString)") // Affiche la réponse brute
         
         if let jsonData = responseString.data(using: .utf8) {
         do {
         if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
         print("Réponse JSON : \(jsonResponse)") // Affiche la réponse JSON complète
         
         if let statusCode = jsonResponse["statusCode"] as? Int {
         DispatchQueue.main.async {
         if statusCode == 200 {
         // Vérifier si l'objet "tokens" est présent dans la réponse
         if let tokens = jsonResponse["tokens"] as? [String: Any] {
         // Sauvegarder les tokens dans UserDefaults
         if let accessToken = tokens["accessToken"] as? String {
         UserDefaults.standard.set(accessToken, forKey: "accessToken")
         print("accessToken sauvegardé : \(accessToken)")
         }
         
         if let refreshToken = tokens["refreshToken"] as? String {
         UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
         print("refreshToken sauvegardé : \(refreshToken)")
         }
         
         // Code de vérification correct, continuer avec l'authentification
         print("Code de vérification correct")
         self.performSegue(withIdentifier: "home", sender: self)
         } else {
         self.showAlert(title: "Erreur", message: "Tokens manquants dans la réponse.")
         }
         } else {
         let message = jsonResponse["message"] as? String ?? "Le code de vérification est incorrect."
         self.showAlert(title: "Échec", message: message)
         }
         }
         } else {
         print("Code de statut manquant dans la réponse.")
         }
         }
         } catch {
         print("Erreur lors de la lecture des données JSON: \(error.localizedDescription)")
         }
         }
         }
         }
         }*/
        guard let verificationCode = verif.text, !verificationCode.isEmpty else {
                   showAlert(title: "Erreur", message: "Veuillez entrer le code de vérification.")
                   return
               }

               guard let email = email else {
                   showAlert(title: "Erreur", message: "Email manquant.")
                   return
               }

               let parameters: [String: Any] = [
                   "email": email,
                   "recoveryCode": verificationCode
               ]

               verifyCode(parameters: parameters)
           }

           private func showAlert(title: String, message: String) {
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               self.present(alert, animated: true, completion: nil)
           }

           private func verifyCode(parameters: [String: Any]) {
               guard let url = URL(string: "http://172.18.1.47:3001/auth/verify-login") else { return }

               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                   var request = URLRequest(url: url)
                   request.httpMethod = "POST"
                   request.httpBody = jsonData
                   request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                   let task = URLSession.shared.dataTask(with: request) { data, response, error in
                       if let error = error {
                           print("Erreur: \(error.localizedDescription)")
                           return
                       }

                       guard let data = data else {
                           print("Pas de données reçues")
                           return
                       }

                       self.handleVerificationResponse(data: data)
                   }

                   task.resume()
               } catch {
                   print("Erreur lors de la sérialisation JSON: \(error.localizedDescription)")
               }
           }

           private func handleVerificationResponse(data: Data) {
               if let responseString = String(data: data, encoding: .utf8) {
                   print("Réponse brute : \(responseString)")

                   if let jsonData = responseString.data(using: .utf8) {
                       do {
                           if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                               print("Réponse JSON : \(jsonResponse)")

                               if let statusCode = jsonResponse["statusCode"] as? Int {
                                   DispatchQueue.main.async {
                                       if statusCode == 200 {
                                           if let tokens = jsonResponse["tokens"] as? [String: Any] {
                                               if let accessToken = tokens["accessToken"] as? String {
                                                   UserDefaults.standard.set(accessToken, forKey: "accessToken")
                                                   print("accessToken sauvegardé : \(accessToken)")
                                               }

                                               if let refreshToken = tokens["refreshToken"] as? String {
                                                   UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                                                   print("refreshToken sauvegardé : \(refreshToken)")
                                               }

                                               print("Code de vérification correct")
                                               self.performSegue(withIdentifier: "home", sender: self)
                                           } else {
                                               self.showAlert(title: "Erreur", message: "Tokens manquants dans la réponse.")
                                           }
                                       } else {
                                           let message = jsonResponse["message"] as? String ?? "Le code de vérification est incorrect."
                                           self.showAlert(title: "Échec", message: message)
                                       }
                                   }
                               } else {
                                   print("Code de statut manquant dans la réponse.")
                               }
                           }
                       } catch {
                           print("Erreur lors de la lecture des données JSON: \(error.localizedDescription)")
                       }
                   }
               }
           }
       }
