"
Common method between Morph and Bloc view
"
Trait {
	#name : 'VoronoiViewTrait',
	#instVars : [
		'diagram',
		'showSites',
		'showEdges',
		'showCells',
		'diagramBounds'
	],
	#category : 'Voronoi-view',
	#package : 'Voronoi',
	#tag : 'view'
}

{ #category : 'adding' }
VoronoiViewTrait >> addRandomSites: count [

	| w h |
	w := diagram bounds width.
	h := diagram bounds height.
	count timesRepeat: [
		diagram addSiteAt: 10 + (w - 20) atRandom @ (10 + (h - 20) atRandom) ].
	self computeAndRefresh
]

{ #category : 'accessing' }
VoronoiViewTrait >> addSiteAt: aPoint [ 
	diagram addSiteAt: aPoint.
	self computeAndRefresh
]

{ #category : 'building' }
VoronoiViewTrait >> clearSites [

	diagram := VoronoiDiagram new
		           bounds: diagram bounds;
		           yourself.
	self refresh
]

{ #category : 'private' }
VoronoiViewTrait >> computeAndRefresh [
	diagram sites isEmpty ifFalse: [ diagram compute ].
	self refresh
]

{ #category : 'accessing' }
VoronoiViewTrait >> diagram [ 
	^ diagram
]

{ #category : 'accessing' }
VoronoiViewTrait >> diagram: aDiagram [ 
	diagram := aDiagram.

]

{ #category : 'accessing' }
VoronoiViewTrait >> diagramBounds [

	diagramBounds ifNil: [ diagramBounds := 500 @ 500 ].
	^ diagramBounds
]

{ #category : 'accessing' }
VoronoiViewTrait >> diagramBounds: aPoint [

	diagramBounds := aPoint.
	diagram  bounds: (0 @ 0 corner: diagramBounds ).
	self initElement
]

{ #category : 'initialization' }
VoronoiViewTrait >> initConstant [

	showSites := true.
	showEdges := true.
	showCells := true.
	diagram := VoronoiDiagram new
		           bounds: (0 @ 0 corner: self diagramBounds );
		           yourself.
]

{ #category : 'accessing' }
VoronoiViewTrait >> showCells [

	^ showCells
]

{ #category : 'accessing' }
VoronoiViewTrait >> showCells: aBoolean [

	showCells := aBoolean.
]

{ #category : 'accessing' }
VoronoiViewTrait >> showEdges [

	^ showEdges
]

{ #category : 'accessing' }
VoronoiViewTrait >> showEdges: aBoolean [

	showEdges := aBoolean.
]

{ #category : 'accessing' }
VoronoiViewTrait >> showSites [

	^ showSites
]

{ #category : 'accessing' }
VoronoiViewTrait >> showSites: aBoolean [

	showSites := aBoolean.
]
