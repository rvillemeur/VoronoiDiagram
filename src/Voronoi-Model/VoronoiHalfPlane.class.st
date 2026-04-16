Class {
	#name : 'VoronoiHalfPlane',
	#superclass : 'Object',
	#instVars : [ 'a', 'b', 'c' ],
	#category : 'Voronoi-Model'
}

"Represents the half-plane: a*x + b*y + c <= 0
 Used to define the region closer to one site than another.
 Given sites s and t, the Voronoi cell of s satisfies dist(p,s) <= dist(p,t),
 which expands to: 2*(tx-sx)*x + 2*(ty-sy)*y - (tx^2+ty^2-sx^2-sy^2) <= 0"

{ #category : 'instance creation' }
VoronoiHalfPlane class >> between: siteS and: siteT [
	"Creates the half-plane for points closer to siteS than siteT."
	| sx sy tx ty a b c |
	sx := siteS x asFloat.
	sy := siteS y asFloat.
	tx := siteT x asFloat.
	ty := siteT y asFloat.
	a := 2.0 * (tx - sx).
	b := 2.0 * (ty - sy).
	c := (sx * sx) + (sy * sy) - (tx * tx) - (ty * ty).
	^ self new
		a: a b: b c: c;
		yourself
]

{ #category : 'instance creation' }
VoronoiHalfPlane class >> withA: anA b: aB c: aC [
	^ self new
		a: anA b: aB c: aC;
		yourself
]

{ #category : 'initialization' }
VoronoiHalfPlane >> a: anA b: aB c: aC [
	a := anA.
	b := aB.
	c := aC
]

{ #category : 'accessing' }
VoronoiHalfPlane >> a [ ^ a ]
{ #category : 'accessing' }
VoronoiHalfPlane >> b [ ^ b ]
{ #category : 'accessing' }
VoronoiHalfPlane >> c [ ^ c ]

{ #category : 'testing' }
VoronoiHalfPlane >> isInside: aPoint [
	"Returns true if aPoint satisfies a*x + b*y + c <= 0"
	^ (a * aPoint x) + (b * aPoint y) + c <= 0.0
]

{ #category : 'computing' }
VoronoiHalfPlane >> evaluate: aPoint [
	"Signed value: negative means inside, positive means outside."
	^ (a * aPoint x) + (b * aPoint y) + c
]

{ #category : 'computing' }
VoronoiHalfPlane >> intersectionOf: p1 with: p2 [
	"Returns the intersection of segment p1-p2 with the boundary line a*x+b*y+c=0."
	| f1 f2 t |
	f1 := self evaluate: p1.
	f2 := self evaluate: p2.
	t := f1 / (f1 - f2).
	^ ((p2 x - p1 x) * t + p1 x) @ ((p2 y - p1 y) * t + p1 y)
]

{ #category : 'printing' }
VoronoiHalfPlane >> printOn: aStream [
	aStream
		nextPutAll: 'VoronoiHalfPlane(';
		print: a; nextPutAll: 'x + ';
		print: b; nextPutAll: 'y + ';
		print: c; nextPutAll: ' <= 0)'
]
