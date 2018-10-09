//
//  TTTSettingViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/9/11.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit

class TTTSettingViewController: UIViewController {

    @IBOutlet private weak var localView: UIView!
    @IBOutlet private weak var cdnView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveSettings(_ sender: Any) {
        var localVC: TTTSLocalViewController? = nil
        var cdnVc: TTTSCdnViewController? = nil
        for vc in childViewControllers {
            if vc is TTTSLocalViewController {
                localVC = vc as? TTTSLocalViewController
            } else if vc is TTTSCdnViewController {
                cdnVc = vc as? TTTSCdnViewController
            }
        }
        if let localError = localVC?.saveAction() {
            showToast(localError)
            return
        }
        
        if let cdnError = cdnVc?.saveAction() {
            showToast(cdnError)
            return
        }
        TTManager.isCustom = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingChoiceAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            localView.isHidden = false
            cdnView.isHidden = true
            view.bringSubview(toFront: localView)
        } else {
            localView.isHidden = true
            cdnView.isHidden = false
            view.bringSubview(toFront: cdnView)
        }
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
