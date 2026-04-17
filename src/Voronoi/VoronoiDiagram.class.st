"
I compute and hold a bounded Voronoi diagram.

Algorithm — half-plane clipping (O(n^3)):
  For each site S, start with the bounding rectangle as a convex polygon,
  then clip it successively by the half-plane ""closer to S than to T"" for
  every other site T. The result is the Voronoi cell of S.
  Clipping uses the Sutherland-Hodgman algorithm (see #clip:by:).

[algorithm Reference](https://inria.hal.science/hal-00647979/file/main.pdf)

Instance variables:
-  sites   <OrderedCollection of VoronoiSite>  — seed points
-  cells   <OrderedCollection of VoronoiCell>  — computed cells (one per site)
-  bounds  <Rectangle>                         — clipping boundary

Typical usage:
```st
  diagram := VoronoiDiagram new
      bounds: (0 @ 0 corner: 500 @ 500);
      addSiteAt: 100 @ 200;
      addSiteAt: 300 @ 150;
      yourself.
  diagram compute.
  diagram cells do: [ :cell | Transcript show: cell area printString ].
```
Key methods:
-  addSiteAt: aPoint   — add a site and reset computed cells
-  compute             — run the algorithm; must be called before querying cells
-  nearestSiteTo: p    — brute-force nearest-site query (O(n))
-  totalArea           — sum of all cell areas; should equal the bounding box area'
"
Class {
	#name : 'VoronoiDiagram',
	#superclass : 'Object',
	#instVars : [
		'sites',
		'cells',
		'bounds'
	],
	#category : 'Voronoi-model',
	#package : 'Voronoi',
	#tag : 'model'
}

{ #category : 'instance creation' }
VoronoiDiagram class >> withSites: aCollection inBounds: aRectangle [

	| diagram |
	diagram := self new
		           bounds: aRectangle;
		           yourself.
	aCollection doWithIndex: [ :pos :i |
		diagram addSite: (VoronoiSite at: pos index: i) ].
	^ diagram
]

{ #category : 'building' }
VoronoiDiagram >> addSite: aSite [

	aSite index ifNil: [ aSite index: sites size + 1 ].
	sites add: aSite.
	^ aSite
]

{ #category : 'building' }
VoronoiDiagram >> addSiteAt: aPoint [

	^ self addSite: (VoronoiSite at: aPoint index: sites size + 1)
]

{ #category : 'computing' }
VoronoiDiagram >> boundingPolygon [
"Returns the bounding box as an ordered list of vertices (clockwise in screen coords)."
	^ OrderedCollection
		  with: bounds topLeft
		  with: bounds topRight
		  with: bounds bottomRight
		  with: bounds bottomLeft
]

{ #category : 'accessing' }
VoronoiDiagram >> bounds [

	^ bounds
]

{ #category : 'accessing' }
VoronoiDiagram >> bounds: anObject [

	bounds := anObject
]

{ #category : 'querying' }
VoronoiDiagram >> cellForSite: aSite [

	^ cells detect: [ :cell | cell site = aSite ] ifNone: [ nil ]
]

{ #category : 'accessing' }
VoronoiDiagram >> cells [

	^ cells
]

{ #category : 'accessing' }
VoronoiDiagram >> cells: anObject [

	cells := anObject
]

{ #category : 'computing' }
VoronoiDiagram >> clip: aPolygon by: aHalfPlane [
"Sutherland-Hodgman algorithm: clips a convex polygon by a single half-plane.
	 Points satisfying halfPlane.evaluate(p) <= 0 are inside."

	| input output n |
	input := aPolygon.
	n := input size.
	n = 0 ifTrue: [ ^ OrderedCollection new ].
	output := OrderedCollection new.
	1 to: n do: [ :i |
			| s e |
			s := input at: i.
			e := input at: i \\ n + 1.
			(aHalfPlane isInside: e)
				ifTrue: [
						(aHalfPlane isInside: s) ifFalse: [
							output add: (aHalfPlane intersectionOf: s with: e) ].
						output add: e ]
				ifFalse: [
						(aHalfPlane isInside: s) ifTrue: [
							output add: (aHalfPlane intersectionOf: s with: e) ] ] ].
	^ output
]

{ #category : 'computing' }
VoronoiDiagram >> compute [
"Computes the Voronoi cells for all sites using half-plane clipping."
	cells := OrderedCollection new.
	sites do: [ :site |
			| polygon |
			polygon := self boundingPolygon.
			sites do: [ :other |
					other = site ifFalse: [
							polygon := self
								           clip: polygon
								           by: (VoronoiHalfPlane between: site and: other) ] ].
			cells add: (VoronoiCell site: site vertices: polygon) ]
]

{ #category : 'initialization' }
VoronoiDiagram >> initialize [

	sites := OrderedCollection new.
	cells := OrderedCollection new.
	bounds := 0 @ 0 corner: 400 @ 400
]

{ #category : 'querying' }
VoronoiDiagram >> nearestSiteTo: aPoint [
"Returns the site whose Voronoi cell contains the given point."
	| nearest minDist |
	nearest := nil.
	minDist := Float infinity.
	sites do: [ :site |
			| dist |
			dist := site squaredDistanceTo: aPoint.
			dist < minDist ifTrue: [
					minDist := dist.
					nearest := site ] ].
	^ nearest
]

{ #category : 'printing' }
VoronoiDiagram >> printOn: aStream [
	aStream
		nextPutAll: 'VoronoiDiagram(';
		print: sites size;
		nextPutAll: ' sites, bounds: ';
		print: bounds;
		nextPut: $)

]

{ #category : 'accessing' }
VoronoiDiagram >> sites [

	^ sites
]

{ #category : 'accessing' }
VoronoiDiagram >> sites: anObject [

	sites := anObject
]

{ #category : 'querying' }
VoronoiDiagram >> totalArea [
"Returns the sum of all cell areas (should equal the bounding box area)."
	^ cells inject: 0.0 into: [ :sum :cell | sum + cell area ]
]
