//
//  ViewController.swift
//  Currency
//
//  Created by Robert O'Connor on 18/10/2017.
//  Copyright © 2017 WIT. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate
{
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    var currencyArray = [Currency]()
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    
    //MARK Outlets
    //@IBOutlet weak var convertedLabel: UILabel!
    
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

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // print("currencyDict has \(self.currencyDict.count) entries")
        
        // create currency dictionary
        
        self.createCurrencyDictionary()
        
        self.addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        // get latest currency values
        getConversionTable()
        convertValue = 1
        
        // set up base currency screen items
        //baseTextField.text = String(format: "%.02f", baseCurrency.rate)
        baseSymbol.text = baseCurrency.symbol
        baseFlag.text = baseCurrency.flag
        
        
        // set up last updated date
        setLatestDate()
        
        //self.convert()
        
        // display currency info
        self.displayCurrencyInfo()
        
        
        // setup view mover
        baseTextField.delegate = self
        
        //gbpValueLabel.layer.borderWidth = 0.5
        //gbpValueLabel.layer.borderColor = UIColor.white.cgColor
        
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
    
    //simple method to remove keyboard when tapped anywhere but the keyboard Link:
    //https://stackoverflow.com/questions/32281651/how-to-dismiss-keyboard-when-touching-anywhere-outside-uitextfield-in-swift
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
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
                                                target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.baseTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.baseTextField.resignFirstResponder()
    }
    
    
    @objc func keyboardWillShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            if self.view.frame.origin.y == 0
            {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            if self.view.frame.origin.y != 0
            {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
    
    func createCurrencyDictionary()
    {
        //let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
        //self.currencyDict[name] = c
        currencyDict["GBP"] = Currency(name:"GBP", rate: 1, flag: "🇬🇧", symbol: "£")
        currencyDict["USD"] = Currency(name:"USD", rate: 1, flag: "🇺🇸", symbol: "$")
        currencyDict["CAD"] = Currency(name:"CAD", rate: 1, flag: "🇨🇦", symbol: "$")
        currencyDict["JPY"] = Currency(name:"JPY", rate: 1, flag: "🇯🇵", symbol: "¥")
        currencyDict["AUD"] = Currency(name:"AUD", rate: 1, flag: "🇦🇺", symbol: "$")
        currencyDict["CNY"] = Currency(name:"CNY", rate: 1, flag: "🇨🇳", symbol: "¥")
    }
    
    func displayCurrencyInfo()
    {
        // GBP
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
    }
    
    
    func getConversionTable()
    {
        //var result = "<NOTHING>"
        
        let urlStr:String = "https://api.fixer.io/latest"
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        URLSession.shared.dataTask(with: request)
        { data, response, error in
            
            DispatchQueue.main.async(execute:
                { indicator.stopAnimating()   }) // stop animating
            
            if error == nil
            {
                //print(response!)
                
                do
                {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    //print(jsonDict)
                    
                    if let ratesData = jsonDict["rates"] as? NSDictionary
                    {
                        //print(ratesData)
                        for rate in ratesData
                        {
                            //print("#####")
                            let name = String(describing: rate.key)
                            let rate = (rate.value as? NSNumber)?.doubleValue
                            //var symbol:String
                            //var flag:String
                            
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
                                let c:Currency = self.currencyDict["CAD"]!
                                c.rate = rate!
                                self.currencyDict["CAD"] = c
                            case "AUD":
                                let c:Currency = self.currencyDict["AUD"]!
                                c.rate = rate!
                                self.currencyDict["AUD"] = c
                            case "JPY":
                                let c:Currency = self.currencyDict["JPY"]!
                                c.rate = rate!
                                self.currencyDict["JPY"] = c
                            case "CNY":
                                let c:Currency = self.currencyDict["CNY"]!
                                c.rate = rate!
                                self.currencyDict["CNY"] = c
                            default:
                                print("Ignoring currency: \(String(describing: rate))")
                            }
                            
                            /*
                             let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
                             self.currencyDict[name] = c
                             */
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
        
        if(baseTextField.text!.count < 10)
        {
            if let euro = Double(baseTextField.text!)
            {
                convertValue = euro
                if let gbp = self.currencyDict["GBP"]
                {
                    resultGBP = convertValue * gbp.rate
                }
                if let usd = self.currencyDict["USD"]
                {
                    resultUSD = convertValue * usd.rate
                }
                if let cad = self.currencyDict["CAD"]
                {
                    resultCAD = convertValue * cad.rate
                }
                if let aud = self.currencyDict["AUD"]
                {
                    resultAUD = convertValue * aud.rate
                }
                if let jpy = self.currencyDict["JPY"]
                {
                    resultJPY = convertValue * jpy.rate
                }
                if let cny = self.currencyDict["CNY"]
                {
                    resultCNY = convertValue * cny.rate
                }
            }
        }
        else
        {
            baseTextField.text = String(1) //reset to 1 if too long
        }
        //GBP
        
        //convertedLabel.text = String(describing: resultGBP)
        
        gbpValueLabel.text = String(format: "%.02f", resultGBP)
        usdValueLabel.text = String(format: "%.02f", resultUSD)
        cadValueLabel.text = String(format: "%.02f", resultCAD)
        audValueLabel.text = String(format: "%.02f", resultAUD)
        yenValueLabel.text = String(format: "%.02f", resultJPY)
        cnyValueLabel.text = String(format: "%.02f", resultCNY)
        
    }
    
    @IBAction func convert(_ sender: Any)
    {
        convert()
    }
    
    @IBAction func refresh(_ sender: Any)
    {
        self.lastUpdatedDate = Date()
        setLatestDate()
        //TODO add in update all fields as well
        convert()
    }
    
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
     }
     */
    
}

