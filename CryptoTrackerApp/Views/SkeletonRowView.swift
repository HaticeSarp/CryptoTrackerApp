//
//  SkeletonRowView.swift
//  CryptoTrackerApp
//
//  Created by Hatice Sarp on 20.02.2026.
//

import SwiftUI

struct SkeletonRowView: View {
    var body: some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 8){
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 12)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8){
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 16)
            }
        }
        .padding(.vertical, 4)
        .redacted(reason: .placeholder) 
    }
}
