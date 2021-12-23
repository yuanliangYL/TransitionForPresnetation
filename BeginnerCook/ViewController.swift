/*
* Copyright (c) 2014-present Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

let herbs = HerbModel.all()

class ViewController: UIViewController {
  
  @IBOutlet var listView: UIScrollView!
  @IBOutlet var bgImage: UIImageView!
  var selectedImage: UIImageView?

  let transition = PopAnimator()

  //MARK: UIViewController

    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }

  override func viewDidLoad() {
    super.viewDidLoad()

    transition.dismissCompletion = {
        self.selectedImage!.isHidden = false
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if listView.subviews.count < herbs.count {
      while let view = listView.viewWithTag(0) {
        view.tag = 1000 //prevent confusion when looking up images
      }
      setupList()
    }

  }



  //MARK: View setup
  
  //add all images to the list
  func setupList() {
    
    for i in herbs.indices {
      
      //create image view
      let imageView  = UIImageView(image: UIImage(named: herbs[i].image))
      imageView.tag = i
      imageView.contentMode = .scaleAspectFill
      imageView.isUserInteractionEnabled = true
      imageView.layer.cornerRadius = 20.0
      imageView.layer.masksToBounds = true
      listView.addSubview(imageView)
      
      //attach tap detector
      imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))
    }
    
    listView.backgroundColor = UIColor.clear
    positionListItems()
  }
  
  //position all images inside the list
  func positionListItems() {

    let listHeight = listView.frame.height
    let itemHeight: CGFloat = listHeight * 1.33
    let aspectRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    let itemWidth: CGFloat = itemHeight / aspectRatio
    
    let horizontalPadding: CGFloat = 10.0
    
    for i in herbs.indices {

      let imageView = listView.viewWithTag(i) as! UIImageView
      imageView.frame = CGRect(
        x: CGFloat(i) * itemWidth + CGFloat(i+1) * horizontalPadding, y: 0.0,
        width: itemWidth, height: itemHeight)
    }
    
    listView.contentSize = CGSize(
      width: CGFloat(herbs.count) * (itemWidth + horizontalPadding) + horizontalPadding,
      height:  0)
  }
  
  //MARK: Actions
  
  @objc func didTapImageView(_ tap: UITapGestureRecognizer) {

    selectedImage = tap.view as? UIImageView
    
    let index = tap.view!.tag
    let selectedHerb = herbs[index]
    
    //present details view controller
    let herbDetails = storyboard!.instantiateViewController(withIdentifier: "HerbDetailsViewController") as! HerbDetailsViewController
    herbDetails.herb = selectedHerb
    herbDetails.modalPresentationStyle = .overFullScreen
    herbDetails.transitioningDelegate = self
    present(herbDetails, animated: true, completion: nil)
  }


//    屏幕旋转转场
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { context in
      self.bgImage.alpha = (size.width>size.height) ? 0.25 : 0.55
      self.positionListItems()
    }, completion: nil)


  }
}

// MARK: -- 控制器转场协议实现
extension ViewController: UIViewControllerTransitioningDelegate {

    //Presented和Presengting,这也是一组相对的概念，它容易与fromView和toView混淆。简单来说，它不受present或dismiss的影响，如果是从A视图控制器present到B，那么A总是presentedViewController,B总是presentingViewController。
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

      //将转场动画的originFrame设置为selectedImage的frame，并在动画期间隐藏初始图像
    //// 将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect
    transition.originFrame = selectedImage!.superview!.convert(selectedImage!.frame, to: view)
      print(selectedImage!.superview?.frame as Any,selectedImage!.frame,transition.originFrame,view.convert(selectedImage!.frame, from: selectedImage!.superview!))

    transition.presenting = true

    selectedImage!.isHidden = true
    return transition

  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

      //操作标签：dismiss
    transition.presenting = false

    return transition

  }
}
