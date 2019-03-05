//
//  YZHud.swift
//  TTTLive
//
//  Created by yanzhen on 2018/11/14.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit

private let YZHudBlack = false
private let YZHudWH: CGFloat = 80
private let YZHudRate: CGFloat = 0.7
private let YZHudShowViewCornerRadius: CGFloat = 5

class YZHud: UIView {

    private var hudView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hudView = UIView()
        hudView.backgroundColor = YZHudBlack ? UIColor.black : UIColor(white: 0.8, alpha: 0.6)
        hudView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        hudView.layer.cornerRadius = 5
        addSubview(hudView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hudView.center = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YZHud {
    class func showHud(_ view: UIView, message: String = "", color: UIColor? = nil) {
        hideHud(for: view)
        let hud = YZHud(frame: view.bounds)
        hud.build(message, color: color)
        view.addSubview(hud)
    }
    
    class func hideHud(for view: UIView, animated: Bool = false) {
        for subView in view.subviews where subView is YZHud {
            if animated {
                UIView.animate(withDuration: 1, animations: {
                    subView.alpha = 0
                }, completion: { (finished) in
                    subView.removeFromSuperview()
                })
            }else{
                subView.removeFromSuperview()
            }
        }
    }
}

private extension YZHud {
    func build(_ message: String, color: UIColor?) {
        if message == "" {
            let indicatorView = buildHudActivityIndicatorView()
            hudView.frame = CGRect(x: 0, y: 0, width: YZHudWH, height: YZHudWH)
            indicatorView.center = CGPoint(x: YZHudWH / 2, y: YZHudWH / 2)
            return
        }
        
        let indicatorView = buildHudActivityIndicatorView()
        newTitleForHud(indicatorView, message: message, textColor: color)
    }
    
    func newTitleForHud(_ view: UIView, message: String, textColor: UIColor?) {
        let titleLabel = buildHudTitleLabel()
        titleLabel.text = message
        if let textColor = textColor {
            titleLabel.textColor = textColor
        }
        let maxSize = CGSize(width: bounds.size.width * YZHudRate, height: bounds.size.height * YZHudRate)
        let textSize = message.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : titleLabel.font], context: nil).size
        let padding: CGFloat = 15
        var showW = textSize.width + padding * 2;
        if showW < YZHudWH {
            showW = YZHudWH
        }
        let showH = padding + view.frame.size.height + padding * 2.34
        hudView.frame = CGRect(x: 0, y: 0, width: showW, height: showH)
        view.center = CGPoint(x: showW * 0.5, y: view.frame.size.height * 0.5 + padding)
        titleLabel.frame = CGRect(x: padding, y: view.frame.maxY + padding / 3, width: showW - padding * 2, height: padding + 2)
    }
    
    func buildHudActivityIndicatorView() -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicatorView.color = YZHudBlack ? UIColor.white : UIColor.black
        indicatorView.startAnimating()
        hudView.addSubview(indicatorView)
        return indicatorView
    }
    
    func buildHudTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = YZHudBlack ? UIColor.white : UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.backgroundColor = UIColor.clear
        hudView.addSubview(titleLabel)
        return titleLabel
    }
}

