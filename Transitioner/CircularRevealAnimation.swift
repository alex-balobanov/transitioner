//
//  Created by Alex Balobanov on 4/30/17.
//  Copyright © 2017 ITlekt Corporation. All rights reserved.
//

import UIKit

public class CircularRevealAnimation: TransitionerAnimator {
	
	public weak var sourceView: UIView?
	
	override public func animate(presentation: Bool, using transitionContext: UIViewControllerContextTransitioning) {
		// the final view's rect
		let finalRect = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
		
		// the source mask layer rect
		let sourceMaskRect: CGRect
		if let sourceView = sourceView, let sourceViewSuperView = sourceView.superview {
			// source view's rect (i.g. button)
			let frame = sourceViewSuperView.convert(sourceView.frame, to: transitionContext.containerView)
			let edge = min(frame.width, frame.height)
			sourceMaskRect = CGRect(x: frame.origin.x + (frame.width - edge) / 2, y: frame.origin.y + (frame.height - edge) / 2, width: edge, height: edge)
		}
		else {
			// 8x8 rect at the center of the final rect
			sourceMaskRect = CGRect(x: finalRect.width / 2, y: finalRect.height / 2, width: 8, height: 8)
		}
		
		// the destination mask layer rects
		let edge = CGFloat(hypotf(Float(finalRect.width), Float(finalRect.height)))
		let destMaskRect = CGRect(x: -(edge - finalRect.width) / 2, y: -(edge - finalRect.height) / 2, width: edge, height: edge)
		
		// set vars in depends on presentation/dismissal
		let maskRectFrom: CGRect
		let maskRectTo: CGRect
		let alphaFrom: CGFloat
		let alphaTo: CGFloat
		let topView: UIView
		let bottomView: UIView
		
		if presentation {
			maskRectFrom = sourceMaskRect
			maskRectTo = destMaskRect
			alphaFrom = 0.0
			alphaTo = 1.0
			topView = transitionContext.view(forKey: .to)!
			bottomView = transitionContext.view(forKey: .from)!
		}
		else {
			maskRectFrom = destMaskRect
			maskRectTo = sourceMaskRect
			alphaFrom = 1.0
			alphaTo = 0.0
			topView = transitionContext.view(forKey: .from)!
			bottomView = transitionContext.view(forKey: .to)!
		}
		
		// add views to the container view
		transitionContext.containerView.addSubview(bottomView)
		transitionContext.containerView.addSubview(topView)
		topView.frame = finalRect
		topView.alpha = alphaTo
		bottomView.frame = finalRect
		
		// set mask layer
		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(ovalIn: maskRectTo).cgPath
		topView.layer.mask = maskLayer
		
		// animation
		let duration = transitionDuration(using: transitionContext)
		CATransaction.begin()
		CATransaction.setCompletionBlock({
			topView.layer.mask = nil
			let cancelled = transitionContext.transitionWasCancelled
			if cancelled {
				topView.alpha = alphaFrom
			}
			transitionContext.completeTransition(!cancelled)
		})
		
		// path animation
		let changePath = CABasicAnimation(keyPath: "path")
		changePath.duration = duration
		changePath.fromValue = UIBezierPath(ovalIn: maskRectFrom).cgPath
		changePath.toValue = UIBezierPath(ovalIn: maskRectTo).cgPath
		maskLayer.add(changePath, forKey: "changePath")
		
		// top view opacity animation
		let changeOpacity = CABasicAnimation(keyPath: "opacity")
		changeOpacity.duration = duration
		changeOpacity.fromValue = alphaFrom
		changeOpacity.toValue = alphaTo
		topView.layer.add(changeOpacity, forKey: "changeOpacity")
		CATransaction.commit()
	}
	
	override public func percentComplete(presentation: Bool, using recognizer: UIPanGestureRecognizer) -> CGFloat {
		// calculate completion percentage using tap gesture recognizer
		let translation = recognizer.translation(in: recognizer.view)
		let size = recognizer.view!.bounds.size
		return CGFloat(hypotf(fabs(Float(translation.x)), fabs(Float(translation.y)))) / (min(size.width, size.height) / 2)
	}
	
}
