# gol.py
###### efficient Game of Life in Python

This code demonstrates a small and reasonably efficient implementation of Conway's Game of Life in pure Python 3. The only dependency is a video player capable of displaying a stream of PBM images (e.g. [mpv](https://mpv.io/)).

Usage:

`./gol.py | mpv - --fps=60 --no-correct-pts`

You can change the output resolution by modifying the values of `W` and `H` in `gol.py`.

## How does it work?

Magic.

To give a more serious answer, I used [minizinc](https://www.minizinc.org/) and [OR-Tools](https://github.com/google/or-tools) to find the smallest possible boolean circuit using AND/OR/XOR gates that encodes the rules of Conway's Game of Life.

This circuit was then translated to bitwise operators, treating python bigints as 1D arrays. This leads to good performance, since we operate on many cells at once.

Take a look at `search.mzn` to see the minizinc code used to perform this search.

If you're curious, the result of this search showed that the minimum is 48 gates with the following being an example of a 48-gate GoL circuit:

```
((I OR (((A XOR B) XOR (C XOR D)) XOR ((E XOR F) XOR (G XOR H)))) AND ((((((A XOR B) XOR (C XOR D)) AND ((E XOR F) OR (G XOR H))) OR (((A XOR B) AND (C XOR D)) XOR ((E XOR F) AND (G XOR H)))) OR ((((A AND B) OR (C AND D)) OR ((E AND F) AND (G AND H))) AND (((A AND B) AND (C AND D)) OR ((E AND F) OR (G AND H))))) XOR (((A AND B) OR (C AND D)) OR ((E AND F) OR (G AND H)))))
```

`I` is the variable corresponding to the value of the central cell, the remaining variables represent the values of neighbors.
