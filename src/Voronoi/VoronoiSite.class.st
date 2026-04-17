"
I represent a seed point (generator) in a Voronoi diagram.

Each site has a position (a Pharo Point) and an integer index used for identification.
The Voronoi cell of a site is the region of space closer to that site than to any other.

Instance variables:
-   position  <Point>    — the 2D coordinates of the seed point
-   index     <Integer>  — unique identifier within a VoronoiDiagram

Example:
```st
  VoronoiSite at: 200 @ 150 index: 3
  VoronoiSite x: 100 y: 200'
``` 
"
Class {
	#name : 'VoronoiSite',
	#superclass : 'Object',
	#instVars : [
		'position',
		'index'
	],
	#category : 'Voronoi-model',
	#package : 'Voronoi',
	#tag : 'model'
}

{ #category : 'instance creation' }
VoronoiSite class >> at: aPoint [

	^ self new
		  position: aPoint;
		  yourself
]

{ #category : 'instance creation' }
VoronoiSite class >> at: aPoint index: anInteger [

	^ self new
		  position: aPoint;
		  index: anInteger;
		  yourself
]

{ #category : 'instance creation' }
VoronoiSite class >> x: anX y: aY [

	^ self at: anX @ aY
]

{ #category : 'comparing' }
VoronoiSite >> = other [

	(other isKindOf: VoronoiSite) ifFalse: [ ^ false ].
	^ position = other position
]

{ #category : 'accessing' }
VoronoiSite >> index [

	^ index
]

{ #category : 'accessing' }
VoronoiSite >> index: anInteger [

	index := anInteger
]

{ #category : 'accessing' }
VoronoiSite >> position [

	^ position
]

{ #category : 'accessing' }
VoronoiSite >> position: aPoint [

	position := aPoint
]

{ #category : 'printing' }
VoronoiSite >> printOn: aStream [

	aStream
		nextPutAll: 'VoronoiSite(';
		print: index;
		nextPutAll: ' @ ';
		print: position;
		nextPut: $)
]

{ #category : 'computing' }
VoronoiSite >> squaredDistanceTo: aPoint [

	| dx dy |
	dx := aPoint x - position x.
	dy := aPoint y - position y.
	^ dx * dx + (dy * dy)
]

{ #category : 'accessing' }
VoronoiSite >> x [

	^ position x
]

{ #category : 'accessing' }
VoronoiSite >> y [

	^ position y
]
