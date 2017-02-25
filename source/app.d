import std.algorithm;
import std.file;
import std.random;
import std.range;
import std.stdio;
import std.string;
import std.traits;

import statistics;
import thompson;

/// Interview results for a single candidate.
struct CandidateResult {
  uint id;
  uint numYes;
  uint numNo;

  // Value in range [0, 1] that represents candidate quality. This is the
  // actual value of the candidate we're using interviews to guess at.
  double quality;
};

/**
 * Performs a single interview with the given candidate. Their quality
 * determines the probability that they receive a yes.
 *
 * Params:
 *     candidate = Candidate to be interviewed.
 *     rng = Random number generator to be used in evaluation.
 */
void interviewCandidate(ref CandidateResult candidate, ref Random rng) {
  if (bernoulli(candidate.quality, rng)) {
    candidate.numYes += 1;
  } else {
    candidate.numNo += 1;
  }
}

/**
 * The probability that candidate is better than candidate_prime based on
 * results.
 *
 * Params:
 *     candidate = The left-hand side candidate.
 *     candidate_prime = The right-hand side candidate.
 *
 * Returns: The probability in the range [0, 1).
 */
T likelihood(T = double)(CandidateResult candidate,
                         CandidateResult candidate_prime)
if (isFloatingPoint!T)
{
  return (
    1.0 - psi(
      candidate.numYes, candidate.numNo,
      candidate_prime.numYes, candidate_prime.numNo
    )
  );
}

/**
 * Prints an adjancency list indicating the comparative quality between the
 * given candidate and all of the others.
 *
 * Params:
 *     candidate = The candidate the be evaluated relative to peers.
 *     allCandidates = All candidates, including the one to be evaluated.
 */
void printAdjacencyList(ref CandidateResult candidate,
                        ref CandidateResult[] allCandidates) {
  auto rest = filter!((a) => a.id != candidate.id)(allCandidates);
  foreach (other; rest) {
    writefln("\t%d %d - %d %d %d %d - %f",
             candidate.id,
             other.id,
             candidate.numYes,
             candidate.numNo,
             other.numYes,
             other.numNo,
             likelihood(candidate, other));
  }
}

/**
 * Returns Graphviz dot format string containing a graph of the complete
 * comparisons between all candidates.
 *
 * Params:
 *     allCandidates = All of the interview candidates.
 *
 * Returns: String containing graphviz results.
 */
string dotAdjacencyList(ref CandidateResult[] allCandidates) {
  string result = "digraph candidates {\n";
  foreach (candidate; allCandidates) {
    auto rest = filter!((a) => a.id != candidate.id)(allCandidates);
    foreach (other; rest) {
      result ~= format("\tC%d -> C%d [label=\"%f\"]\n",
                       candidate.id,
                       other.id,
                       likelihood(candidate, other));
    }
  }
  result ~= "}";
  return result;
}

void main()
{
  CandidateResult[] candidates = [
    {0, 0, 0, 0.1},
    {1, 0, 0, 0.2},
    {2, 0, 0, 0.3},
    {3, 0, 0, 0.4},
    {4, 0, 0, 0.5}
  ];
  immutable uint numInterviews = 4;
  auto rng = Random(unpredictableSeed);

  writeln("[EXPECTED]");
  foreach (index, candidate; candidates) {
    writefln("%d: %f", candidate.id, candidate.quality);
  }

  writeln("\nConducting interviews...");
  foreach (ref candidate; candidates) {
    foreach(i; 0..numInterviews) {
      interviewCandidate(candidate, rng);
    }
  }

  writeln("\n[ACTUAL]");
  foreach(index, candidate; candidates.enumerate(1)) {
    writefln("%d: %f - %d %d",
             candidate.id,
             candidate.quality,
             candidate.numYes,
             candidate.numNo);
    printAdjacencyList(candidate, candidates);
  }

  writeln("\nWriting dotfile image to results.dot ...");
  File file = File("results.dot", "w");
  file.write(dotAdjacencyList(candidates));
  file.close();
}
