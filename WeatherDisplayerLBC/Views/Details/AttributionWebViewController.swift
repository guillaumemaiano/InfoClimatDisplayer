//
//  AttributionWebViewController.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit
import WebKit

// Self contained view, mostly Apple code
class AttributionWebViewController: UIViewController, WKUIDelegate {
        
        var webView: WKWebView!
        
        override func loadView() {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.uiDelegate = self
            view = webView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            // Force-unwrap is sensible because the URL is hardcoded
            var components = URLComponents()
            components.host = Constants.Endpoint.weatherServer().host!
            components.scheme = Constants.Endpoint.weatherServer().scheme!
            let weatherSiteWebUrl: URL = components.url!

            let webviewRequest = URLRequest(url: weatherSiteWebUrl)
            webView.load(webviewRequest)
        }
}
