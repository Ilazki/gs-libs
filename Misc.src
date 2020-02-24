// NOTE:  Currently only the PIPE function works correctly in Grey Hack due to a
// problem with how the game currently handles scoping vs. regular MiniScript

////////////////////
// MISCELLANEOUS 
////////////////////

// Pipes the initial argument (acc) through a list of functions (fs), in
// order, passing each function's return value to the next fuction until
// all (fs) are evaluated, then returns the final function's return
// value.  All (fs) must accept and return a single argument.  This is
// similar to using a shell pipeline (e.g. "foo | bar | baz").
// 
// Unlike comp, pipe evaluates immediately and does NOT return a function.
// 
// Example:
// 
// double = function (n)
//   return n * 2
// end function
// pipe(2, [@double,@double,@double,@print])

pipe = function (acc,fs)
  for f in fs
    acc = f(acc)
  end for
  return acc
end function

// Takes a list of functions (fs) that accept a single argument and
// composes them into a new function.
// 
// Example:
// 
//    double = function (n)
// 	    return n * 2
//    end function
//    x8_print = comp([@double,@double,@double,@print])
//    x8_print(2)

comp = function (fs)
  f = fs[0]
  return function (arg)
    acc = f(arg)
    for f in fs[1:]
      acc = f(acc)
    end for
    return acc
  end function
end function

// Returns a memoized version of a function (f).  The memoized function
// accepts one argument and caches its argument results so that
// subsequent calls to (f) with the same argument will return the cached
// result without invoking (f) again.  This increases memory usage but
// can speed up repeat calls to a slow function.
// 
// Example:
// 
// slow = function (s)
//   wait 5
//   return s
// end function
// 
// memo_slow = memoize(@slow)
// 
// print memo_slow("slow function call")
// print memo_slow("slow first call")
// print memo_slow([1,2,3,4])
// print memo_slow([1,2,3,4])

memoize = function (f)
  realized = {}
  return function (arg)
    if not realized.hasIndex(arg) then
      realized[arg] = f(arg)
    end if
    return realized[arg]
  end function
end function
