Trait {
	#name : 'VoronoiViewTrait',
	#instVars : [
		'diagram',
		'showSites',
		'showEdges',
		'showCells',
		'cellColors'
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

{ #category : 'accessing' }
VoronoiViewTrait >> diagram [ 
	^ diagram
]

{ #category : 'accessing' }
VoronoiViewTrait >> showCells [

	^ showCells
]

{ #category : 'accessing' }
VoronoiViewTrait >> showEdges [

	^ showEdges
]

{ #category : 'accessing' }
VoronoiViewTrait >> showSites [

	^ showSites
]
