module statistics;

import std.random;
import std.range;
import std.traits;

/**
 * Returns the factorial up to the given number.
 *
 * Params:
 *     n = Upper-bound for factorial computation.
 *
 * Returns: n!
 */
T factorial(T = uint)(T n)
if (isIntegral!T)
in
{
  assert(n >= 0);
}
body
{
  uint result = 1;

  while (n > 1) {
    result *= n;
    n--;
  }

  return result;
}

unittest {
  assert(factorial(0) == 1);
  assert(factorial(1) == 1);
  assert(factorial(3) == 6);
  assert(factorial(5) == 120);
  assert(factorial(7) == 5040);
}

/**
 * Computes the binomial coefficient for the given n and k.
 *
 * Params:
 *     n = Top component of binomial coefficient.
 *     k = Bottom component of binomial coefficient.
 *
 * Returns: The binomial coefficient for the given values.
 */
T choose(T = uint)(T n, T k)
if (isIntegral!T)
in
{
  assert(n >= k);
  assert(k >= 0);
}
body
{
  return factorial(n) / (factorial(k) * factorial(n - k));
}

unittest {
  assert(choose(7, 1) == 7);
  assert(choose(8, 4) == 70);
}

/**
 * Samples a boolean value from the bernoulli distribution using the
 * probability and random number generator (RNG) provided.
 *
 * Params:
 *     p = The probability with which to return true.
 *     rng = The random number generator (RNG) to be used for sampling.
 * 
 * Returns: True with probability p, false with probability (1 - p).
 */
bool bernoulli(T = double, UniformRNG)(T p, ref UniformRNG rng)
if (isFloatingPoint!T && isUniformRNG!UniformRNG)
in
{
  assert(p >= 0.0);
  assert(p <= 1.0);
}
body
{
  if (uniform01!T(rng) <= p) {
    return true;
  }

  return false;
}

unittest {
  assert(bernoulli(0.0, rndGen) == false);
  assert(bernoulli(1.0, rndGen) == true);
}

/**
 * Represents a series of biased coin tosses by as an infinite range consisting
 * of repeated random sampling from the bernoulli distribution.
 *
 * Params:
 *     p = The probability with which to return true.
 * 
 * Returns: An infinite InputRange of biased coin toss samples.
 */
auto biasedCoin(T = double, UniformRNG)(T p, ref UniformRNG rng)
if (isFloatingPoint!T && isUniformRNG!UniformRNG)
in
{
  assert(p >= 0.0);
  assert(p <= 1.0);
}
body
{
  return generate!(() => bernoulli(p, rng));
}

unittest {
  auto result = biasedCoin(0.0, rndGen).take(4);
  assert(result.front == false);
  assert(result.length == 4);
}
