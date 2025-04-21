//
//  SectionHeader.swift
//  testB
//
//  Created by Michael Miroshnikov on 14/04/2025.
//

import SwiftUI

struct CustomSectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .textCase(.uppercase)
            Spacer()
        }
    }
}
