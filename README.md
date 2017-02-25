# thompson_sampling

Implements a prototype of Thompson Sampling for use in evaluating interview
candidates.

# Compilation

To build the application:

```
$ dub build
```

You can then use dub to run the application:

```
$ dub run
```

This will output a file named `results.dot`. You can convert this into an image
using graphviz:

```
$ dot -Tpng results.dot > results.png
```

You can find example results in the `results` directory.