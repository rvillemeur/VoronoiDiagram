Class {
	#name : 'VoronoiCell',
	#superclass : 'Object',
	#instVars : [ 'site', 'vertices' ],
	#category : 'Voronoi-Model'
}

{ #category : 'instance creation' }
VoronoiCell class >> site: aSite vertices: aVertexCollection [
	^ self new
		site: aSite;
		vertices: aVertexCollection asArray;
		yourself
]

{ #category : 'accessing' }
VoronoiCell >> site [
	^ site
]

{ #category : 'accessing' }
VoronoiCell >> site: aSite [
	site := aSite
]

{ #category : 'accessing' }
VoronoiCell >> vertices [
	^ vertices
]

{ #category : 'accessing' }
VoronoiCell >> vertices: aCollection [
	vertices := aCollection asArray
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
		j := (i \\ n) + 1.
		p1 := vertices at: i.
		p2 := vertices at: j.
		sum := sum + ((p1 x * p2 y) - (p2 x * p1 y))
	].
	^ sum abs / 2.0
]

{ #category : 'computing' }
VoronoiCell >> containsPoint: aPoint [
	"Tests if a point is inside the cell polygon using ray casting."
	| n inside px py |
	n := vertices size.
	n < 3 ifTrue: [ ^ false ].
	inside := false.
	px := aPoint x asFloat.
	py := aPoint y asFloat.
	| j |
	j := n.
	1 to: n do: [ :i |
		| vi vj |
		vi := vertices at: i.
		vj := vertices at: j.
		((vi y > py) ~= (vj y > py)) ifTrue: [
			| xIntersect |
			xIntersect := (vj x - vi x) * (py - vi y) / (vj y - vi y) + vi x.
			px < xIntersect ifTrue: [ inside := inside not ]
		].
		j := i
	].
	^ inside
]

{ #category : 'computing' }
VoronoiCell >> centroid [
	"Returns the centroid of the cell polygon."
	| sumX sumY n |
	n := vertices size.
	n = 0 ifTrue: [ ^ 0 @ 0 ].
	sumX := 0.0.
	sumY := 0.0.
	vertices do: [ :v |
		sumX := sumX + v x.
		sumY := sumY + v y
	].
	^ (sumX / n) @ (sumY / n)
]

{ #category : 'printing' }
VoronoiCell >> printOn: aStream [
	aStream
		nextPutAll: 'VoronoiCell(site: ';
		print: site;
		nextPutAll: ', vertices: ';
		print: vertices size;
		nextPut: $)
]
