import DifferenceKit

/// Represents a section of list UI, containing header node, footer node
/// and collection of cell nodes.
/// This works as an intermediary for `DifferenceKit`.
public struct Section {
    /// A type-erased identifier that can be used to uniquely
    /// identify the section.
    public var id: AnyHashable

    /// A node representing header view.
    public var header: ViewNode?

    /// A collection of nodes representing cells.
    public var cells: [CellNode]

    /// A node representing footer view.
    public var footer: ViewNode?

    /// Create a section wrapping id, header node, footer node and cell nodes.
    ///
    /// - Parameters:
    ///   - id: An identifier to be wrapped.
    ///   - header: A node for header view.
    ///   - cells: A collection of nodes for cells.
    ///   - footer: A node for footer view.
    @inlinable
    public init<I: Hashable, C: Swift.Collection>(id: I, header: ViewNode? = nil, cells: C, footer: ViewNode? = nil) where C.Element == CellNode {
        // This is workaround for avoid redundant `AnyHashable` wrapping.
        if type(of: id) == AnyHashable.self {
            self.id = unsafeBitCast(id, to: AnyHashable.self)
        }
        else {
            self.id = id
        }

        self.header = header
        self.footer = footer
        self.cells = Array(cells)
    }

    /// Create a section wrapping id, header node, footer node and cell nodes.
    ///
    /// - Note: The nil contained in the collection of cell nodes is removed.
    ///
    /// - Parameters:
    ///   - id: An identifier to be wrapped.
    ///   - header: A node for header view.
    ///   - cells: A collection of nodes for cells that can be contains nil.
    ///   - footer: A node for footer view.
    @inlinable
    public init<I: Hashable, C: Swift.Collection>(id: I, header: ViewNode? = nil, cells: C, footer: ViewNode? = nil) where C.Element == CellNode? {
        self.init(id: id, header: header, cells: cells.compactMap { $0 }, footer: footer)
    }

    /// Create a section wrapping id, header node, footer node.
    ///
    /// - Parameters:
    ///   - id: An identifier to be wrapped.
    ///   - header: A node for header view.
    ///   - footer: A node for footer view.
    @inlinable
    public init<I: Hashable>(id: I, header: ViewNode? = nil, footer: ViewNode? = nil) {
        self.init(id: id, header: header, cells: [], footer: footer)
    }

    /// Create a section by given closure.
    ///
    /// - Parameters:
    ///   - id: An identifier to be wrapped.
    ///   - buildSection: A closure to build section.
    @available(*, deprecated, message: "This method will be removed next version owing to avoid ambiguity with new syntax using function builder.")
    @inlinable
    public init<I: Hashable>(id: I, _ buildSection: (inout Section) -> Void) {
        var section = Section(id: id)
        buildSection(&section)
        self = section
    }
}

public extension Section {
    @inlinable
    init<I: Hashable, C: CellsBuildable>(id: I, @CellsBuilder cells: () -> C) {
        self.init(id: id, cells: cells().buildCells())
    }

    @inlinable
    init<I: Hashable, H: Component, F: Component, C: CellsBuildable>(id: I, header: H?, footer: F?, @CellsBuilder cells: () -> C) {
        self.init(
            id: id,
            header: header.map(ViewNode.init),
            cells: cells().buildCells(),
            footer: footer.map(ViewNode.init)
        )
    }

    @inlinable
    init<I: Hashable, H: Component, F: Component>(id: I, header: H?, footer: F?) {
        self.init(
            id: id,
            header: header.map(ViewNode.init),
            footer: footer.map(ViewNode.init)
        )
    }

    @inlinable
    init<I: Hashable, H: Component>(id: I, header: H?, @CellsBuilder cells: () -> CellsBuildable) {
        self.init(
            id: id,
            header: header.map(ViewNode.init),
            cells: cells().buildCells()
        )
    }

    @inlinable
    init<I: Hashable, H: Component>(id: I, header: H?) {
        self.init(id: id, header: header.map(ViewNode.init))
    }

    @inlinable
    init<I: Hashable, F: Component, C: CellsBuildable>(id: I, footer: F?, @CellsBuilder cells: () -> C) {
        self.init(
            id: id,
            cells: cells().buildCells(),
            footer: footer.map(ViewNode.init)
        )
    }

    @inlinable
    init<I: Hashable, F: Component>(id: I, footer: F?) {
        self.init(id: id, footer: footer.map(ViewNode.init))
    }
}

extension Section: SectionsBuildable {
    public func buildSections() -> [Section] {
        [self]
    }
}

extension Section: DifferentiableSection {
    /// An identifier value for difference calculation.
    @inlinable
    public var differenceIdentifier: AnyHashable {
        return id
    }

    /// The collection of element in the section.
    @inlinable
    public var elements: [CellNode] {
        return cells
    }

    /// Indicate whether the content of `self` is equals to the content of
    /// the given source value.
    @inlinable
    public func isContentEqual(to source: Section) -> Bool {
        return header.isContentEqual(to: source.header) && footer.isContentEqual(to: source.footer)
    }

    /// Creates a new section reproducing the given source section with replacing the elements.
    @inlinable
    public init<C: Swift.Collection>(source: Section, elements cells: C) where C.Element == CellNode {
        self.init(id: source.id, header: source.header, cells: cells, footer: source.footer)
    }
}
