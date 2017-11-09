//
//  ViewController.swift
//  Currency
//
//  Created by Robert O'Connor on 18/10/2017.
//  Edited by David Larkin
//  Copyright © 2017 WIT. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    var currencyArray = [Currency]()
    
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    var bottomConstraintConstant:CGFloat = 60.0
    

    
    //MARK Outlets
    //@IBOutlet weak var convertedLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var stackView : UIStackView!
    
    @IBOutlet weak var baseSymbol: UILabel!
    @IBOutlet weak var baseTextField: UITextField!
    @IBOutlet weak var baseFlag: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBOutlet weak var gbpSymbolLabel: UILabel!
    @IBOutlet weak var gbpValueLabel: UILabel!
    @IBOutlet weak var gbpFlagLabel: UILabel!
    
    @IBOutlet weak var usdSymbolLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var usdFlagLabel: UILabel!
    
    @IBOutlet weak var cadSymbolLabel: UILabel!
    @IBOutlet weak var cadValueLabel: UILabel!
    @IBOutlet weak var cadFlagLabel: UILabel!
    
    @IBOutlet weak var yenSymbolLabel: UILabel!
    @IBOutlet weak var yenValueLabel: UILabel!
    @IBOutlet weak var yenFlagLabel: UILabel!
    
    @IBOutlet weak var audSymbolLabel: UILabel!
    @IBOutlet weak var audValueLabel: UILabel!
    @IBOutlet weak var audFlagLabel: UILabel!
    
    @IBOutlet weak var cnySymbolLabel : UILabel!
    @IBOutlet weak var cnyValueLabel: UILabel!
    @IBOutlet weak var cnyFlagLabel: UILabel!
    
    @IBOutlet weak var eurSymbolLabel: UILabel!
    @IBOutlet weak var eurValueLabel: UILabel!
    @IBOutlet weak var eurFlagLabel: UILabel!
    
    
    //var indicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // create currency dictionary
        self.createCurrencyDictionary()
        
        self.addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        // get latest currency values
        getConversionTable()
        convertValue = 1
        
        // set up base currency screen items
        
        baseSymbol.text = baseCurrency.symbol
        baseFlag.text = baseCurrency.flag
        pickerView.selectRow(6, inComponent: 0, animated: false)
        
        // set up last updated date
        setLatestDate()
        
        //self.convert()
        
        // display currency info
        self.displayCurrencyInfo()
        
        // setup view mover
        baseTextField.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let char = currencyArray[row].name.index(currencyArray[row].name.startIndex, offsetBy: 0)
        let symbol = currencyArray[row].symbol
        let name:String = [currencyArray[row].name[char]] + symbol
        
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return currencyArray.count
    }
    
    //changes the base flag and symbol to match the new one
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        baseSymbol.text = currencyArray[row].symbol
        baseFlag.text = currencyArray[row].flag
        
        convert()
    }
    //change the style of status bar to white
    override func viewWillAppear(_ animated: Bool)
    {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //change status bar style back to default
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    //simple method to remove keyboard when tapped anywhere but the keyboard and reset constraint on textfield. Link:
    //https://www.youtube.com/watch?v=N3f0Esjc5aQ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        baseTextField.resignFirstResponder()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, animations:
        {
            self.bottomConstraint.constant = self.bottomConstraintConstant
            self.view.layoutIfNeeded()
        })
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
    }
    
    func setLatestDate()
    {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy hh:mm a"
        lastUpdatedDateLabel.text = dateformatter.string(from: lastUpdatedDate)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                    target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done,
                                                    target: self, action: #selector(ViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.baseTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        UIView.animate(withDuration: 0.25, animations:
        {
            //reset the constraint to original one
            self.bottomConstraint.constant = self.bottomConstraintConstant
            self.view.layoutIfNeeded()
        })
        
        self.baseTextField.resignFirstResponder()
    }
    
    //Method that is fired when keyboard is to show, idea from youtube link above
    @objc func keyboardWillShow(notification: Notification)
    {
        if let info = notification.userInfo
        {
            let rect = (info["UIKeyboardFrameEndUserInfoKey"] as! NSValue).cgRectValue //keyboard size
            
            // y position to get to with the text field
            let targetY = view.frame.size.height - rect.height - 20 - baseTextField.frame.size.height
            
            //the current position of the text field in the screen
            let textFieldY = stackView.frame.origin.y + baseTextField.frame.origin.y
            
            //difference of position to move to and current position of text field
            let difference = targetY - textFieldY
            
            //change the constraint to the pre-set constraint minus the difference to move the text field to the new position
            let targetOffsetConstraint = bottomConstraint.constant - difference
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations:
            {
                self.bottomConstraint.constant = targetOffsetConstraint
                self.view.layoutIfNeeded()
            })
        }
    }

    func createCurrencyDictionary()
    {
        currencyDict["GBP"] = Currency(name:"GBP", rate: 1, flag: "🇬🇧", symbol: "£")
        currencyArray.append(currencyDict["GBP"]!)
        currencyDict["USD"] = Currency(name:"USD", rate: 1, flag: "🇺🇸", symbol: "$")
        currencyArray.append(currencyDict["USD"]!)
        currencyDict["CAD"] = Currency(name:"CAD", rate: 1, flag: "🇨🇦", symbol: "$")
        currencyArray.append(currencyDict["CAD"]!)
        currencyDict["JPY"] = Currency(name:"JPY", rate: 1, flag: "🇯🇵", symbol: "¥")
        currencyArray.append(currencyDict["JPY"]!)
        currencyDict["AUD"] = Currency(name:"AUD", rate: 1, flag: "🇦🇺", symbol: "$")
        currencyArray.append(currencyDict["AUD"]!)
        currencyDict["CNY"] = Currency(name:"CNY", rate: 1, flag: "🇨🇳", symbol: "¥")
        currencyArray.append(currencyDict["CNY"]!)
        currencyDict["EUR"] = Currency(name:"EUR", rate: 1, flag: "🇪🇺", symbol: "€")
        currencyArray.append(currencyDict["EUR"]!)
        
    }
    
    func displayCurrencyInfo()
    {
        if let c = currencyDict["GBP"]
        {
            gbpSymbolLabel.text = c.symbol
            gbpValueLabel.text = String(format: "%.02f", c.rate)
            gbpFlagLabel.text = c.flag
        }
        if let c = currencyDict["USD"]
        {
            usdSymbolLabel.text = c.symbol
            usdValueLabel.text = String(format: "%.02f", c.rate)
            usdFlagLabel.text = c.flag
        }
        if let c = currencyDict["CAD"]
        {
            cadSymbolLabel.text = c.symbol
            cadValueLabel.text = String(format: "%.02f", c.rate)
            cadFlagLabel.text = c.flag
        }
        if let c = currencyDict["JPY"]
        {
            yenSymbolLabel.text = c.symbol
            yenValueLabel.text = String(format: "%.02f", c.rate)
            yenFlagLabel.text = c.flag
        }
        if let c = currencyDict["AUD"]
        {
            audSymbolLabel.text = c.symbol
            audValueLabel.text = String(format: "%.02f", c.rate)
            audFlagLabel.text = c.flag
        }
        if let c = currencyDict["CNY"]
        {
            cnySymbolLabel.text = c.symbol
            cnyValueLabel.text = String(format: "%.02f", c.rate)
            cnyFlagLabel.text = c.flag
        }
        if let c = currencyDict["EUR"]
        {
            eurSymbolLabel.text = c.symbol
            eurValueLabel.text = String(format: "%.02f", c.rate)
            eurFlagLabel.text = c.flag
        }
    }
  
    
    func getConversionTable()
    {

        let urlStr:String = "https://api.fixer.io/latest"
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
 
        URLSession.shared.dataTask(with: request)
        { data, response, error in
            
            DispatchQueue.main.async(execute:
            {
                indicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }) // stop animating

            if error == nil
            {
                do
                {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    
                    if let ratesData = jsonDict["rates"] as? NSDictionary
                    {
                        for rate in ratesData
                        {
                            let name = String(describing: rate.key)
                            let rate = (rate.value as? NSNumber)?.doubleValue
                            
                            switch(name)
                            {
                            case "USD":
                                //symbol = "$"
                                //flag = "🇺🇸"
                                let c:Currency  = self.currencyDict["USD"]!
                                c.rate = rate!
                                self.currencyDict["USD"] = c
                            case "GBP":
                                //symbol = "£"
                                //flag = "🇬🇧"
                                let c:Currency  = self.currencyDict["GBP"]!
                                c.rate = rate!
                                self.currencyDict["GBP"] = c
                            case "CAD":
                                //symbol = "$"
                                //flag = "🇨🇦"
                                let c:Currency = self.currencyDict["CAD"]!
                                c.rate = rate!
                                self.currencyDict["CAD"] = c
                            case "AUD":
                                //symbol = "$"
                                //flag = "🇦🇺"
                                let c:Currency = self.currencyDict["AUD"]!
                                c.rate = rate!
                                self.currencyDict["AUD"] = c
                            case "JPY":
                                //symbol = "¥"
                                //flag = "🇯🇵"
                                let c:Currency = self.currencyDict["JPY"]!
                                c.rate = rate!
                                self.currencyDict["JPY"] = c
                            case "CNY":
                                //symbol = "¥"
                                //flag = "🇨🇳"
                                let c:Currency = self.currencyDict["CNY"]!
                                c.rate = rate!
                                self.currencyDict["CNY"] = c
                            case "EUR":
                                let c:Currency = self.currencyDict["EUR"]!
                                c.rate = rate!
                                self.currencyDict["EUR"] = c
                            default:
                                print("Ignoring currency: \(String(describing: rate))")
                            }
                        }
                        self.lastUpdatedDate = Date()
                    }
                }
                catch let error as NSError
                {
                    print(error)
                }
            }
            else
            {
                print("Error")
            }
        }.resume()
    }
    
    func convert()
    {
        var resultGBP = 0.0
        var resultUSD = 0.0
        var resultCAD = 0.0
        var resultJPY = 0.0
        var resultAUD = 0.0
        var resultCNY = 0.0
        var resultEUR = 0.0
        
        baseCurrency.rate = (currencyDict[currencyArray[pickerView.selectedRow(inComponent: 0)].name]?.rate)!
        
        if(baseTextField.text!.count < 10)
        {
            if let euro = Double(baseTextField.text!)
            {
                convertValue = euro
                if let gbp = self.currencyDict["GBP"]
                {
                    resultGBP = convertValue * (gbp.rate/baseCurrency.rate)
                }
                if let usd = self.currencyDict["USD"]
                {
                    resultUSD = convertValue * (usd.rate/baseCurrency.rate)
                }
                if let cad = self.currencyDict["CAD"]
                {
                    resultCAD = convertValue * (cad.rate/baseCurrency.rate)
                }
                if let aud = self.currencyDict["AUD"]
                {
                    resultAUD = convertValue * (aud.rate/baseCurrency.rate)
                }
                if let jpy = self.currencyDict["JPY"]
                {
                    resultJPY = convertValue * (jpy.rate/baseCurrency.rate)
                }
                if let cny = self.currencyDict["CNY"]
                {
                    resultCNY = convertValue * (cny.rate/baseCurrency.rate)
                }
                if let eur = self.currencyDict["EUR"]
                {
                    resultEUR = convertValue * (eur.rate/baseCurrency.rate)
                }
            }
        }
        else
        {
            baseTextField.text = String(1) //reset to 1 if too long
        }
        
        gbpValueLabel.text = String(format: "%.02f", resultGBP)
        usdValueLabel.text = String(format: "%.02f", resultUSD)
        cadValueLabel.text = String(format: "%.02f", resultCAD)
        audValueLabel.text = String(format: "%.02f", resultAUD)
        yenValueLabel.text = String(format: "%.02f", resultJPY)
        cnyValueLabel.text = String(format: "%.02f", resultCNY)
        eurValueLabel.text = String(format: "%.02f", resultEUR)
        
    }
    
    @IBAction func convert(_ sender: Any)
    {
        convert()
    }
    
    @IBAction func refresh(_ sender: Any)
    {
        self.lastUpdatedDate = Date()
        setLatestDate()
        convert()
    }
    
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
     }
     */
    
}

