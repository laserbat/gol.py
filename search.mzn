%%%% Parameters

% We search for a specific tree where each non-leaf node represents a gate
% and leaf nodes are variables. This tree represets a boolean formula constructed
% out of the specified gates.
int: tree_height = 7;

% There are 8 symmetric variables ('neighbors') and one non-symmetric variable,
% representing the value of central cell in the neighborhood.
%
% Rules of GoL depend on value of central cell and number of its alive neighbors,
% because of this we can ignore ordering of first 8 variables (which significantly
% reduces the seach space) and only treat one additional variable in a special way.
int: num_symmetric_vars = 8;


%%%% Basic definitions and helper functions/predicates

% Gates that can appear as non-leaf nodes in our tree.
% `LEFT` is a special gate that simply returns its left argument. It is used as a
% do-nothing gate that can be ignored in the output.
enum GATES = {AND, OR, XOR, LEFT};

int: num_nodes = pow(2, tree_height) - 1;

set of int: sym_vars = 1..num_symmetric_vars;
set of int: nodes = 1..num_nodes;

set of int: possible_assignments = 0..(pow(2, num_symmetric_vars + 1) - 1);

% Checks if a variable is true in a given assignment
function bool: verify(int: assignment, int: variable) = (
    if variable == 1
    then (assignment) mod 2 == 1
    else verify(assignment div 2, variable - 1)
    endif
);

function int: count_true(int: assignment) =
    count(i in sym_vars) (verify(assignment, i));

% The leaf nodes of the tree are variables, they are introduced in a fixed order:
% The variable representing the central cell appears only once, as the leftmost leaf.
% All other leaves are assigned to symmetric variables, with cyclically repeating
% assignments.
function int: leaf_variable(int: path) = (
    if path == num_nodes + 1
    then num_symmetric_vars + 1
    else (path mod (num_symmetric_vars)) + 1
    endif
);

predicate gate(var GATES: gate, var bool: a, var bool: b) = (
    if     gate == AND then a  /\ b
    elseif gate == OR  then a  \/ b
    elseif gate == XOR then a xor b
    else   a
    endif
);

% Recursively evaluate the boolean circuit with `assignment` representing the values
% of variables.
predicate evaluate(int: path, int: assignment) = (
    if path in nodes then
        gate(tree[path],
            evaluate(path * 2,     assignment),
            evaluate(path * 2 + 1, assignment)
        )
    else
        verify(assignment, leaf_variable(path))
    endif
);


%%%% Problem definition

var int: gates_used;
array[nodes] of var GATES: tree;

% Require that the boolean formula represented by the tree is equivalent to GoL
constraint forall(assignment in possible_assignments) (
    evaluate(1, assignment)  <-> (
        count_true(assignment) in
            if verify(assignment, num_symmetric_vars + 1)
            then {2, 3}
            else {3}
            endif
    )
);

constraint gates_used == count(i in nodes) (tree[i] != LEFT);
solve minimize gates_used;


%%%% Output handling

array[int] of string: letters = [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" ];

function string: out_formula(int: path) = (
    if path in nodes then let {
            int: L = path * 2;
            int: R = path * 2 + 1;

            GATES: gate = fix(tree[path]);
        } in (
            if gate == LEFT then
                out_formula(L)
            else
                "(" ++ join(" ", [out_formula(L), show(gate), out_formula(R)]) ++ ")"
            endif
    ) else
        letters[leaf_variable(path)]
    endif
);

output [
    out_formula(1), "\n",
    "using \(gates_used) gates\n"
];
