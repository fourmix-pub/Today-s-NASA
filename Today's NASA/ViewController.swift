//
//  ViewController.swift
//  Today's NASA
//
//  Created by Jie Wu on 2019/01/10.
//  Copyright © 2019 lindelin. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var historyPhotos: HistoryPhotos = HistoryPhotos.find()
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var copyright: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
    }
    
    func loadData() {
        Photo.fetchPhotoInfo { (photo) in
            if let photo = photo {
                DispatchQueue.main.async {
                    self.updateUI(photo: photo)
                    self.storeData(photo: photo)
                }
            }
        }
    }
    
    func updateUI(photo: Photo) {
        if photo.mediaType == "video" {
            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true
            let webview = WKWebView(frame: CGRect(x: self.photo.frame.origin.x,
                                                  y: self.photo.frame.origin.y,
                                                  width: self.photo.frame.width,
                                                  height: self.photo.frame.height), configuration: config)
            webview.load(URLRequest(url: photo.url.withQueries(["playsinline" : "1"])!))
            self.view.addSubview(webview)
        } else {
            photo.fetchImage { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.photo.image = image
                    }
                }
            }
        }
        
        self.navigationItem.title = photo.title
        self.content.text = photo.content
        if let copyright = photo.copyright {
            self.copyright.text = "Copyright: \(copyright)"
        } else {
            self.copyright.isHidden = true
        }
    }
    
    func storeData(photo: Photo) {
        if historyPhotos.photos.contains(where: { (historyPhoto) -> Bool in
            return photo.date == historyPhoto.date
        }) {
            return
        }
        
        historyPhotos.photos.insert(photo, at: 0)
        historyPhotos.store()
    }
}

