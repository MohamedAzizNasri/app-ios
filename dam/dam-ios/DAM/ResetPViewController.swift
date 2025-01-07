//
//  ResetPViewController.swift
//  DAM
//
//  Created by Mac-Mini-2021 on 6/11/2024.
//


import UIKit

class ResetPViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var newpasswordTF: UITextField!
    
    @IBOutlet weak var confirmNewpasswordTF: UITextField!
    
    var resetToken: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
               
           if newpasswordTF == nil || confirmNewpasswordTF == nil {
               print("Error: IBOutlet is not connected properly.")
           }

           newpasswordTF.delegate = self
           confirmNewpasswordTF.delegate = self
               
               
           }
           
    @IBAction func saveButton(_ sender: Any) {
        // Vérification des mots de passe
               guard let newPassword = newpasswordTF.text, let confirmPassword = confirmNewpasswordTF.text, newPassword == confirmPassword else {
                showAlert(message: "Passwords do not match.")
                   return
               }

               // Paramètres pour la requête
               let parameters: [String: Any] = [
                   "resetToken": resetToken,  // Utilisation du resetToken récupéré
                   "newPassword": newpasswordTF.text!,
                   "confirmPassword": confirmNewpasswordTF.text!
               ]
               
               // Envoi de la requête de réinitialisation
               sendResetPasswordRequest(parameters: parameters)
           }

           // Envoi de la requête pour réinitialiser le mot de passe
           private func sendResetPasswordRequest(parameters: [String: Any]) {
               guard let url = URL(string: "http://172.18.1.47:3001/auth/reset-password") else { return }

               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                   print("sendResetPasswordRequest", jsonData)

                   var request = URLRequest(url: url)
                   request.httpMethod = "PUT"
                   request.httpBody = jsonData
                   request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                   print(jsonData)
                   
                   let task = URLSession.shared.dataTask(with: request) { data, response, error in
                       if let error = error {
                           print("Error: \(error.localizedDescription)")
                           return
                       }

                       guard let data = data else {
                           print("No data received")
                           return
                       }

                       self.handleResponse(data: data)
                   }

                   // Démarrer la tâche de la requête
                   task.resume()

               } catch {
                   print("Error serializing JSON: \(error.localizedDescription)")
               }
           }

           // Traitement de la réponse du serveur
           private func handleResponse(data: Data) {
               if let responseString = String(data: data, encoding: .utf8) {
                   print("Response: \(responseString)")

                   // Tentative de parsing de la réponse JSON
                   if let jsonData = responseString.data(using: .utf8) {
                       do {
                           if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                               // Vérification du code de statut
                               if let statusCode = jsonResponse["statusCode"] as? Int {
                                   if statusCode > 200 {
                                       print("Password reset successful")
                                       DispatchQueue.main.async {
                                           // Utiliser performSegue pour aller à la page suivante
                                           self.performSegue(withIdentifier: "vSeg", sender: nil)
                                       }
                                   } else {
                                       print("Unexpected error: \(statusCode)")
                                   }
                               }
                           }
                       } catch {
                           print("Failed to parse JSON: \(error.localizedDescription)")
                       }
                   }
               }
           }

           // Afficher une alerte pour les erreurs
        func showAlert(message: String) {
       let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
 present(alert, animated: true, completion: nil)
  }
       }
