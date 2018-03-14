//
//  AuthWebViewController.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 2/28/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit

class AuthWebViewController: UIViewController, WKUIDelegate
{
    var wkWebView: WKWebView!

    private var userContentController: WKUserContentController!
    
    override func loadView()
    {
        userContentController = WKUserContentController()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        
        wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        wkWebView.uiDelegate = self
        view = wkWebView
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        userContentController.removeAllUserScripts()
        
        let userScript = WKUserScript(source: scriptWithDOMSelector(selector: "#formContainer"),
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)
        
        userContentController.addUserScript(userScript)
        
        let myURL = URL(string: "https://stackexchange.com/oauth/dialog?client_id=11764&redirect_uri=https://stackexchange.com/oauth/login_success&scope=private_info")
        
        let myRequest = URLRequest(url: myURL!)
        wkWebView.load(myRequest)
    }
    
    private func scriptWithDOMSelector(selector: String) -> String
    {
        let script =
            "var selectedElement = document.querySelector('\(selector)');" +
        "document.body.innerHTML = selectedElement.innerHTML;"
        return script
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
