"""Performance sur la tâche : kNN, linear probe, online probe.

Le probe est entraîné une fois sur le train propre, puis appliqué à tous les jeux de test.
Sa recette (figée à la fin du pilote) est écrite dans chaque JSON.
L'online probe sert au suivi pendant l'entraînement -> il sous-estime le probe final.
"""
