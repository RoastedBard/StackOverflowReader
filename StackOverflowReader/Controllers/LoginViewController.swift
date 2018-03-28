//
//  LoginViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit

// Keychain Configuration
struct KeychainConfiguration
{
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController, UIScrollViewDelegate, WKNavigationDelegate
{
    // MARK: - UI Elements
    
    var wkWebView: WKWebView!
    var activityIndicator : UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var userContentController: WKUserContentController!
    private var loginUrl = "https://stackexchange.com/oauth/dialog?client_id=11764&redirect_uri=https://stackexchange.com/oauth/login_success&scope=no_expiry"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        setupWebView()

        loadLoginPage()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        webView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    {
        webView.isHidden = true
        activityIndicator.startAnimating()
        
        let redirectUrl = webView.url?.absoluteString ?? ""
        
        if redirectUrl.contains("error"), redirectUrl.contains("stackexchange") {
            processAuthErrors(url: redirectUrl)
        }
        
        if redirectUrl.contains("access_token") {
            webView.stopLoading()
            
            AuthorizationManager.login(urlWithAccessToken: redirectUrl) {
                self.performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    // Disables magnification
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return nil
    }
    
    // MARK: - Methods
    
    fileprivate func setupWebView()
    {
        userContentController = WKUserContentController()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        
        wkWebView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        
        self.view.addSubview(wkWebView)
        self.view.addSubview(activityIndicator)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        wkWebView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    fileprivate func loadLoginPage()
    {
        userContentController.removeAllUserScripts()
        
        // This script makes approve dialog fit on the screen
        let scriptSource =
        """
           var approveDialog = document.querySelector('.app-authorization')

           if(approveDialog) {
                document.body.innerHTML = approveDialog.innerHTML;
                document.body.setAttribute('style','min-width:\(UIScreen.main.bounds.width)px !important; width:\(UIScreen.main.bounds.width)px; min-height:\(UIScreen.main.bounds.height)px !important; height:\(UIScreen.main.bounds.height)px');
           }
        """
        
        let userScript = WKUserScript(source: scriptSource,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let myURL = URL(string: loginUrl)
        
        let myRequest = URLRequest(url: myURL!)
        
        userContentController.addUserScript(userScript)
        
        activityIndicator.startAnimating()
        
        wkWebView.load(myRequest)
    }
    
    fileprivate func processAuthErrors(url : String)
    {
        guard let error = Utility.parseUrlForValue(url: url, valueForKey: "error") else {
            return
        }
        
        switch error {
        case "access_denied":
            AuthorizationManager.deleteCookies()
            loadLoginPage()
            
        case "unauthorized_client":
            Utility.showAlert(self, title: "Login Error", message: "Unauthorized Client")
            return
            
        case "invalid_request":
            Utility.showAlert(self, title: "Login Error", message: "Invalid Request")
            return
            
        case "unsupported_response_type":
            Utility.showAlert(self, title: "Login Error", message: "Unsupported Response Type")
            return
            
        case "invalid_scope":
            Utility.showAlert(self, title: "Login Error", message: "Invalid Scope")
            return
            
        case "server_error":
            Utility.showAlert(self, title: "Login Error", message: "Server Error")
            return
            
        case "temporarily_unavailable":
            Utility.showAlert(self, title: "Login Error", message: "Temporarily Unavailable")
            return
            
        default:
            return
        }
    }
}
