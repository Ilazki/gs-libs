// NOTE:  These functions DO NOT WORK in Grey Hack currently due to an
// issue with how it's handling lexical scoping.  They DO work as expected
// in MiniScript, though, despite its own interesting scoping issues.
//
// Use Lazy.src instead for a Grey Hack compatible version.

////////////////////
// LAZY SEQUENCES
////////////////////

// Lazily evaluated sequences.  Execution of an element is deferred until
// that element is accessed, and can either be stand-alone or depend on
// the value of the previous element, allowing the creation of infinite
// sequences of data.  Works by taking a supplied single-argument function
// that either ignores its argument or uses it to return the next value
// in the sequence.
// 
// Examples:
// 
// Infinite sequence of die rolls.
//    // Since a single function argument is necessary but ignored,
//    // underscore is used by convention.
//    die_roll = function (_)
//      return floor(1 + rnd*6)
//    end function
//    die_rolls = Lazy.make(@die_roll)
//    print "Rolling die :" + Lazy.take(@die_rolls, 10)
//    print "Rolling more:" + Lazy.take(@die_rolls, 10)
// 
// Infinite sequence of positive integers
//    inc = function (n)
//      return n + 1
//    end function
//    numbers = Lazy.make(@inc,0)
//    print Lazy.take(numbers,5) // 1,2,3,4,5
//    print Lazy.take(numbers,5) // 6,7,8,9,10
// 
// Get the 10th element of a lazy sequence (fast!)
//    print Lazy.nth(Lazy.make(@inc,0),10)
// 
// Get the 1,000,000th element of a lazy sequence (slow!)
//    print Lazy.nth(Lazy.make(@inc,0),1000000)

Lazy = { }

// Create a lazy sequence from a supplied function.
// (body) -> function that MUST accept a single argument and return a value.
//          However, the body function MAY ignore its argument if desired.
// (init) -> initial value to be passed to (body) to start the sequence.
Lazy.make = function (body, init)
  return function ()
    result = body(init)
    return [result,Lazy.make(@body,result)]
  end function
end function

// Take (n) elements from (lazy).  Be aware that if a sequence is saved to
// a name, future invocations of Lazy.take will start where previous ones
// ended.
Lazy.take = function (lazy,n)
  list = []
  lz = lazy
  realized = null
  i = 0
  // Can't use range() for arbitrarily large values, which defeats the
  // purpose of using a lazy sequence.
  while i <= n
    if i == n then return list; end if
    realized = lz()
    if [] == realized[0] then return list; end if
    list.push(realized[0])
    lz=realized[1]
    i = i + 1
  end while
end function

// Return the (n)th element from (lazy).  Like Lazy.take, be aware that
// if (lazy) is a saved sequence, Lazy.nth will begin counting from where
// previous Lazy.take or Lazy.nth invocations stopped.
Lazy.nth = function (lazy,n)
  lz = lazy
  i = 0
  realized = null
  // while required because range() won't work for very large values.
  while i <= n
    if [] == realized[0] then return null; end if
    if i == n then return realized[0]; end if
    realized = lz()
    lz=realized[1]
    i = i + 1
  end while
end function

// infinite sequence of (v)
// print join(Lazy.take(Lazy.repeatedly("9 ", 9)))
Lazy.repeatedly = function (v)
  value = function (_)
    return v
  end function
  return Lazy.make(@v)
end function

// infinite sequence of elements in (l)
Lazy.cycle = function (l)
  len = l.len
  // Lexical scoping is weird in MiniScript.  Outer values are read-only
  // unless accessed with the 'outer' keyword.  Maps being pass-by-ref
  // can be abused to work around this.
  n = {}
  n.v = -1
  next = function (_)
    n.v = n.v + 1
    if n.v == len then n.v = 0; end if
    return l[n.v]
  end function
  return Lazy.make(@next)
end function

//print join(Lazy.take(Lazy.repeatedly("9 "), 9))
//print Lazy.take(Lazy.cycle([1,2,3,2]), 13)

