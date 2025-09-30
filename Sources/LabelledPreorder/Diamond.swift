// SPDX-FileCopyrightText: 2025 The Project Pterodactyl Developers
//
// SPDX-License-Identifier: MPL-2.0

//
//  Diamond.swift
//  LabelledPreorder
//
//  Created by Jonathan Sterling on 2025-09-30.
//

extension LabelledPreorder {
  /// A “diamond” in the context of Sakaguchi’s algorithm is a three-place factorisation being compared against a single path.
  public struct Diamond: Sendable {
    public var factorisation: Factorisation
    public var referencePath: Path

    init(factorisation: Factorisation, referencePath: Path) {
      precondition(factorisation.boundary == referencePath.boundary)
      self.factorisation = factorisation
      self.referencePath = referencePath
    }

    /// The diamond commutes when the factored path is equal to the reference path.
    func commutes() async throws -> Bool {
      try await factorisation.path == referencePath
    }
  }
}
