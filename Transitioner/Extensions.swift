//
//  Created by Alex Balobanov on 4/28/17.
//  Copyright © 2017 ITlekt Corporation. All rights reserved.
//

import UIKit

extension UIViewController {
	
	// MARK: - Transitioner

	public var transitioner: TransitionerProtocol {
		guard let transitioner = transitioningDelegate as? TransitionerProtocol else {
			fatalError("This view controller doesn't use Transitioner: \(self)")
		}
		return transitioner
	}
	
	// MARK: - Dismissal
	
	public func transitionerEnableInteractiveDissmiss() {
		let recognizer = UIPanGestureRecognizer(target: self, action: #selector(transitionerHandleDissmissPanGesture(recognizer:)))
		view.addGestureRecognizer(recognizer)
	}
	
	open func transitionerDidDismissViewController() {
	}
	
	internal func transitionerHandleDissmissPanGesture(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			transitioner.startInteraction()
			dismiss(animated: true, completion: nil)
			
		case .changed:
			let percentComplete = transitioner.dismissal.percentComplete(presentation: false, using: recognizer)
			transitioner.updateInteraction(percentComplete)
			
		case .ended, .cancelled:
			if transitioner.finishInteraction() {
				transitionerDidDismissViewController()
			}
			
		default:
			break
		}
	}
	
}
