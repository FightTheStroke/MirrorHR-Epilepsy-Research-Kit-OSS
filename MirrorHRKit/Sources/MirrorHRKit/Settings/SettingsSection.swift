//
//  SettingsSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

struct SettingsSection: Identifiable {
    var id: String
    var header: String?
    var image: String
    var rows: [SettingsRowKind]
    var footer: String?
    var isEnabled: Bool = true
    var foregroundColor: Color?
}
