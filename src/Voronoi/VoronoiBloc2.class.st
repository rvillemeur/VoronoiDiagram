"
I render a VoronoiDiagram using the Bloc framework (Pharo 10+).

I subclass BlElement and create child for each sub element I want to display

Clicking inside my bounds adds a new site at the cursor position.

Usage:
```
  VoronoiBlocView openDefault.

  ""Or with an existing diagram:""
  (VoronoiBlocView on: myDiagram) openInSpace.
```
"
Class {
	#name : 'VoronoiBloc2',
	#superclass : 'BlElement',
	#traits : 'VoronoiViewTrait',
	#classTraits : 'VoronoiViewTrait classTrait',
	#instVars : [
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

{ #category : 'instance creation' }
VoronoiBloc2 class >> on: aDiagram [

	^ self new
		  diagram: aDiagram;
		  yourself
]

{ #category : 'instance creation' }
VoronoiBloc2 class >> openDefault [ 
<sampleInstance>
	"VoronoiBlocView openDefault"
	| view |
	view := self new.
	view addRandomSites: 120.
	view openInSpace.
	^ view
]

{ #category : 'adding' }
VoronoiBloc2 >> addCell: acell [

	| elt verts |
	verts := acell vertices.
	verts size >= 3 ifFalse: [ ^ self ].
	elt := BlElement new geometry: (BlPolylineGeometry vertices: verts).
	showCells ifTrue: [ elt background: Color random ].
	showEdges ifTrue: [
		elt border: (BlBorder paint: Color black width: 1) ].
	self addChild: elt
]

{ #category : 'accessing' }
VoronoiBloc2 >> backgroundColor [

	^ Color white asBlBackground
]

{ #category : 'drawing' }
VoronoiBloc2 >> drawSites [

	| r |
	r := 2.0.
	diagram sites do: [ :site |
			| cx cy elt |
			cx := site x asFloat.
			cy := site y asFloat.
			elt := BlElement new 
			geometry: (BlCircleGeometry new matchExtent: 5@5 );
			extent: 7@7;
		  background: Color red.
		self addChild: elt.
		elt position:  cx - r @ (cy - r) ].
	



]

{ #category : 'initialization' }
VoronoiBloc2 >> initElement [
	self extent: self diagramBounds .
	self background: self backgroundColor.
	self installMouseHandler.
]

{ #category : 'initialization' }
VoronoiBloc2 >> initialize [

	super initialize.
	self initConstant.
	self initElement

	
]

{ #category : 'initialization' }
VoronoiBloc2 >> installMouseHandler [ 
	self addEventHandlerOn: BlMouseDownEvent do: [ :event |
		| pos |
		pos := event position x truncated @ event position y truncated.
		(diagram bounds containsPoint: pos) ifTrue: [
			self addSiteAt: pos.
			event consume ] ]
]

{ #category : 'building' }
VoronoiBloc2 >> refresh [
	diagram cells do: [ :cell | self addCell: cell ].
	showSites ifTrue: [ self drawSites ].

]
