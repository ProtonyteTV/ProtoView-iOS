import UIKit
import WebKit
import UserNotifications

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKScriptMessageHandler, UIScrollViewDelegate {

    var webView: WKWebView!
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation appearance
        setupNavigationAppearance()

        // Request notification permission
        requestNotificationPermission()

        // Schedule notifications
        scheduleMonthlyNotification()
        scheduleDailyNotification()

        // Check for GitHub update
        checkForUpdate()

        // Configure WKWebView
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self, name: "requestImage")

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self // For dynamic title
        view.addSubview(webView)

        // Layout constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Load local HTML
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

        // Setup image picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
    }

    // MARK: - Navigation Appearance

    func setupNavigationAppearance() {
        self.title = "112823"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            navigationController?.navigationBar.isTranslucent = false
        }
    }

    // MARK: - ScrollView Delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        navigationController?.navigationBar.prefersLargeTitles = offset <= 0
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
        let content = UNMutableNotificationContent()
        content.title = "112823"
        content.body = "mahal happy monthsaryyyy iloveyou always mwuaah!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.day = 28
        dateComponents.hour = 6
        dateComponents.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "monthlyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }

    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "112823"
        content.body = "mahal 8pm na gusto ko lang iremind ka na mahal na mahal kita palagi mwuaaaah!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20
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

    // MARK: - GitHub Update Check

    func checkForUpdate() {
    guard let url = URL(string: "https://api.github.com/repos/ProtonyteTV/Protoview/releases/latest") else { return }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else { return }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let latestVersion = json["tag_name"] as? String,
                   let releaseURL = json["html_url"] as? String {

                    let currentVersion = "9.0" // Update this as needed
                    if latestVersion != currentVersion {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(
                                title: "New Update Available",
                                message: "112823 \(latestVersion) download mo na yung update mahal ko hahaha!",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                                if let url = URL(string: releaseURL) {
                                    UIApplication.shared.open(url)
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
        }
    }
    task.resume()
}

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "requestImage" {
        present(imagePicker, animated: true)
    }
}

    // MARK: - Image Picker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {

            let base64String = imageData.base64EncodedString()
            let base64ImageString = "data:image/jpeg;base64,\(base64String)"
            let javascriptCode = "addImageToEntry('\(base64ImageString)')"

            webView.evaluateJavaScript(javascriptCode) { result, error in
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
