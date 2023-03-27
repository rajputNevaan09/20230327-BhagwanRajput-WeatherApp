//
//  EnterCityVC.swift
//  WeatherApp
//
//  Created by Bhagwan Rajput on 27/03/23.
//

import SwiftUI
import Foundation


//SwiftUI class View
struct EnterCityView: View {
    
    //Variable decleration
    @State private var textFieldInput = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Please Enter City", text: $textFieldInput)
                .textFieldStyle(.roundedBorder)
                .padding()
                .autocorrectionDisabled(true)
            
            Button(action: {
                // Add your code here to handle the submit button action
                if textFieldInput.contains(" ") {
                    let newString = textFieldInput.replacingOccurrences(of: " ", with: "%20")
                    // do something with the new string
                    Constant.city = newString
                }else{
                    Constant.city = textFieldInput
                }
                presentationMode.wrappedValue.dismiss()
                print("Submit button tapped with text input: \(textFieldInput)")
            }) {
                Text("SUBMIT")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .frame(width: 200, height: 35, alignment: .center)
                
            }
        }
    }
}



struct EnterCityView_Preview: PreviewProvider {
    static var previews: some View {
        EnterCityView()
    }
}


struct MyViewControllerWrapper: UIViewControllerRepresentable {
    
    // Implement the required methods of UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> UIViewController {
        // Create an instance of the UIKit view controller you want to navigate back to
        let myVC = WeatherHomeVC()
        return myVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Implement this method if you need to update the view controller
        // based on changes in the SwiftUI view
    }
}
