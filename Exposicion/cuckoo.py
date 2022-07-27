#pip install --upgrade swarmlib

from swarmlib import CuckooProblem, FUNCTIONS

# problem = CuckooProblem(function=FUNCTIONS['michalewicz'], nests=25)
# best_nest = problem.solve()
# problem.replay()


problem = CuckooProblem(function=FUNCTIONS['michalewicz'], nests=25)
best_nest = problem.solve()
problem.replay()