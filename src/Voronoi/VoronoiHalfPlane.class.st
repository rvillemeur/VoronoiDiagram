"
I represent the half-plane used to clip a Voronoi cell.

A half-plane is defined by the inequality:  a*x + b*y + c <= 0
A point satisfying this inequality is ""inside"" (closer to the reference site).

Given two sites S and T, the locus of points equidistant from both is the
perpendicular bisector of segment ST. The half-plane for the cell of S is:

```
  dist(p, S)^2 <= dist(p, T)^2
```
  =>  2*(Tx-Sx)*x  +  2*(Ty-Sy)*y  +  (Sx^2+Sy^2-Tx^2-Ty^2)  <=  0

Instance variables:
-  a, b, c  <Float>  — coefficients of the inequality ax + by + c <= 0

Key methods:
-  isInside: aPoint          — true if ax+by+c <= 0
-  intersectionOf: p1 with: p2  — intersection of segment p1-p2 with boundary line
"
Class {
	#name : 'VoronoiHalfPlane',
	#superclass : 'Object',
	#instVars : [
		'a',
		'b',
		'c'
	],
	#category : 'Voronoi-model',
	#package : 'Voronoi',
	#tag : 'model'
}

{ #category : 'instance creation' }
VoronoiHalfPlane class >> between: siteS and: siteT [
	"Half-plane of points closer to siteS than siteT. 
	 Satisfies: 2*(tx-sx)*x + 2*(ty-sy)*y + (sx^2+sy^2-tx^2-ty^2) <= 0"

	| sx sy tx ty na nb nc |
	sx := siteS x asFloat.
	sy := siteS y asFloat.
	tx := siteT x asFloat.
	ty := siteT y asFloat.
	na := 2.0 * (tx - sx).
	nb := 2.0 * (ty - sy).
	nc := sx * sx + (sy * sy) - (tx * tx) - (ty * ty).
	^ self new
		  a: na b: nb c: nc;
		  yourself
]

{ #category : 'accessing' }
VoronoiHalfPlane >> a [

	^ a
]

{ #category : 'initialization' }
VoronoiHalfPlane >> a: anA b: aB c: aC [

	a := anA.
	b := aB.
	c := aC
]

{ #category : 'accessing' }
VoronoiHalfPlane >> b [

	^ b
]

{ #category : 'accessing' }
VoronoiHalfPlane >> c [

	^ c
]

{ #category : 'computing' }
VoronoiHalfPlane >> evaluate: aPoint [
"Signed value: negative means inside, positive means outside."
	^ (a * aPoint x asFloat) + (b * aPoint y asFloat) + c
]

{ #category : 'computing' }
VoronoiHalfPlane >> intersectionOf: p1 with: p2 [
"Returns the intersection of segment p1-p2 with the boundary line a*x+b*y+c=0."
	| f1 f2 t |
	f1 := self evaluate: p1.
	f2 := self evaluate: p2.
	t := f1 / (f1 - f2).
	^ (p2 x - p1 x) asFloat * t + p1 x asFloat
	  @ ((p2 y - p1 y) asFloat * t + p1 y asFloat)
]

{ #category : 'testing' }
VoronoiHalfPlane >> isInside: aPoint [
	"True if a*x + b*y + c <= 0 (point is closer to siteS)."

	^ a * aPoint x asFloat + (b * aPoint y asFloat) + c <= 0.0
]
