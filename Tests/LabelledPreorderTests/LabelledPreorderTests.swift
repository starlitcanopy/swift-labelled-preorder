import Testing

@testable import LabelledPreorder

struct StringPath: LabelledPath {
  typealias Vertex = String

  var boundary: Boundary<Vertex>
  var label: String
  
  init(boundary: Boundary<Vertex>, label: String) {
    self.boundary = boundary
    self.label = label
  }
  
  init(source: Vertex, target: Vertex, label: Vertex) {
    self.init(boundary: Boundary(source: source, target: target), label: label)
  }

  func appending(_ path: Self) -> Self {
    precondition(target == path.source)
    return Self(source: source, target: path.target, label: label + path.label)
  }

  static func identity(_ x: String) -> Self {
    Self(source: x, target: x, label: "")
  }

  static func == (lhs: StringPath, rhs: StringPath) async -> Bool {
    lhs.label == rhs.label
  }
}

extension LabelledPreorder where Path == StringPath {
  func addEdge(from x: String, to y: String, label: String) async throws {
    try await extend(by: StringPath(source: x, target: y, label: label))
  }
}

@Test func basicTransitivity() async throws {
  let table = LabelledPreorder<StringPath>()
  
  await #expect(throws: Never.self){
    try await table.addEdge(from: "a", to: "b", label: "f")
    try await table.addEdge(from: "b", to: "c", label: "g")
  }

  #expect(await table.hasPath(from: "a", to: "b"))
  #expect(await table.hasPath(from: "a", to: "c"))
  #expect(await table.hasPath(from: "b", to: "c"))
  
  let path = await table.path(from: "a", to: "c")
  #expect(path?.label == "fg")
}

@Test func coherentDuplicatePath() async throws {
  let table = LabelledPreorder<StringPath>()
  await #expect(throws: Never.self) {
    try await table.addEdge(from: "a", to: "b", label: "f")
    try await table.addEdge(from: "b", to: "c", label: "g")
    try await table.addEdge(from: "a", to: "c", label: "fg")
  }
}

@Test func incoherentDuplicatePath() async throws {
  let table = LabelledPreorder<StringPath>()
  
  await #expect(throws: Never.self) {
    try await table.addEdge(from: "a", to: "b", label: "f")
    try await table.addEdge(from: "b", to: "c", label: "g")
  }
  
  let error = await #expect(throws: LabelledPreorder<StringPath>.CoherenceError.self) {
    try await table.addEdge(from: "a", to: "c", label: "incoherent")
  }
  
  guard let error else { return }
  
  #expect(!error.violations.isEmpty)
}

@Test func incoherentLoop() async throws {
  let table = LabelledPreorder<StringPath>()
  
  await #expect(throws: Never.self) {
    try await table.addEdge(from: "a", to: "b", label: "f")
    try await table.addEdge(from: "b", to: "c", label: "g")
  }
  
  let error = await #expect(throws: LabelledPreorder<StringPath>.CoherenceError.self) {
    try await table.addEdge(from: "c", to: "a", label: "h")
  }
  
  guard let error else { return }
  #expect(!error.violations.isEmpty)
}

@Test func coherentLoop() async throws {
  let table = LabelledPreorder<StringPath>()
  
  await #expect(throws: Never.self) {
    try await table.addEdge(from: "a", to: "b", label: "")
    try await table.addEdge(from: "b", to: "c", label: "")
    try await table.addEdge(from: "c", to: "a", label: "")
  }
  
  #expect(await table.hasPath(from: "b", to: "a"))
}

@Test func identityEdges() async throws {
  let table = LabelledPreorder<StringPath>()
  await #expect(throws: Never.self) {
    try await table.addEdge(from: "a", to: "b", label: "")
  }
  #expect(await table.hasPath(from: "a", to: "a"))
}
