Class {
	#name : #LzLepiterExamples,
	#superclass : #Object,
	#traits : 'TGtExampleAssertable',
	#classTraits : 'TGtExampleAssertable classTrait',
	#category : #'Leibniz2-Lepiter'
}

{ #category : #example }
LzLepiterExamples >> arrayIndexing [
	<gtExample>
	| context |
	context := (LzContextBuilder fromPage: 'One-dimensional array slicing') context.
	^ {
		{ '{[ 1, 2, 3 ]}\(2)'. '2' }.
		{ '{[ 1, 2, 3 ]}\(2 ⋯ 3)'. '{[ 2, 3 ]}' }.
		{ '{[ 1, 2, 3 ]}\(2 ⋯ ∎)'. '{[ 2, 3 ]}' }.
		{ '{[ 1, 2, 3 ]}\(2 ⋯ 2)'. '{[ 2 ]}' }.
		{ '{[ 1, 2, 3 ]}\(2 ⋯ 1)'. '{[ ]}' }.
	} collect: [ :each |
		| term reducedTerm |
		term := context term: each first.
		reducedTerm := context term: each second.
		self assert: (context reduce: term) equals: reducedTerm.
		{ term. reducedTerm } ]
]

{ #category : #example }
LzLepiterExamples >> booleanUnifications [
	<gtExample>
	| c |
	c := (LzContextBuilder fromPage: 'Boolean algebra') context.
	^ {
		{'⊤'. '∀ X_:𝔹 X_'. '(X_=⊤)'}.
		{'∀ X_:𝔹 ¬(X_)'. '¬(⊤)'. '(X_=⊤)'}.
		{'∀ X_:𝔹 X_'. '¬(⊤)'. '(X_=¬(⊤))'}.
		{'⊤ ⊻ ⊥ ⊻ ⊤ ⊻ ¬(⊤)'. '∀ X_:𝔹 ∀ Y_:𝔹 (⊤ ⊻ ⊥ ⊻ X_ ⊻ Y_)'. '(X_=⊤, Y_=¬(⊤))'}.
		{'∀ X_:𝔹 (⊥ ⊻ X_ ⊻ ⊤ ⊻ ¬(⊤))'. '∀ X_:𝔹 ∀ Y_:𝔹 (⊥ ⊻ ⊤ ⊻ X_ ⊻ Y_)'. '(X_=⊤, Y_=¬(⊤))'}.
		{'∀ X_:𝔹 (X_ ⊻ ¬(X_))'. '∀ X_:𝔹 (⊥ ⊻ ¬(X_))'. '(X_=⊥)'}.
		{'∀ X_:𝔹 ∀ Y_:𝔹 (X_ ⊻ ¬(Y_))'. '∀ Y_:𝔹 (⊥ ⊻ ¬(Y_))'. '(Y_, X_=⊥)'}.
		{'∀ X_:𝔹 (⊥ ⊻ ¬(X_))'. '∀ Y_:𝔹 (⊥ ⊻ ¬(Y_))'. '(X_=Y_)'}.
		{'⊤'. '⊥'.  '(failure #nonUnifiableTerms: ⊥, ⊤)' }.
		{'∀ foo_:𝔹 ¬(foo_)'. '∀ bar_:𝔹 ¬(bar_)'. '(bar_=foo_)'}
	} collect: [ :each |
		| unification string |
		unification := (c pattern: each first) unify: (c pattern: each  second).
		string := unification printString.
		self assert: (string allButFirst: (string findString: '(') - 1) equals: each third.
		unification ]
]

{ #category : #example }
LzLepiterExamples >> equalityTerms [
	<gtExample>
	| context |
	context := (LzContextBuilder new
		addDeclarationsFromPageNamed: 'Term equality';
		addDeclarationsFromPageNamed: 'One-dimensional arrays';
		addDeclarationsFromPageNamed: 'Integers')
		context.
	self assert: (context term: '1 == ⊤') hasSort not.
	^ {
		{ '1 == 1'. '⊤'}.
		{ '1 == 2'. '⊥'}.
		{ '{[1]} == {[1]}'. '⊤'}.
		{ '{[1]} == {[2]}'. '⊥'}.
		{ '1 == ⊤'. '1 == ⊤' }.
	} collect: [ :each |
		| term rewrittenTerm expected |
		term := context term: each first.
		expected := context term: each second.
		rewrittenTerm := context reduce: term.
		self assert: rewrittenTerm equals: expected.
		{ term. rewrittenTerm } ]
]

{ #category : #example }
LzLepiterExamples >> integerArithmetic [
	<gtExample>
	| context cache |
	context := (LzContextBuilder fromPage: 'Integers') context.
	cache := LzRewriteCache new
				rewriteSystem: context rewriteSystem.
	^ {
		{ '-(2)'. '-2' }.
		{ '2 + 2'. '4'}.
		{ '2 - 2'. '0'}.
		{ '3 × 2'. '6'}.
		{ '3 div 2'. '1'}.		
		{ '3 rem 2'. '1'}.
		{ '3^(2)'. '9'}.
		{ '3^(0)'. '1'}.
		{ '0^(2)'. '0'}.
		{ '2 < 3'. '⊤'}.
		{ '2 > 3'. '⊥'}.
	}
	collect: [ :each |
		| term result |
		term := context term: each first.
		result := context reduce: term.
		self assert: result equals: (context term: each second).
		self assert: (cache reduce: term) equals: result.
		{ term. result } ]
]

{ #category : #example }
LzLepiterExamples >> integerTerms [
	<gtExample>
	| context |
	context := (LzContextBuilder fromPage: 'Integers') context.	^ {
		{ '0'. 'zero'. }.
		{ '1'. 'ℕ.nz' }.
		{ '-1'. 'ℤ.nz' }.
		{ '-1 + 1'. 'ℤ' }.
		{ '1 + 1'. 'ℕ.nz' }.
	}
	collect: [ :each |
		| term |
		term := context term: each first.
		self assert: term sort asLeibnizSyntaxString equals: each second.
		term  ]
]

{ #category : #example }
LzLepiterExamples >> rationalArithmetic [
	<gtExample>
	| context cache |
	context := (LzContextBuilder fromPage: 'Rational numbers') context.
	cache := LzRewriteCache new
				rewriteSystem: context rewriteSystem.
	^ {
		{ '-(2/3)'. '-2/3' }.
		{ '1/3 + 2/3'. '1'}.
		{ '2/3 - 2/3'. '0'}.
		{ '1/3 × 2/5'. '2/15'}.
		{ '3 ÷ 2'. '3/2'}.
		{ '3/2^(2)'. '9/4'}.
		{ '3/2^(0)'. '1'}.
		{ '2/5 < 3/5'. '⊤'}.
		{ '2/5 > 3/5'. '⊥'}.
	}
	collect: [ :each |
		| term result |
		term := context term: each first.
		result := context reduce: term.
		self assert: result equals: (context term: each second).
		self assert: (cache reduce: term) equals: result.
		{ term. result } ]
]

{ #category : #example }
LzLepiterExamples >> rationalNumberTerms [
	<gtExample>
	| context |
	context := (LzContextBuilder fromPage: 'Rational numbers') context.
	^ {
		{ '0'. 'zero'. }.
		{ '1'. 'ℕ.nz' }.
		{ '-1'. 'ℤ.nz' }.
		{ '-1 + 1'. 'ℤ' }.
		{ '1 + 1'. 'ℕ.nz' }.
		{ '1/3'. 'ℚ.p' }.
		{ '-1/3'. 'ℚ.nz' }.
		{ '-1/3 + 1/3'. 'ℚ' }.
		{ '1/3 + 1/3'. 'ℚ.p' }.
		{ '#0.5'. 'ℚ.p' }.
		{ '#-0.5e1'. 'ℤ.nz' }.
	}
	collect: [ :each |
		| term |
		term := context term: each first.
		self assert: term sort asLeibnizSyntaxString equals: each second.
		term  ]
]

{ #category : #accessing }
LzLepiterExamples >> stringOperations [
	<gtExample>
	| context |
	context := (LzContextBuilder fromPage: 'Character strings') context.
	^ {
		{ '"" + ""'. '""' }.
		{ '"abc" + "xyz"'. '"abcxyz"'}.
		{ '"abc" + ""'. '"abc"'}.
	}
	collect: [ :each |
		| term result |
		term := context term: each first.
		result := context reduce: term.
		self assert: result equals: (context term: each second).
		{ term. result } ]
]

{ #category : #accessing }
LzLepiterExamples >> stringTerms [
	<gtExample>
	| context |
	context := (LzContextBuilder fromPage: 'Character strings') context.
	^ {
		{ '""'. 'string'. }.
		{ '"abc"'. 'string' }.
	}
	collect: [ :each |
		| term |
		term := context term: each first.
		self assert: term sort asLeibnizSyntaxString equals: each second.
		term  ]
]
