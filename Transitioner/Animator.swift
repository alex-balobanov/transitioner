//
//  Created by Alex Balobanov on 4/28/17.
//  Copyright © 2017 ITlekt Corporation. All rights reserved.
//

import UIKit

public protocol TransitionerAnimatorProtocol: UIViewControllerAnimatedTransitioning {
	var animationInProgress: Bool { get }
	init(_ presentation: Bool)
	func animate(presentation: Bool, using transitionContext: UIViewControllerContextTransitioning)
	func percentComplete(presentation: Bool, using recognizer: UIPanGestureRecognizer) -> CGFloat
}

public class TransitionerAnimator: NSObject, TransitionerAnimatorProtocol {
	private let isPresentation: Bool
	
	// MARK: TransitionerAnimatorProtocol

	private(set) public var animationInProgress = false

	required public init(_ presentation: Bool) {
		isPresentation = presentation
	}
	
	public func animate(presentation: Bool, using transitionContext: UIViewControllerContextTransitioning) {
	}
	
	public func percentComplete(presentation: Bool, using recognizer: UIPanGestureRecognizer) -> CGFloat {
		return 0
	}
	
	// MARK: UIViewControllerAnimatedTransitioning
	
	// This is used for percent driven interactive transitions, as well as for
	// container controllers that have companion animations that might need to
	// synchronize with the main animation.
	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}
	
	// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		animationInProgress = true
		animate(presentation: isPresentation, using: transitionContext)
	}
	
	// This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
	public func animationEnded(_ transitionCompleted: Bool) {
		animationInProgress = false
	}
	
	// MARK: UIPercentDrivenInteractiveTransition
	
}
