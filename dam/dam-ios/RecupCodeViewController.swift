//
//  RecupCodeViewController.swift
//  DAM
//
//  Created by Apple Esprit on 11/11/2024.
//

import UIKit

class RecupCodeViewController: UIViewController,UITextFieldDelegate {
    
    
    
    @IBOutlet weak var otpTextField: UITextField!
    
    
    var email : String?
    var resetToken: String?  // Pour stocker le token de réinitialisation
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set delegate and keyboard type for the OTP text field
        otpTextField.delegate = self
        otpTextField.keyboardType = .numberPad
    }
    
    // Restrict input to numeric characters and limit to 6 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numbers
        let characterSet = CharacterSet(charactersIn: "0123456789")
        let filtered = string.rangeOfCharacter(from: characterSet.inverted)
        
        // Prevent non-numeric input
        if filtered != nil {
            return false
        }
        
        // Limit input to 6 characters
        let currentText = textField.text ?? ""
        return currentText.count + string.count - range.length <= 6
    }
    
    // Action for Continue button
    @IBAction func continueAction(_ sender: Any) {
        guard let codeOtpEnter = otpTextField.text, codeOtpEnter.count == 6 else {
                   showAlert(message: "Le code OTP doit contenir exactement 6 chiffres.")
                   return
               }
               
               // Validation OTP avec le backend
               validateOtp(code: codeOtpEnter) { (isValid, resetToken) in
                   if isValid, let resetToken = resetToken {
                       // Successfully validated, navigate to the next screen
                       self.resetToken = resetToken
                       self.performSegue(withIdentifier: "otpSeg", sender: resetToken)
                   } else {
                       // Show error alert if OTP validation failed
                       self.showAlert(message: "Le code OTP est incorrect ou a expiré.")
                   }
               }
           }

           // Function to validate OTP with backend
           func validateOtp(code: String, completion: @escaping (Bool, String?) -> Void) {
               guard let url = URL(string: "http://172.18.1.47:3001/auth/verify-otp") else {
                   completion(false, nil)
                   return
               }

               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")

               // Utilisation de otpTextField.text comme recoveryCode
               let body: [String: Any] = [
                   "email": email ?? "",
                   "recoveryCode": code // Utilisation du code saisi dans otpTextField
               ]

               do {
                   request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
               } catch {
                   print("Erreur lors de l'encodage des données OTP.")
                   completion(false, nil)
                   return
               }

               URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                       print("Erreur lors de la requête : \(error.localizedDescription)")
                       completion(false, nil)
                       return
                   }

                   guard let httpResponse = response as? HTTPURLResponse else {
                       print("Réponse du serveur invalide.")
                       completion(false, nil)
                       return
                   }

                   // Vérifier le statut HTTP
                   if httpResponse.statusCode > 200 {
                       guard let data = data,
                             let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                             let resetToken = jsonResponse["resetToken"] as? String else {
                           print("Erreur dans la réponse JSON ou absence de resetToken.")
                           completion(false, nil)
                           return
                       }

                       print("Requête réussie, resetToken : \(resetToken)")
                       completion(true, resetToken)
                   } else {
                       print("La requête a échoué avec le code de statut : \(httpResponse.statusCode)")
                       completion(false, nil)
                   }
               }.resume()
           }

           // Prepare for segue to ResetPViewController
           override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               if segue.identifier == "otpSeg", let resetToken = sender as? String {
                   let destinationVC = segue.destination as! ResetPViewController
                   destinationVC.resetToken = resetToken
               }
           }

           // Function to show alert message
           func showAlert(message: String) {
               let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
           }
       }
