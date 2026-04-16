"
I render a VoronoiDiagram using the Bloc framework (Pharo 10+).

I subclass BlElement and override drawOnSpartaCanvas: to draw cells, edges
and sites using the Sparta vector-graphics canvas.

Clicking inside my bounds adds a new site at the cursor position.

Usage:
```
  VoronoiBlocView openDefault.

  ""Or with an existing diagram:""
  (VoronoiBlocView on: myDiagram) openInSpace.
```
"
Class {
	#name : 'VoronoiBlocView',
	#superclass : 'BlElement',
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

{ #category : 'instance creation' }
VoronoiBlocView class >> on: aDiagram [

	^ self new
		  diagram: aDiagram;
		  yourself
]

{ #category : 'instance creation' }
VoronoiBlocView class >> openDefault [ 
<sampleInstance>
	"VoronoiBlocView openDefault"
	| view |
	view := self new.
	view addRandomSites: 120.
	view openInSpace.
	^ view
]

{ #category : 'building' }
VoronoiBlocView >> addRandomSites: count [

	| w h |
	w := diagram bounds width.
	h := diagram bounds height.
	count timesRepeat: [
		diagram addSiteAt: 10 + (w - 20) atRandom @ (10 + (h - 20) atRandom) ].
	self computeAndRefresh
]

{ #category : 'building' }
VoronoiBlocView >> addSiteAt: aPoint [ 
	diagram addSiteAt: aPoint.
	self computeAndRefresh
]

{ #category : 'drawing' }
VoronoiBlocView >> aeDrawOn: aeCanvas [ 
	"Entry point called by the Bloc rendering pipeline. 	 aeCanvas is an Alexandrie Canvas - Cairo front-end to draw custom BlElement"
	super aeDrawOn:  aeCanvas.
	showCells ifTrue: [ self drawCells: aeCanvas ].
	showEdges ifTrue: [ self drawEdges: aeCanvas ].
	showSites ifTrue: [ self drawSites: aeCanvas ]
]

{ #category : 'private' }
VoronoiBlocView >> assignCellColors [

	| palette |
	palette := self colorPalette.
	cellColors := Dictionary new.
	diagram cells doWithIndex: [ :cell :i |
		cellColors
			at: cell site
			put: (palette at: i - 1 \\ palette size + 1) ]
]

{ #category : 'building' }
VoronoiBlocView >> clearSites [

	diagram := VoronoiDiagram new
		           bounds: diagram bounds;
		           yourself.
	cellColors := Dictionary new.
	self invalidate
]

{ #category : 'private' }
VoronoiBlocView >> colorPalette [

	^ Array withAll: {
			  (Color r: 0.8 g: 0.6 b: 0.6).
			  (Color r: 0.6 g: 0.8 b: 0.6).
			  (Color r: 0.6 g: 0.6 b: 0.9).
			  (Color r: 0.9 g: 0.9 b: 0.6).
			  (Color r: 0.9 g: 0.7 b: 0.5).
			  (Color r: 0.6 g: 0.9 b: 0.9).
			  (Color r: 0.9 g: 0.6 b: 0.9).
			  (Color r: 0.7 g: 0.85 b: 0.7).
			  (Color r: 0.85 g: 0.7 b: 0.85).
			  (Color r: 0.7 g: 0.7 b: 0.85).
			  (Color r: 0.85 g: 0.85 b: 0.7).
			  (Color r: 0.75 g: 0.9 b: 0.8) }
]

{ #category : 'private' }
VoronoiBlocView >> computeAndRefresh [
	diagram sites isEmpty ifFalse: [ diagram compute ].
	self assignCellColors.
	self invalidate
]

{ #category : 'accessing' }
VoronoiBlocView >> diagram [ 
	^ diagram
]

{ #category : 'accessing' }
VoronoiBlocView >> diagram: aDiagram [ 
	diagram := aDiagram.
	cellColors := Dictionary new.
	self computeAndRefresh
]

{ #category : 'drawing' }
VoronoiBlocView >> drawCells: aCanvas [

	diagram cells do: [ :cell |
			| verts color |
			verts := cell vertices.
			verts size >= 3 ifTrue: [
					color := cellColors at: cell site ifAbsent: [ Color lightGray ].
					self drawPolygon: verts on: aCanvas fill: color ] ]
]

{ #category : 'drawing' }
VoronoiBlocView >> drawEdges: aeCanvas [

	diagram cells do: [ :cell |
			| verts n |
			verts := cell vertices.
			n := verts size.
			n >= 2 ifTrue: [
					1 to: n do: [ :i |
							| p1 p2 |
							p1 := verts at: i.
							p2 := verts at: i \\ n + 1.

							aeCanvas pathFactory: [ :cairoContext |
									cairoContext
										moveTo: p1 x asFloat @ p1 y asFloat;
										lineTo: p2 x asFloat @ p2 y asFloat ].
							aeCanvas setOutskirtsCentered.
							aeCanvas setBorderBlock: [
									aeCanvas
										setSourceColor: Color black;
										setBorderWidth: 1 ].
							aeCanvas drawFigure ] ] ]
]

{ #category : 'drawing' }
VoronoiBlocView >> drawPolygon: vertices on: aeCanvas fill: aColor [

	aeCanvas pathFactory: [ :cairoContext |
			cairoContext moveTo:
				vertices first x asFloat @ vertices first y asFloat.
			vertices allButFirst do: [ :v |
				cairoContext lineTo: v x asFloat @ v y asFloat ].
			cairoContext closePath ].

	aeCanvas setBackgroundWith: [ aeCanvas setSourceSolidColor: aColor ].

	aeCanvas setBorderOff.
	aeCanvas drawFigure
]

{ #category : 'drawing' }
VoronoiBlocView >> drawSites: aeCanvas [

	| r |
	r := 2.0.
	diagram sites do: [ :site |
			| cx cy |
			cx := site x asFloat.
			cy := site y asFloat.
			aeCanvas pathFactory: [ :cairoContext |
				cairoContext circleCenter: cx - r @ (cy - r) radius: r * 2.0 ].
			aeCanvas setBackgroundWith: [
				aeCanvas setSourceSolidColor: Color red ].

			aeCanvas setBorderOff.
			aeCanvas drawFigure ]
]

{ #category : 'initialization' }
VoronoiBlocView >> initialize [

	super initialize.
	showSites := true.
	showEdges := true.
	showCells := true.
	self extent: 500 @ 500.
	self background: Color white asBlBackground.
	diagram := VoronoiDiagram new
		           bounds: (0 @ 0 corner: 500 @ 500);
		           yourself.
	cellColors := Dictionary new.
	self installMouseHandler
]

{ #category : 'initialization' }
VoronoiBlocView >> installMouseHandler [ 
	self addEventHandlerOn: BlMouseDownEvent do: [ :event |
		| pos |
		pos := event position x truncated @ event position y truncated.
		(diagram bounds containsPoint: pos) ifTrue: [
			self addSiteAt: pos.
			event consume ] ]
]

{ #category : 'accessing' }
VoronoiBlocView >> showCells [  ^ showCells 
]

{ #category : 'accessing' }
VoronoiBlocView >> showCells: aBoolean [

	showCells := aBoolean.
	self invalidate
]

{ #category : 'accessing' }
VoronoiBlocView >> showEdges [  ^ showEdges 
]

{ #category : 'accessing' }
VoronoiBlocView >> showEdges: aBoolean [

	showEdges := aBoolean.
	self invalidate
]

{ #category : 'accessing' }
VoronoiBlocView >> showSites [

	^ showSites 
]

{ #category : 'accessing' }
VoronoiBlocView >> showSites: aBoolean [

	showSites := aBoolean.
	self invalidate
]
