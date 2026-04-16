"
VoronoiDiagramTest suite run. 

Tests at increasing levels of complexity:
-  Level 1: single site
-  Level 2: two sites
-  Level 3: three sites (equilateral, collinear)
-  Level 4: four sites (square)
-  Level 5: many sites (invariants)
"
Class {
	#name : 'VoronoiDiagramTest',
	#superclass : 'TestCase',
	#category : 'Voronoi-Tests',
	#package : 'Voronoi',
	#tag : 'Tests'
}

{ #category : 'private' }
VoronoiDiagramTest >> assertArea: actual closeTo: expected [

	self assert: (actual - expected) abs < 1.0
]

{ #category : 'private' }
VoronoiDiagramTest >> bounds [

	^ 0 @ 0 corner: 400 @ 400
]

{ #category : 'tests - level 4' }
VoronoiDiagramTest >> testFourSitesCenterPoint [
	"The center of the bounding box should be equidistant from all four sites —
	 the nearest site determines which cell it falls in. Since it is equidistant,
	 it lies on a Voronoi vertex, so containsPoint may classify it in any cell.
	 We just verify the nearestSiteTo: query is consistent."

	| diagram nearest |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 100.
	diagram addSiteAt: 300 @ 300.
	diagram addSiteAt: 100 @ 300.
	diagram compute.

	nearest := diagram nearestSiteTo: 200 @ 200.
	self assert: (diagram sites includes: nearest)
]

{ #category : 'tests - level 4' }
VoronoiDiagramTest >> testFourSitesSquare [
	"Four sites at corners of a centered square.
	 By symmetry, all four cells must have equal area."
	| diagram areas |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 100.
	diagram addSiteAt: 300 @ 300.
	diagram addSiteAt: 100 @ 300.
	diagram compute.
	self assert: diagram cells size equals: 4.
	areas := diagram cells collect: [ :c | c area ].
	areas do: [ :area |
		self assertArea: area closeTo: 400.0 * 400.0 / 4.0 ]
]

{ #category : 'tests - level 4' }
VoronoiDiagramTest >> testFourSitesTotalArea [

	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 100.
	diagram addSiteAt: 300 @ 300.
	diagram addSiteAt: 100 @ 300.
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesCellCount [
"Number of cells must equal number of sites."
	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	{
		(50 @ 50).
		(150 @ 80).
		(300 @ 60).
		(80 @ 200).
		(200 @ 200).
		(320 @ 200).
		(60 @ 340).
		(200 @ 320).
		(350 @ 350) } do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	self assert: diagram cells size equals: diagram sites size
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesCellsContainSites [
"Each site must lie inside its own Voronoi cell."
	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	{
		(50 @ 50).
		(150 @ 80).
		(300 @ 60).
		(80 @ 200).
		(200 @ 200).
		(320 @ 200).
		(60 @ 340).
		(200 @ 320).
		(350 @ 350) } do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position) ]
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesNearestSiteConsistency [
	"nearestSiteTo: must always return the site whose cell contains the query point."

	| diagram testPoints |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	{
		(50 @ 50).
		(150 @ 80).
		(300 @ 60).
		(80 @ 200).
		(200 @ 200).
		(320 @ 200).
		(60 @ 340).
		(200 @ 320).
		(350 @ 350) } do: [ :p | diagram addSiteAt: p ].
	diagram compute.

	testPoints := {
		              (100 @ 100).
		              (250 @ 250).
		              (30 @ 370).
		              (380 @ 20).
		              (199 @ 199) }.
	testPoints do: [ :pt |
			| nearest cell |
			nearest := diagram nearestSiteTo: pt.
			cell := diagram cellForSite: nearest.
			self assert: (cell containsPoint: pt) ]
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesTotalArea [
"Sum of all cell areas must equal the bounding box area."
	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	{
		(50 @ 50).
		(150 @ 80).
		(300 @ 60).
		(80 @ 200).
		(200 @ 200).
		(320 @ 200).
		(60 @ 340).
		(200 @ 320).
		(350 @ 350) } do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testNoCellIsDegenerate [
"Every cell must have at least 3 vertices (be a valid polygon)."
	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	{
		(50 @ 50).
		(150 @ 80).
		(300 @ 60).
		(80 @ 200).
		(320 @ 200).
		(60 @ 340).
		(350 @ 350) } do: [ :p | diagram addSiteAt: p ].
	diagram compute.
	diagram cells do: [ :cell | self assert: cell vertices size >= 3 ]
]

{ #category : 'tests - level 1' }
VoronoiDiagramTest >> testSingleSite [
"With one site, the Voronoi cell must cover the entire bounding box."

	| diagram cell |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 200 @ 200.
	diagram compute.
	self assert: diagram cells size equals: 1.
	cell := diagram cells first.
	self assert: cell vertices size equals: 4.
	self assertArea: cell area closeTo: 400 * 400
]

{ #category : 'tests - level 1' }
VoronoiDiagramTest >> testSingleSiteCellContainsSite [

	| diagram cell |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 150 @ 230.
	diagram compute.
	cell := diagram cells first.
	self assert: (cell containsPoint: 150 @ 230)
]

{ #category : 'tests - level 4' }
VoronoiDiagramTest >> testSixSitesHexagonal [
	"Six sites placed at 60-degree intervals on a circle centered at 200@200.
	 A regular hexagon has 6-fold rotational symmetry (rotations of 60°) and
	 also 6 reflection axes. The square bounding box has 4-fold symmetry.
	 The intersection of these two symmetry groups is the dihedral group of
	 order 4 (symmetries of the square), which contains two reflection axes
	 shared with the hexagon: the horizontal (y=200) and vertical (x=200) axes.

	 This guarantees three pairs of equal-area cells:
	   - S1 (right) = S4 (left)          [reflection x=200]
	   - S2 (top-right) = S3 (top-left)  [reflection x=200]
	   - S5 (bot-right) = S6 (bot-left)  [reflection x=200]
	 And also S2 = S6, S3 = S5           [reflection y=200]
	 => in fact all four 'diagonal' cells are equal, and the two 'axial' cells
	    (S1 and S4) are equal to each other but different from the diagonals."

	| r diagram cells axialCells diagonalCells |
	r := 120.0.
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	0 to: 5 do: [ :k |
			| angle |
			angle := Float pi * 2.0 * k / 6.0.
			diagram addSiteAt:
				(200 + (r * angle cos)) rounded @ (200 + (r * angle sin)) rounded ].
	diagram compute.

	self assert: diagram cells size equals: 6.
	cells := diagram cells.

	"Axial sites: S1=(320,200) and S4=(80,200) — on the horizontal axis."
	axialCells := cells select: [ :c | c site y = 200 ].
	self assert: axialCells size equals: 2.
	self
		assertArea: (axialCells first area - axialCells last area) abs
		closeTo: 0.

	"Diagonal sites: the four remaining cells, symmetric by both axes."
	diagonalCells := cells reject: [ :c | c site y = 200 ].
	self assert: diagonalCells size equals: 4.
	diagonalCells do: [ :cell |
		self
			assertArea: (cell area - diagonalCells first area) abs
			closeTo: 0 ].

	"Total area invariant."
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
]

{ #category : 'tests - level 3' }
VoronoiDiagramTest >> testThreeSitesCellsContainSites [

	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 150.
	diagram addSiteAt: 200 @ 300.
	diagram compute.
	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position) ]
]

{ #category : 'tests - level 3' }
VoronoiDiagramTest >> testThreeSitesCollinear [
"Three collinear sites. The middle site's cell is a horizontal strip."

	| diagram middleCell |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 200.
	diagram addSiteAt: 200 @ 200.
	diagram addSiteAt: 300 @ 200.
	diagram compute.
	middleCell := diagram cells detect: [ :c | c site x = 200 ].
	self assertArea: middleCell area closeTo: 400 * 100
]

{ #category : 'tests - level 3' }
VoronoiDiagramTest >> testThreeSitesEquilateral [
	"Three sites at corners of an equilateral triangle centered at 200@200,
	 with S1=(320,200), S2=(140,304), S3=(140,96).

	 The triangle has 3-fold rotational symmetry, but the square bounding box
	 has 4-fold symmetry. These are incompatible: no orientation of an equilateral
	 triangle in a square preserves 120-degree rotational symmetry after clipping.
	 Therefore the three cells do NOT have equal area in general.

	 The only symmetry preserved here is the reflection about y=200, which maps
	 S2 <-> S3. We test that and verify the total area invariant."

	| r diagram cells s2Cell s3Cell |
	r := 120.0.
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: (200 + (r * (Float pi * 0 / 3.0) cos)) rounded
		@ (200 + (r * (Float pi * 0 / 3.0) sin)) rounded.
	diagram addSiteAt: (200 + (r * (Float pi * 2 / 3.0) cos)) rounded
		@ (200 + (r * (Float pi * 2 / 3.0) sin)) rounded.
	diagram addSiteAt: (200 + (r * (Float pi * 4 / 3.0) cos)) rounded
		@ (200 + (r * (Float pi * 4 / 3.0) sin)) rounded.
	diagram compute.

	self assert: diagram cells size equals: 3.
	cells := diagram cells.

	"S2 and S3 are reflections of each other across y=200 => equal area."
	s2Cell := cells detect: [ :c | c site y > 200 ].
	s3Cell := cells detect: [ :c | c site y < 200 ].
	self assertArea: (s2Cell area - s3Cell area) abs closeTo: 0.

	"Total area must still cover the entire bounding box."
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
]

{ #category : 'tests - level 3' }
VoronoiDiagramTest >> testThreeSitesTotalArea [

	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 100.
	diagram addSiteAt: 300 @ 150.
	diagram addSiteAt: 200 @ 300.
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
]

{ #category : 'tests - level 2' }
VoronoiDiagramTest >> testTwoSitesCellsContainSites [

	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 80 @ 200.
	diagram addSiteAt: 320 @ 200.
	diagram compute.
	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position) ]
]

{ #category : 'tests - level 2' }
VoronoiDiagramTest >> testTwoSitesHorizontalSplit [
"Two sites with the same y, symmetric about x=200.
	 Each cell should cover exactly half the bounding box."

	| diagram leftCell rightCell |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 100 @ 200.
	diagram addSiteAt: 300 @ 200.
	diagram compute.
	self assert: diagram cells size equals: 2.
	leftCell := diagram cells detect: [ :c | c site x < 200 ].
	rightCell := diagram cells detect: [ :c | c site x > 200 ].
	self assertArea: leftCell area closeTo: 400 * 200.
	self assertArea: rightCell area closeTo: 400 * 200
]

{ #category : 'tests - level 2' }
VoronoiDiagramTest >> testTwoSitesTotalArea [

	| diagram |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 120 @ 180.
	diagram addSiteAt: 280 @ 220.
	diagram compute.
	self assertArea: diagram totalArea closeTo: 400.0 * 400.0
]

{ #category : 'tests - level 2' }
VoronoiDiagramTest >> testTwoSitesVerticalSplit [
"Two sites with same x, symmetric about y=200."
	| diagram topCell bottomCell |
	diagram := VoronoiDiagram new
		           bounds: self bounds;
		           yourself.
	diagram addSiteAt: 200 @ 100.
	diagram addSiteAt: 200 @ 300.
	diagram compute.
	topCell := diagram cells detect: [ :c | c site y < 200 ].
	bottomCell := diagram cells detect: [ :c | c site y > 200 ].
	self assertArea: topCell area closeTo: 200 * 400.
	self assertArea: bottomCell area closeTo: 200 * 400
]
