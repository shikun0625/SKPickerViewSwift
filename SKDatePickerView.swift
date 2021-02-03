//
//  SKDatePickerView.swift
//  MoneyEveryday
//
//  Created by 施　坤 on 2021/01/29.
//

import UIKit

private let SCREEN_WIDTH                    = UIScreen.main.bounds.width
private let SCREEN_HEIGHT                   = UIScreen.main.bounds.height


public class SKDatePickerView: UIView {
    
    
    @available(iOS 13.4, *)
    static var style: UIDatePickerStyle                                 = .automatic
    static var maxDate: Date?
    static var minDate: Date?
    static var minuteInterval: SKDatePickerMinuteInterval               = .fiveMinutes
    static var theme:SKPickerViewTheme                                  = .defalut
    static var backgroundColor: [UIColor]                               = [UIColor.white, UIColor.black]
    static var pickerColor: [UIColor]                                   = [UIColor.init(red: 0.996, green: 0.957, blue: 0.906, alpha: 1), UIColor.init(red: 0.251, green: 0.251, blue: 0.251, alpha: 1)]
    static var toolbarColor: [UIColor]                                  = [UIColor.init(red: 0.918, green: 0.918, blue: 0.886, alpha: 1), UIColor.init(red: 0.173, green: 0.173, blue: 0.173, alpha: 1)]
    static var toolbarTint: [UIColor]                                   = [UIColor.init(red: 0.0, green: 0.627, blue: 0.776, alpha: 1), UIColor.white]
    static var showToolbar: Bool                                        = false         // false, when pickerView disappeared that will auto send confirmPick event,
                                                                                        // true, only press Done button that will send confirmPick event
    
    private var callback:(_ event: SKPickerEvent, _ date: Date) -> Void = {_,_ in }
    private let backgroundView: UIView = UIView.init()
    private let toolBar: UIView = UIView.init()
    private let picker: UIDatePicker = UIDatePicker.init()
    private let doneButton: UIButton = UIButton.init(type: .system)
    
    /*
     data only support Array<String>, Dictionary<String, Array<String>>, Dictionary<String, Array<Dictionary<String, Array<String>>>>...
     */
    static func ShowPicker(_ date:Date?, _ pickType:UIDatePicker.Mode, _ callback:@escaping (_ event: SKPickerEvent, _ date: Date) -> Void) {
        let pickView =  SKDatePickerView(date, pickType, callback);
        if pickView != nil {
            pickView!.show()
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init?(_ date:Date?, _ pickType:UIDatePicker.Mode, _ callback:@escaping (_ event: SKPickerEvent, _ date: Date) -> Void) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.backgroundColor = UIColor.clear
        self.callback = callback
        
        self.backgroundView.frame = self.frame
        self.backgroundView.alpha = 0
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.backgroundViewPressed(gestureRecognizer:))))
        self.addSubview(self.backgroundView)
        
        if SKDatePickerView.showToolbar {
            self.toolBar.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 30)
            self.addSubview(self.toolBar)
            self.doneButton.setTitle("Done", for: .normal)
            self.doneButton.sizeToFit()
            self.doneButton.frame = CGRect.init(x: self.toolBar.frame.width - 15 - self.doneButton.frame.width, y: (self.toolBar.frame.height - self.doneButton.frame.height) / 2.0, width: self.doneButton.frame.width, height: self.doneButton.frame.height)
            self.doneButton.addTarget(self, action: #selector(toolDonePressed(sender:)), for: .touchUpInside)
            self.toolBar.addSubview(self.doneButton)
        } else {
            self.toolBar.frame = CGRect.init()
        }
        
        
        if #available(iOS 13.4, *)  {
            self.picker.preferredDatePickerStyle = SKDatePickerView.style
            self.picker.sizeToFit()
        }
        if self.picker.frame.height < 50 {
            self.picker.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT + self.toolBar.frame.size.height, width: SCREEN_WIDTH, height: 100)
        } else {
            self.picker.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT + self.toolBar.frame.size.height, width: SCREEN_WIDTH, height: self.picker.frame.height)
        }
        self.picker.datePickerMode = pickType
        self.picker.maximumDate = SKDatePickerView.maxDate
        self.picker.minimumDate = SKDatePickerView.minDate
        self.picker.minuteInterval = SKDatePickerView.minuteInterval.rawValue
        if date != nil {
            self.picker.date = date!
        }
        self.picker.addTarget(self, action: #selector(valueChange(picker:)), for: .valueChanged)
        self.addSubview(self.picker)
        
        let window = UIApplication.shared.windows.last
        window?.rootViewController?.view.addSubview(self)
       
        if #available(iOS 13.0, *) {
            let currentMode = UITraitCollection.current.userInterfaceStyle
            if SKDatePickerView.theme == .defalut {
                if currentMode == .dark {
                    self.setTheme(.Dark)
                } else {
                    self.setTheme(.Light)
                }
            } else {
                self.setTheme(SKDatePickerView.theme)
            }
        } else {
            self.setTheme(.Light)
        }
    }
    
    private func show() {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        self.callback(.willAppare, self.picker.date)
        UIView .animate(withDuration: 0.5) {
            self.backgroundView.alpha = 0.5
            self.toolBar.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT - self.picker.frame.height - self.toolBar.frame.height, width: SCREEN_WIDTH, height: self.toolBar.frame.height)
            self.picker.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT - self.picker.frame.height, width: SCREEN_WIDTH, height: self.picker.frame.height)
        } completion: { (Bool) in
            self.callback(.didAppare, self.picker.date)
        }
        
    }
    
    private func setTheme(_ theme: SKPickerViewTheme) {
        self.backgroundView.backgroundColor = SKDatePickerView.backgroundColor[theme.rawValue]
        self.picker.backgroundColor = SKDatePickerView.pickerColor[theme.rawValue]
        self.toolBar.backgroundColor = SKDatePickerView.toolbarColor[theme.rawValue]
        self.doneButton.setTitleColor(SKDatePickerView.toolbarTint[theme.rawValue], for: .normal)
    }
    
    @objc private func backgroundViewPressed(gestureRecognizer: UITapGestureRecognizer) {
        if SKDatePickerView.showToolbar {
            self.callback(.cancelPick, self.picker.date)
        } else {
            self.callback(.confirmPick, self.picker.date)
        }
        self.hide()
    }
    
    private func hide() {
        self.callback(.willDisappare, self.picker.date)
        UIView.animate(withDuration: 0.5) {
            self.backgroundView.alpha = 0
            self.picker.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT + self.toolBar.frame.height, width: SCREEN_WIDTH, height: self.picker.frame.height)
            self.toolBar.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: self.toolBar.frame.height)
        } completion: { (Bool) in
            self.callback(.didDisappare, self.picker.date)
            self.removeFromSuperview()
        }
    }
    
    
    @objc private func toolDonePressed(sender: UIButton) {
        self.callback(.confirmPick, self.picker.date)
        self.hide()
    }
  
    @objc private func valueChange(picker: UIDatePicker) {
        self.callback(.valueChanged, picker.date)
    }
}
