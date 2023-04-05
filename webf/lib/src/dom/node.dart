/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';
import 'node_data.dart';
import 'node_list.dart';

enum NodeType {
  ELEMENT_NODE,
  TEXT_NODE,
  COMMENT_NODE,
  DOCUMENT_NODE,
  DOCUMENT_FRAGMENT_NODE,
}

enum DocumentPosition {
  EQUIVALENT,
  DISCONNECTED,
  PRECEDING,
  FOLLOWING,
  CONTAINS,
  CONTAINED_BY,
  IMPLEMENTATION_SPECIFIC,
}

enum RenderObjectManagerType { FLUTTER_ELEMENT, WEBF_NODE }

typedef NodeVisitor = void Function(Node node);

/// [RenderObjectNode] provide the renderObject related abstract life cycle for
/// [Node] or [Element]s, which wrap [RenderObject]s, which provide the actual
/// rendering of the application.
abstract class RenderObjectNode {
  RenderBox? get renderer;

  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectNode] represents, using the configuration described by this
  /// [RenderObjectNode].
  ///
  /// This method should not do anything with the children of the render object.
  /// That should instead be handled by the method that overrides
  /// [Node.attachTo] in the object rendered by this object.
  RenderBox createRenderer();

  /// The renderObject will be / has been insert into parent. You can apply properties
  /// to renderObject.
  ///
  /// This method should not do anything to update the children of the render
  /// object.
  @protected
  void willAttachRenderer();

  @protected
  void didAttachRenderer();

  /// A render object previously associated with this Node will be / has been removed
  /// from the tree. The given [RenderObject] will be of the same type as
  /// returned by this object's [createRenderer].
  @protected
  void willDetachRenderer();

  @protected
  void didDetachRenderer();
}

/// Lifecycle that triggered when node tree changes.
/// Ref: https://html.spec.whatwg.org/multipage/custom-elements.html#concept-custom-element-definition-lifecycle-callbacks
abstract class LifecycleCallbacks {
  // Invoked each time the custom element is appended into a document-connected element.
  // This will happen each time the node is moved, and may happen before the element's
  // contents have been fully parsed.
  void connectedCallback();

  // Invoked each time the custom element is disconnected from the document's DOM.
  void disconnectedCallback();

// Invoked each time the custom element is moved to a new document.
// @TODO: Currently only single document exists, this callback will never be triggered.
// void adoptedCallback();

// @TODO: [attributeChangedCallback] works with static getter [observedAttributes].
// void attributeChangedCallback();
}

abstract class Node extends EventTarget implements RenderObjectNode, LifecycleCallbacks {
  Widget? get flutterWidget => null;

  /// WebF nodes could be wrapped by [WebFHTMLElementToWidgetAdaptor] and the renderObject of this node is managed by Flutter framework.
  /// So if managedByFlutterWidget is true, WebF DOM can not disposed Node's renderObject directly.
  bool managedByFlutterWidget = false;

  /// true if node are created by Flutter widgets.
  bool createdByFlutterWidget = false;

  /// The Node.parentNode read-only property returns the parent of the specified node in the DOM tree.
  ContainerNode? get parentNode => parentOrShadowHostNode;

  ContainerNode? _parentOrShadowHostNode;
  ContainerNode? get parentOrShadowHostNode => _parentOrShadowHostNode;
  set parentOrShadowHostNode(ContainerNode? value) {
    _parentOrShadowHostNode = value;
  }

  Node? _previous;
  Node? _next;

  Node? get firstChild;
  Node? get lastChild;

  NodeType nodeType;
  String get nodeName;

  NodeData? _node_data;
  NodeData ensureNodeData() {
    _node_data ??= NodeData();
    return _node_data!;
  }

  Node treeRoot() {
    Node? currentNode = this;
    while (currentNode!.parentNode != null) {
      currentNode = currentNode.parentNode;
    }
    return currentNode;
  }

  // Children changed steps for node.
  // https://dom.spec.whatwg.org/#concept-node-children-changed-ext
  void childrenChanged() {
    if (!isConnected) {
      return;
    }
    ownerDocument.updateStyleIfNeeded();
  }

  // FIXME: The ownerDocument getter steps are to return null, if this is a document; otherwise this’s node document.
  // https://dom.spec.whatwg.org/#dom-node-ownerdocument
  late Document ownerDocument;

  /// The Node.parentElement read-only property returns the DOM node's parent Element,
  /// or null if the node either has no parent, or its parent isn't a DOM Element.
  Element? get parentElement {
    if (parentNode != null && parentNode!.nodeType == NodeType.ELEMENT_NODE) {
      return parentNode as Element;
    }
    return null;
  }

  Element? get previousElementSibling {
    if (previousSibling != null && previousSibling!.nodeType == NodeType.ELEMENT_NODE) {
      return previousSibling as Element;
    }
    return null;
  }

  Element? get nextElementSibling {
    if (nextSibling != null && nextSibling!.nodeType == NodeType.ELEMENT_NODE) {
      return nextSibling as Element;
    }
    return null;
  }

  Node(this.nodeType, [BindingContext? context]) : super(context);

  bool _isConnected = false;
  // If node is on the tree, the root parent is body.
  bool get isConnected => _isConnected;

  bool isInTreeScope() { return isConnected; }

  Node? get previousSibling => _previous;
  set previousSibling(Node? value) {
    _previous = value;
  }

  Node? get nextSibling => _next;
  set nextSibling(Node? value) {
    _next = value;
  }

  NodeList get childNodes {
    if (this is ContainerNode) {
      return ensureNodeData().ensureChildNodeList(this as ContainerNode);
    }
    return ensureNodeData().ensureEmptyChildNodeList(this);
  }

  // Is child renderObject attached.
  bool get isRendererAttached => renderer != null && renderer!.attached;

  bool contains(Node? node) {
    if (node == null) return false;
    return this == node || node.isDescendantOf(this);
  }

  bool isDescendantOf(Node? other) {
    // Return true if other is an ancestor of this, otherwise false
    if (other == null || isConnected != other.isConnected) {
      return false;
    }
    if (other.ownerDocument != ownerDocument) {
      return false;
    }
    ContainerNode? n = parentNode;
    while (n != null) {
      if (n == other) {
        return true;
      }
      n = n.parentNode;
    }
    return false;
  }

  /// Attach a renderObject to parent.
  void attachTo(Element parent, {RenderBox? after}) {}

  /// Unmount referenced render object.
  void unmountRenderObject({bool deep = false, bool keepFixedAlive = false}) {}

  /// Release any resources held by this node.
  @override
  Future<void> dispose() async {
    parentNode?.removeChild(this);
    assert(!isRendererAttached, 'Should unmount $this before calling dispose.');
    super.dispose();
  }

  @override
  RenderBox createRenderer() => throw FlutterError('[createRenderer] is not implemented.');

  @override
  void willAttachRenderer() {}

  @override
  void didAttachRenderer() {}

  @override
  void willDetachRenderer() {}

  @override
  void didDetachRenderer() {}

  Node? appendChild(Node child) { return null; }

  Node? insertBefore(Node child, Node referenceNode) { return null; }

  Node? removeChild(Node child) { return null; }

  Node? replaceChild(Node newNode, Node oldNode) { return null; }

  /// Ensure child and child's child render object is attached.
  void ensureChildAttached() {}

  @override
  void connectedCallback() {
    for (var child in childNodes) {
      child.connectedCallback();
    }
  }

  @override
  void disconnectedCallback() {
    for (var child in childNodes) {
      child.disconnectedCallback();
    }
  }

  @override
  void dispatchEvent(Event event) {
    if (disposed) return;
    super.dispatchEvent(event);
  }

  @override
  EventTarget? get parentEventTarget => parentNode;

  // Whether Kraken Node need to manage render object.
  RenderObjectManagerType get renderObjectManagerType => RenderObjectManagerType.WEBF_NODE;

  // ---------------------------------------------------------------------------
  // Notification of document structure changes (see container_node.h for more
  // notification methods)
  //
  // InsertedInto() implementations must not modify the DOM tree, and must not
  // dispatch synchronous events.
  void insertedInto(ContainerNode insertion_point) {
    assert(insertion_point.isConnected || isContainerNode());
    if (insertion_point.isConnected) {
      _isConnected = true;
      insertion_point.ownerDocument.incrementNodeCount();
    }
  }

  void removedFrom(ContainerNode insertionPoint) {
    assert(insertionPoint.isConnected || isContainerNode());
    if (insertionPoint.isConnected) {
      _isConnected = false;
      insertionPoint.ownerDocument.decrementNodeCount();
    }
  }

  bool isTextNode() { return this is TextNode; }
  bool isContainerNode() { return this is ContainerNode; }
  bool isElementNode() { return this is Element; }
  bool isDocumentFragment() { return this is DocumentFragment;}
  bool hasChildren() { return firstChild != null; }

  DocumentPosition compareDocumentPosition(Node other) {
    if (this == other) {
      return DocumentPosition.EQUIVALENT;
    }

    // We need to find a common ancestor container, and then compare the indices of the two immediate children.
    List<Node> chain1 = [];
    List<Node> chain2 = [];
    Node? current = this;
    while (current != null && current.parentNode != null) {
      chain1.insert(0, current);
      current = current.parentNode;
    }
    current = other;
    while (current != null && current.parentNode != null) {
      chain2.insert(0, current);
      current = current.parentNode;
    }

    // If the two elements don't have a common root, they're not in the same tree.
    if (chain1.first != chain2.first) {
      return DocumentPosition.DISCONNECTED;
    }

    // Walk the two chains backwards and look for the first difference.
    for (int i = 0; i < math.min(chain1.length, chain2.length); i++) {
      if (chain1[i] != chain2[i]) {
        if (chain2[i].nextSibling == null) {
          return DocumentPosition.FOLLOWING;
        }
        if (chain1[i].nextSibling == null) {
          return DocumentPosition.PRECEDING;
        }

        // Otherwise we need to see which node occurs first.  Crawl backwards from child2 looking for child1.
        Node? previousSibling = chain2[i].previousSibling;
        while (previousSibling != null) {
          if (chain1[i] == previousSibling) {
            return DocumentPosition.FOLLOWING;
          }
          previousSibling = previousSibling.previousSibling;
        }
        return DocumentPosition.PRECEDING;
      }
    }
    // There was no difference between the two parent chains, i.e., one was a subset of the other.  The shorter
    // chain is the ancestor.
    return chain1.length < chain2.length ? DocumentPosition.FOLLOWING : DocumentPosition.PRECEDING;
  }
}

/// https://dom.spec.whatwg.org/#dom-node-nodetype
int getNodeTypeValue(NodeType nodeType) {
  switch (nodeType) {
    case NodeType.ELEMENT_NODE:
      return 1;
    case NodeType.TEXT_NODE:
      return 3;
    case NodeType.COMMENT_NODE:
      return 8;
    case NodeType.DOCUMENT_NODE:
      return 9;
    case NodeType.DOCUMENT_FRAGMENT_NODE:
      return 11;
  }
}
