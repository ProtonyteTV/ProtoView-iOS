//
//  ViewController.swift
//  112823
//
//  Created by ProtonyteTV on 2025-06-13.
// MARK: Initials

import UIKit
import WebKit
import UserNotifications

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    
    var webView: WKWebView!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Appearance
        setupNavigationAppearance()
        
        // Notifications
        requestNotificationPermission()
        scheduleMonthlyNotification()
        scheduleDailyNotification()
        
        // GitHub Update Check
        checkForUpdate()
        
        // MARK: WKWebView Setup
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "requestImage")
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Load Local HTML
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        
        // Image Picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
    }
    
    // MARK: Navigation Appearance
    
    func setupNavigationAppearance() {
        
        navigationItem.largeTitleDisplayMode = .never
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationItem.titleView = {
            let titleLabel = UILabel()
            titleLabel.text = "112823"
            titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            titleLabel.textColor = UIColor.label
            titleLabel.textAlignment = .left
            return titleLabel
            
        }()

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        navigationController?.navigationBar.prefersLargeTitles = offset <= 0
    }
    
    // MARK: Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error { print("Permission error: \(error)") }
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
        UNUserNotificationCenter.current().add(request)
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
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: GitHub Update
    
    func checkForUpdate() {
        guard let url = URL(string: "https://api.github.com/repos/ProtonyteTV/Protoview/releases/latest") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let latestVersion = json["tag_name"] as? String,
                   let releaseURL = json["html_url"] as? String {
                    
                    let currentVersion = "26.0"
                    if latestVersion != currentVersion {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "New Update Available", message: "112823 \(latestVersion) download mo na yung update mahal ko hahaha!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                                if let url = URL(string: releaseURL) {
                                    UIApplication.shared.open(url)
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "Later", style: .cancel))
                            self.present(alert, animated: true)
                        }
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }.resume()
    }
    
    // MARK: WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "requestImage" {
            present(imagePicker, animated: true)
        }
    }
    
    // MARK: ImagePicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            let js = "addImageToEntry('data:image/jpeg;base64,\(base64String)')"
            webView.evaluateJavaScript(js)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
