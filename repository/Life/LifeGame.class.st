Class {
	#name : #LifeGame,
	#superclass : #BorderedMorph,
	#instVars : [
		'cells',
		'rows',
		'columns'
	],
	#classInstVars : [
		'pointsSortBlock'
	],
	#category : #Life
}

{ #category : #'initialize-release' }
LifeGame class >> initialize [

	"we need the same instance of block to sort points otherwise = on SortedCollection return false."
	pointsSortBlock := [:p1 :p2 | 
		(p1 x < p2 x) or: [(p1 x = p2 x) and: [p1 y < p2 y]]]
]

{ #category : #'as yet unclassified' }
LifeGame class >> play [
	| builder content game |
	builder := UITheme builder.
	
	content := builder newColumn: {
		game := LifeGame rows: 35 columns: 35.
		builder newRow: {
			builder newButtonFor: game action: #nextGen getEnabled: nil label: 'next' help:'to compute and display the next state'.
			builder newButtonFor: game action: #startStepping getEnabled: nil label: 'play' help:'do ''next'' until the board stops moving.'.
			builder newButtonFor: game action: #stopStepping getEnabled: nil label: 'stop' help:'interrupt when playing'.
			builder newButtonFor: game action: #clear getEnabled: nil label: 'clear' help:'reset the board' 
		}.
	}.
	(content openInWindowLabeled: 'Conway''s Game of Life') extent: 436@496.
	(game isStepping) ifTrue: [ game stopStepping ].
	game takeKeyboardFocus 
]

{ #category : #'as yet unclassified' }
LifeGame class >> rows: anInt columns: anotherInt [

	^ self basicNew rows: anInt; columns: anotherInt; initialize
]

{ #category : #sorting }
LifeGame class >> sortCollectionOfPoints: aCollOfPoints [
	^aCollOfPoints asSortedCollection: pointsSortBlock
]

{ #category : #accessing }
LifeGame >> at: aRow at: aColumn [
	^ cells at: aRow at: aColumn
]

{ #category : #evaluating }
LifeGame >> clear [

	cells do: [ :each | each turnOff ]
]

{ #category : #accessing }
LifeGame >> columns [
	columns notNil ifTrue: [ ^columns ] ifFalse:  [ ^self defaultCellsPerSide ]
]

{ #category : #accessing }
LifeGame >> columns: anObject [
	columns := anObject
]

{ #category : #evaluating }
LifeGame >> countAliveNeighboursAt: aRow at: aColumn [ 
	
	| c |
	c := 0.
	(self neighboursPositionsAt: aRow at: aColumn) do: [ :p | (self at: p y at: p x) isOn ifTrue: [ c := c + 1 ] ].
	^ c 
	
]

{ #category : #initialization }
LifeGame >> defaultCellsPerSide [
	"The number of cells along each side of the game."
	^ 48
]

{ #category : #'as yet unclassified ' }
LifeGame >> handleKeystroke: anEvent [ 
	| keyValue |
	keyValue := anEvent keyValue.
	Transcript show: keyValue; cr.
]

{ #category : #initialization }
LifeGame >> initialize [

	| sampleCell cellWidth cellHeight w h |
	super initialize.
	h := self rows.
	w := self columns.
	sampleCell := LifeCell new.
	cellWidth := sampleCell width.
	cellHeight := sampleCell height.
	self extent: ((cellWidth * w)@(cellHeight * h)) + (2 * self borderWidth).
	cells := Array2D rows: self rows columns: self columns tabulate: [ :i :j | self newCellAt: i at: j ].
]

{ #category : #neighbours }
LifeGame >> neighboursPositionsAt: i at: j [
"returns all the neighbours coordinates in the form of a collection of points.
_|_|_
_|_|_
_|_|_
"
	^LifeGame sortCollectionOfPoints: (
		{	(i - 1)@(j - 1). i@(j - 1).	(i + 1)@(j - 1).
			(i - 1)@j. 				(i + 1)@j.
	   		(i - 1)@(j + 1). i@(j + 1). (i + 1)@(j + 1) } select: [ :p | 
		p x > 0 and: [ p y > 0 and: 
			[ p x <= self columns  and: 
			[ p y <= self rows ] ] ] ])

]

{ #category : #initialization }
LifeGame >> newCellAt: row at: column [
	"Create a cell for position (row, column) and add it to my on-screen representation at the appropriate screen position.
	 Answer the new cell."
	
	| c origin |
	c := LifeCell new.
	origin := self innerBounds origin.
	self addMorph: c.
	^c position: ((column - 1) * c width) @ ((row - 1) * c height) + origin
]

{ #category : #evaluating }
LifeGame >> nextGen [
	| changedCells |
	changedCells := OrderedCollection new.
	cells withIndicesDo: [ :cell :column :row | | c | "not sure why I receive column then row here..."
		c := self countAliveNeighboursAt: row at: column.
		c < 2 ifTrue: [ cell isOn ifTrue: [ changedCells add: cell ] ] 	"under-population"
			   ifFalse: [ 
				"(c <= 3 and: [ cell isOn ]) ifTrue: [ cell turnOn ]" 	"surviving - no op"
				c > 3 ifTrue: [ cell isOn ifTrue: [ changedCells add: cell ] ] "overcrowding"
					   ifFalse: [ c = 3 ifTrue: [ cell isOn ifFalse: [ changedCells add: cell ] ] ] "reproduction"
			   ]
		].
	changedCells do: [ :each | each toggleState ].
	^ changedCells size
]

{ #category : #accessing }
LifeGame >> rows [
	rows notNil ifTrue: [ ^rows ] ifFalse: [ ^self defaultCellsPerSide ]
]

{ #category : #accessing }
LifeGame >> rows: anObject [
	rows := anObject
]

{ #category : #evaluating }
LifeGame >> stabilize: maxIterations [
	"loop on #nextGen until it stops moving"
	| flipped c |
	c := 0.
	[ c < maxIterations and: [ flipped = 0 ] ] whileFalse: [ c := c + 1. flipped := self nextGen. self refreshWorld ]
]

{ #category : #'stepping and presenter' }
LifeGame >> step [ 
	self nextGen
]

{ #category : #testing }
LifeGame >> stepTime [
	^1000
]
