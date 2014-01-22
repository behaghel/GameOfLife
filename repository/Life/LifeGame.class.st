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
	| window game button |
	window := SystemWindow labelled: 'Conway''s Game of Life'.
	game := LifeGame rows: 35 columns: 35.
	window model: game.
	"window extent: game extent."
	button := SimpleButtonMorph new 
		label: 'next';
		target: game;
		actionSelector: #nextGen.
	window addMorph: game frame: (0@0 corner: 0.8@1).
	window addMorph: button frame: (0.85@0.1 corner: 0.9@0.2).
	window openInWorld
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
	cells := Matrix rows: self rows columns: self columns tabulate: [ :i :j | self newCellAt: i at: j ].
]

{ #category : #'as yet unclassified' }
LifeGame >> neighboursPositionsAt: i at: j [
"
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
	| oldGen |
	oldGen := self veryDeepCopy.
	cells withIndicesDo: [ :cell :column :row | | c | "not sure why I receive column then row here..."
		c := oldGen countAliveNeighboursAt: row at: column.
		c < 2 ifTrue: [ cell turnOff ] 		"under-population"
			   ifFalse: [ 
				"(c <= 3 and: [ cell isOn ]) ifTrue: [ cell turnOn ]" "surviving - no op"
				c > 3 ifTrue: [ cell turnOff ] "overcrowding"
					   ifFalse: [ c = 3 ifTrue: [ cell turnOn ] ] "reproduction"
			   ]
		]
]

{ #category : #accessing }
LifeGame >> rows [
	rows notNil ifTrue: [ ^rows ] ifFalse: [ ^self defaultCellsPerSide ]
]

{ #category : #accessing }
LifeGame >> rows: anObject [
	rows := anObject
]
