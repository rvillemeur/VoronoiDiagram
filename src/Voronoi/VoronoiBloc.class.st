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
	#name : 'VoronoiBloc',
	#superclass : 'BlElement',
	#traits : 'VoronoiViewTrait',
	#classTraits : 'VoronoiViewTrait classTrait',
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
VoronoiBloc class >> on: aDiagram [

	^ self new
		  diagram: aDiagram;
		  yourself
]

{ #category : 'instance creation' }
VoronoiBloc class >> openDefault [ 
<sampleInstance>
	"VoronoiBlocView openDefault"
	| view |
	view := self new.
	view addRandomSites: 120.
	view openInSpace.
	^ view
]

{ #category : 'drawing' }
VoronoiBloc >> aeDrawOn: aeCanvas [ 
	"Entry point called by the Bloc rendering pipeline. 	 aeCanvas is an Alexandrie Canvas - Cairo front-end to draw custom BlElement"
	super aeDrawOn:  aeCanvas.
	showCells ifTrue: [ self drawCells: aeCanvas ].
	showEdges ifTrue: [ self drawEdges: aeCanvas ].
	showSites ifTrue: [ self drawSites: aeCanvas ]
]

{ #category : 'drawing' }
VoronoiBloc >> drawCells: aCanvas [

	diagram cells do: [ :cell |
			| verts color |
			verts := cell vertices.
			verts size >= 3 ifTrue: [
					color := cellColors at: cell site ifAbsent: [ Color lightGray ].
					self drawPolygon: verts on: aCanvas fill: color ] ]
]

{ #category : 'drawing' }
VoronoiBloc >> drawEdges: aeCanvas [

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
VoronoiBloc >> drawPolygon: vertices on: aeCanvas fill: aColor [

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
VoronoiBloc >> drawSites: aeCanvas [

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
VoronoiBloc >> initElement [
	self extent: self diagramBounds .
	self background: Color white asBlBackground.
	self installMouseHandler
]

{ #category : 'initialization' }
VoronoiBloc >> initialize [

	super initialize.
	self initConstant.
	self initElement
]

{ #category : 'initialization' }
VoronoiBloc >> installMouseHandler [ 
	self addEventHandlerOn: BlMouseDownEvent do: [ :event |
		| pos |
		pos := event position x truncated @ event position y truncated.
		(diagram bounds containsPoint: pos) ifTrue: [
			self addSiteAt: pos.
			event consume ] ]
]

{ #category : 'building' }
VoronoiBloc >> refresh [
	self invalidate
]
