// Copyright (c) 2018 NUS CS3217. All rights reserved.

/**
 The `Graph` ADT is able to represent the following graph types with
 corresponding constraints:
 - Undirected graph
   + An undirected edge is represented by 2 directed edges
 - Directed graph
 - Simple graph
 - Multigraph
   + Edges from the same source to the same destination should have
 different cost
 - Unweighted graph
   + Edges' weights are to set to 1.0
 - Weighted graph

 Hence, the representation invariants for every Graph g:
 - g is either directed or undirected
 - All nodes in g must have unique labels
 - Multiple edges from the same source to the same destination must
 not have the same weight

 Similar to `Node` and `Edge`, `Graph` is a generic type with a type parameter
 `T` that defines the type of the nodes' labels.

 - Authors: CS3217
 - Date: 2018
 */
class Graph<T: Hashable> {
    typealias N = Node<T>
    typealias E = Edge<T>

    let isDirected: Bool
    
    private var _adjList = [N: Set<E>]()

    /// Constructs a direct or undirected graph.
    init(isDirected: Bool) {
        self.isDirected = isDirected        
        assert(_checkRep())
    }

    /// Adds the given node to the graph.
    /// If the node already exists in the graph, do nothing.
    func addNode(_ addedNode: N) {
        assert(_checkRep())
        
        guard _adjList[addedNode] == nil else {
            assert(_checkRep())
            return
        }
        
        _adjList[addedNode] = []
        
        assert(_checkRep())
    }

    /// Remove the given node from the graph.
    /// If the node does not exist in the graph, do nothing.
    func removeNode(_ removedNode: N) {
        assert(_checkRep())
        
        // remove all edges with removedNode as destination
        edges.filter({ $0.destination == removedNode })
            .forEach(removeEdge)
        // remove all edges with removedNode as source
        _adjList[removedNode] = nil
        
        assert(_checkRep())
    }

    /// Whether the graph contains the requested node.
    /// - Returns: true if the node exists in the graph
    func containsNode(_ targetNode: N) -> Bool {
        assert(_checkRep())
        return _adjList[targetNode] != nil
    }

    /// Adds the given edge to the graph.
    /// If the edge already exists, do nothing. If any of the nodes referenced
    /// in the edge does not exist, it is added to the graph.
    func addEdge(_ addedEdge: E) {
        assert(_checkRep())
        
        if _adjList[addedEdge.source] == nil {
            _adjList[addedEdge.source] = Set<E>()
        }
        if _adjList[addedEdge.destination] == nil {
            _adjList[addedEdge.destination] = Set<E>()
        }
        
        _adjList[addedEdge.source]?.insert(addedEdge)
        
        if !isDirected {
            _adjList[addedEdge.destination]?.insert(Graph.flipEdge(addedEdge))
        }
        
        assert(_checkRep())
    }
    
    /// Removes the requested edge from the graph. If it does not exist, do
    /// nothing.
    func removeEdge(_ removedEdge: E) {
        assert(_checkRep())
        
        for (node, adjEdges) in _adjList {
            adjEdges
                .filter({ $0 == removedEdge })
                .forEach({ _adjList[node]?.remove($0) })
            
            if !isDirected {
                adjEdges
                    .filter({ $0 == Graph.flipEdge(removedEdge) })
                    .forEach({ _adjList[node]?.remove($0) })
            }
        }
        
        assert(_checkRep())
    }
    
    /// Whether the requested edge exists in the graph.
    /// - Returns: true if the requested edge exists.
    func containsEdge(_ targetEdge: E) -> Bool {
        assert(_checkRep())
        return edges.filter({ $0 == targetEdge }).count != 0
    }

    /// Returns a list of edges directed from `fromNode` to `toNode`. If one of
    /// the nodes does not exist, returns an empty array.
    /// - Parameters:
    ///   - fromNode: the source `Node`
    ///   - toNode: the destination `Node`
    /// - Returns: an array of `Edge`s
    func edgesFromNode(_ fromNode: N, toNode: N) -> [E] {
        assert(_checkRep())
        return edges.filter({ $0.source == fromNode && $0.destination == toNode })
    }

    /// Returns adjacent nodes of the `fromNode`, i.e. there is a directed edge
    /// from `fromNode` to its adjacent node. If the requested node does not
    /// exist, returns an empty array.
    /// - Parameters:
    ///   - fromNode: the source `Node`
    /// - Returns: an array of `Node`s
    func adjacentNodesFromNode(_ fromNode: N) -> [N] {
        assert(_checkRep())
        guard let adjEdges: Set<E> = _adjList[fromNode] else {
            return [N]()
        }
        
        return Array(adjEdges.map({ $0.destination }))
    }

    /// A read-only computed property that contains all the nodes
    /// of the graphs.
    var nodes: [N] {
        return _adjList.map({ (node, _) in node })
    }

    /// A read-only computed property that contains all the edges
    /// of the graphs.
    var edges: [E] {
        var edgeSet = Set<E>()
        _adjList.forEach({ $1.forEach({ edgeSet.insert($0) }) })
        return Array(edgeSet)
    }

    /// Checks the representation invariants.
    private func _checkRep() -> Bool {
        if !_checkRepEdgesValid() {
            return false
        }
        if !isDirected && !_checkRepUndirectedEdge() {
            return false
        }
        
        return true
    }
    
    private func _checkRepEdgesValid() -> Bool {
        for (node, adjEdges) in _adjList {
            for edge in adjEdges {
                let srcExists = edge.source == node
                let destExists = _adjList[edge.destination] != nil
                
                if (!(srcExists && destExists)) {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func _checkRepUndirectedEdge() -> Bool {
        for (_, adjEdges) in _adjList {
            for edge in adjEdges {
                let oppositeEdgeMissing = _adjList[edge.destination]!.filter({ $0 == Graph.flipEdge(edge) }).isEmpty
                if oppositeEdgeMissing {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Returns the shortest path from `fromNode` to `toNode` assuming that the
    /// graph is not a multigraph.
    /// - Parameters:
    ///   - fromNode: the source `Node`
    ///   - toNode: the destination `Node`
    /// - Returns: a non-empty array of edges representing the shortest path
    /// order, if the two nodes are connected, an empty array otherwise
    func shortestPathFromNode(_ fromNode: N, toNode: N) -> [E] {
        assert(_checkRep())
        
        // Dijkstra's algorithm, implementation loosely follows Wikipedia
        
        var dist = [N: Double]()
        var prev = [N: N]()
        var frontier = PriorityQueue<PriorityValue<N>>()
        
        for node in nodes {
            let initialDistance = Double.greatestFiniteMagnitude
            
            dist[node] = initialDistance
            frontier.add(PriorityValue(initialDistance, node))
        }
        
        // initialize the start node
        dist[fromNode] = 0;
        frontier.add(PriorityValue(0, fromNode))
        
        // traverse all reachable nodes, build up partial order of visitation
        while let current: PriorityValue<N> = frontier.poll() {
            if current.priority == Double.greatestFiniteMagnitude {
                continue
            }
            let currentNode = current.value
            
            for neighbour in adjacentNodesFromNode(currentNode) {
                // these are all safe to force-unwrap, otherwise _checkRep() would have failed
                let edgeWeight: Double = edgesFromNode(currentNode, toNode: neighbour).min(by: { $0.weight < $1.weight })!.weight
                let distToCurrentNode: Double = dist[currentNode]!
                let distToNeighbour: Double = dist[neighbour]!
                
                let altDistToNeighbour = distToCurrentNode + edgeWeight
                
                if altDistToNeighbour < distToNeighbour {
                    dist[neighbour] = altDistToNeighbour
                    prev[neighbour] = currentNode
                    frontier.add(PriorityValue(altDistToNeighbour, neighbour))
                }
            }
        }
        
        // toNode never reached i.e. fromNode and toNode are disconnected
        guard prev[toNode] != nil else {
            return [E]()
        }
        
        // convert partial order of visitation (stored in prev) to an actual path
        // from source to destination
        var shortestPath = [E]()
        var currentNode = toNode
        repeat {
            // safe to force unwrap, as current node is guaranteed to be visited from some previous node
            let prevNode = prev[currentNode]!
            // safe to force unwrap, as there must exist some edge to visit currentNode from prevNode
            let shortestEdge = edgesFromNode(prevNode, toNode: currentNode).min(by: { $0.weight < $1.weight })!
            
            shortestPath.append(shortestEdge)
            currentNode = prevNode
        } while currentNode != fromNode
        
        assert(_checkRep())
        return shortestPath.reversed()
    }
    
    /// Creates a new edge with source and destination flipped.
    /// Useful when handling undirected graphs.
    private static func flipEdge(_ edge: E) -> E {
        // initializer is guaranteed to not fail since the weight is not being modified
        // the weight must have been acceptable to begin with, otherwise the original edge cannot exist
        return E(source: edge.destination, destination: edge.source, weight: edge.weight).unsafelyUnwrapped
    }
}
