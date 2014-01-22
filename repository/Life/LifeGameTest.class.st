"
A LifeGameTest is a test class for testing the behavior of LifeGame
"
Class {
	#name : #LifeGameTest,
	#superclass : #TestCase,
	#category : #'Life-Tests'
}

{ #category : #tests }
LifeGameTest >> testNeighboursPositionsAtAt [

	| game neighbours11 expected11 neighbours22 expected22 expected13 neighbours13 |
	game := LifeGame new.
	expected11 := LifeGame sortCollectionOfPoints: {2@1. 1@2. 2@2}.
	neighbours11 := game neighboursPositionsAt: 1 at: 1.
	self assert: neighbours11 =  expected11.
	expected22 := LifeGame sortCollectionOfPoints: {1@1. 2@1. 3@1. 1@2. 3@2. 1@3. 2@3. 3@3}.
	neighbours22 := game neighboursPositionsAt: 2 at: 2.
	self assert: neighbours22 = expected22.
	game delete.
	game := LifeGame rows: 3 columns: 3.
	expected13 := LifeGame sortCollectionOfPoints: { 1@2. 2@2. 2@3 }.
	neighbours13 := game neighboursPositionsAt: 1 at: 3.
	self assert: neighbours13 = expected13.
]

{ #category : #tests }
LifeGameTest >> testOvercrowding [
	"Any live cell with more than three live neighbours dies, as if by overcrowding."
	
	| game |
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOn. "cell under test"
	(game at: 1 at: 1) turnOn. "1 neighbour alive"
	(game at: 1 at: 3) turnOn. "2 neighbours alive"
	(game at: 3 at: 1) turnOn. "3 neighbours alive"
	(game at: 3 at: 3) turnOn. "4 neighbours alive"
	self assert: (game countAliveNeighboursAt: 2 at: 2) > 3.
	game nextGen.
	self assert: (game at: 2 at: 2) isOff.
	game delete.
	
	"ensure dead cells remain dead under such circumstances"
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOff. "cell under test"
	(game at: 1 at: 1) turnOn. "1 neighbour alive"
	(game at: 1 at: 3) turnOn. "2 neighbours alive"
	(game at: 3 at: 1) turnOn. "3 neighbours alive"
	(game at: 3 at: 3) turnOn. "4 neighbours alive"
	self assert: (game countAliveNeighboursAt: 2 at: 2) > 3.
	game nextGen.
	self assert: (game at: 2 at: 2) isOff.
	game delete.
]

{ #category : #tests }
LifeGameTest >> testReproduction [
	"Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction."

	| game |
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOff. "cell under test"
	(game at: 1 at: 1) turnOn. "1 neighbour alive"
	(game at: 1 at: 3) turnOn. "2 neighbours alive"
	(game at: 3 at: 1) turnOn. "3 neighbours alive"
	game nextGen.
	self assert: (game at: 2 at: 2) isOn.
	game delete.
	
	"ensure alive cell stay alive ...ah ah ah ah stay aliiiiiive"
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOn. "cell under test"
	(game at: 1 at: 1) turnOn. "1 neighbour alive"
	(game at: 1 at: 3) turnOn. "2 neighbours alive"
	(game at: 3 at: 1) turnOn. "3 neighbours alive"
	game nextGen.
	self assert: (game at: 2 at: 2) isOn.
	game delete.
]

{ #category : #tests }
LifeGameTest >> testSurviving [
	"Any live cell with two or three live neighbours lives on to the next generation."

	| game |
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOn. "cell under test"
	(game at: 1 at: 2) turnOn. "1 neighbour alive"
	(game at: 3 at: 2) turnOn. "2 neighbours alive"
	game nextGen.
	self assert: (game at: 2 at: 2) isOn.
	game delete.
	
	"ensure it only occur to live cells"
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOff. "cell under test"
	(game at: 1 at: 2) turnOn. "1 neighbour alive"
	(game at: 3 at: 2) turnOn. "2 neighbours alive"
	game nextGen.
	self assert: (game at: 2 at: 2) isOff.
	game delete.
]

{ #category : #tests }
LifeGameTest >> testUnderPopulation [
	"Any live cell with fewer than two live neighbours dies, as if caused by under-population."

	| game |
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOn.
	game nextGen.
	self assert: (game at: 2 at: 2) isOff.
	game delete.
	"ensure dead cells remain dead under similar circumstances"
	game := LifeGame rows: 3 columns: 3.
	(game at: 2 at: 2) turnOff.
	game nextGen.
	self assert: (game at: 2 at: 2) isOff.
	game delete.
]
