//
//  C_Definition.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import UIKit

public typealias JSONObject = [String: Any]
public typealias Closure_JSON_Void = (JSONObject?) -> Void
public typealias Closure_String_Void = (String?) -> Void
public typealias Closure_String_Bool = (String?) -> Bool
public typealias Closure_Int_Void = (Int) -> Void
public typealias Closure_Void_Void = () -> Void
public typealias SimpleMessHandler = (Result<String, SimpleMessError>) -> Void
public typealias ObjectMessHandler<T> = (Result<T, SimpleMessError>) -> Void

public typealias Closure_Button_Void = (UIButton?) -> Void
public typealias Closure_View_Void = (UIView?) -> Void
public typealias Closure_Switch_Void = (UISwitch) -> Void

public struct SimpleMessError: Error {
    let message: String
    let code: Int
    
    var localizedDescription: String {
        return self.message
    }
}

