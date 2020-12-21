"""
curry(f, x)
Returns a curried `f` by passing `x` as first argument.
"""
curry(f, x) = (xs...) -> f(x, xs...)
