//
//  PhotoBrowserViewModel.swift
//  AlamofireTest1
//
//  Created by alun on 16/5/13.
//  Copyright © 2016年 cascade. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire

class PhotoBrowserViewModel: NSObject {
    
    func getPhotos(page: Int = 1) -> Observable<AnyObject> {
        return Observable.create { observer in
            let request = Alamofire.request(modelFor500px.Router.PopularPhotos(page))
                .responseJSON() { response in
                
                    if let error = response.result.error {
                        observer.on(.Error(error))
                    } else if let JSON = response.result.value {
                        let photoInfos = (JSON.valueForKey("photos") as! [NSDictionary]).filter({ image in
                            (image["nsfw"] as! Bool) == false
                        }).map { photo in
                            PhotoInfo(id: photo["id"] as! Int, url: photo["image_url"] as! String)
                        }
                        observer.on(.Next(photoInfos))
                        observer.on(.Completed)
                    } else {
                        observer.on(.Error(NSError(domain: "json not exists", code: -10001, userInfo: nil)))
                    }
                    
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
    func getImage(url: String) -> Observable<AnyObject> {
        return Observable.create { observer in
            let request = Alamofire.request(.GET, url).validate(contentType:["image/*"]).responseImage() {
                response in
                
                if let error = response.result.error {
                    observer.on(.Error(error))
                } else if let image = response.result.value {
                    observer.on(.Next(image))
                    observer.on(.Completed)
                } else {
                    observer.on(.Error(NSError(domain: "image not exists", code: -10002, userInfo: nil)))
                }
            }
            return AnonymousDisposable {
                return request.cancel()
            }
        }
    }
    
    func getPhoto(photoId: Int, imageSize: modelFor500px.ImageSize = modelFor500px.ImageSize.Large) -> Observable<AnyObject> {
        return Observable.create { observer in
            let request = Alamofire.request(modelFor500px.Router.PhotoInfo(photoId, imageSize))
                .validate()
                .responseObject() { (response: Response<PhotoInfo, NSError>) in
                    if let error = response.result.error {
                        observer.on(.Error(error))
                    } else if let object = response.result.value {
                        observer.on(.Next(object))
                        observer.on(.Completed)
                    } else {
                        observer.on(.Error(NSError(domain: "object not exists", code: -10003, userInfo: nil)))
                    }

            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
    func getPhotoUrl(photoId: Int, imageSize: modelFor500px.ImageSize = modelFor500px.ImageSize.XLarge) -> Observable<(String,(NSURL, NSHTTPURLResponse) -> NSURL)> {
        return Observable.create { observer in
            let request = Alamofire.request(modelFor500px.Router.PhotoInfo(photoId, imageSize))
                .validate()
                .responseJSON() { response in
                    if let error = response.result.error {
                        observer.on(.Error(error))
                    } else if let object = response.result.value {
                        let dict = object as! NSDictionary
                        let imageURL = dict.valueForKeyPath("photo.image_url") as! String
                        let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = { temporaryURL, response in
                            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                            let pathComponent = response.suggestedFilename
                            return directoryURL.URLByAppendingPathComponent("\(photoId).\(pathComponent)")
                        }
                        let result = (imageURL, destination)
                        observer.on(.Next(result))
                        observer.on(.Completed)
                    } else {
                        observer.on(.Error(NSError(domain: "json not exists", code: -10001, userInfo: nil)))
                    }
                    
            }
            return AnonymousDisposable {
                request.cancel()
            } 
        }
    }
    
    func getComments(photoId: Int) -> Observable<[Comment]> {
        return Observable.create { observer in
            let request = Alamofire.request(modelFor500px.Router.Comments(photoId, 1)).validate().responseCollection() {
                (response: Response<[Comment], NSError>) in
                
                if let error = response.result.error {
                    observer.on(.Error(error))
                } else if let comments = response.result.value {
                    observer.on(.Next(comments))
                    observer.on(.Completed)
                } else {
                    observer.on(.Error(NSError(domain: "comments not exists", code: -10004, userInfo: nil)))
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
}
