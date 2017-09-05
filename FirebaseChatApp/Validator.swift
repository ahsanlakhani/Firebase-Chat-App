

import UIKit

class Validator: NSObject {
    
    class func validateEmail(email:String)->Bool{
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
//        if (email.rangeOfString(emailRegex, options: .RegularExpressionSearch) == nil)
        if (email.range(of: emailRegex, options: .regularExpression) == nil)
        {
            return false
        }
        return true
    }
    
    class func validateTextFields(textFields:[UITextField])->Bool{
        for textField in textFields{
            if(textField.text!.isEmpty){
                return false
            }
        }
        return true
    }
    
    class func compareTextFields(textFields:(UITextField,UITextField))->Bool{
        if(textFields.0.text == textFields.1.text){
            return true
        }
        return false
    }
    
}
