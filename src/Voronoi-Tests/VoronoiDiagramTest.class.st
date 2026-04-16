Class {
	#name : 'VoronoiDiagramTest',
	#superclass : 'TestCase',
	#category : 'Voronoi-Tests'
}

"Tests at increasing levels of complexity:
  Level 1: single site
  Level 2: two sites
  Level 3: three sites (equilateral, collinear)
  Level 4: four sites (square)
  Level 5: many sites (invariants)
"

{ #category : 'private' }
VoronoiDiagramTest >> bounds [
	^ 0 @ 0 corner: 400 @ 400
]

{ #category : 'private' }
VoronoiDiagramTest >> epsilon [
	^ 1.0e-6
]

{ #category : 'private' }
VoronoiDiagramTest >> assertArea: actual closeTo: expected [
	self assert: (actual - expected) abs < 1.0
]

"============================================================
 Level 1 — Single site
 ============================================================"

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
	self assertArea: cell area closeTo: 400 * 400.
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
	self assert: (cell containsPoint: 150 @ 230).
]

"============================================================
 Level 2 — Two sites
 ============================================================"

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

	leftCell  := diagram cells detect: [ :c | c site x < 200 ].
	rightCell := diagram cells detect: [ :c | c site x > 200 ].

	self assertArea: leftCell area closeTo: 400 * 200.
	self assertArea: rightCell area closeTo: 400 * 200.
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

	self assert: diagram cells size equals: 2.

	topCell    := diagram cells detect: [ :c | c site y < 200 ].
	bottomCell := diagram cells detect: [ :c | c site y > 200 ].

	self assertArea: topCell area closeTo: 200 * 400.
	self assertArea: bottomCell area closeTo: 200 * 400.
]

{ #category : 'tests - level 2' }
VoronoiDiagramTest >> testTwoSitesCellsContainRespectiveSites [
	| diagram |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	diagram addSiteAt: 80 @ 200.
	diagram addSiteAt: 320 @ 200.
	diagram compute.

	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position)
	]
]

{ #category : 'tests - level 2' }
VoronoiDiagramTest >> testTwoSitesTotalAreaEqualsBounds [
	| diagram total |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	diagram addSiteAt: 120 @ 180.
	diagram addSiteAt: 280 @ 220.
	diagram compute.

	total := diagram totalArea.
	self assertArea: total closeTo: 400.0 * 400.0.
]

"============================================================
 Level 3 — Three sites
 ============================================================"

{ #category : 'tests - level 3' }
VoronoiDiagramTest >> testThreeSitesEquilateral [
	"Three sites at corners of an equilateral triangle centered at 200@200.
	 By symmetry, all three cells should have equal area."
	| r diagram areas |
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
	areas := diagram cells collect: [ :c | c area ].

	"All three areas should be equal within tolerance."
	self assertArea: (areas first - areas second) abs closeTo: 0.
	self assertArea: (areas first - areas last) abs closeTo: 0.
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

	self assert: diagram cells size equals: 3.

	middleCell := diagram cells detect: [ :c | c site x = 200 ].

	"Middle cell is bounded left and right by bisectors at x=150 and x=250."
	self assertArea: middleCell area closeTo: 400 * 100.
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

	self assertArea: diagram totalArea closeTo: 400.0 * 400.0.
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
		self assert: (cell containsPoint: cell site position)
	]
]

"============================================================
 Level 4 — Four sites at square corners
 ============================================================"

{ #category : 'tests - level 4' }
VoronoiDiagramTest >> testFourSitesSquare [
	"Four sites at corners of a centered square.
	 By symmetry, all four cells must have equal area."
	| diagram areas boundsArea |
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
	boundsArea := 400.0 * 400.0.

	areas do: [ :area |
		self assertArea: area closeTo: boundsArea / 4.0
	]
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
	self assert: (diagram sites includes: nearest).
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

	self assertArea: diagram totalArea closeTo: 400.0 * 400.0.
]

"============================================================
 Level 5 — Many sites (invariants)
 ============================================================"

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesCellCount [
	"Number of cells must equal number of sites."
	| diagram |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.

	self assert: diagram cells size equals: diagram sites size.
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesTotalArea [
	"Sum of all cell areas must equal the bounding box area."
	| diagram |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.

	self assertArea: diagram totalArea closeTo: 400.0 * 400.0.
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesCellsContainSites [
	"Each site must lie inside its own Voronoi cell."
	| diagram |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.

	diagram cells do: [ :cell |
		self assert: (cell containsPoint: cell site position)
	]
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testManySitesNearestSiteConsistency [
	"nearestSiteTo: must always return the site whose cell contains the query point."
	| diagram testPoints |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	#(50@50 150@80 300@60 80@200 200@200 320@200 60@340 200@320 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.

	testPoints := #(100@100 250@250 30@370 380@20 199@199).
	testPoints do: [ :pt |
		| nearest cell |
		nearest := diagram nearestSiteTo: pt.
		cell := diagram cellForSite: nearest.
		self assert: (cell containsPoint: pt)
	]
]

{ #category : 'tests - level 5' }
VoronoiDiagramTest >> testNoCellIsDegenerate [
	"Every cell must have at least 3 vertices (be a valid polygon)."
	| diagram |
	diagram := VoronoiDiagram new
		bounds: self bounds;
		yourself.
	#(50@50 150@80 300@60 80@200 320@200 60@340 350@350)
		do: [ :p | diagram addSiteAt: p ].
	diagram compute.

	diagram cells do: [ :cell |
		self assert: cell vertices size >= 3
	]
]
