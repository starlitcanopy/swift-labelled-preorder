// SPDX-FileCopyrightText: 2025 The Project Pterodactyl Developers
//
// SPDX-License-Identifier: MPL-2.0

/// A labelled preorder is a preorder in which arrows/paths are coherently equipped with labels. Coherence here means that the projection of labels is preserved by composition.
///
/// This is an actor because it closes over some internal state that is used to ensure that diamonds can be computed efficiently.
public actor LabelledPreorder<Path: LabelledPath> {
  // MARK: Private State
  private var coercions: [Boundary<Path.Vertex>: Path] = [:]
  private var vertices: Set<Path.Vertex> = []
  private var coslices: [Path.Vertex: Set<Path.Vertex>] = [:]
  private var slices: [Path.Vertex: Set<Path.Vertex>] = [:]

  // MARK: Public Accessors
  
  /// - Returns: the canonical path with the given boundary, or `nil` if one does not exist.
  public func path(boundary: Boundary<Path.Vertex>) -> Path? {
    coercions[boundary]
  }

  /// A convenience wrapper around ``path(boundary:)``.
  /// - Returns: the canonical path with the given source and target, or `nil` if one doesn't exist.
  public func path(
    from source: Path.Vertex,
    to target: Path.Vertex
  ) -> Path? {
    path(boundary: Boundary(source: source, target: target))
  }

  /// - Returns: a boolean indicating whether or not there exists a path with the given source and target.
  public func hasPath(
    from source: Path.Vertex,
    to target: Path.Vertex
  ) -> Bool {
    path(from: source, to: target) != nil
  }

  /// - Returns: the slice of the preorder over a given vertex, i.e. the set of vertices with an edge *from* that vertex.
  public func slice(_ x: Path.Vertex) -> Set<Path.Vertex> {
    slices[x] ?? []
  }

  /// - Returns: the co-slice of the preorder over a given vertex, i.e. the set of vertices with an edge *to* that vertex.
  public func coslice(_ x: Path.Vertex) -> Set<Path.Vertex> {
    coslices[x] ?? []
  }
}

extension LabelledPreorder {
  /// A coherence error indicates that a path could not be added because it would result in a number of non-commuting diamonds.
  public struct CoherenceError: Error {
    /// The non-commuting diamonds that would have resulted.
    public let violations: [Diamond]
  }

  private struct Checker {
    var violations: [Diamond] = []
    var paths: [Path] = []
  }

  /// Returns `true` when the path was added.
  private func check(
    checker: inout Checker,
    factorisation: Factorisation
  ) async throws -> Bool {
    if let diamond = diamond(for: factorisation) {
      if try await !diamond.commutes() { checker.violations.append(diamond) }
      return false
    }

    checker.paths.append(factorisation.path)
    return true
  }

  /// Coherently extend the preorder by a labelled path.
  /// - Throws: `CoherenceError` if such a coherent extension does not exist.
  public func extend(by path: Path) async throws {
    insertIfAbsent(vertex: path.source)
    insertIfAbsent(vertex: path.target)

    var checker = Checker()

    if try await check(
      checker: &checker,
      factorisation: Factorisation(middle: path)
    ) {
      for factorisation in irreducibleFactorisations(inducedBy: path) {
        _ = try await check(checker: &checker, factorisation: factorisation)
      }
    }

    guard checker.violations.isEmpty else {
      throw CoherenceError(violations: checker.violations)
    }

    for path in checker.paths {
      register(path: path)
    }
  }
  
  
  private func insertIfAbsent(vertex x: Path.Vertex) {
    if !vertices.contains(x) {
      vertices.insert(x)
      register(path: Path.identity(x))
    }
  }

  private func register(path p: Path) {
    coercions[p.boundary] = p
    slices[p.source, default: []].insert(p.target)
    coslices[p.target, default: []].insert(p.source)
  }

  private func diamond(for factorisation: Factorisation) -> Diamond? {
    guard let path = path(boundary: factorisation.boundary) else { return nil }
    return Diamond(factorisation: factorisation, referencePath: path)
  }

  private func irreducibleFactorisations(inducedBy middle: Path) -> [Factorisation] {
    var factorisations: [Factorisation] = []

    for ancestor in coslice(middle.source) {
      let left = path(from: ancestor, to: middle.source)!
      for descendent in slice(middle.target) {
        let right = path(from: middle.target, to: descendent)!

        // u-[p]-x-[c]-y-[q]-z
        let factorisation = Factorisation(
          left: left,
          middle: middle,
          right: right
        )

        if isIrreducible(factorisation: factorisation) {
          factorisations.append(factorisation)
        }
      }
    }

    return factorisations
  }

  private func isIrreducible(factorisation: Factorisation) -> Bool {
    let outer = factorisation.boundary
    let inner = factorisation.middle.boundary
    let interior =
      slice(outer.source)
      .intersection(coslice(outer.target))

    let preReducers =
      interior
      .intersection(coslice(inner.source))
      .subtracting(coslice(outer.source))

    guard preReducers.isEmpty else { return false }

    let postReducers =
      interior
      .intersection(slice(inner.target))
      .subtracting(slice(outer.target))

    return postReducers.isEmpty
  }
}
