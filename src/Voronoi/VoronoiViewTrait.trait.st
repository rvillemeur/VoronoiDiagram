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
		'cellColors',
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

{ #category : 'private' }
VoronoiViewTrait >> assignCellColors [

	| palette |
	palette := self colorPalette.
	cellColors := Dictionary new.
	diagram cells doWithIndex: [ :cell :i |
		cellColors
			at: cell site
			put: (palette at: i - 1 \\ palette size + 1) ]
]

{ #category : 'building' }
VoronoiViewTrait >> clearSites [

	diagram := VoronoiDiagram new
		           bounds: diagram bounds;
		           yourself.
	cellColors := Dictionary new.
	self refresh
]

{ #category : 'private' }
VoronoiViewTrait >> colorPalette [
	^ Array withAll: {  
		. (Color r: 0.8 g: 0.6 b: 0.6)
		. (Color r: 0.6 g: 0.8 b: 0.6)
		. (Color r: 0.6 g: 0.6 b: 0.9)
		. (Color r: 0.9 g: 0.9 b: 0.6)
		. (Color r: 0.9 g: 0.7 b: 0.5)
		. (Color r: 0.6 g: 0.9 b: 0.9)
		. (Color r: 0.9 g: 0.6 b: 0.9)
		. (Color r: 0.7 g: 0.85 b: 0.7)
		. (Color r: 0.85 g: 0.7 b: 0.85)
		. (Color r: 0.7 g: 0.7 b: 0.85)
		. (Color r: 0.85 g: 0.85 b: 0.7)
		. (Color r: 0.75 g: 0.9 b: 0.8) }

]

{ #category : 'private' }
VoronoiViewTrait >> computeAndRefresh [
	diagram sites isEmpty ifFalse: [ diagram compute ].
	self assignCellColors.
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
	cellColors := Dictionary new.
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
