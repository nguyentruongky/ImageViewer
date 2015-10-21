//
//  ImageViewerController.swift
//  ImageViewer
//
//  Created by Ky Nguyen on 10/9/15.
//  Copyright © 2015 Ky Nguyen. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController, UIScrollViewDelegate {

    var image = UIImage()
    var imageView = UIImageView()
    var pan = UIPanGestureRecognizer()
    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        
        view.addSubview(scrollView)
    }

    func setupScrollView() {
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.delegate = self
        
        registerScrollViewTapGesture()
    }
    
    func registerScrollViewTapGesture() {
        
        let tapOnce = UITapGestureRecognizer.init(target: self, action: Selector("tapOnceAction"))
        let tapTwice = UITapGestureRecognizer.init(target: self, action: Selector("tapTwiceAction:"))
        
        tapOnce.numberOfTapsRequired = 1
        tapTwice.numberOfTapsRequired = 2
        tapOnce.requireGestureRecognizerToFail(tapTwice)
        
        scrollView.addGestureRecognizer(tapOnce)
        scrollView.addGestureRecognizer(tapTwice)
    }
    
    func centerPictureFromPoint(point: CGPoint, ofSize size: CGSize) {
        
        setupImageView(point, ofSize: size)
        
        scrollView.addSubview(imageView)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            let newSize = self.calculateNewSize()
            
            self.imageView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, newSize.newWidth, newSize.newHeight)
            
            self.imageView.center = self.scrollView.center
            
            self.view.backgroundColor = UIColor.blackColor()
            
            }) { (Bool) -> Void in
                
                UIApplication.sharedApplication().statusBarHidden = true
                
                self.pan = UIPanGestureRecognizer.init(target: self, action: Selector("moveImage:"))

                self.scrollView.addGestureRecognizer(self.pan)
        }
    }
    
    func calculateNewSize() -> (newWidth: CGFloat, newHeight: CGFloat) {
        
        let imageWidth = self.image.size.width
        let imageHeight = self.image.size.height
        let imageRatio = imageWidth / imageHeight
        let viewRatio = self.view.frame.size.width / self.view.frame.size.height
        
        var ratio: CGFloat = 0
        if imageRatio >= viewRatio {
            
            ratio = imageWidth / self.view.frame.size.width
        }
        else {
            
            ratio = imageHeight / self.view.frame.size.height
        }
        
        let newWidth = imageWidth / ratio
        let newHeight = imageHeight / ratio
        
        return (newWidth, newHeight)
    }
    
    func setupImageView(point: CGPoint, ofSize size: CGSize) {
        
        imageView = UIImageView(frame: CGRectMake(point.x, point.y, size.width, size.height))
        imageView.clipsToBounds = true
        
        imageView.image = image
    }

    func tapOnceAction() {
        
        if self.scrollView.zoomScale != self.scrollView.minimumZoomScale {
            
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func tapTwiceAction(gestureRecognizer: UIGestureRecognizer) {
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            
            let zoomRect = zoomRectForScale(scrollView.maximumZoomScale, withCenter: gestureRecognizer.locationInView(gestureRecognizer.view))
            
            scrollView.zoomToRect(zoomRect, animated: true)
        }
        else {
            
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, var withCenter center: CGPoint) -> CGRect {
        
        var zoomRect = CGRect()
        
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        center = imageView.convertPoint(center, fromView: self.view)
        zoomRect.origin.x = center.x - ((zoomRect.size.width / 2))
        zoomRect.origin.y = center.y - ((zoomRect.size.height / 2))
        
        return zoomRect
    }
    
    func moveImage(gesture: UIPanGestureRecognizer) {
        
        let deltaY = gesture.translationInView(self.scrollView).y
        
        let translatedPoint = CGPointMake(self.view.center.x, self.view.center.y + deltaY)
        
        self.scrollView.center = translatedPoint
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            let velocityY = gesture.velocityInView(scrollView).y
            
            let maxDeltaY = (self.view.frame.size.height - self.imageView.frame.size.height) / 2

            // swipe down
            if velocityY > 700 || (abs(deltaY) > maxDeltaY && deltaY > 0) {

                swipeToRemove(1)
            }
                
            // swipe up
            else if velocityY < -700 || (abs(deltaY) > maxDeltaY && deltaY < 0) {
                
                swipeToRemove((-1))
            }
            else {
                
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    
                    self.scrollView.center = self.view.center
                })
            }
        }
    }
    
    /**
   
    Swipe up or down to exit fullscreen mode. direction: -1 is up; 1 is down
    
    */
    
    func swipeToRemove(direction: CGFloat) {
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.imageView.frame = CGRectMake(
                self.imageView.frame.origin.x,
                direction * self.imageView.frame.size.height,
                self.imageView.frame.size.width,
                self.imageView.frame.size.height)
            
            self.view.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
                self.view.removeFromSuperview()
        })

    }

    func centerScrollViewContents() {
        
        let boundSize = self.scrollView.bounds.size
        var contentFrame = self.imageView.frame
        
        setContentFrameX(&contentFrame, boundSize: boundSize)
        
        setContentFrameY(&contentFrame, boundSize: boundSize)

        imageView.frame = contentFrame
    }
    
    func setContentFrameY(inout contentFrame: CGRect, boundSize: CGSize) {
        
        if contentFrame.size.height < boundSize.height {
            
            contentFrame.origin.y = (boundSize.height - contentFrame.size.height) / 2
        }
        else {
            
            contentFrame.origin.y = 0.0
        }

    }
    
    func setContentFrameX(inout contentFrame: CGRect, boundSize: CGSize) {
        
        if (contentFrame.size.width < boundSize.width) {
            
            contentFrame.origin.x = (boundSize.width - contentFrame.size.width) / 2
        }
        else {
            
            contentFrame.origin.x = 0.0
        }

    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        centerScrollViewContents()
        
        addRemovePanGesture()
    }
    
    func addRemovePanGesture() {
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            
            scrollView.addGestureRecognizer(pan)
        }
        else {
            
            scrollView.removeGestureRecognizer(pan)
        }
    }

}

