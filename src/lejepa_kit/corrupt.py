"""Corruptions de Hendrycks & Dietterich : 15 types, sévérités 1 à 5.

imagecorruptions copié et patché (glass_blur, gaussian_blur et fog plantent avec numpy 2).
Tirages faits une fois, avec leur propre seed, et stockés sur /scratch.
Deux usages : corrompre une fraction p du train (exp 1), construire les jeux de test corrompus.
"""
