module thompson;

import std.traits;

import statistics;

/**
 * Numerator of Thompson's psi function.
 *
 * Params:
 *     r = Number of positive samples from first probability.
 *     s = Number of negative samples from first probability.
 *     r_prime = Number of positive samples from second probability.
 *     s_prime = Number of negative samples from second probability.
 *
 * Returns: The numerator of the probability.
 */
T numer(T = uint)(T r, T s, T r_prime, T s_prime)
if (isIntegral!T)
{
  T result = 0;

  foreach(a; 0..(r_prime + 1)) {
    auto left = choose(r + r_prime - a, r);
    auto right = choose(s + s_prime + 1 + a, s);
    result += left * right;
  }

  return result;
}

unittest {
  assert(numer(4, 0, 0, 3) == 1);
  assert(numer(3, 1, 1, 2) == 21);
  assert(numer(5, 0, 4, 1) == 210);
}

/**
 * Denominator of Thompson's psi function.
 *
 * Params:
 *     n = Total number of samples from first probability.
 *     n_prime = Total number of samples from second probability. 
 *
 * Returns: The denominator of the probability.     
 */
T denom(T = uint)(T n, T n_prime)
if (isIntegral!T)
{
  return choose(n + n_prime + 2, n + 1);
}

unittest {
  assert(denom(4, 3) == 126);
  assert(denom(5, 5) == 924);
}

/**
 * Thompson's psi function for determining the likelihood that one unknown
 * probability exceeds another.
 *
 * In this case is (r, s) come from probability p1 and (r_prime, s_prime) come
 * from probability p2. The result is the probability that p2 > p1. The
 * probability that they are equal is 0 by Thompson's hypothesis.
 * 
 * Params:
 *     r = Number of positive samples from first probability.
 *     s = Number of negative samples from first probability.
 *     r_prime = Number of positive samples from second probability.
 *     s_prime = Number of negative samples from second probability.
 *
 * Returns: The probability that the first "treatment" is better than the
 * second.
 */
T psi(T = double, U = uint)(U r, U s, U r_prime, U s_prime)
if (isFloatingPoint!T && isIntegral!U)
{
  return numer(r, s, r_prime, s_prime) / T(denom(r + s, r_prime + s_prime));
}

unittest {
  assert(psi(4, 0, 3, 0) == 56.0 / 126.0);
  assert(psi(5, 0, 4, 1) == 210.0 / 924.0);
}
