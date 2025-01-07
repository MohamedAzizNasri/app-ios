/*import Foundation
import Speech
import AVFoundation
import UIKit

class DoctorAIViewModel: ObservableObject {
    @Published var message: String = "Appuyez sur le micro pour poser une question médicale."
    @Published var isListening: Bool = false
    @Published var isLoading: Bool = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()

    private let doctorAIService = DoctorAIService()

    // Demander l'autorisation pour la reconnaissance vocale
    func requestSpeechAuthorization(from viewController: UIViewController) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Autorisation accordée pour la reconnaissance vocale.")
                case .denied:
                    self.message = "Autorisation refusée. Activez la reconnaissance vocale dans les réglages."
                    self.showAuthorizationAlert(from: viewController, message: "L'autorisation a été refusée. Vous devez activer la reconnaissance vocale dans les réglages de l'appareil.")
                case .restricted:
                    self.message = "La reconnaissance vocale est restreinte sur cet appareil."
                    self.showAuthorizationAlert(from: viewController, message: "La reconnaissance vocale est restreinte sur cet appareil.")
                case .notDetermined:
                    self.message = "Autorisation non déterminée."
                    self.showAuthorizationAlert(from: viewController, message: "L'autorisation pour la reconnaissance vocale n'a pas encore été demandée.")
                @unknown default:
                    self.message = "Erreur inconnue d'autorisation."
                    self.showAuthorizationAlert(from: viewController, message: "Une erreur inconnue est survenue.")
                }
            }
        }
    }

    // Afficher une alerte pour l'autorisation vocale
    private func showAuthorizationAlert(from viewController: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Permission Requise", message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Ajout d'un bouton pour ouvrir les réglages si l'autorisation a été refusée
        if !message.contains("n'a pas encore été demandée") {
            alertController.addAction(UIAlertAction(title: "Ouvrir Réglages", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
        }

        viewController.present(alertController, animated: true, completion: nil)
    }

    // Démarrer ou arrêter l'écoute
    func toggleSpeechRecognition() {
        if isListening {
            stopSpeechRecognition()
        } else {
            startSpeechRecognition()
        }
    }

    private func startSpeechRecognition() {
        isListening = true
        message = "Écoute en cours..."

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        // Vérification du format audio
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("Format audio invalide : SampleRate ou ChannelCount incorrect.")
            message = "Erreur audio. Veuillez réessayer."
            stopSpeechRecognition()
            return
        }
        
        // Si sur le simulateur, on peut essayer de forcer un format compatible
        if TARGET_OS_SIMULATOR != 0 {
            let modifiedFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
            node.installTap(onBus: 0, bufferSize: 1024, format: modifiedFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
        } else {
            // Utilisation du format audio standard sur un appareil réel
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Erreur de démarrage de l'audio : \(error.localizedDescription)")
            message = "Erreur audio. Veuillez réessayer."
            stopSpeechRecognition()
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                let text = result.bestTranscription.formattedString
                self.message = "Vous : \(text)"
                
                if result.isFinal {
                    self.stopSpeechRecognition()
                    self.handleEmergencyCall(for: text)
                    self.fetchDoctorAIResponse(for: text)
                }
            } else if let error = error {
                print("Erreur de reconnaissance : \(error.localizedDescription)")
                self.message = "Erreur d'écoute. Réessayez."
                self.stopSpeechRecognition()
            }
        }
    }

    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask?.cancel()
        isListening = false
    }

    // Détection de la commande d'urgence
    private func handleEmergencyCall(for input: String) {
        let normalizedInput = input.lowercased()
        if normalizedInput.contains("appeler secours") || normalizedInput.contains("appel secours") {
            callEmergencyNumber()
        }
    }

    private func callEmergencyNumber() {
        guard let url = URL(string: "tel://190") else { return }
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.message = "Erreur : Impossible d'appeler le 190."
            }
        }
    }

    // Appel à l'API pour obtenir une réponse
    private func fetchDoctorAIResponse(for input: String) {
        isLoading = true
        doctorAIService.fetchResponse(for: input) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let reply = response else {
                    self?.message = "Erreur du Docteur IA. Réessayez."
                    return
                }
                self?.message = "Docteur IA : \(reply)"
                self?.speak(reply)
            }
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        synthesizer.speak(utterance)
    }
}
*/
import Foundation
import Speech
import AVFoundation
import UIKit

class DoctorAIViewModel: ObservableObject {
    @Published var message: String = "Appuyez sur le micro pour poser une question médicale."
    @Published var isListening: Bool = false
    @Published var isLoading: Bool = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()

    private let doctorAIService = DoctorAIService()

    // Demander l'autorisation pour la reconnaissance vocale
    func requestSpeechAuthorization(from viewController: UIViewController) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Autorisation accordée pour la reconnaissance vocale.")
                case .denied:
                    self.showAuthorizationAlert(from: viewController, message: "L'autorisation a été refusée. Activez la reconnaissance vocale dans les réglages.")
                case .restricted:
                    self.showAuthorizationAlert(from: viewController, message: "La reconnaissance vocale est restreinte sur cet appareil.")
                case .notDetermined:
                    self.showAuthorizationAlert(from: viewController, message: "L'autorisation pour la reconnaissance vocale n'a pas encore été demandée.")
                @unknown default:
                    self.showAuthorizationAlert(from: viewController, message: "Une erreur inconnue est survenue.")
                }
            }
        }
    }

    // Affichage d'une alerte pour l'autorisation
    private func showAuthorizationAlert(from viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "Permission Requise", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if !message.contains("n'a pas encore été demandée") {
            alert.addAction(UIAlertAction(title: "Ouvrir Réglages", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
        }
        viewController.present(alert, animated: true)
    }

    // Basculer l'écoute
    func toggleSpeechRecognition() {
        if isListening {
            stopSpeechRecognition()
        } else {
            startSpeechRecognition()
        }
    }

    func startSpeechRecognition() {
        // Vérifier quel microphone est utilisé
        checkAudioRoute()

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            message = "La reconnaissance vocale n'est pas disponible."
            return
        }

        // Configuration de la session audio
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Essayer de configurer la session audio pour utiliser le périphérique Bluetooth si disponible
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .allowBluetooth)
            try audioSession.setActive(true)

            // Vérification si les AirPods sont utilisés
            checkAudioRoute()
        } catch {
            message = "Erreur d'initialisation du microphone."
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isListening = true
            message = "Je vous écoute..."
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    self.message = result.bestTranscription.formattedString
                }
                if let error = error {
                    self.stopSpeechRecognition()
                    self.message = "Erreur de reconnaissance vocale: \(error.localizedDescription)"
                }
            }
        } catch {
            message = "Erreur lors du démarrage de l'audio."
        }
    }

    // Arrêter la reconnaissance vocale
    private func stopSpeechRecognition() {
        // Arrêter l'audio et nettoyer les ressources
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Réinitialiser la session audio
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.soloAmbient)
        } catch {
            message = "Erreur lors de la réinitialisation de la session audio."
        }

        isListening = false
        message = "Reconnaissance vocale arrêtée."
    }

    func checkAudioRoute() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            // Configurer la session pour utiliser le Bluetooth en priorité
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .allowBluetooth)
            try audioSession.setActive(true)

            let currentRoute = audioSession.currentRoute
            if currentRoute.inputs.contains(where: { $0.portType == .bluetoothHFP }) {
                print("Microphone des AirPods utilisé")
            } else {
                print("Utilisation du microphone interne. Essayez de reconnecter les AirPods.")
            }
        } catch {
            print("Erreur lors de la configuration de la session audio: \(error.localizedDescription)")
        }
    }

    func restartAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .allowBluetooth)
            try audioSession.setActive(true)
        } catch {
            print("Erreur lors de la réinitialisation de la session audio: \(error.localizedDescription)")
        }
    }

    func checkIfBluetoothIsConnected() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            let currentRoute = audioSession.currentRoute
            for input in currentRoute.inputs {
                if input.portType == .bluetoothHFP {
                    print("AirPods ou périphérique Bluetooth utilisé.")
                }
            }
        } catch {
            print("Erreur lors de la vérification du périphérique Bluetooth: \(error.localizedDescription)")
        }
    }

    // Gérer l'appel d'urgence
    private func handleEmergencyCall(for input: String) {
        let keywords = ["appeler secours", "appel secours"]
        if keywords.contains(where: input.lowercased().contains) {
            callEmergencyNumber()
        }
    }

    private func callEmergencyNumber() {
        guard let url = URL(string: "tel://190"), UIApplication.shared.canOpenURL(url) else {
            message = "Erreur : Impossible d'appeler le 190."
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }

    // Appel à l'API pour obtenir une réponse
    private func fetchDoctorAIResponse(for input: String) {
        isLoading = true
        doctorAIService.fetchResponse(for: input) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let reply = response else {
                    self?.message = "Erreur du Docteur IA. Réessayez."
                    return
                }
                self?.message = "Docteur IA : \(reply)"
                self?.speak(reply)
            }
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        synthesizer.speak(utterance)
    }
}
