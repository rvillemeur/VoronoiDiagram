Class {
	#name : 'VoronoiDiagram',
	#superclass : 'Object',
	#instVars : [ 'sites', 'cells', 'bounds' ],
	#category : 'Voronoi-Model'
}

"VoronoiDiagram computes a Voronoi diagram using the half-plane clipping algorithm.

 For each site s, its Voronoi cell is the region of the bounding box closer
 to s than to any other site. This is computed by clipping the bounding box
 successively with each perpendicular bisector half-plane.

 Algorithm complexity: O(n^2) per site => O(n^3) total.

 Usage:
   diagram := VoronoiDiagram new
       bounds: (0 @ 0 corner: 500 @ 500);
       addSite: (VoronoiSite x: 100 y: 200);
       addSite: (VoronoiSite x: 300 y: 150);
       yourself.
   diagram compute.
   diagram cells do: [ :cell | ... ]."

{ #category : 'instance creation' }
VoronoiDiagram class >> withSites: aCollection inBounds: aRectangle [
	| diagram |
	diagram := self new
		bounds: aRectangle;
		yourself.
	aCollection doWithIndex: [ :pos :i |
		diagram addSite: (VoronoiSite at: pos index: i)
	].
	^ diagram
]

{ #category : 'initialization' }
VoronoiDiagram >> initialize [
	sites := OrderedCollection new.
	cells := OrderedCollection new.
	bounds := 0 @ 0 corner: 400 @ 400
]

{ #category : 'accessing' }
VoronoiDiagram >> bounds [
	^ bounds
]

{ #category : 'accessing' }
VoronoiDiagram >> bounds: aRectangle [
	bounds := aRectangle
]

{ #category : 'accessing' }
VoronoiDiagram >> sites [
	^ sites
]

{ #category : 'accessing' }
VoronoiDiagram >> cells [
	^ cells
]

{ #category : 'building' }
VoronoiDiagram >> addSite: aSite [
	aSite index ifNil: [ aSite index: sites size + 1 ].
	sites add: aSite.
	cells := OrderedCollection new.  "reset computed cells"
	^ aSite
]

{ #category : 'building' }
VoronoiDiagram >> addSiteAt: aPoint [
	^ self addSite: (VoronoiSite at: aPoint index: sites size + 1)
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
				| halfPlane |
				halfPlane := VoronoiHalfPlane between: site and: other.
				polygon := self clip: polygon by: halfPlane
			]
		].
		cells add: (VoronoiCell site: site vertices: polygon)
	]
]

{ #category : 'private' }
VoronoiDiagram >> boundingPolygon [
	"Returns the bounding box as an ordered list of vertices (clockwise in screen coords)."
	^ OrderedCollection with: bounds topLeft
		with: bounds topRight
		with: bounds bottomRight
		with: bounds bottomLeft
]

{ #category : 'private' }
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
		e := input at: (i \\ n) + 1.
		(aHalfPlane isInside: e)
			ifTrue: [
				(aHalfPlane isInside: s) ifFalse: [
					output add: (aHalfPlane intersectionOf: s with: e)
				].
				output add: e
			]
			ifFalse: [
				(aHalfPlane isInside: s) ifTrue: [
					output add: (aHalfPlane intersectionOf: s with: e)
				]
			]
	].
	^ output
]

{ #category : 'querying' }
VoronoiDiagram >> cellForSite: aSite [
	^ cells detect: [ :cell | cell site = aSite ] ifNone: [ nil ]
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
			nearest := site
		]
	].
	^ nearest
]

{ #category : 'querying' }
VoronoiDiagram >> totalArea [
	"Returns the sum of all cell areas (should equal the bounding box area)."
	^ cells inject: 0.0 into: [ :sum :cell | sum + cell area ]
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
