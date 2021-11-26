//
//  File.swift
//  
//
//  Created by Yannis Lang on 24/11/2021.
//

import Foundation
import SwiftUI

public struct YLFlexSheet<Content: View>: View {
    
    @State private var dragOffset = CGSize.zero
    
    private let content: () -> Content
    private let draggable: Bool
    @Binding private var sheetMode: YLSheetMode
    
    public init(sheetMode: Binding<YLSheetMode>,
                draggable: Bool = false,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._sheetMode = sheetMode
        self.draggable = draggable
    }
    
    public var body: some View {
        Group {
            if draggable {
                    content()
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded{ value in
                                    dragOffset = .zero
                                    updateMode(translationHeight: value.translation.height)
                                }
                    )
            }else{
                content()
            }
        }
        .cornerRadius(20)
        .offset(y: offSet > 0 ? offSet : 0)
        .animation(.spring())
        .edgesIgnoringSafeArea(.all)
    }
}

extension YLFlexSheet {
    private var offSet: CGFloat {
        positionOffset + dragOffset.height
    }
    
    private var positionOffset: CGFloat {
        switch sheetMode {
        case .none:
            return UIScreen.main.bounds.height
        case .quarter:
            return UIScreen.main.bounds.height * 0.75
        case .half:
            return UIScreen.main.bounds.height * 0.5
        case .full:
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
    }
    
    private func updateMode(translationHeight: CGFloat) {
        
        let quarter = UIScreen.main.bounds.height * 0.75
        let half = UIScreen.main.bounds.height * 0.5
        let none = UIScreen.main.bounds.height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        let endPos = (offSet + translationHeight) * 1.2
        
        switch endPos {
        case ..<half:
            sheetMode = .full
        case half..<quarter:
            sheetMode = .half
        case quarter..<none:
            sheetMode = .quarter
        default:
            sheetMode = .none
        }
    }
}

struct FlexibleSheet_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var sheetMode = YLSheetMode.quarter
        
        var body: some View {
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)
                YLFlexSheet(sheetMode: $sheetMode){
                    List {
                        Text("Hello")
                    }
                }
            }
        }
    }
}
