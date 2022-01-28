//
//  LeadCollectionField.swift
//  Kommunicate
//
//  Created by sathyan elangovan on 27/01/22.
//

import Foundation

public struct LeadCollectionField: Decodable {
    let type: String
    let field: String
    let required: Bool
    let placeholder: String
    let element: String?
    let options: [LeadCollectionDropDownField]?

    public init(type: String, field: String, req: Bool, placeHolder: String, element: String?, option: [LeadCollectionDropDownField]?) {
        self.type = type
        self.field = field
        required = req
        placeholder = placeHolder
        self.element = element
        options = option
    }
}

public struct LeadCollectionDropDownField: Decodable {
    let value: String

    public init(_ value: String) {
        self.value = value
    }
}
