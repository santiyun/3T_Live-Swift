//
//  TLSViewController.swift
//  TTTLive
//
//  Created by yanzhen on 2018/12/10.
//  Copyright © 2018 yanzhen. All rights reserved.
//

import UIKit

class TLSViewController: UIViewController {

    @IBOutlet private weak var localView: UIView!
    @IBOutlet private weak var cdnView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveSettings(_ sender: Any) {
        var localVC: TLSLViewController? = nil
        var cdnVc: TLSCViewController? = nil
        for vc in childViewControllers {
            if vc is TLSLViewController {
                localVC = vc as? TLSLViewController
            } else if vc is TLSCViewController {
                cdnVc = vc as? TLSCViewController
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
        AppManager.isCustom = true
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
