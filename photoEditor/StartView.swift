//
//  StartView.swift
//  photoEditor
//
//  Created by Вадим on 11.05.2024.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    StartView()
}
