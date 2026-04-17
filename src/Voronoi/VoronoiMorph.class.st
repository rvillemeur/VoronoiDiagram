"
VoronoiMorph renders a VoronoiDiagram using Morphic.

 Usage:
```
   | morph |
   morph := VoronoiMorph new openInWindow.
   morph addRandomSites: 15.
```

 Or with an existing diagram:
``` 
   morph := VoronoiMorph on: myDiagram.
```
"
Class {
	#name : 'VoronoiMorph',
	#superclass : 'Morph',
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
VoronoiMorph class >> on: aDiagram [

	^ self new
		  diagram: aDiagram;
		  yourself
]

{ #category : 'instance creation' }
VoronoiMorph class >> openDefault [

	<sampleInstance>
	"VoronoiMorph openDefault"

	| morph |
	morph := self new.
	morph addRandomSites: 120.
	^ morph openInWindow
]

{ #category : 'drawing' }
VoronoiMorph >> drawCellsOn: aCanvas [
	diagram cells do: [ :cell |
		| verts |
		verts := cell vertices.
		verts size >= 3 ifTrue: [
			color := Color random.
			self drawPolygon: verts on: aCanvas fill: color ] ]
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
				aCanvas
					line: (verts at: i) + origin
					to: (verts at: (i \\ n) + 1) + origin
					width: 1
					color: Color black ] ] ]
]

{ #category : 'drawing' }
VoronoiMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.
	showCells ifTrue: [ self drawCellsOn: aCanvas ].
	showEdges ifTrue: [ self drawEdgesOn: aCanvas ].
	showSites ifTrue: [ self drawSitesOn: aCanvas ]


]

{ #category : 'drawing' }
VoronoiMorph >> drawPolygon: vertices on: aCanvas fill: aColor [
	| origin pts |
	origin := self position.
	pts := vertices collect: [ :v | v + origin ].
	aCanvas
		drawPolygon: pts
		color: aColor
		borderWidth: 0
		borderColor: Color transparent

]

{ #category : 'drawing' }
VoronoiMorph >> drawSitesOn: aCanvas [
	| origin r |
	origin := self position.
	r := 4.
	diagram sites do: [ :site |
		aCanvas
			fillOval: (Rectangle center: site position + origin
				extent: (r * 2) @ (r * 2))
			color: Color red ]

]

{ #category : 'event handling' }
VoronoiMorph >> handlesMouseDown: anEvent [
	^ true


]

{ #category : 'initialization' }
VoronoiMorph >> initElement [ 
	self extent: self diagramBounds .
	self color: Color white
]

{ #category : 'initialization' }
VoronoiMorph >> initialize [

	super initialize.
	self initConstant.
	self initElement
]

{ #category : 'event handling' }
VoronoiMorph >> mouseDown: anEvent [
	| localPos |
	localPos := anEvent position - self position.
	(diagram bounds containsPoint: localPos) ifTrue: [
		self addSiteAt: localPos ]


]

{ #category : 'building' }
VoronoiMorph >> refresh [
	self changed
]
