//
//  CustomAlertViewModifier.swift
//
//
//  Created by Alex Nagy on 07.01.2021.
//

import SwiftUI

public struct CustomAlertViewModifier<AlertContent: View>: ViewModifier {
    
    @ObservedObject public var customAlertManager: CustomAlertManager
    public var alertContent: () -> AlertContent
    public var buttons: [CustomAlertButton]
    
    public var requireHorizontalPositioning: Bool {
        let maxButtonPositionedHorizontally = 2
        return buttons.count > maxButtonPositionedHorizontally
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content.disabled(customAlertManager.isPresented)
            if customAlertManager.isPresented {
                GeometryReader { geometry in
                    Color(.systemBackground)
                        .colorInvert()
                        .opacity(0.2)
                        .ignoresSafeArea()
                    HStack {
                        Spacer()
                        VStack {
                            let expectedWidth = geometry.size.width * 0.7
                            
                            Spacer()
                            VStack(spacing: 0) {
                                alertContent().padding()
                                buttonsPad(expectedWidth)
                            }
                            .frame(
                                minWidth: expectedWidth,
                                maxWidth: expectedWidth
                            )
                            .background(Color(.systemBackground).opacity(0.95))
                            .cornerRadius(13)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                }
            }
            
        }
    }
    
    public func buttonsPad(_ expectedWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            if buttons.count < 1 {
                fatalError("Please provide at least one button for your custom alert.")
            }
            if requireHorizontalPositioning {
                verticalButtonPad()
            } else {
                Divider().padding([.leading, .trailing], -12)
                horizontalButtonsPadFor(expectedWidth)
            }
        }
    }
    
    public func verticalButtonPad() -> some View {
        VStack(spacing: 0) {
            ForEach(buttons, id: \.id) { button in
                Divider().padding([.leading, .trailing], -12)
                
                Button(action: {
                    if !button.isCancel {
                        button.action()
                    }
                    
                    withAnimation {
                        self.customAlertManager.isPresented.toggle()
                    }
                }, label: {
                    button.content
                })
                .padding(8)
                .frame(minHeight: 44)
            }
        }
    }

    
    public func horizontalButtonsPadFor(_ expectedWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            let sidesOffset: CGFloat = 12 * 2
            let maxHorizontalWidth = requireHorizontalPositioning ?
                expectedWidth - sidesOffset :
                expectedWidth / 2 - sidesOffset
            
            Spacer()
            
            if !requireHorizontalPositioning {
                ForEach(buttons, id: \.id) { button in
                    if buttons.firstIndex(where: { $0.id == button.id }) != 0 {
                        Divider().frame(height: 44)
                    }
                    
                    Button(action: {
                        if !button.isCancel {
                            button.action()
                        }
                        
                        withAnimation {
                            self.customAlertManager.isPresented.toggle()
                        }
                    }, label: {
                        button.content
                    })
                    .padding(8)
                    .frame(maxWidth: maxHorizontalWidth, minHeight: 44)
                }
            }
            
            Spacer()
        }
    }
    
}

#if os(watchOS)
extension UIColor {
    public static var systemBackground: UIColor {
        return UIColor(.black)
    }
}
#endif

