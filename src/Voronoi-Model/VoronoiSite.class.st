Class {
	#name : 'VoronoiSite',
	#superclass : 'Object',
	#instVars : [ 'position', 'index' ],
	#category : 'Voronoi-Model'
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

{ #category : 'accessing' }
VoronoiSite >> position [
	^ position
]

{ #category : 'accessing' }
VoronoiSite >> position: aPoint [
	position := aPoint
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
VoronoiSite >> x [
	^ position x
]

{ #category : 'accessing' }
VoronoiSite >> y [
	^ position y
]

{ #category : 'computing' }
VoronoiSite >> squaredDistanceTo: aPoint [
	| dx dy |
	dx := aPoint x - position x.
	dy := aPoint y - position y.
	^ (dx * dx) + (dy * dy)
]

{ #category : 'comparing' }
VoronoiSite >> = other [
	other isKindOf: VoronoiSite ifFalse: [ ^ false ].
	^ position = other position
]

{ #category : 'comparing' }
VoronoiSite >> hash [
	^ position hash
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
