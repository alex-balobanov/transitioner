//
//  Created by Alex Balobanov on 4/28/17.
//  Copyright © 2017 ITlekt Corporation. All rights reserved.
//

import UIKit

public protocol TransitionerProtocol: NSObjectProtocol {
	var presentation: TransitionerAnimatorProtocol { get }
	var dismissal: TransitionerAnimatorProtocol { get }
	var interactionInProgress: Bool { get }
	
	func startInteraction()
	func updateInteraction(_ percentComplete: CGFloat)
	func finishInteraction() -> Bool
	
	func enableInteractivePresent(for parent: UIViewController, on edge: UIRectEdge, using creator: @escaping ((Void) -> UIViewController))
}

public class Transitioner<P: TransitionerAnimatorProtocol, D: TransitionerAnimatorProtocol>: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate, TransitionerProtocol {
	
	private var creator: ((Void) -> UIViewController)?
	private weak var parent: UIViewController?
	
	internal func transitionerHandlePresentPanGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			if let viewController = creator?(), let parentViewController = parent {
				startInteraction()
				viewController.transitioningDelegate = self
				parentViewController.present(viewController, animated: true, completion: nil)
			}
			
		case .changed:
			let percentComplete = dismissal.percentComplete(presentation: true, using: recognizer)
			updateInteraction(percentComplete)
			
		case .ended, .cancelled:
			if finishInteraction() {
				//transitionerDidPresentViewController()
			}
			
		default:
			break
		}
	}
	
	// MARK: - TransitionerProtocol
	
	public let presentation: TransitionerAnimatorProtocol = P(true)
	public let dismissal: TransitionerAnimatorProtocol = D(false)
	private(set) public var interactionInProgress = false
	
	public func enableInteractivePresent(for parent: UIViewController, on edge: UIRectEdge, using creator: @escaping ((Void) -> UIViewController)) {
		let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(transitionerHandlePresentPanGesture(recognizer:)))
		recognizer.edges = edge
		parent.view.addGestureRecognizer(recognizer)
		self.creator = creator
		self.parent = parent
	}
	
	
	public func startInteraction() {
		interactionInProgress = true
	}
	
	public func updateInteraction(_ percentComplete: CGFloat) {
		if interactionInProgress && (presentation.animationInProgress || dismissal.animationInProgress) {
			update(percentComplete)
		}
	}
	
	public func finishInteraction() -> Bool {
		if interactionInProgress {
			interactionInProgress = false
			let complete = percentComplete > 0.5
			if complete {
				finish()
			}
			else {
				cancel()
			}
			return complete
		}
		return false
	}
	
	// MARK: - UIViewControllerTransitioningDelegate
	
	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return presentation
	}
	
	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return dismissal
	}
	
	public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interactionInProgress ? self : nil
	}
	
	public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interactionInProgress ? self : nil
	}
	
}
