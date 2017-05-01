//
//  Created by Alex Balobanov on 4/28/17.
//  Copyright © 2017 ITlekt Corporation. All rights reserved.
//

import UIKit

public class SlideAnimation: TransitionerAnimator {
	
	public enum Direction {
		case bottomToTop, topToBottom, leftToRight, rightToLeft
	}
	
	public var direction = Direction.bottomToTop
	public var backgroundColor = Config.backgroundColor
	
	override public func animate(presentation: Bool, using transitionContext: UIViewControllerContextTransitioning) {
		// offscreen/onscreen rects
		let onScreenRect = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
		var offScreenRect = onScreenRect
		switch direction {
		case .bottomToTop:
			offScreenRect.origin.y += onScreenRect.height
		case .topToBottom:
			offScreenRect.origin.y -= onScreenRect.size.height
		case .leftToRight:
			offScreenRect.origin.x -= onScreenRect.size.width
		case .rightToLeft:
			offScreenRect.origin.x += onScreenRect.size.width
		}
		
		// semi-transparent background view
		let backgroundView = UIView()
		backgroundView.backgroundColor = presentation ? UIColor.clear : backgroundColor
		backgroundView.frame = onScreenRect
		
		// from/to views
		let topView = transitionContext.view(forKey: presentation ? .to : .from)!
		let bottomView = transitionContext.view(forKey: presentation ? .from : .to)
		
		// add views to the container view
		if let bottomView = bottomView {
			bottomView.frame = onScreenRect
			transitionContext.containerView.addSubview(bottomView)
		}
		transitionContext.containerView.addSubview(backgroundView)
		transitionContext.containerView.addSubview(topView)
		topView.frame = presentation ? offScreenRect : onScreenRect
		
		// animation
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			topView.frame = presentation ? onScreenRect : offScreenRect
			backgroundView.backgroundColor = presentation ? self.backgroundColor : UIColor.clear
		}, completion: { finished in
			backgroundView.removeFromSuperview()
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
		
	}
	
	override public func percentComplete(presentation: Bool, using recognizer: UIPanGestureRecognizer) -> CGFloat {
		// calculate completion percentage using tap gesture recognizer
		let translation = recognizer.translation(in: recognizer.view)
		let size = recognizer.view!.bounds.size
		var fraction = CGFloat(0)
		if (translation.x > 0 && direction == (presentation ? .leftToRight : .rightToLeft)) || (translation.x < 0 && direction == (presentation ? .rightToLeft : .leftToRight)) {
			fraction = fabs(translation.x) / size.width
		}
		else if (translation.y > 0 && direction == (presentation ? .topToBottom : .bottomToTop)) || (translation.y < 0 && direction == (presentation ? .bottomToTop : .topToBottom)) {
			fraction = fabs(translation.y) / size.height
		}
		return fraction
	}
	
}
