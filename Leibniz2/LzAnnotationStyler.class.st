Class {
	#name : #LzAnnotationStyler,
	#superclass : #LeComponentStyler,
	#traits : 'TLzParseTreeNodeVisitor',
	#classTraits : 'TLzParseTreeNodeVisitor classTrait',
	#category : #'Leibniz2-Lepiter'
}

{ #category : #initializing }
LzAnnotationStyler class >> initialize [
	LeSnippetStylerVisitor additionalStylers add: self
]

{ #category : #initializing }
LzAnnotationStyler class >> obsolete [
	LeSnippetStylerVisitor additionalStylers remove: self ifAbsent: [  ].
	^ super obsolete
]

{ #category : #private }
LzAnnotationStyler >> colorFor: aDeclarationAnnotation [
	| color |
	color := LzColors declarationColor.
	(aDeclarationAnnotation optionsAt: #example)
		ifTrue: [ color := LzColors exampleColor ].
	(aDeclarationAnnotation optionsAt: #subcontext)
		ifNotNil: [ color := LzColors exampleColor ].
	^ color
]

{ #category : #private }
LzAnnotationStyler >> elements [
	^ self composite elements
]

{ #category : #private }
LzAnnotationStyler >> expanded [
	^ self composite expanded
]

{ #category : #private }
LzAnnotationStyler >> inTextButton: aText [
	| button |

	button := BrButton new.
	button connector beVisualSource.

	button 
		addAptitude: LzButtonLabelAptitude new;
		padding: (BlInsets top: 2 left: 0 bottom: 0 right: 0);
		margin: (BlInsets top: -1 left: 0 bottom: 0 right: 0);
		beSmallSize;
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent. ];
		label: aText.
	^ button
]

{ #category : #accessing }
LzAnnotationStyler >> page [
	^ self snippet page
]

{ #category : #private }
LzAnnotationStyler >> parseOptions: aTopLevelAnnotation [
	^ (aTopLevelAnnotation options collect: [ :each |
		each key source
			-> (LzDeclarationBuilder new acceptNode: each value) value ])
		asDictionary
]

{ #category : #accessing }
LzAnnotationStyler >> snippet [
	^ self composite snippetViewModel snippetModel
]

{ #category : #styling }
LzAnnotationStyler >> styleAnnotation: anAnnotation [
	(self text from: anAnnotation parent startPosition to: anAnnotation parent stopPosition)
		fontName: LzCodeFont defaultFamily
]

{ #category : #styling }
LzAnnotationStyler >> styleAutoHidingAnnotation: anAnnotation [
	| first last range |
	first := anAnnotation parent startPosition max: 1.
	last := anAnnotation parent stopPosition min: self text size.
	range := first to: last.
	composite
		styleAutoHiding: range
		and: range
		whenOutside: anAnnotation parent sourceInterval
]

{ #category : #styling }
LzAnnotationStyler >> styleButtonFor: anAnnotation label: aSyntaxLabel [
	| attribute |
	attribute := GtButtonAttribute new
		beAppend;
		stencil: [ (aSyntaxLabel beSmallSize) asElement
					padding: (BlInsets top: 2 left: 0 bottom: 0 right: 0) ].
	self text
		attribute: attribute
		from: anAnnotation parent startPosition
		to: anAnnotation parent stopPosition
]

{ #category : #styling }
LzAnnotationStyler >> styleDeclarationButton: anLzAnnotation [
	| annotatedDeclaration declaration label |
	annotatedDeclaration := LzDeclarationBuilder new
			acceptNode: anLzAnnotation.
	declaration := annotatedDeclaration declaration.
	label := (LzSyntaxLabel
				for: declaration
				color: (self colorFor: annotatedDeclaration))
				declaration: declaration.
	self styleButtonFor: anLzAnnotation label: label
]

{ #category : #styling }
LzAnnotationStyler >> styleExpandingObject: aTerm in: anAnnotation [
	| cacheKey attribute |
	aTerm hasInlineView ifFalse: [ ^ self ].

	cacheKey := anAnnotation source.
	attribute := (GtCachedTextExpandButtonAttribute new)
		isExpanded: (self expanded at: cacheKey ifAbsentPut: [ true ]);
		attributesCreatingBlock:
				[ (GtResizablePreviewAttribute new)
						withCache: self elements key: cacheKey;
						result: aTerm inlineView;
						showSelector: #gtLiveFor:;
						height: 300 ];
		onCachingDo: [ :aBoolean :theAttribute |
			self expanded at: cacheKey put: aBoolean ].

	self text
		attribute: attribute
		from: anAnnotation parent startPosition
		to: anAnnotation parent stopPosition
]

{ #category : #styling }
LzAnnotationStyler >> styleObjectButton: anLzAnnotation [
	self
		styleObjectButton: anLzAnnotation
		text: [ :annotatedDeclaration :declaration :object |
			(declaration asRopedTextColored:
					(self colorFor: annotatedDeclaration)) ]
]

{ #category : #styling }
LzAnnotationStyler >> styleObjectButton: anLzAnnotation text: aBlock [
	| object annotatedDeclaration declaration label |
	[
		object :=  LzObjectBuilder new
			contextPageName: self page title;
			acceptNode: anLzAnnotation.
		annotatedDeclaration := object first.
		declaration := annotatedDeclaration declaration.
		object := object second.
		label := LzSyntaxLabel new
					text: (aBlock
								value: annotatedDeclaration
								value: declaration
								value: object);
					declaration: declaration ;
					object: object.
	] on: Exception do: [ :ex |
		ex freeze.
		label := LzSyntaxLabel new
					text: (ex printString asRopedText foreground: Color red);
					declaration: ex ].
	self styleButtonFor: anLzAnnotation label: label
]

{ #category : #accessing }
LzAnnotationStyler >> subcontext: aString [
	^ (LzGlobalCache uniqueInstance
			contextCacheFor: self page title)
		subcontext: aString
]

{ #category : #private }
LzAnnotationStyler >> text [
	^ self composite text
]

{ #category : #visiting }
LzAnnotationStyler >> visitParseTree: aParseTree [
	^ self visitSmaCCParseNode: aParseTree
]

{ #category : #visiting }
LzAnnotationStyler >> visitSmaCCError: aSmaCCError [
	(self text from: aSmaCCError parent startPosition to: aSmaCCError parent stopPosition)
		fontName: LzCodeFont defaultFamily.
	(self text from: aSmaCCError startPosition to: aSmaCCError stopPosition)
		underlineColor: Color red
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelAsset: aTopLevelAsset [
	self styleAnnotation: aTopLevelAsset.
	self styleAutoHidingAnnotation: aTopLevelAsset.
	self
		styleObjectButton: aTopLevelAsset
		text: [ :annotatedDeclaration :declaration :object |
			| displayedObject |
			(annotatedDeclaration optionsAt: 'withNormalForm')
				ifTrue: [
					| context | 
					context := self subcontext:(annotatedDeclaration optionsAt: #subcontext).
					displayedObject := object normalFormIn: context ]
				ifFalse: [
					(annotatedDeclaration optionsAt: 'withValue')
						ifTrue: [ displayedObject := object ]
						ifFalse: [ displayedObject := declaration ] ].
			displayedObject asRopedTextColored:
				(self colorFor: annotatedDeclaration) ]
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelEqualityAxiom: aTopLevelEqualityAxiom [
	self styleAnnotation: aTopLevelEqualityAxiom.
	self styleAutoHidingAnnotation: aTopLevelEqualityAxiom.
	self styleObjectButton: aTopLevelEqualityAxiom
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelOp: aTopLevelOpAnnotation [
	self styleAnnotation: aTopLevelOpAnnotation.
	self styleAutoHidingAnnotation: aTopLevelOpAnnotation.
	self styleObjectButton: aTopLevelOpAnnotation
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelRule: aTopLevelRule [
	self styleAnnotation: aTopLevelRule.
	self styleAutoHidingAnnotation: aTopLevelRule.
	self styleObjectButton: aTopLevelRule
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelSort: aTopLevelSortAnnotation [
	self styleAnnotation: aTopLevelSortAnnotation.
	self styleAutoHidingAnnotation: aTopLevelSortAnnotation.
	self styleObjectButton: aTopLevelSortAnnotation
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelSpecialTerms: aTopLevelSpecialTerms [
	self styleAnnotation: aTopLevelSpecialTerms.
	self styleAutoHidingAnnotation: aTopLevelSpecialTerms.
	self styleDeclarationButton: aTopLevelSpecialTerms
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelSubsort: aTopLevelSubsort [
	self styleAnnotation: aTopLevelSubsort.
	self styleAutoHidingAnnotation: aTopLevelSubsort.
	self styleObjectButton: aTopLevelSubsort
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelTerm: aTopLevelTermAnnotation [
	| label attribute term |
	self styleAnnotation: aTopLevelTermAnnotation.
	self styleAutoHidingAnnotation: aTopLevelTermAnnotation.

	[
		| color object annotatedDeclaration declaration  output |
		color := LzColors exampleColor.
		object := LzObjectBuilder new
			contextPageName: self page title;
			acceptNode: aTopLevelTermAnnotation.
		annotatedDeclaration := object first.
		declaration := annotatedDeclaration declaration.
		term := object second.
		output := annotatedDeclaration asRopedTextColored: color.
		term sort isKind ifTrue: [
			output attribute:
				(BlTextDecorationAttribute new
					underline;
					color: Color red) ].
		(annotatedDeclaration optionsAt: #withSort)
			ifTrue: [
				| value colon sort |
				value := annotatedDeclaration asRopedTextColored: color.
				colon := ' : ' asRopedText foreground: color lzDeemphasized.
				sort := term sort asRopedTextColored: color lzDeemphasized.
				output append: colon.
				output append: sort ].
		(annotatedDeclaration optionsAt: #withNormalForm)
			ifTrue: [
				| normalForm |
				normalForm := term normalForm asRopedTextColored: color.
				output append: (' ⇒ ' asRopedText foreground: color; fontName: LzCodeFont defaultFamily).
				output append: normalForm ].
		label := LzSyntaxLabel new
					text: output;
					declaration: declaration;
					object: term
	] on: Exception do: [ :ex |
	 	ex freeze.
	 	label := LzSyntaxLabel new
					text: (ex printString asRopedText foreground: Color red);
					declaration: ex  ].

	attribute := GtButtonAttribute new
		beAppend;
		stencil: [ label beSmallSize ].
	self text
		attribute: attribute
		from: aTopLevelTermAnnotation parent startPosition
		to: aTopLevelTermAnnotation parent stopPosition.

	self styleExpandingObject: term in: aTopLevelTermAnnotation
]

{ #category : #visiting }
LzAnnotationStyler >> visitTopLevelUseContext: aTopLevelUseContext [
	| annotation declaration pageReference color attribute label |
	self styleAnnotation: aTopLevelUseContext.

	annotation := LzDeclarationBuilder new acceptNode: aTopLevelUseContext.
	declaration := annotation declaration.
	pageReference := declaration contextName.
	(LzBook hasPageNamed: pageReference)
		ifFalse: [
			self text
				attribute: (BlTextForegroundAttribute paint: Color red)
				from: aTopLevelUseContext parent startPosition
				to: aTopLevelUseContext parent stopPosition.
			^ self ].

	self styleAutoHidingAnnotation: aTopLevelUseContext.

	color := self colorFor: annotation.
	label := pageReference asRopedText
		foreground: color.
	declaration subcontext ifNotNil: [ :s |
		label append: (('/', s) asRopedText foreground:  color) ].
	(annotation optionsAt: #forSorts)
		ifTrue: [
			label append:
				(' (in sorts)' asRopedText foreground:  color lzDeemphasized) ].

	attribute := GtButtonAttribute new
		beAppend;
		stencil: [
			(self inTextButton: label)
				action: [ :aButton |
					aButton phlow spawnTool:
						(LzBook pageNamed: pageReference)
							asPhlowTool ];
				yourself ].

	self text
		attribute: attribute
		from: aTopLevelUseContext parent startPosition
		to: aTopLevelUseContext parent stopPosition
]
