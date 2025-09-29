/// Represents the boundary of a path in a graph, preorder, or category.
public struct Boundary<Vertex> {
  let source: Vertex
  let target: Vertex
}

extension Boundary: Sendable where Vertex: Sendable {}
extension Boundary: Equatable where Vertex: Equatable {}
extension Boundary: Hashable where Vertex: Hashable {}

extension Boundary where Vertex: Equatable {
  var loopBoundary: Vertex? { source == target ? source : nil }
  var isLoop: Bool { loopBoundary != nil }
}
