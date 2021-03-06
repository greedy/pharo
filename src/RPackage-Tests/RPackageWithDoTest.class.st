"
SUnit tests for RPackage
"
Class {
	#name : #RPackageWithDoTest,
	#superclass : #TestCase,
	#instVars : [
		'x'
	],
	#category : #'RPackage-Tests'
}

{ #category : #accessing }
RPackageWithDoTest >> announcer [
	^ SystemAnnouncer uniqueInstance private
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> do: aBlock [ 

	x := 5.
	[aBlock value] ensure: [x :=3.]
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> doC: aBlock [ 
	
	x := 5.
	[aBlock value] ifCurtailed: [x :=3]
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> doOnDo: aBlock [ 
	
	x := 5.
	[aBlock value.
	self ensure] on: Error do:  [:ex | self ensure].
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> ensure [

	x := 3
]

{ #category : #tests }
RPackageWithDoTest >> info [
	
	
	self announcer hasSubscriber: RPackageOrganizer default.
	Smalltalk garbageCollect.
	RPackageOrganizer allInstances collect: [:each | self announcer hasSubscriber: each ] 
]

{ #category : #tests }
RPackageWithDoTest >> packageClass [
	^ RPackage
]

{ #category : #tests }
RPackageWithDoTest >> packageOrganizerClass [
	^ RPackageOrganizer
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> testDo [
	[ self do: [ Error signal ] ]
		on: Error
		do: [ :ex |  ].
	"necessary else SUnit believes that the error is not handled"
	self assert: x equals: 3
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> testDo2 [
	[ self do: [ self error ] ]
		on: Error
		do: [ :ex |  ].
	"necessary else SUnit believes that the error is not handled"
	self assert: x equals: 3
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> testDoC [
	[ self doC: [ self error ] ]
		on: Error
		do: [ :e |  ].
	"necessary else SUnit believes that the error is not handled"
	self assert: x equals: 3
]

{ #category : #tests }
RPackageWithDoTest >> testImageContainsOneSubscribedOrganizer [
	"to be sure that this is real default one"
	self assert: (self announcer hasSubscriber: self packageOrganizerClass default) description: 'System announcer should have the default instance of the organizer as subscriber.'.
	"note that this test is not precise enough because I could get the wrong one."
	
	[ self assert: self packageOrganizerClass allInstances size equals: 1 ]
		on: AssertionFailure
		do: [ :ex | 
			"If it fails it might be because there was other instances created by other tests. Run some full GC and re-test to see if it's a real regression."
			5 timesRepeat: [ Smalltalk garbageCollect ].
			self assert: self packageOrganizerClass allInstances size equals: 1 ]

	"To debug: self packageOrganizerClass allInstances collect: [:each | self announcer hasSubscriber: each ] "
]

{ #category : #'simple ensure tests' }
RPackageWithDoTest >> testOnDo [
	self doOnDo: [ self error ].
	self assert: x equals: 3.
	x := 77.
	self doOnDo: [ x = 21 ].
	self assert: x equals: 3
]

{ #category : #tests }
RPackageWithDoTest >> testOrganizerContainsPackages [
	self assert: self packageOrganizerClass default packageNames isNotEmpty description: 'RPackageOrganizer should contains package names since an image should at least contains one package.'.
	self assert: self packageOrganizerClass default packages isNotEmpty description: 'RPackageOrganizer should not be empty since an image should at least contains one package.'
]

{ #category : #tests }
RPackageWithDoTest >> testWithDoIsCorrectlyReinstallingDefault [
	| current empty |
	current := self packageOrganizerClass default.
	empty := self packageOrganizerClass basicNew initialize.
	empty debuggingName: 'empty from PackageWithDoTest'.
	self packageClass
		withOrganizer: empty
		do: [ self assert: (self announcer hasSubscriber: empty) description: 'During #withOrganizer:do:, the system announcer should have the organizer as parameter in its subscriber.'.
			self deny: (self announcer hasSubscriber: current) description: 'During #withOrganizer:do:, the system announcer shouldn''t have the default organizer in its subscriber.' ].
	self assert: (self announcer hasSubscriber: current) description: 'After the use of #withOrganizer:do:, the default organizer should be reinstalled in system announcer subscribers.'.
	self deny: (self announcer hasSubscriber: empty) description: 'After the use of #withOrganizer:do:, the empty organizer should be removed from the system announcer subscribers.'
]

{ #category : #tests }
RPackageWithDoTest >> testWithDoIsCorrectlyReinstallingDefaultEvenIfHalt [
	| current empty |
	current := self packageOrganizerClass default.
	empty := self packageOrganizerClass basicNew initialize.
	[ self packageClass
		withOrganizer: empty
		do: [ self assert: (self announcer hasSubscriber: empty) description: 'During #withOrganizer:do:, the system announcer should have the organizer as parameter in its subscriber.'.
			self deny: (self announcer hasSubscriber: current) description: 'During #withOrganizer:do:, the system announcer shouldn''t have the default organizer in its subscriber.'.
			self error ] ]
		on: Error
		do: [ :ex |  ].
	self assert: (self announcer hasSubscriber: current) description: 'After the use of #withOrganizer:do:, the default organizer should be reinstalled in system announcer subscribers.'.
	self deny: (self announcer hasSubscriber: empty) description: 'After the use of #withOrganizer:do:, the empty organizer should be removed from the system announcer subscribers.'
]
