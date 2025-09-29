extension LabelledPreorder {
  /// Represents an (optional) pre-and-post composition of a path.
  public struct Factorisation: Sendable {
    /// The left factor.
    public let left: Path?
    
    /// The middle factor.
    public let middle: Path
    
    /// The right factor.
    public let right: Path?
    
    init(left: Path? = nil, middle: Path, right: Path? = nil) {
      if let left { precondition(left.target == middle.source) }
      if let right { precondition(middle.target == right.source) }
      self.left = left
      self.middle = middle
      self.right = right
    }
    
    /// The path that the factorisation factors.
    public var path: Path {
      switch (left, right) {
      case (let left?, let right?): left + middle + right
      case (let left?, nil): left + middle
      case (nil, let right?): middle + right
      case (nil, nil): middle
      }
    }
    
    /// The boundary of the path that the factorisation factors.
    public var boundary: Boundary<Path.Vertex> {
      Boundary(
        source: left?.source ?? middle.source,
        target: right?.target ?? middle.target
      )
    }
  }
}
