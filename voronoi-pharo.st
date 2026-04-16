"============================================================
 Voronoi Diagram for Pharo
 Import with: FileStream fileIn: '/path/to/voronoi-pharo.st'
 Or drag-and-drop into a Pharo image.
 ============================================================"

"--- VoronoiSite ---"

Object subclass: #VoronoiSite
	instanceVariableNames: 'position index'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Voronoi-Model'!

!VoronoiSite class methodsFor: 'instance creation'!
at: aPoint
	^ self new
		position: aPoint;
		yourself
!

at: aPoint index: anInteger
	^ self new
		position: aPoint;
		index: anInteger;
		yourself
!

x: anX y: aY
	^ self at: anX @ aY
! !

!VoronoiSite methodsFor: 'accessing'!
position
	^ position
!

position: aPoint
	position := aPoint
!

index
	^ index
!

index: anInteger
	index := anInteger
!

x
	^ position x
!

y
	^ position y
! !

!VoronoiSite methodsFor: 'computing'!
squaredDistanceTo: aPoint
	| dx dy |
	dx := aPoint x - position x.
	dy := aPoint y - position y.
	^ (dx * dx) + (dy * dy)
! !

!VoronoiSite methodsFor: 'comparing'!
= other
	(other isKindOf: VoronoiSite) ifFalse: [ ^ false ].
	^ position = other position
!

hash
	^ position hash
! !

!VoronoiSite methodsFor: 'printing'!
printOn: aStream
	aStream
		nextPutAll: 'VoronoiSite(';
		print: index;
		nextPutAll: ' @ ';
		print: position;
		nextPut: $)
! !


"--- VoronoiHalfPlane ---"

Object subclass: #VoronoiHalfPlane
	instanceVariableNames: 'a b c'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Voronoi-Model'!

!VoronoiHalfPlane class methodsFor: 'instance creation'!
between: siteS and: siteT
	"Half-plane of points closer to siteS than siteT.
	 Satisfies: 2*(tx-sx)*x + 2*(ty-sy)*y + (sx^2+sy^2-tx^2-ty^2) <= 0"
	| sx sy tx ty na nb nc |
	sx := siteS x asFloat.
	sy := siteS y asFloat.
	tx := siteT x asFloat.
	ty := siteT y asFloat.
	na := 2.0 * (tx - sx).
	nb := 2.0 * (ty - sy).
	nc := (sx * sx) + (sy * sy) - (tx * tx) - (ty * ty).
	^ self new
		a: na b: nb c: nc;
		yourself
! !

!VoronoiHalfPlane methodsFor: 'initialization'!
a: anA b: aB c: aC
	a := anA.
	b := aB.
	c := aC
! !

!VoronoiHalfPlane methodsFor: 'accessing'!
a [ ^ a ]
b [ ^ b ]
c [ ^ c ]
! !

!VoronoiHalfPlane methodsFor: 'testing'!
isInside: aPoint
	"True if a*x + b*y + c <= 0 (point is closer to siteS)."
	^ (a * aPoint x asFloat) + (b * aPoint y asFloat) + c <= 0.0
! !

!VoronoiHalfPlane methodsFor: 'computing'!
evaluate: aPoint
	^ (a * aPoint x asFloat) + (b * aPoint y asFloat) + c
!

intersectionOf: p1 with: p2
	| f1 f2 t |
	f1 := self evaluate: p1.
	f2 := self evaluate: p2.
	t := f1 / (f1 - f2).
	^ ((p2 x - p1 x) asFloat * t + p1 x asFloat)
		@ ((p2 y - p1 y) asFloat * t + p1 y asFloat)
! !


"--- VoronoiCell ---"

Object subclass: #VoronoiCell
	instanceVariableNames: 'site vertices'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Voronoi-Model'!

!VoronoiCell class methodsFor: 'instance creation'!
site: aSite vertices: aCollection
	^ self new
		site: aSite;
		vertices: aCollection asArray;
		yourself
! !

!VoronoiCell methodsFor: 'accessing'!
site
	^ site
!

site: aSite
	site := aSite
!

vertices
	^ vertices
!

vertices: aCollection
	vertices := aCollection asArray
! !

!VoronoiCell methodsFor: 'testing'!
isEmpty
	^ vertices isEmpty
!

isUnbounded
	^ vertices size < 3
! !

!VoronoiCell methodsFor: 'computing'!
area
	"Shoelace formula."
	| n sum |
	n := vertices size.
	n < 3 ifTrue: [ ^ 0.0 ].
	sum := 0.0.
	1 to: n do: [ :i |
		| j p1 p2 |
		j := (i \\ n) + 1.
		p1 := vertices at: i.
		p2 := vertices at: j.
		sum := sum + ((p1 x asFloat * p2 y asFloat) - (p2 x asFloat * p1 y asFloat))
	].
	^ sum abs / 2.0
!

containsPoint: aPoint
	"Ray casting algorithm."
	| n inside px py j |
	n := vertices size.
	n < 3 ifTrue: [ ^ false ].
	inside := false.
	px := aPoint x asFloat.
	py := aPoint y asFloat.
	j := n.
	1 to: n do: [ :i |
		| vi vj |
		vi := vertices at: i.
		vj := vertices at: j.
		((vi y asFloat > py) ~= (vj y asFloat > py)) ifTrue: [
			| xIntersect |
			xIntersect := (vj x asFloat - vi x asFloat)
				* (py - vi y asFloat)
				/ (vj y asFloat - vi y asFloat)
				+ vi x asFloat.
			px < xIntersect ifTrue: [ inside := inside not ]
		].
		j := i
	].
	^ inside
!

centroid
	| n sumX sumY |
	n := vertices size.
	n = 0 ifTrue: [ ^ 0 @ 0 ].
	sumX := 0.0. sumY := 0.0.
	vertices do: [ :v | sumX := sumX + v x. sumY := sumY + v y ].
	^ (sumX / n) @ (sumY / n)
! !

!VoronoiCell methodsFor: 'printing'!
printOn: aStream
	aStream
		nextPutAll: 'VoronoiCell(site: ';
		print: site;
		nextPutAll: ', verts: ';
		print: vertices size;
		nextPut: $)
! !


"--- VoronoiDiagram ---"

Object subclass: #VoronoiDiagram
	instanceVariableNames: 'sites cells bounds'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Voronoi-Model'!

!VoronoiDiagram class methodsFor: 'instance creation'!
withSites: aCollection inBounds: aRectangle
	| diagram |
	diagram := self new bounds: aRectangle; yourself.
	aCollection doWithIndex: [ :pos :i |
		diagram addSite: (VoronoiSite at: pos index: i) ].
	^ diagram
! !

!VoronoiDiagram methodsFor: 'initialization'!
initialize
	sites := OrderedCollection new.
	cells := OrderedCollection new.
	bounds := 0 @ 0 corner: 400 @ 400
! !

!VoronoiDiagram methodsFor: 'accessing'!
bounds
	^ bounds
!

bounds: aRectangle
	bounds := aRectangle
!

sites
	^ sites
!

cells
	^ cells
! !

!VoronoiDiagram methodsFor: 'building'!
addSite: aSite
	aSite index ifNil: [ aSite index: sites size + 1 ].
	sites add: aSite.
	cells := OrderedCollection new.
	^ aSite
!

addSiteAt: aPoint
	^ self addSite: (VoronoiSite at: aPoint index: sites size + 1)
! !

!VoronoiDiagram methodsFor: 'computing'!
compute
	cells := OrderedCollection new.
	sites do: [ :site |
		| polygon |
		polygon := self boundingPolygon.
		sites do: [ :other |
			other = site ifFalse: [
				polygon := self clip: polygon
					by: (VoronoiHalfPlane between: site and: other)
			]
		].
		cells add: (VoronoiCell site: site vertices: polygon)
	]
!

boundingPolygon
	^ OrderedCollection
		with: bounds topLeft
		with: bounds topRight
		with: bounds bottomRight
		with: bounds bottomLeft
!

clip: aPolygon by: aHalfPlane
	"Sutherland-Hodgman single half-plane clip."
	| input output n |
	input := aPolygon.
	n := input size.
	n = 0 ifTrue: [ ^ OrderedCollection new ].
	output := OrderedCollection new.
	1 to: n do: [ :i |
		| s e |
		s := input at: i.
		e := input at: (i \\ n) + 1.
		(aHalfPlane isInside: e)
			ifTrue: [
				(aHalfPlane isInside: s) ifFalse: [
					output add: (aHalfPlane intersectionOf: s with: e) ].
				output add: e ]
			ifFalse: [
				(aHalfPlane isInside: s) ifTrue: [
					output add: (aHalfPlane intersectionOf: s with: e) ] ]
	].
	^ output
! !

!VoronoiDiagram methodsFor: 'querying'!
cellForSite: aSite
	^ cells detect: [ :cell | cell site = aSite ] ifNone: [ nil ]
!

nearestSiteTo: aPoint
	| nearest minDist |
	nearest := nil.
	minDist := Float infinity.
	sites do: [ :site |
		| dist |
		dist := site squaredDistanceTo: aPoint.
		dist < minDist ifTrue: [ minDist := dist. nearest := site ]
	].
	^ nearest
!

totalArea
	^ cells inject: 0.0 into: [ :sum :cell | sum + cell area ]
! !

!VoronoiDiagram methodsFor: 'printing'!
printOn: aStream
	aStream
		nextPutAll: 'VoronoiDiagram(';
		print: sites size;
		nextPutAll: ' sites, bounds: ';
		print: bounds;
		nextPut: $)
! !


"--- VoronoiMorph ---"

Morph subclass: #VoronoiMorph
	instanceVariableNames: 'diagram showSites showEdges showCells cellColors'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Voronoi-View'!

!VoronoiMorph class methodsFor: 'instance creation'!
on: aDiagram
	^ self new diagram: aDiagram; yourself
!

openDefault
	"VoronoiMorph openDefault"
	| morph |
	morph := self new.
	morph addRandomSites: 12.
	^ morph openInWindow
! !

!VoronoiMorph methodsFor: 'initialization'!
initialize
	super initialize.
	showSites := true.
	showEdges := true.
	showCells := true.
	self extent: 500 @ 500.
	self color: Color white.
	diagram := VoronoiDiagram new
		bounds: (0 @ 0 corner: 500 @ 500);
		yourself.
	cellColors := Dictionary new
! !

!VoronoiMorph methodsFor: 'accessing'!
diagram
	^ diagram
!

diagram: aDiagram
	diagram := aDiagram.
	cellColors := Dictionary new.
	self computeAndRefresh
!

showSites [ ^ showSites ]
showSites: aBoolean [ showSites := aBoolean. self changed ]
showEdges [ ^ showEdges ]
showEdges: aBoolean [ showEdges := aBoolean. self changed ]
showCells [ ^ showCells ]
showCells: aBoolean [ showCells := aBoolean. self changed ]
! !

!VoronoiMorph methodsFor: 'building'!
addSiteAt: aPoint
	diagram addSiteAt: aPoint.
	self computeAndRefresh
!

addRandomSites: count
	| w h |
	w := diagram bounds width.
	h := diagram bounds height.
	count timesRepeat: [
		diagram addSiteAt:
			(10 + (w - 20) atRandom) @ (10 + (h - 20) atRandom)
	].
	self computeAndRefresh
!

clearSites
	diagram := VoronoiDiagram new bounds: diagram bounds; yourself.
	cellColors := Dictionary new.
	self changed
! !

!VoronoiMorph methodsFor: 'private'!
computeAndRefresh
	diagram sites isEmpty ifFalse: [ diagram compute ].
	self assignCellColors.
	self changed
!

assignCellColors
	| palette |
	palette := self colorPalette.
	cellColors := Dictionary new.
	diagram cells doWithIndex: [ :cell :i |
		cellColors at: cell site put: (palette at: (i - 1) \\ palette size + 1) ]
!

colorPalette
	^ Array
		with: (Color r: 0.8 g: 0.6 b: 0.6)
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
! !

!VoronoiMorph methodsFor: 'drawing'!
drawOn: aCanvas
	super drawOn: aCanvas.
	showCells ifTrue: [ self drawCellsOn: aCanvas ].
	showEdges ifTrue: [ self drawEdgesOn: aCanvas ].
	showSites ifTrue: [ self drawSitesOn: aCanvas ]
!

drawCellsOn: aCanvas
	diagram cells do: [ :cell |
		| verts color |
		verts := cell vertices.
		verts size >= 3 ifTrue: [
			color := cellColors at: cell site ifAbsent: [ Color lightGray ].
			self drawPolygon: verts on: aCanvas fill: color ] ]
!

drawPolygon: vertices on: aCanvas fill: aColor
	| origin pts |
	origin := self position.
	pts := vertices collect: [ :v | v + origin ].
	aCanvas
		drawPolygon: pts
		color: aColor
		borderWidth: 0
		borderColor: Color transparent
!

drawEdgesOn: aCanvas
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
!

drawSitesOn: aCanvas
	| origin r |
	origin := self position.
	r := 4.
	diagram sites do: [ :site |
		aCanvas
			fillOval: (Rectangle center: site position + origin
				extent: (r * 2) @ (r * 2))
			color: Color red ]
! !

!VoronoiMorph methodsFor: 'event handling'!
mouseDown: anEvent
	| localPos |
	localPos := anEvent position - self position.
	(diagram bounds containsPoint: localPos) ifTrue: [
		self addSiteAt: localPos ]
!

handlesMouseDown: anEvent
	^ true
! !


"--- VoronoiDiagramTest ---"

TestCase subclass: #VoronoiDiagramTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Voronoi-Tests'!

!VoronoiDiagramTest methodsFor: 'private'!
bounds
	^ 0 @ 0 corner: 400 @ 400
!

assertArea: actual closeTo: expected
	self assert: (actual - expected) abs < 1.0
! !

!VoronoiDiagramTest methodsFor: 'tests - level 1'!
testSingleSite
	"One site => cell covers the entire bounding box."
	| diagram cell |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 200 @ 200.
	diagram compute.
	self assert: diagram cells size equals: 1.
	cell := diagram cells first.
	self assert: cell vertices size equals: 4.
	self assertArea: cell area closeTo: 400 * 400
!

testSingleSiteCellContainsSite
	| diagram cell |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 150 @ 230.
	diagram compute.
	cell := diagram cells first.
	self assert: (cell containsPoint: 150 @ 230)
! !

!VoronoiDiagramTest methodsFor: 'tests - level 2'!
testTwoSitesHorizontalSplit
	"Two sites symmetric about x=200 => each cell is half the bounding box."
	| diagram leftCell rightCell |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 100 @ 200.
	diagram addSiteAt: 300 @ 200.
	diagram compute.
	self assert: diagram cells size equals: 2.
	leftCell  := diagram cells detect: [ :c | c site x < 200 ].
	rightCell := diagram cells detect: [ :c | c site x > 200 ].
	self assertArea: leftCell area closeTo: 400 * 200.
	self assertArea: rightCell area closeTo: 400 * 200
!

testTwoSitesVerticalSplit
	| diagram topCell bottomCell |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 200 @ 100.
	diagram addSiteAt: 200 @ 300.
	diagram compute.
	topCell    := diagram cells detect: [ :c | c site y < 200 ].
	bottomCell := diagram cells detect: [ :c | c site y > 200 ].
	self assertArea: topCell area closeTo: 200 * 400.
	self assertArea: bottomCell area closeTo: 200 * 400
!

testTwoSitesCellsContainSites
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 80 @ 200.
	diagram addSiteAt: 320 @ 200.
	diagram compute.
	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position) ]
!

testTwoSitesTotalArea
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 120 @ 180.
	diagram addSiteAt: 280 @ 220.
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
! !

!VoronoiDiagramTest methodsFor: 'tests - level 3'!
testThreeSitesEquilateral
	"Three sites at 120° intervals => all three cells have equal area."
	| r diagram areas |
	r := 120.0.
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	#(0 1 2) do: [ :k |
		| angle |
		angle := Float pi * 2 * k / 3.0.
		diagram addSiteAt:
			(200 + (r * angle cos)) rounded @ (200 + (r * angle sin)) rounded ].
	diagram compute.
	self assert: diagram cells size equals: 3.
	areas := diagram cells collect: [ :c | c area ].
	self assertArea: (areas first - areas second) abs closeTo: 0.
	self assertArea: (areas first - areas last) abs closeTo: 0
!

testThreeSitesCollinear
	"Middle site of three collinear => its cell is a vertical strip of width 100."
	| diagram middleCell |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 100 @ 200.
	diagram addSiteAt: 200 @ 200.
	diagram addSiteAt: 300 @ 200.
	diagram compute.
	middleCell := diagram cells detect: [ :c | c site x = 200 ].
	self assertArea: middleCell area closeTo: 400 * 100
!

testThreeSitesTotalArea
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 150.
	diagram addSiteAt: 200 @ 300.
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
!

testThreeSitesCellsContainSites
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 150.
	diagram addSiteAt: 200 @ 300.
	diagram compute.
	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position) ]
! !

!VoronoiDiagramTest methodsFor: 'tests - level 4'!
testFourSitesSquare
	"Four sites at corners of a centered square => equal cells."
	| diagram areas |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 100.
	diagram addSiteAt: 300 @ 300.
	diagram addSiteAt: 100 @ 300.
	diagram compute.
	self assert: diagram cells size equals: 4.
	areas := diagram cells collect: [ :c | c area ].
	areas do: [ :area | self assertArea: area closeTo: 400.0 * 400.0 / 4.0 ]
!

testFourSitesTotalArea
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 100.
	diagram addSiteAt: 300 @ 300.
	diagram addSiteAt: 100 @ 300.
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
! !

!VoronoiDiagramTest methodsFor: 'tests - level 5'!
testManySitesCellCount
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	self assert: diagram cells size equals: diagram sites size
!

testManySitesTotalArea
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
!

testManySitesCellsContainSites
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position) ]
!

testNoCellIsDegenerate
	| diagram |
	diagram := VoronoiDiagram new bounds: self bounds; yourself.
	#(50@50 150@80 300@60 80@200 320@200 60@340 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	diagram cells do: [ :cell |
		self assert: cell vertices size >= 3 ]
! !
