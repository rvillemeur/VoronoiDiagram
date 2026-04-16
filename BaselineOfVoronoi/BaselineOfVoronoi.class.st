Class {
	#name : 'BaselineOfVoronoi',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfVoronoi'
}

{ #category : 'baselines' }
BaselineOfVoronoi >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'Voronoi-Model';
			package: 'Voronoi-View' with: [ spec requires: #('Voronoi-Model') ];
			package: 'Voronoi-Tests' with: [ spec requires: #('Voronoi-Model') ]
	]
]
