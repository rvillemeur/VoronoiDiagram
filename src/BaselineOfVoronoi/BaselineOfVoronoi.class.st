Class {
	#name : 'BaselineOfVoronoi',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfVoronoi',
	#package : 'BaselineOfVoronoi'
}

{ #category : 'baselines' }
BaselineOfVoronoi >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec package: 'Voronoi' with: [ spec requires: #( 'Bloc' ) ].
			spec
				baseline: 'Bloc'
				with: [
				spec repository: 'github://pharo-graphics/Bloc:dev/src' ] ]
]
