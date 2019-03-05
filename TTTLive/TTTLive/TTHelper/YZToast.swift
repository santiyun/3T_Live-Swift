import UIKit

extension UIView {
    
    func showToast(_ message: String, duration: TimeInterval = 2.5) {
        let backView = messageView(message)
        showToast(backView, duration: duration)
    }
}

private extension UIView {
    func showToast(_ toast: UIView, duration: TimeInterval) {
        toast.isUserInteractionEnabled = false
        toast.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        toast.alpha = 0
        addSubview(toast)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            toast.alpha = 1
        }) { (easeOut) in
            UIView.animate(withDuration: 0.2, delay: duration, options: .curveEaseIn, animations: {
                toast.alpha = 0
            }) { (easeOut) in
                toast.removeFromSuperview()
            }
        }
    }
    
    func messageView(_ message: String) -> UIView {
        let toast = UIView()
        toast.backgroundColor = UIColor.black
        toast.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        toast.layer.cornerRadius = 3
        //
        toast.layer.shadowColor = UIColor.black.cgColor
        toast.layer.shadowOpacity = 1
        toast.layer.shadowRadius = 6
        toast.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        //label
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        let font = UIFont.systemFont(ofSize: 16)
        messageLabel.font = font
        messageLabel.textColor = UIColor.white
        messageLabel.text = message
        
        let maxSize = CGSize(width: bounds.size.width * 0.8, height: bounds.size.height * 0.8)
        let messageSize = message.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).size
        messageLabel.frame = CGRect(x: 10, y: 10, width: messageSize.width, height: messageSize.height)
        toast.frame = CGRect(x: 0, y: 0, width: messageSize.width + 2 * 10, height: messageSize.height + 2 * 10)
        toast.addSubview(messageLabel)
        return toast
    }
    
}

extension UIViewController {
    func showToast(_ message: String) {
        view.showToast(message)
    }
}

