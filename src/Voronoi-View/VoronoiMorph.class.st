Class {
	#name : 'VoronoiMorph',
	#superclass : 'Morph',
	#instVars : [ 'diagram', 'showSites', 'showEdges', 'showCells', 'cellColors' ],
	#category : 'Voronoi-View'
}

"VoronoiMorph renders a VoronoiDiagram using Morphic.

 Usage:
   | morph |
   morph := VoronoiMorph new openInWindow.
   morph addRandomSites: 15.

 Or with an existing diagram:
   morph := VoronoiMorph on: myDiagram."

{ #category : 'instance creation' }
VoronoiMorph class >> on: aDiagram [
	^ self new
		diagram: aDiagram;
		yourself
]

{ #category : 'instance creation' }
VoronoiMorph class >> openDefault [
	"Opens a window with a default random Voronoi diagram."
	| morph |
	morph := self new.
	morph addRandomSites: 12.
	^ morph openInWindow
]

{ #category : 'initialization' }
VoronoiMorph >> initialize [
	super initialize.
	showSites := true.
	showEdges := true.
	showCells := true.
	self extent: 500 @ 500.
	self color: Color white.
	diagram := VoronoiDiagram new
		bounds: (0 @ 0 corner: 500 @ 500);
		yourself.
	cellColors := Dictionary new.
]

{ #category : 'accessing' }
VoronoiMorph >> diagram [
	^ diagram
]

{ #category : 'accessing' }
VoronoiMorph >> diagram: aDiagram [
	diagram := aDiagram.
	cellColors := Dictionary new.
	self computeAndRefresh
]

{ #category : 'accessing' }
VoronoiMorph >> showSites [ ^ showSites ]
{ #category : 'accessing' }
VoronoiMorph >> showSites: aBoolean [ showSites := aBoolean. self changed ]

{ #category : 'accessing' }
VoronoiMorph >> showEdges [ ^ showEdges ]
{ #category : 'accessing' }
VoronoiMorph >> showEdges: aBoolean [ showEdges := aBoolean. self changed ]

{ #category : 'accessing' }
VoronoiMorph >> showCells [ ^ showCells ]
{ #category : 'accessing' }
VoronoiMorph >> showCells: aBoolean [ showCells := aBoolean. self changed ]

{ #category : 'building' }
VoronoiMorph >> addSiteAt: aPoint [
	diagram addSiteAt: aPoint.
	self computeAndRefresh
]

{ #category : 'building' }
VoronoiMorph >> addRandomSites: count [
	| w h |
	w := diagram bounds width.
	h := diagram bounds height.
	count timesRepeat: [
		diagram addSiteAt:
			(10 + (w - 20) atRandom) @ (10 + (h - 20) atRandom)
	].
	self computeAndRefresh
]

{ #category : 'building' }
VoronoiMorph >> clearSites [
	diagram := VoronoiDiagram new
		bounds: diagram bounds;
		yourself.
	cellColors := Dictionary new.
	self changed
]

{ #category : 'private' }
VoronoiMorph >> computeAndRefresh [
	diagram sites isEmpty ifFalse: [ diagram compute ].
	self assignCellColors.
	self changed
]

{ #category : 'private' }
VoronoiMorph >> assignCellColors [
	"Assign a distinct pastel color to each cell."
	| palette |
	palette := self colorPalette.
	cellColors := Dictionary new.
	diagram cells doWithIndex: [ :cell :i |
		cellColors at: cell site put: (palette at: (i - 1) \\ palette size + 1)
	]
]

{ #category : 'private' }
VoronoiMorph >> colorPalette [
	^ Array with: (Color r: 0.8 g: 0.6 b: 0.6)
		with: (Color r: 0.6 g: 0.8 b: 0.6)
		with: (Color r: 0.6 g: 0.6 b: 0.9)
		with: (Color r: 0.9 g: 0.9 b: 0.6)
		with: (Color r: 0.9 g: 0.7 b: 0.5)
		with: (Color r: 0.6 g: 0.9 b: 0.9)
		with: (Color r: 0.9 g: 0.6 b: 0.9)
		with: (Color r: 0.7 g: 0.85 b: 0.7)
		with: (Color r: 0.85 g: 0.7 b: 0.85)
		with: (Color r: 0.7 g: 0.7 b: 0.85)
		with: (Color r: 0.85 g: 0.85 b: 0.7)
		with: (Color r: 0.75 g: 0.9 b: 0.8)
]

{ #category : 'drawing' }
VoronoiMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.
	showCells ifTrue: [ self drawCellsOn: aCanvas ].
	showEdges ifTrue: [ self drawEdgesOn: aCanvas ].
	showSites ifTrue: [ self drawSitesOn: aCanvas ]
]

{ #category : 'drawing' }
VoronoiMorph >> drawCellsOn: aCanvas [
	diagram cells do: [ :cell |
		| verts color |
		verts := cell vertices.
		verts size < 3 ifFalse: [
			color := cellColors at: cell site ifAbsent: [ Color lightGray ].
			self drawPolygon: verts on: aCanvas fill: color
		]
	]
]

{ #category : 'drawing' }
VoronoiMorph >> drawPolygon: vertices on: aCanvas fill: aColor [
	"Fills a polygon using aCanvas fillPolygon:color: if available, otherwise use individual triangles."
	| origin pts |
	origin := self position.
	pts := vertices collect: [ :v | v + origin ].
	aCanvas
		drawPolygon: pts
		color: aColor
		borderWidth: 0
		borderColor: Color transparent.
]

{ #category : 'drawing' }
VoronoiMorph >> drawEdgesOn: aCanvas [
	| origin |
	origin := self position.
	diagram cells do: [ :cell |
		| verts n |
		verts := cell vertices.
		n := verts size.
		n >= 2 ifTrue: [
			1 to: n do: [ :i |
				| p1 p2 |
				p1 := (verts at: i) + origin.
				p2 := (verts at: (i \\ n) + 1) + origin.
				aCanvas
					line: p1
					to: p2
					width: 1
					color: Color black
			]
		]
	]
]

{ #category : 'drawing' }
VoronoiMorph >> drawSitesOn: aCanvas [
	| origin r |
	origin := self position.
	r := 4.
	diagram sites do: [ :site |
		| center |
		center := site position + origin.
		aCanvas
			fillOval: (Rectangle center: center extent: (r * 2) @ (r * 2))
			color: Color red.
	]
]

{ #category : 'event handling' }
VoronoiMorph >> mouseDown: anEvent [
	"Add a new site where the user clicks."
	| localPos |
	localPos := anEvent position - self position.
	(diagram bounds containsPoint: localPos) ifTrue: [
		self addSiteAt: localPos
	]
]

{ #category : 'event handling' }
VoronoiMorph >> handlesMouseDown: anEvent [
	^ true
]
