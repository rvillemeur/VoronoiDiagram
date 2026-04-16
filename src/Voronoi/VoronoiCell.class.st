"
'I represent a single cell of a Voronoi diagram.

A Voronoi cell is the convex polygon containing all points of the plane
that are closer to my site than to any other site. Within a bounded diagram
the polygon is the intersection of the bounding box with a set of half-planes.

Instance variables:
-  site      <VoronoiSite>   — the generator (seed point) of this cell
-  vertices  <Array of Point> — ordered polygon vertices (screen-coordinate winding)

Key methods:
-  area            — polygon area via the shoelace formula (always positive)
-  containsPoint:  — ray-casting point-in-polygon test
-  centroid        — arithmetic mean of the vertices
-  isUnbounded     — true when clipping produced fewer than 3 vertices (degenerate)'
"
Class {
	#name : 'VoronoiCell',
	#superclass : 'Object',
	#instVars : [
		'site',
		'vertices'
	],
	#category : 'Voronoi-model',
	#package : 'Voronoi',
	#tag : 'model'
}

{ #category : 'instance creation' }
VoronoiCell class >> site: aSite vertices: aCollection [

	^ self new
		  site: aSite;
		  vertices: aCollection asArray;
		  yourself
]

{ #category : 'computing' }
VoronoiCell >> area [
"Computes the signed area using the shoelace formula.
	 Returns a positive value for counterclockwise winding."

	| n sum |
	n := vertices size.
	n < 3 ifTrue: [ ^ 0.0 ].
	sum := 0.0.
	1 to: n do: [ :i |
			| j p1 p2 |
			j := i \\ n + 1.
			p1 := vertices at: i.
			p2 := vertices at: j.
			sum := sum
			       +
			       (p1 x asFloat * p2 y asFloat - (p2 x asFloat * p1 y asFloat)) ].
	^ sum abs / 2.0
]

{ #category : 'computing' }
VoronoiCell >> centroid [
"Returns the centroid of the cell polygon."
	| n sumX sumY |
	n := vertices size.
	n = 0 ifTrue: [ ^ 0 @ 0 ].
	sumX := 0.0.
	sumY := 0.0.
	vertices do: [ :v |
			sumX := sumX + v x.
			sumY := sumY + v y ].
	^ sumX / n @ (sumY / n)
]

{ #category : 'computing' }
VoronoiCell >> containsPoint: aPoint [
"Tests if a point is inside the cell polygon using ray casting."
	| n inside px py j |
	n := vertices size.
	n < 3 ifTrue: [ ^ false ].
	inside := false.
	px := aPoint x asFloat.
	py := aPoint y asFloat.
	j := n.
	1 to: n do: [ :i |
			| vi vj |
			vi := vertices at: i.
			vj := vertices at: j.
			vi y asFloat > py ~= (vj y asFloat > py) ifTrue: [
					| xIntersect |
					xIntersect := vj x asFloat - vi x asFloat * (py - vi y asFloat)
					              / (vj y asFloat - vi y asFloat) + vi x asFloat.
					px < xIntersect ifTrue: [ inside := inside not ] ].
			j := i ].
	^ inside
]

{ #category : 'testing' }
VoronoiCell >> isEmpty [

	^ vertices isEmpty
]

{ #category : 'testing' }
VoronoiCell >> isUnbounded [
"A cell is considered unbounded if it was clipped to fewer than 3 vertices (degenerate)."
	^ vertices size < 3
]

{ #category : 'printing' }
VoronoiCell >> printOn: aStream [

	aStream
		nextPutAll: 'VoronoiCell(site: ';
		print: site;
		nextPutAll: ', verts: ';
		print: vertices size;
		nextPut: $)
]

{ #category : 'accessing' }
VoronoiCell >> site [

	^ site
]

{ #category : 'accessing' }
VoronoiCell >> site: anObject [

	site := anObject
]

{ #category : 'accessing' }
VoronoiCell >> vertices [

	^ vertices
]

{ #category : 'accessing' }
VoronoiCell >> vertices: anObject [

	vertices := anObject
]
