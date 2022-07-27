#pip install --upgrade swarmlib

from swarmlib import FireflyProblem, FUNCTIONS

problem = FireflyProblem(function=FUNCTIONS['michalewicz'], firefly_number=25, continuous=True)
best_firefly = problem.solve()
problem.replay()