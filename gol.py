#!/usr/bin/python3
import random
from sys import stdout

W, H = 1920, 1080

B = W * H


def variables(x, y):
    rotr = lambda y: x >> y | x << B - y & (1 << B) - 1
    p, q = rotr(y), rotr(B - y)
    return p ^ q, p & q


def transform(x):
    A, B = variables(x, 1)
    C, D = variables(x, W - 1)
    E, F = variables(x, W)
    G, H = variables(x, W + 1)

    I = B | D
    J = F | H
    K = A ^ C

    x |= K ^ E ^ G
    x &= (I | J) ^ (K & (E | G) | (A & C ^ E & G) | (I | F & H) & (B & D | J))

    return x


header = bytes(f"P4\n{W} {H}\n", "ascii")
data = random.randint(0, 2**B)

while True:
    stdout.buffer.write(header)
    stdout.buffer.write(data.to_bytes(B // 8, "big"))
    data = transform(data)
