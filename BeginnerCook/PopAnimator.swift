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

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  //时间
  let duration = 1.0
  //是用判断当前是呈现还是解除
  var presenting = true
  //用来存储用户点击的图像的原始 frame —— 呈现动画就是需要它从原始frame到全屏图像frame，对应的解除动画正好相反:以便动画执行返回原点
  var originFrame = CGRect.zero


  var dismissCompletion: (()->Void)?

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

      //fadaInFadeOut(transitionContext: transitionContext)
      //popAnimatin(transitionContext: transitionContext)
      presentationAnimation(transitionContext: transitionContext)

  }

}

//最终实现
extension PopAnimator{

    //呈现效果实现
    func presentationAnimation( transitionContext: UIViewControllerContextTransitioning){
        //获得动画将在其中进行的容器视图，
      let containerView = transitionContext.containerView


        //更多优化start:内容的平滑展现==========================================
        //获取呈现的控制器
        let herbController = transitionContext.viewController(forKey: presenting ? .to : .from) as! HerbDetailsViewController
        if presenting {
            //指定视图可见性
            herbController.containerView.alpha = 0.0
        }
        //更多优化end=============================================



        //在代码和文字中，经常会出现fromView和toView。如果错误的理解它们的含义会导致动画逻辑完全错误。fromView表示当前视图，toView表示要跳转到的视图。如果是从A视图控制器present到B，则A是from，B是to。从B视图控制器dismiss到A时，B变成了from，A是to
        //然后您将获取新视图并将其存储在toView中
        //这里始终是在获取被动花的竖图，也就是第二页
      let herbView = presenting ? transitionContext.view(forKey: .to)! : transitionContext.view(forKey: .from)!

        //前后状态下的初始frame
      let initialFrame = presenting ? originFrame : herbView.frame
        //前后状态下的最终frame：与initialFrame相反值
      let finalFrame = presenting ? herbView.frame : originFrame

        //xScaleFactor 和yScaleFactor分别是x轴和y轴上视图变化的比例因子（scale factor）
        var xScaleFactor:CGFloat = 0
        if presenting {
            xScaleFactor =  initialFrame.width / finalFrame.width
        }else{
            xScaleFactor =  finalFrame.width / initialFrame.width
        }

        //简洁语法
      let yScaleFactor = presenting ?
        initialFrame.height / finalFrame.height :
        finalFrame.height / initialFrame.height

        print(xScaleFactor,yScaleFactor)

        //形变比例
       let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        //呈现
      if presenting {

          //至于与点击图片相同的初始位置
        herbView.transform = scaleTransform
        herbView.center = CGPoint(
          x: initialFrame.midX,
          y: initialFrame.midY)
        herbView.clipsToBounds = true
      }
      //dismiss是toView为nil
      else{
          print(transitionContext.view(forKey: .to) ?? "toView is nil")
      }

      if let toView = transitionContext.view(forKey: .to) {
        containerView.addSubview(toView)
      }
      containerView.bringSubviewToFront(herbView)

      UIView.animate(withDuration: duration,
                     delay:0.0,
                     usingSpringWithDamping: 0.4,
                     initialSpringVelocity: 0.0,
                     animations: {


                      herbView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
                      herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)

                      //圆角
                      herbView.layer.cornerRadius = self.presenting ? 0.0 : 20.0/xScaleFactor
                      //内容效果
                      herbController.containerView.alpha = self.presenting ? 1.0 : 0.0

      }, completion: { _ in


        if !self.presenting {
          self.dismissCompletion?()
        }

        //调用了completeTransition()告诉UIKit转场动画已经完成
        transitionContext.completeTransition(true)

      })
    }

}


//测试效果
extension PopAnimator{

//    1淡出转场
    func fadaInFadeOut( transitionContext: UIViewControllerContextTransitioning){
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        containerView.addSubview(toView)
        toView.alpha = 0.0
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1.0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })

    }

//    2pop转场
    func popAnimatin(transitionContext: UIViewControllerContextTransitioning){

        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)! //containerView是动画将存在的地方，而toView是要呈现的新视图
        let herbView = presenting ? toView : transitionContext.view(forKey: .from)!

        //initialFrame和finalFrame分别是初始和最终动画的frame
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame

        //xScaleFactor 和yScaleFactor分别是x轴和y轴上视图变化的比例因子（scale factor）
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height

        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            herbView.clipsToBounds = true
        }
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(herbView)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            herbView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
