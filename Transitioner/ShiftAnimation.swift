//
//  Created by Alex Balobanov on 6/5/17.
//  Copyright © 2017 ITlekt Corporation. All rights reserved.
//

import UIKit

public class ShiftAnimation: TransitionerAnimator {

	public enum Direction {
		case bottomToTop, topToBottom, leftToRight, rightToLeft
	}
	
	public var direction = Direction.bottomToTop
	
	override public func animate(presentation: Bool, using transitionContext: UIViewControllerContextTransitioning) {
		// offscreen/onscreen rects
		let onScreenRect = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
		var offScreenRectForTopView = onScreenRect
		var offScreenRectForBottomView = onScreenRect
		switch direction {
		case .bottomToTop:
			offScreenRectForTopView.origin.y += onScreenRect.height
			offScreenRectForBottomView.origin.y -= onScreenRect.height
		case .topToBottom:
			offScreenRectForTopView.origin.y -= onScreenRect.size.height
			offScreenRectForBottomView.origin.y += onScreenRect.size.height
		case .leftToRight:
			offScreenRectForTopView.origin.x -= onScreenRect.size.width
			offScreenRectForBottomView.origin.x += onScreenRect.size.width
		case .rightToLeft:
			offScreenRectForTopView.origin.x += onScreenRect.size.width
			offScreenRectForBottomView.origin.x -= onScreenRect.size.width
		}
		
		// from/to views
		let topView = transitionContext.view(forKey: presentation ? .to : .from)!
		let bottomView = transitionContext.view(forKey: presentation ? .from : .to)!
		
		// add views to the container view
		transitionContext.containerView.addSubview(topView)
		transitionContext.containerView.addSubview(bottomView)
		
		// set initial frames
		topView.frame = presentation ? offScreenRectForTopView : onScreenRect
		bottomView.frame = presentation ? onScreenRect : offScreenRectForBottomView
		
		// animation
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			topView.frame = presentation ? onScreenRect : offScreenRectForTopView
			bottomView.frame = presentation ? offScreenRectForBottomView : onScreenRect
		}, completion: { finished in
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
