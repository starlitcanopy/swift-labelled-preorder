// SPDX-FileCopyrightText: 2025 The Project Pterodactyl Developers
//
// SPDX-License-Identifier: MPL-2.0

/// The entry point into this library: you must supply an instance of the protocol ``LabelledPath`` with which to instantiate ``LabelledPreorder``.
public protocol LabelledPath: Sendable {
  associatedtype Vertex: Hashable & Sendable
  
  /// Composition of paths in diagrammatic order.
  func appending(_: Self) -> Self
  
  /// Identity paths.
  static func identity(_: Vertex) -> Self

  var boundary: Boundary<Vertex> { get }
  
  /// Semantic equality for paths. Can throw if `lhs.boundary != rhs.boundary`.
  static func == (lhs: Self, rhs: Self) async throws -> Bool
}

extension LabelledPath {
  var source: Vertex { boundary.source }
  var target: Vertex { boundary.target }

  static func + (p: Self, q: Self) -> Self {
    p.appending(q)
  }
}
