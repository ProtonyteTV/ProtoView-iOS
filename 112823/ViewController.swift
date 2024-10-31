import UIKit
import WebKit
import UserNotifications

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        self.title = "112823"
        
        // Request notification permission
        requestNotificationPermission()
        
        // Schedule monthly and daily notifications
        scheduleMonthlyNotification()
        scheduleDailyNotification()
        
        // Configure WKWebView
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self, name: "requestImage")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // WebView layout constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        // Load local HTML file
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        
        // Configure image picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Permission error: \(error)")
            }
        }
    }
    
    func scheduleMonthlyNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Define the notification content
        let content = UNMutableNotificationContent()
        content.title = "112823"
        content.body = "Ano love walang bati bati motmot naten ngayon!."
        content.sound = .default
        
        // Set the trigger date to the 28th at 6:30 am
        var dateComponents = DateComponents()
        dateComponents.day = 28
        dateComponents.hour = 6
        dateComponents.minute = 30
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "monthlyReminder", content: content, trigger: trigger)
        
        // Schedule the notification
        center.add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }
    
    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "112823"
        content.body = "Love Wala ba tayong pa notes for today?"
        content.sound = .default
        
        // Set the time components for 8:00 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 20  // 8:00 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily notification: \(error.localizedDescription)")
            } else {
                print("Daily notification scheduled for 8:00 PM")
            }
        }
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "requestImage" {
            present(imagePicker, animated: true)
        }
    }
    
    // MARK: - Image Picker Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage,
            let imageData = image.jpegData(compressionQuality: 0.8) {
            
            // Convert image data to base64 string
            let base64String = imageData.base64EncodedString()
            let base64ImageString = "data:image/jpeg;base64,\(base64String)"
            
            // Inject JavaScript to call addImageToEntry with base64 string
            let javascriptCode = "addImageToEntry('\(base64ImageString)')"
            webView.evaluateJavaScript(javascriptCode) { (result, error) in
                if let error = error {
                    print("JavaScript error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
